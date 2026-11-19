`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/06/2026 06:40:27 PM
// Design Name: 
// Module Name: Master
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


module Master(
    input clk_20MHz,
    input I_Bus_RX,
    output Servo_TX,
    output ESC_PWM
    );
    reg [14:1] IBUS_Channels [11:0];
    wire [15:0] Ch_buf [0:5];
    wire [7:0] Throttle;
    wire [7:0] Servo_Pos [2:0]; // [0] pitch, [1] right wing, [2] left wing.
    wire Failsafe;
    wire FrameValid;
    wire throttle_active;
    
    localparam roll_channel = 0;
    localparam pitch_channel = 1;
    localparam throttle_channel = 2;
    localparam throttle_enable = 4;
    // Some Processing can be done here
    
    
    
    IBUS_RX #(.CLK_HZ(20_000_000)) I1 (clk_20MHz, I_Bus_RX, {Ch_buf[6], 
    Ch_buf[5], Ch_buf[4], Ch_buf[3], Ch_buf[2], Ch_buf[1], Ch_buf[0]
    }, FrameValid, Failsafe);
    
    IBUS_Channel_Decoder #(.res(8), .min_out(0), .max_out(256)) D1 (Ch_buf[throttle_channel], Throttle); //trottle
    IBUS_Channel_Decoder #(.res(10), .min_out(380), .max_out(700)) D2 (Ch_buf[roll_channel], Servo_Pos[1]); // right wing pos
    IBUS_Channel_Decoder #(.res(10), .min_out(360), .max_out(650)) D3 (Ch_buf[roll_channel], Servo_Pos[2]); // left wing pos
    IBUS_Channel_Decoder #(.res(10), .min_out(200), .max_out(700)) D4 (Ch_buf[pitch_channel], Servo_Pos[0]);
    IBUS_Channel_Decoder #(.res(1), .min_out(0), .max_out(1)) D5 (Ch_buf[throttle_enable], throttle_active);
    
    ESC_Controller O1 (clk_20MHz, ((Failsafe | throttle_active)? 0 : Throttle), ESC_PWM);
    SCS009_Interpreter O2 (clk_20MHz, Servo_TX, {Servo_Pos[0], 2'b00}, Servo_Pos[1], Servo_Pos[2], 1, Servo_Ready);
endmodule