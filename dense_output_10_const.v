`timescale 1ns / 1ps

module dense_output_10_const (
    input  wire        clk,
    input  wire        rst,
    input  wire        start,
    input  wire [15:0] relu0,
    input  wire [15:0] relu1,
    input  wire [15:0] relu2,
    output reg  [15:0] logit0,
    output reg  [15:0] logit1,
    output reg  [15:0] logit2,
    output reg  [15:0] logit3,
    output reg  [15:0] logit4,
    output reg  [15:0] logit5,
    output reg  [15:0] logit6,
    output reg  [15:0] logit7,
    output reg  [15:0] logit8,
    output reg  [15:0] logit9,
    output reg         done
);

    parameter IDLE = 4'd0, MAC0_WAIT = 4'd1, MAC1_WAIT = 4'd2, MAC2_WAIT = 4'd3,
              STORE = 4'd4, DONE = 4'd5;

    reg [3:0] state;
    reg [3:0] idx;
    reg [1:0] wait_cnt;
    reg       wait_flag;

    reg [15:0] mac_out0, mac_out1, mac_out2;
    reg [15:0] w0_i, w1_i, w2_i;

    wire [15:0] mac0_out, mac1_out, mac2_out;

    reg [15:0] w0 [0:9];
    reg [15:0] w1 [0:9];
    reg [15:0] w2 [0:9];
    reg [15:0] relu_out2;


    // Example weights (replace with real ones)
initial begin
    w0[0] = 16'hbed1; w1[0] = 16'h40dd; w2[0] = 16'haf47;
    w0[1] = 16'h3e33; w1[1] = 16'hb2ae; w2[1] = 16'hb522;
    w0[2] = 16'h3aa8; w1[2] = 16'hbaf1; w2[2] = 16'h395b;
    w0[3] = 16'hb593; w1[3] = 16'hb426; w2[3] = 16'h3d26;
    w0[4] = 16'h3e13; w1[4] = 16'h3d75; w2[4] = 16'hbff7;
    w0[5] = 16'hbeab; w1[5] = 16'hbd9a; w2[5] = 16'h3fdf;
    w0[6] = 16'h408d; w1[6] = 16'hbbff; w2[6] = 16'hbfa5;
    w0[7] = 16'h3477; w1[7] = 16'h3d87; w2[7] = 16'ha8eb;
    w0[8] = 16'h3b44; w1[8] = 16'h3632; w2[8] = 16'h2daf;
    w0[9] = 16'hbc97; w1[9] = 16'h3b40; w2[9] = 16'h3c4b;

end


    fp16_mac mac0 (.clk(clk), .rst(rst), .mul_in1(relu0), .mul_in2(w0_i), .acc_in(16'h0000), .mac_out(mac0_out));
    fp16_mac mac1 (.clk(clk), .rst(rst), .mul_in1(relu1), .mul_in2(w1_i), .acc_in(mac_out0), .mac_out(mac1_out));
    fp16_mac mac2 (.clk(clk), .rst(rst), .mul_in1(relu2), .mul_in2(w2_i), .acc_in(mac_out1), .mac_out(mac2_out));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            idx <= 0;
            wait_cnt <= 0;
            wait_flag <= 0;
	    relu_out2 <= 0;
        end else begin
            if (wait_flag) begin
                if (wait_cnt == 2) begin
                    wait_flag <= 0;
                    wait_cnt <= 0;
                end else begin
                    wait_cnt <= wait_cnt + 1;
                end
            end else begin
                case (state)
                    IDLE: begin
                        done <= 0;
                        if (start) begin
                            idx <= 0;
                            w0_i <= w0[0];
                            w1_i <= w1[0];
                            w2_i <= w2[0];
                            wait_flag <= 1;
                            state <= MAC0_WAIT;
                        end
                    end
                    MAC0_WAIT: begin
                        mac_out0 <= mac0_out;
                        wait_flag <= 1;
                        state <= MAC1_WAIT;
                    end
                    MAC1_WAIT: begin
                        mac_out1 <= mac1_out;
                        wait_flag <= 1;
                        state <= MAC2_WAIT;
                    end
                    MAC2_WAIT: begin
                        mac_out2 <= mac2_out;
                        state <= STORE;
                    end
                    STORE: begin
			relu_out2 = (mac_out2[15] == 1'b1) ? 16'h0000 : mac_out2;
                        case (idx)
                         0: logit0 <= relu_out2;
     			 1: logit1 <= relu_out2;
       			 2: logit2 <= relu_out2;
      			 3: logit3 <= relu_out2;
     			 4: logit4 <= relu_out2;
      			 5: logit5 <= relu_out2;
      			 6: logit6 <= relu_out2;
       			 7: logit7 <= relu_out2;
       			 8: logit8 <= relu_out2;
       			 9: logit9 <= relu_out2;
                        endcase
                        if (idx == 9)
                            state <= DONE;
                        else begin
                            idx <= idx + 1;
                            w0_i <= w0[idx + 1];
                            w1_i <= w1[idx + 1];
                            w2_i <= w2[idx + 1];
                            wait_flag <= 1;
                            state <= MAC0_WAIT;
                        end
                    end
                    DONE: begin
                        done <= 1;
                        state <= IDLE;
                    end
                endcase
            end
        end
    end


    function [7:0] FtoB;
    input [15:0] fin;

    reg [4:0] exp;
    reg [9:0] mts;
    reg signed [5:0] pos;
    reg [8:0] base, temp;
    reg [3:0] shift;
    reg [9:0] half, leftover;
    reg [7:0] addon;
    reg roundup;

    begin
        exp = fin[14:10];
        mts = fin[9:0];

        if (fin == 16'b0) begin
            FtoB = 8'd0;
        end
        else if (exp == 5'b00000) begin
            FtoB = 8'd0;  // denormals as 0
        end
        else if (exp == 5'b11111) begin
            FtoB = 8'hFF; // inf/nan
        end
        else begin
            pos = exp - 15;
            if (pos < 0) begin
                temp = 0;
            end
            else if (pos > 7) begin
                temp = 8'hFF;
            end
            else begin
                base = 1 << pos;
                shift = 10 - pos;
                addon = mts >> shift;

                leftover = mts & ((1 << shift) - 1);
                half = 1 << (shift - 1);
                if (leftover > half)
                    roundup = 1;
                else if (leftover < half)
                    roundup = 0;
                else begin
                    if (((base + addon) & 1) == 1)
                        roundup = 1;
                    else
                        roundup = 0;
                end

                temp = base + addon + roundup;
            end

            if (temp > 8'hFF)
                FtoB = 8'hFF;
            else
                FtoB = temp[7:0];
        end
    end
endfunction

endmodule

