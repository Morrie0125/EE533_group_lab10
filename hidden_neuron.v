`timescale 1ns / 1ps

module hidden_neuron (
    input  wire        clk,
    input  wire        rst,
    input  wire [63:0] image,
    input  wire [16*64-1:0] weight_flat,
    output reg  [15:0] relu_out
);

    // === State encoding ===
    parameter IDLE       = 3'd0;
    parameter LOAD       = 3'd1;
    parameter WAIT1      = 3'd2;
    parameter WAIT2      = 3'd3;
    parameter ACCUMULATE = 3'd4;
    parameter RELU       = 3'd5;
    parameter DONE       = 3'd6;

    reg [2:0] state;

    // === Unpack weights ===
    wire [15:0] weight [0:63];
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin : unpack
            assign weight[i] = weight_flat[i*16 +: 16];
        end
    endgenerate

    reg [6:0] mac_idx;
    reg [15:0] acc;
    wire [15:0] mac_out;

    wire [15:0] muxed_weight = image[mac_idx] ? weight[mac_idx] : 16'h0000;

    // === MAC unit (3-cycle latency) ===
    fp16_mac mac_inst (
        .clk(clk),
        .rst(rst),
        .mul_in1(muxed_weight),
        .mul_in2(16'h3C00),  // FP16 1.0
        .acc_in(acc),
        .mac_out(mac_out)
    );

    // === FSM ===
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            mac_idx <= 0;
            acc <= 16'h0000;
            relu_out <= 16'h0000;
        end else begin
            case (state)
                IDLE: begin
                    mac_idx <= 0;
                    acc <= 16'h0000;
                    relu_out <= 16'h0000;
                    state <= LOAD;
                end

                LOAD: begin
                    // ???? input?????
                    state <= WAIT1;
                end

                WAIT1: state <= WAIT2;
                WAIT2: state <= ACCUMULATE;

                ACCUMULATE: begin
                    acc <= mac_out;
                    mac_idx <= mac_idx + 1;
                    if (mac_idx == 7'd63)
                        state <= RELU;
                    else
                        state <= LOAD;
                end

                RELU: begin
                    relu_out <= (mac_out[15] == 1'b1) ? 16'h0000 : mac_out;
                    state <= DONE;
                end

                DONE: begin
                    // ?????? reset
                    state <= DONE;
                end
            endcase
        end
    end

endmodule

