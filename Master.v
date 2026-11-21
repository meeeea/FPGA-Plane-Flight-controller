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
    output ESC_PWM,
    output DEBUG_TX
    );
    reg [15:0] Channel [5:0];
    wire [15:0] Ch_buf [5:0];
    wire [7:0] Throttle;
    wire [9:0] Servo_Pos [2:0]; // [0] pitch, [1] right wing, [2] left wing.
    wire Failsafe;
    wire FrameValid;
    wire throttle_active;
    reg [20:0] counter;
    reg counter_prev;
    
    localparam roll_channel = 0;
    localparam pitch_channel = 1;
    localparam throttle_channel = 2;
    localparam throttle_enable = 4;
    // Some Processing can be done here
        
    always @(posedge clk_20MHz) begin
        Channel[0] <= Ch_buf[0];
        Channel[1] <= Ch_buf[1];
        Channel[2] <= Ch_buf[2];
        Channel[3] <= Ch_buf[3];
        Channel[4] <= Ch_buf[4];
        Channel[5] <= Ch_buf[5];
        
        counter_prev <= counter[20];
        counter <= counter + 1;
    end
    
    
    
    IBUS_RX #(.CLK_HZ(20_000_000)) I1 (clk_20MHz, I_Bus_RX, {Ch_buf[5], Ch_buf[4], 
                Ch_buf[3], Ch_buf[2], Ch_buf[1], Ch_buf[0]}, FrameValid, Failsafe);
    
    IBUS_Channel_Decoder #(.res(8), .min_out(0), .max_out(255)) D1 (Channel[throttle_channel], Throttle); //trottle
    
    IBUS_Channel_Decoder #(.res(10), .min_out(380), .max_out(700)) D2 (Channel[roll_channel], Servo_Pos[1]); // right wing pos
    IBUS_Channel_Decoder #(.res(10), .min_out(360), .max_out(680)) D3 (Channel[roll_channel], Servo_Pos[2]); // left wing pos
    
    IBUS_Channel_Decoder #(.res(10), .min_out(200), .max_out(700)) D4 (Channel[pitch_channel], Servo_Pos[0]);
    IBUS_Channel_Decoder #(.res(1), .min_out(0), .max_out(1)) D5 (Channel[throttle_enable], throttle_active);
    
    ESC_Controller O1 (clk_20MHz, ((Failsafe | throttle_active)? 8'h00 :Throttle), ESC_PWM);
    SCS009_Interpreter O2 (clk_20MHz, Servo_TX, 10'h3FF - Servo_Pos[0], Servo_Pos[1], Servo_Pos[2], (counter_prev & ~counter[20]), Servo_Ready);
    
    // debug test
    UART_TX T1 (clk_20MHz, DEBUG_TX, Ch_buf[0][7:0], 1);
endmodule