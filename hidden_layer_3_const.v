`timescale 1ns / 1ps

module hidden_layer_3_const (
    input  wire        clk,
    input  wire        rst,
    input  wire [63:0] image,
    output wire [15:0] relu_out_0,
    output wire [15:0] relu_out_1,
    output wire [15:0] relu_out_2
);

    // === Neuron 0 Weights ===
    wire [15:0] weight_0 [0:63];
    wire [1023:0] weight_0_flat;

    assign weight_0[ 0] = 16'h2c61; assign weight_0[ 1] = 16'hab4b; assign weight_0[ 2] = 16'h288c; assign weight_0[ 3] = 16'hb8b9;
    assign weight_0[ 4] = 16'haf26; assign weight_0[ 5] = 16'h3232; assign weight_0[ 6] = 16'hbaa1; assign weight_0[ 7] = 16'h3260;
    assign weight_0[ 8] = 16'h255c; assign weight_0[ 9] = 16'haa97; assign weight_0[10] = 16'hb8b2; assign weight_0[11] = 16'hb7d8;
    assign weight_0[12] = 16'hb23d; assign weight_0[13] = 16'h3a70; assign weight_0[14] = 16'h31f4; assign weight_0[15] = 16'ha9ac;
    assign weight_0[16] = 16'h2f7d; assign weight_0[17] = 16'h252b; assign weight_0[18] = 16'hbbb6; assign weight_0[19] = 16'h2c4b;
    assign weight_0[20] = 16'h3e81; assign weight_0[21] = 16'h353a; assign weight_0[22] = 16'h36b9; assign weight_0[23] = 16'ha334;
    assign weight_0[24] = 16'h2ab0; assign weight_0[25] = 16'h0c19; assign weight_0[26] = 16'hbca4; assign weight_0[27] = 16'h2adf;
    assign weight_0[28] = 16'h3c5a; assign weight_0[29] = 16'h34f3; assign weight_0[30] = 16'h371b; assign weight_0[31] = 16'haddb;
    assign weight_0[32] = 16'h24b8; assign weight_0[33] = 16'h24f1; assign weight_0[34] = 16'hb99b; assign weight_0[35] = 16'h3caf;
    assign weight_0[36] = 16'h3ef3; assign weight_0[37] = 16'h9f33; assign weight_0[38] = 16'hb3a8; assign weight_0[39] = 16'h252e;
    assign weight_0[40] = 16'h2d61; assign weight_0[41] = 16'h2e0d; assign weight_0[42] = 16'h3c83; assign weight_0[43] = 16'h3ff7;
    assign weight_0[44] = 16'h3d73; assign weight_0[45] = 16'hb5b4; assign weight_0[46] = 16'hb660; assign weight_0[47] = 16'h2ced;
    assign weight_0[48] = 16'h2edf; assign weight_0[49] = 16'h2de2; assign weight_0[50] = 16'h3771; assign weight_0[51] = 16'h30d4;
    assign weight_0[52] = 16'h2e51; assign weight_0[53] = 16'h3950; assign weight_0[54] = 16'h313e; assign weight_0[55] = 16'h2cd5;
    assign weight_0[56] = 16'h2d93; assign weight_0[57] = 16'ha819; assign weight_0[58] = 16'hb6ca; assign weight_0[59] = 16'hae34;
    assign weight_0[60] = 16'h3a88; assign weight_0[61] = 16'h3af5; assign weight_0[62] = 16'h391f; assign weight_0[63] = 16'h38f5;



    // === Neuron 1 Weights ===
    wire [15:0] weight_1 [0:63];
    wire [1023:0] weight_1_flat;
assign weight_1[ 0] = 16'h9fc8; assign weight_1[ 1] = 16'ha93c; assign weight_1[ 2] = 16'h28d7; assign weight_1[ 3] = 16'h37e7;
assign weight_1[ 4] = 16'h38ae; assign weight_1[ 5] = 16'hb62e; assign weight_1[ 6] = 16'ha2a1; assign weight_1[ 7] = 16'h3474;
assign weight_1[ 8] = 16'hac26; assign weight_1[ 9] = 16'had49; assign weight_1[10] = 16'h3813; assign weight_1[11] = 16'h24eb;
assign weight_1[12] = 16'h35e8; assign weight_1[13] = 16'h3bb2; assign weight_1[14] = 16'h3124; assign weight_1[15] = 16'h2818;
assign weight_1[16] = 16'hadeb; assign weight_1[17] = 16'hb3c3; assign weight_1[18] = 16'hb896; assign weight_1[19] = 16'hb446;
assign weight_1[20] = 16'h3ae0; assign weight_1[21] = 16'h4003; assign weight_1[22] = 16'h3569; assign weight_1[23] = 16'ha7b5;
assign weight_1[24] = 16'h2cd9; assign weight_1[25] = 16'hb602; assign weight_1[26] = 16'hb893; assign weight_1[27] = 16'h280f;
assign weight_1[28] = 16'h2b6c; assign weight_1[29] = 16'h3aa0; assign weight_1[30] = 16'h3c01; assign weight_1[31] = 16'h22ed;
assign weight_1[32] = 16'h2f24; assign weight_1[33] = 16'h389a; assign weight_1[34] = 16'h29ad; assign weight_1[35] = 16'h320e;
assign weight_1[36] = 16'ha865; assign weight_1[37] = 16'h37f3; assign weight_1[38] = 16'h3935; assign weight_1[39] = 16'h2f1a;
assign weight_1[40] = 16'h0a3a; assign weight_1[41] = 16'h3c0e; assign weight_1[42] = 16'h3af0; assign weight_1[43] = 16'h35ab;
assign weight_1[44] = 16'h38ff; assign weight_1[45] = 16'h2e8a; assign weight_1[46] = 16'h27b4; assign weight_1[47] = 16'h28ad;
assign weight_1[48] = 16'h2d31; assign weight_1[49] = 16'hb20b; assign weight_1[50] = 16'h2e32; assign weight_1[51] = 16'hb6f3;
assign weight_1[52] = 16'hbab4; assign weight_1[53] = 16'hb84b; assign weight_1[54] = 16'hb841; assign weight_1[55] = 16'haeb9;
assign weight_1[56] = 16'h2d20; assign weight_1[57] = 16'h2743; assign weight_1[58] = 16'hb2eb; assign weight_1[59] = 16'haa47;
assign weight_1[60] = 16'h3105; assign weight_1[61] = 16'hbb10; assign weight_1[62] = 16'hbb00; assign weight_1[63] = 16'hb549;



    // === Neuron 2 Weights ===
    wire [15:0] weight_2 [0:63];
    wire [1023:0] weight_2_flat;
assign weight_2[ 0] = 16'ha672; assign weight_2[ 1] = 16'h2bee; assign weight_2[ 2] = 16'h39c4; assign weight_2[ 3] = 16'h3adc;
assign weight_2[ 4] = 16'h3a88; assign weight_2[ 5] = 16'h3b96; assign weight_2[ 6] = 16'h3afc; assign weight_2[ 7] = 16'hb455;
assign weight_2[ 8] = 16'h2ada; assign weight_2[ 9] = 16'h3782; assign weight_2[10] = 16'h3b18; assign weight_2[11] = 16'h34b9;
assign weight_2[12] = 16'h3805; assign weight_2[13] = 16'h3b72; assign weight_2[14] = 16'h3342; assign weight_2[15] = 16'hb265;
assign weight_2[16] = 16'h1b8f; assign weight_2[17] = 16'h3754; assign weight_2[18] = 16'hbc1b; assign weight_2[19] = 16'hb9e3;
assign weight_2[20] = 16'h3d31; assign weight_2[21] = 16'h3c8c; assign weight_2[22] = 16'hb0b9; assign weight_2[23] = 16'hae9f;
assign weight_2[24] = 16'h2cea; assign weight_2[25] = 16'hb89e; assign weight_2[26] = 16'hbe2f; assign weight_2[27] = 16'h365e;
assign weight_2[28] = 16'h3e1c; assign weight_2[29] = 16'h312c; assign weight_2[30] = 16'hb780; assign weight_2[31] = 16'hac25;
assign weight_2[32] = 16'h1d7d; assign weight_2[33] = 16'hb542; assign weight_2[34] = 16'hbbb9; assign weight_2[35] = 16'h3485;
assign weight_2[36] = 16'h3523; assign weight_2[37] = 16'hb4ba; assign weight_2[38] = 16'hb287; assign weight_2[39] = 16'h2e13;
assign weight_2[40] = 16'h94c0; assign weight_2[41] = 16'hb078; assign weight_2[42] = 16'hbb4f; assign weight_2[43] = 16'h31fd;
assign weight_2[44] = 16'h34c8; assign weight_2[45] = 16'h31f1; assign weight_2[46] = 16'hb549; assign weight_2[47] = 16'hac15;
assign weight_2[48] = 16'h28d1; assign weight_2[49] = 16'h2e15; assign weight_2[50] = 16'h30c5; assign weight_2[51] = 16'hba2c;
assign weight_2[52] = 16'h3593; assign weight_2[53] = 16'h30b1; assign weight_2[54] = 16'h2c1e; assign weight_2[55] = 16'h3239;
assign weight_2[56] = 16'h2fbc; assign weight_2[57] = 16'h301f; assign weight_2[58] = 16'h3c1d; assign weight_2[59] = 16'h37b0;
assign weight_2[60] = 16'h3aad; assign weight_2[61] = 16'h32f5; assign weight_2[62] = 16'h38f8; assign weight_2[63] = 16'hb343;


    // === Flatten arrays ===
    genvar i;
    generate
        for (i = 0; i < 64; i = i + 1) begin
            assign weight_0_flat[16*i +: 16] = weight_0[i];
            assign weight_1_flat[16*i +: 16] = weight_1[i];
            assign weight_2_flat[16*i +: 16] = weight_2[i];
        end
    endgenerate

    // === Instantiate Neurons ===
    hidden_neuron n0 (.clk(clk), .rst(rst), .image(image), .weight_flat(weight_0_flat), .relu_out(relu_out_0));
    hidden_neuron n1 (.clk(clk), .rst(rst), .image(image), .weight_flat(weight_1_flat), .relu_out(relu_out_1));
    hidden_neuron n2 (.clk(clk), .rst(rst), .image(image), .weight_flat(weight_2_flat), .relu_out(relu_out_2));

endmodule
