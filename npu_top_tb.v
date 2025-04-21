`timescale 1ns / 1ps

module npu_top_tb;

    reg clk = 0;
    reg rst = 1;
    reg [63:0] image;
    wire [15:0] logit0, logit1, logit2, logit3, logit4;
    wire [15:0] logit5, logit6, logit7, logit8, logit9;
    wire done;
    wire [3:0] predict_idx;
    // Instantiate the NPU top module
    npu_top dut (
        .clk(clk),
        .rst(rst),
        .image(image),
        .logit0(logit0), .logit1(logit1), .logit2(logit2), .logit3(logit3), .logit4(logit4),
        .logit5(logit5), .logit6(logit6), .logit7(logit7), .logit8(logit8), .logit9(logit9),
        .done(done), .predict_idx(predict_idx)
    );

    // Clock generation
    always #10 clk = ~clk;

    // Image example from X_test[0]
    reg [63:0] img_data;
    integer i;

    initial begin
        $display("[Testbench] Starting simulation");
        #20 rst = 0;

	img_data[63:0] = 64'b0001110000110000001100000011000000111100001111100011110000001100;
        // Convert 64x1 image to 64-bit vector (LSB first)
        image = 64'd0;
        for (i = 0; i < 64; i = i + 1) begin
            image[i] = img_data[i];
        end

        // Wait for output
        wait(done);
        #10;

        $display("Logits output:");
        $display("logit[0] = %h", logit0);
        $display("logit[1] = %h", logit1);
        $display("logit[2] = %h", logit2);
        $display("logit[3] = %h", logit3);
        $display("logit[4] = %h", logit4);
        $display("logit[5] = %h", logit5);
        $display("logit[6] = %h", logit6);
        $display("logit[7] = %h", logit7);
        $display("logit[8] = %h", logit8);
        $display("logit[9] = %h", logit9);
	$display(predict_idx);
        $display("[Testbench] Done");
    
    end

endmodule
