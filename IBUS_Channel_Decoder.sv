`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Justin Hutchens
// 
// Create Date: 11/09/2026 10:44:19 AM
// Design Name: 
// Module Name: IBUS_Channel_Decoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IBUS_Channel_Decoder #(
    parameter int min_in = 1000,
    parameter int max_in = 2000,
    parameter int res = 8,
    parameter int min_out = 0,
    parameter int max_out = 2 ** res - 1
    )(
    input [15:0] Data,
    output [res - 1:0] Out
    );
    localparam int step_ratio = ((max_out - min_out) / res) / ((max_in - min_in) / res);
    
    assign Out = min_out + (Data - min_in) * step_ratio; 
endmodule