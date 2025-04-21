`timescale 1ns / 1ps

module fp16_mac (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] mul_in1,   // multiplicand
    input  wire [15:0] mul_in2,   // multiplier 
    input  wire [15:0] acc_in,  // accumulation input
    output wire [15:0] mac_out
);

    wire [15:0] prod;

    fp16_multiplier multiplier (
        .clk(clk),
        .rst(rst),
        .a(mul_in1),
        .b(mul_in2),
        .result(prod)
    );

    fp16_adder adder (
        .clk(clk),
        .rst(rst),
        .a(prod),
        .b(acc_in),
        .result(mac_out)
    );
    
endmodule
