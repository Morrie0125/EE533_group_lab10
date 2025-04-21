`timescale 1ns / 1ps 

module fp16_multiplier (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] a, b, 
    output reg  [15:0] result
);

    function [15:0] fp16_mult;
        input [15:0] op1, op2;
        
        // unpack (extraction)
        reg         sig1, sig2, final_sig;
        reg [4:0]   exp1, exp2;            
        reg [4:0]   exp1_eff, exp2_eff;      
        reg signed [6:0] raw_exp;          
        reg [4:0]   final_exp;             
        reg [9:0]   mts1, mts2;            
        reg [10:0]  mts1_ex, mts2_ex;      
        reg [21:0]  prod_ex;               
        // rounding & norm/denorm
        reg         guard, round, sticky;  
        reg [10:0]  final_mts;            
        reg [21:0]  prod_norm;          
        reg [3:0]   extra_shift;          
        reg [4:0]   shift;                 
        reg         found;

        reg signed [5:0] i;     
                 
        begin
            sig1 = op1[15];
            sig2 = op2[15];
            exp1 = op1[14:10];
            exp2 = op2[14:10];
            mts1 = op1[9:0];
            mts2 = op2[9:0];
            
            final_sig = sig1 ^ sig2;
   
            // nan in, nan out
            if ((exp1 == 5'b11111 && mts1 != 10'd0) || (exp2 == 5'b11111 && mts2 != 10'd0))
                fp16_mult = 16'h7FFF;     
            // inf * 0 , nan out
            else if (((exp1 == 5'b11111) && (mts1 == 0) && (exp2 == 5'd0) && (mts2 == 10'd0)) ||
                     ((exp2 == 5'b11111) && (mts2 == 0) && (exp1 == 5'd0) && (mts1 == 10'd0)))
                fp16_mult = 16'h7FFF;      
            // inf in, inf out
            else if ((exp1 == 5'b11111) || (exp2 == 5'b11111))
                fp16_mult = {final_sig, 5'b11111, 10'd0};      
            // zero in, zero out
            else if ((exp1 == 5'd0 && mts1 == 10'd0) ||
                     (exp2 == 5'd0 && mts2 == 10'd0))
                fp16_mult = {final_sig, 5'd0, 10'd0};
            
            else begin
                // set eff exp for denormal in
                exp1_eff = (exp1 == 5'd0) ? 5'd1 : exp1;
                exp2_eff = (exp2 == 5'd0) ? 5'd1 : exp2;                    
                mts1_ex = (exp1 == 5'd0) ? {1'b0, mts1} : {1'b1, mts1};
                mts2_ex = (exp2 == 5'd0) ? {1'b0, mts2} : {1'b1, mts2};
                
                raw_exp = exp1_eff+exp2_eff-15;
                prod_ex = mts1_ex * mts2_ex;
    
                // normalization
                if (prod_ex[21]) begin // too big: right shift
                    prod_ex = prod_ex >> 1;
                    raw_exp = raw_exp+1;
                end
                if (!prod_ex[20]) begin // too small: left shift
                    shift = 0;
                    found = 1'b0;
                    for (i=19; i>=0; i =i-1) begin
                        if (!found && prod_ex[i]) begin
                            shift = 5'd20-i[4:0];
                            found = 1'b1;
                        end
                    end
                    prod_ex = prod_ex << shift;
                    raw_exp = raw_exp-shift;
                end
    
                // result adjustment
                if (raw_exp > 0) begin // normal out
                    final_exp = raw_exp[4:0];
                    final_mts = prod_ex[20:10];    
                    // rounding
                    guard  = prod_ex[9];
                    round  = prod_ex[8];
                    sticky = |prod_ex[7:0];
                    if (guard && (round || sticky || final_mts[0])) begin
                        final_mts = final_mts+1;
                        
                        //if (final_mts[10]) begin
                        if (final_mts == 11'b10000000000) begin
                            final_mts = final_mts >> 1;
                            final_exp = final_exp+1;
                        end
                    end
    
                    if (final_exp >= 5'd31)
                        fp16_mult = {final_sig, 5'b11111, 10'd0};  // overflow -> inf
                    else
                        fp16_mult = {final_sig, final_exp, final_mts[9:0]};
                end

                else begin // denormal out
                    extra_shift = 1-raw_exp; 
                    if (extra_shift >= 5'd22)
                        fp16_mult = {final_sig, 5'd0, 10'd0};  // underflow -> flush to 0
                    else begin
                        prod_norm = prod_ex >> extra_shift;
                        guard = prod_norm[9];
                        round = prod_norm[8];
                        sticky = |prod_norm[7:0];
                        final_mts = prod_norm[20:10];
    
                        if (guard && (round || sticky || final_mts[0])) begin
                            final_mts = final_mts+1;
                            if (final_mts[10]) begin
                                final_mts = final_mts >> 1;
                                fp16_mult = {final_sig, 5'd1, final_mts[9:0]}; // back to normal
                            end else begin
                                fp16_mult = {final_sig, 5'd0, final_mts[9:0]};
                            end
                        end 
                        else begin
                            fp16_mult = {final_sig, 5'd0, final_mts[9:0]};
                        end
                    end
                end
            end
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= 16'd0;
        else
            result <= fp16_mult(a,b);
    end

endmodule
