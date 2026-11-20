`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: ECEN 361 FPGA Plane
// Engineer: Justin Hutchens
// 
// Create Date: 11/07/2026 06:51:38 PM
// Design Name: 
// Module Name: ESC_Controller
// Project Name: 
// Target Devices: Cmod A7 35t
// Tool Versions: 
// Description: take 8 bit speed value and convert it into a pwm pulse for speed.
// 
// Dependencies: PWM Module By Zane / Justin
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ESC_Controller #(
    parameter int Max_Speed = 16'h9C40, //variable to be used for comparison later when making ranges 
    parameter int Min_Speed = 15'h4E20, 
    parameter int Speed_Resolution = 8
    )(
    input clk_20MHz,
    input [Speed_Resolution - 1:0] Speed,
    output ESC_PWM
    );
    localparam logic Speed_Step = (Max_Speed - Min_Speed) / (2 ** (Speed_Resolution - 1));
    
    logic [18:0] durration;
    
    always_comb begin
        if (Speed <= 0)
            durration = Min_Speed;
        else if (Speed >= 2 ** Speed_Resolution - 1)
            durration = Max_Speed;
        else
            durration = Min_Speed +
                  ((Speed - Min_Speed) * (Max_Speed - Min_Speed))
                  / (2 ** Speed_Resolution - 1);
    end
    
    PWM P1 (clk_20MHz, durration, ESC_PWM);
endmodule