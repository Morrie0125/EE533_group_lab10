module max_index (
    input  wire        clk,
    input  wire        rst,
    input  wire        valid_in,
    input  wire [15:0] logit0,
    input  wire [15:0] logit1,
    input  wire [15:0] logit2,
    input  wire [15:0] logit3,
    input  wire [15:0] logit4,
    input  wire [15:0] logit5,
    input  wire [15:0] logit6,
    input  wire [15:0] logit7,
    input  wire [15:0] logit8,
    input  wire [15:0] logit9,

    output reg  [3:0]  max_idx,
    output reg         valid
);

    // === 用於比較的暫存器 ===
    reg [15:0] current_max;
    reg [3:0]  current_idx;
    reg [3:0]  index;



    // === 暫存 logit ===
    reg [15:0] logit_val;

    // === 比較用 ===
    wire [15:0] a_cmp, b_cmp;
    wire ge;

    assign a_cmp = logit_val;   
    assign b_cmp = current_max;

    fp16_gte fp_cmp (
        .a(a_cmp),
        .b(b_cmp),
        .ge(ge)
    );

    // === 狀態機 ===
    localparam IDLE = 0, COMPARE = 1, DONE = 2;
    reg [1:0] state;

    always @(*) begin
        case (index)
            4'd0: logit_val = logit0;
            4'd1: logit_val = logit1;
            4'd2: logit_val = logit2;
            4'd3: logit_val = logit3;
            4'd4: logit_val = logit4;
            4'd5: logit_val = logit5;
            4'd6: logit_val = logit6;
            4'd7: logit_val = logit7;
            4'd8: logit_val = logit8;
            4'd9: logit_val = logit9;
            default: logit_val = 16'h0000;
        endcase
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            current_max <= 16'd0;
            current_idx <= 4'd0;
            index       <= 4'd0;
            max_idx     <= 4'd0;
            valid       <= 0;
            state       <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        current_max <= logit0;
                        current_idx <= 4'd0;
                        index       <= 4'd1;
                        valid       <= 0;
                        state       <= COMPARE;
                    end
                end

                COMPARE: begin
                    if (ge) begin
                        current_max <= logit_val;
                        current_idx <= index;
                    end
                    if (index == 4'd9)
                        state <= DONE;
                    else
                        index <= index + 1;
                end

                DONE: begin
                    max_idx <= current_idx;
                    valid   <= 1;
                    state   <= IDLE;
                end
            endcase
        end
    end

endmodule
