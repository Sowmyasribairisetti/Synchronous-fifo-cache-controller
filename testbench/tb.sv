`timescale 1ns / 1ps

// 1. Interface Definition
interface top_if(input logic clk);
    logic rst_n;
    
    // FIFO Signals
    logic w_en, r_en;
    logic [7:0] fifo_in;
    logic [7:0] fifo_out;
    logic full, empty;
    
    // Cache Signals
    logic [7:0] addr;
    logic [31:0] cache_wdata;
    logic [31:0] cache_rdata;
    logic mem_w, mem_r, hit;
endinterface

// 2. Top Level Testbench
module tb_top;
    // Clock Generation
    bit clk;
    always #5 clk = ~clk; // 100MHz clock

    // Interface Instance
    top_if tif(clk);

    // 3. DUT Instantiations
    fifo #(8, 16) fifo_dut (
        .clk(tif.clk), .rst_n(tif.rst_n), 
        .w_en(tif.w_en), .r_en(tif.r_en),
        .data_in(tif.fifo_in), .data_out(tif.fifo_out), 
        .full(tif.full), .empty(tif.empty)
    );

    cc #(8, 32, 8) cache_dut (
        .clk(tif.clk), .rst_n(tif.rst_n), 
        .addr(tif.addr), .w_data(tif.cache_wdata),
        .mem_write(tif.mem_w), .mem_read(tif.mem_r), 
        .r_data(tif.cache_rdata), .hit(tif.hit)
    );

    // 4. Functional Coverage
    covergroup cg_fifo_cache @(posedge clk);
        option.per_instance = 1;
        FIFO_FULL:  coverpoint tif.full  { bins b1 = {1}; }
        FIFO_EMPTY: coverpoint tif.empty { bins b1 = {1}; }
        CACHE_HIT:  coverpoint tif.hit   { bins b1 = {1}; }
        CACHE_MISS: coverpoint tif.hit   { bins b0 = {0}; }
    endgroup
    cg_fifo_cache cov_inst = new();

    // 5. SystemVerilog Assertions (SVA)
    // Ensure we never write to a full FIFO
    assert_fifo_overflow: assert property (@(posedge clk) (tif.w_en && tif.full) |-> ##1 tif.full)
        else $error("Assertion Failed: Attempted to write to a FULL FIFO!");

    // 6. Monitor Logic (Console Output)
    always @(posedge clk) begin
        if (tif.w_en && !tif.full)
            $display("[FIFO WRITE] Time=%0t | Data In = %h", $time, tif.fifo_in);
        if (tif.r_en && !tif.empty)
            $display("[FIFO READ]  Time=%0t | Data Out = %h", $time, tif.fifo_out);
        
        if (tif.mem_w)
            $display("[CACHE WRITE] Time=%0t | Addr=%h | Data=%h", $time, tif.addr, tif.cache_wdata);
    end

    // 7. Test Stimulus
    initial begin
        // Initialize and Reset
        tif.rst_n = 0; 
        tif.w_en = 0; tif.r_en = 0; 
        tif.mem_w = 0; tif.mem_r = 0;
        tif.addr = 0; tif.cache_wdata = 0;
        
        repeat(5) @(posedge clk);
        tif.rst_n = 1;
        $display("--- System Reset De-asserted ---");

        // --- TEST 1: FIFO Write/Read Sequence ---
        $display("\n--- Starting FIFO Data Flow Test ---");
        for (int i=0; i<5; i++) begin
            @(posedge clk);
            tif.w_en <= 1;
            tif.fifo_in <= $urandom_range(10, 99);
        end
        @(posedge clk) tif.w_en <= 0;

        repeat(2) @(posedge clk);

        for (int i=0; i<5; i++) begin
            @(posedge clk);
            tif.r_en <= 1;
        end
        @(posedge clk) tif.r_en <= 0;

        // --- TEST 2: Cache Hit/Miss Test ---
        $display("\n--- Starting Cache Data Flow Test ---");
        
        // Write to address 0x10
        @(posedge clk);
        tif.addr <= 8'h10; 
        tif.cache_wdata <= 32'hAAAA_BBBB; 
        tif.mem_w <= 1;
        
        @(posedge clk);
        tif.mem_w <= 0;
        
        // Wait 1 cycle for memory stability
        @(posedge clk);

        // Read from address 0x10 (Expect HIT)
        tif.addr <= 8'h10;
        tif.mem_r <= 1;
        
        // Small delay to capture combinational 'hit' and data
        #2; 
        $display("[CACHE READ]  Time=%0t | Addr=%h | Data=%h | HIT=%b", 
                  $time, tif.addr, tif.cache_rdata, tif.hit);
        if(tif.hit) $display(">>> SUCCESS: Cache Hit Verified!");
        else        $display(">>> ERROR: Cache Missed unexpected address!");

        @(posedge clk);
        tif.mem_r <= 0;
        // Read from address 0x10 (Expect HIT)
        tif.addr <= 8'h10;
        tif.mem_r <= 1;
        
        @(posedge clk); // WAIT for the clock edge so r_data updates
        #2;             // Small offset to sample after the edge
        $display("[CACHE READ]  Time=%0t | Addr=%h | Data=%h | HIT=%b", 
                  $time, tif.addr, tif.cache_rdata, tif.hit);

        #100;
        $display("\n--- Verification Complete ---");
        $display("Functional Coverage: %0.2f%%", cov_inst.get_inst_coverage());
        $finish;
    end
endmodule
