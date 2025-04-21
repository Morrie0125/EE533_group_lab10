`timescale 1ns / 1ps

module npu_top (
    input  wire        clk,
    input  wire        rst,
    input  wire [63:0] image,
    output wire [15:0] logit0,
    output wire [15:0] logit1,
    output wire [15:0] logit2,
    output wire [15:0] logit3,
    output wire [15:0] logit4,
    output wire [15:0] logit5,
    output wire [15:0] logit6,
    output wire [15:0] logit7,
    output wire [15:0] logit8,
    output wire [15:0] logit9,
    output wire        done,
    output wire [3:0]  predict_idx
);

    wire [15:0] relu_out_0, relu_out_1, relu_out_2;
    wire        start_output;

    // instantiate hidden layer (with 3 neurons)
    hidden_layer_3_const hidden_layer (
        .clk(clk),
        .rst(rst),
        .image(image),
        .relu_out_0(relu_out_0),
        .relu_out_1(relu_out_1),
        .relu_out_2(relu_out_2)
    );

    // delay start until hidden layer is finished (you can refine this logic)
    reg [8:0] delay_count = 0;
    reg       start = 0;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            delay_count <= 0;
            start <= 0;
        end else if (delay_count < 9'h110) begin
            delay_count <= delay_count + 1;
            start <= 0;
        end else begin
            start <= 1;
        end
    end

    // output layer
    dense_output_10_const dense_layer (
        .clk(clk),
        .rst(rst),
        .start(start),
        .relu0(relu_out_0),
        .relu1(relu_out_1),
        .relu2(relu_out_2),
        .logit0(logit0),
        .logit1(logit1),
        .logit2(logit2),
        .logit3(logit3),
        .logit4(logit4),
        .logit5(logit5),
        .logit6(logit6),
        .logit7(logit7),
        .logit8(logit8),
        .logit9(logit9),
        .done(done)
    );
	
max_index max_predict (
    .clk(clk),
    .rst(rst),
    .valid_in(done),  // dense ?????
    .logit0(logit0), .logit1(logit1), .logit2(logit2), .logit3(logit3),
    .logit4(logit4), .logit5(logit5), .logit6(logit6), .logit7(logit7),
    .logit8(logit8), .logit9(logit9),
    .max_idx(predict_idx),
    .valid(predict_valid)
);

endmodule
