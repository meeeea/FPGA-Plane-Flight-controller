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
    output reg [res - 1:0] Out
    );
    always_comb begin
        if (Data <= min_in)
            Out = min_out;
        else if (Data >= max_in)
            Out = max_out;
        else
            Out = min_out +
                  ((Data - min_in) * (max_out - min_out))
                  / (max_in - min_in);
    end
endmodule