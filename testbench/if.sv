`timescale 1ns / 1ps

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
