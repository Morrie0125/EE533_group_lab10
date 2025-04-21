`timescale 1ns / 1ps

module fp16_adder (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] a, b,    
    output reg  [15:0] result 
);

    function [15:0] fp16_add;
        input [15:0] op1, op2;

        // unpack (extraction)
        reg        sig1, sig2;
        reg [4:0]  exp1, exp2;
        reg [9:0]  mts1, mts2;
        reg [4:0]  exp1_eff, exp2_eff;  // effective exponents (denormals use 1)
        reg [15:0] mts1_ex, mts2_ex;    
        reg [15:0] mts1_al, mts2_al, sum_ex; 
        reg [4:0]  exp_al;          
        // normalization 
        reg [4:0]  final_exp;        
        reg [3:0]  shift;
        reg        found; 
        reg [10:0] final_mts;        
        reg [4:0]  raw_exp;         
        reg [3:0]  extra_shift;     
        reg [15:0] sum_norm;    
        // rounding 
        reg        guard;
        reg        round;
        reg        sticky;

        reg        final_sig;   
        reg [3:0]  i;
        
        begin
            // unpacking
            sig1 = op1[15];
            sig2 = op2[15];
            exp1 = op1[14:10];
            exp2 = op2[14:10];
            mts1 = op1[9:0];
            mts2 = op2[9:0];
            
            // nan in, nan out
            if ((exp1 == 5'b11111 && mts1 != 10'd0) || (exp2 == 5'b11111 && mts2 != 10'd0))
                fp16_add = 16'h7FFF;           
            // inf + (-inf), nan out
            else if ((exp1 == 5'b11111) && (exp2 == 5'b11111) && (sig1 != sig2))
                fp16_add = 16'h7FFF;            
            // inf in, inf out
            else if (exp1 == 5'b11111)
                fp16_add = {sig1, 5'b11111, 10'd0};
            else if (exp2 == 5'b11111)
                fp16_add = {sig2, 5'b11111, 10'd0};            
            
            else begin
                // mantissa extension: re-format to {carry bit, implicit x, 10-bit mantissa, 4-bit zeros for rounding} (2nd MSB: norm 1, denorm 0)               
                if (exp1 == 5'b00000) begin
                    exp1_eff = 5'd1; // to enable denormal inputs, set effective exp = 1
                    mts1_ex = {1'b0, 1'b0, mts1, 4'b0000}; 
                end else begin
                    exp1_eff = exp1;
                    mts1_ex = {1'b0, 1'b1, mts1, 4'b0000}; // implicit 1 for normal number
                end
                
                if (exp2 == 5'b00000) begin
                    exp2_eff = 5'd1;
                    mts2_ex = {1'b0, 1'b0, mts2, 4'b0000};
                end else begin
                    exp2_eff = exp2;
                    mts2_ex = {1'b0, 1'b1, mts2, 4'b0000};
                end
                
                // exponents alignment 
                if (exp1_eff > exp2_eff) begin
                    exp_al = exp1_eff;
                    mts1_al = mts1_ex;
                    mts2_al = mts2_ex >> (exp1_eff-exp2_eff);
                end 
                else begin
                    exp_al = exp2_eff;
                    mts1_al = mts1_ex >> (exp2_eff-exp1_eff);
                    mts2_al = mts2_ex;
                end
                
                // add (same sign), sub (diff signs)
                if (sig1 == sig2) begin //add
                    sum_ex = mts1_al+mts2_al;
                    final_sig = sig1;
                end 
                else begin //sub
                    if (mts1_al >= mts2_al) begin
                        sum_ex = mts1_al-mts2_al;
                        final_sig = sig1;
                    end 
                    else begin
                        sum_ex = mts2_al-mts1_al;
                        final_sig = sig2;
                    end
                end
                
                // result adjustment
                if (sum_ex == 16'd0) begin // if result=0
                    fp16_add = 16'd0;
                end 
                else begin
                    // normalization
                    if (sum_ex[15] == 1'b1) begin // too big: overflow, need to shift back to [1,2)
                        sum_ex = sum_ex >> 1;
                        raw_exp  = exp_al+1; 
                    end 
                    else begin // too small: need to shift left until the implicit one is at sum_ex[14]
                        shift = 0;
                        found = 1'b0;
                        for (i=4'd14; i!=4'd15; i=i-1) begin
                            if (!found && (sum_ex[i] == 1'b1)) begin
                                shift = 4'd14-i;
                                found = 1'b1;
                            end
                        end
                        sum_ex = sum_ex << shift;
                        raw_exp  = exp_al-shift;
                    end
    
                    if (raw_exp > 0) begin // normal out
                        final_exp = raw_exp;                   
                        // rounding
                        guard  = sum_ex[3];
                        round  = sum_ex[2];
                        sticky = (sum_ex[1:0]!=2'b00);
                        final_mts = sum_ex[14:4];
    
                        // round to nearest even
                        if (guard && (round || sticky || final_mts[0])) begin
                            final_mts = final_mts+1;
                            
                            //if (final_mts[10] == 1'b1) begin
                            if (final_mts == 11'b10000000000) begin
                                final_mts = final_mts >> 1;
                                final_exp  = final_exp+1;
                            end
                        end
                        
                        // exponent overflow then output infinity (7C00)
                        if (final_exp > 5'd30) begin
                            fp16_add = {final_sig, 5'b11111, 10'b0};
                        end 
                        else begin
                            fp16_add = {final_sig, final_exp, final_mts[9:0]};
                        end
                    end          
                    else begin // denormal out: shift right extra to get real value 
                        extra_shift = 1-raw_exp;  
                        sum_norm = sum_ex >> extra_shift; 
                        
                        final_exp = 5'd0;  
                        
                        guard  = sum_norm[3];
                        round  = sum_norm[2];
                        sticky = (sum_norm[1:0] != 2'b00);
                        final_mts = sum_norm[14:4];
    
                        if (guard && (round || sticky || final_mts[0])) begin
                            final_mts = final_mts+1;
                        end
                        
                        fp16_add = {final_sig, final_exp, final_mts[9:0]};
                    end
                end
            end
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst)
            result <= 16'd0;
        else
            result <= fp16_add(a,b);
    end

endmodule
