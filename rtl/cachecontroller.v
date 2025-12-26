`timescale 1ns / 1ps
module cc #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32,
    parameter CACHE_DEPTH = 8
)(
    input wire clk,
    input wire rst_n,
    input wire [ADDR_WIDTH-1:0] addr,
    input wire [DATA_WIDTH-1:0] w_data,
    input wire mem_write,
    input wire mem_read,
    output reg [DATA_WIDTH-1:0] r_data,
    output wire hit
);
    localparam INDEX_BIT = $clog2(CACHE_DEPTH);
    localparam TAG_BIT   = ADDR_WIDTH - INDEX_BIT;

    reg [DATA_WIDTH-1:0] data_mem  [0:CACHE_DEPTH-1];
    reg [TAG_BIT-1:0]    tag_mem   [0:CACHE_DEPTH-1];
    reg                  valid_bit [0:CACHE_DEPTH-1];

    wire [INDEX_BIT-1:0] index = addr[INDEX_BIT-1:0];
    wire [TAG_BIT-1:0]   tag   = addr[ADDR_WIDTH-1:INDEX_BIT];

    assign hit = (valid_bit[index] && (tag_mem[index] == tag)) && (mem_read || mem_write);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r_data <= 0;
            for(integer i=0; i<CACHE_DEPTH; i=i+1) valid_bit[i] <= 0;
        end else begin
            if (mem_write) begin
                data_mem[index]  <= w_data;
                tag_mem[index]   <= tag;
                valid_bit[index] <= 1;
            end
            if (mem_read && hit) begin
                r_data <= data_mem[index];
            end
        end
    end
endmodule
