`timescale 1ns / 1ps
module fifo #(
    parameter DATA_WIDTH = 8,
    parameter DEPTH = 16
)(
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   w_en,
    input  wire                   r_en,
    input  wire [DATA_WIDTH-1:0]  data_in,
    output reg  [DATA_WIDTH-1:0]  data_out,
    output wire                   full,
    output wire                   empty
);
    localparam ADDR_WIDTH = $clog2(DEPTH);
    reg [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];
    reg [ADDR_WIDTH:0]   w_ptr, r_ptr; 

    assign empty = (w_ptr == r_ptr);
    assign full  = (w_ptr[ADDR_WIDTH] != r_ptr[ADDR_WIDTH]) && 
                   (w_ptr[ADDR_WIDTH-1:0] == r_ptr[ADDR_WIDTH-1:0]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_ptr <= 0;
        end else if (w_en && !full) begin
            fifo_mem[w_ptr[ADDR_WIDTH-1:0]] <= data_in;
            w_ptr <= w_ptr + 1;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_ptr <= 0;
            data_out <= 0;
        end else if (r_en && !empty) begin
            data_out <= fifo_mem[r_ptr[ADDR_WIDTH-1:0]];
            r_ptr <= r_ptr + 1;
        end
    end
endmodule
