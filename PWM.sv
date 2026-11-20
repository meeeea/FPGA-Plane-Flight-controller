`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Justin Hutchens & Zane
// 
// Create Date: 10/01/2026 07:30:28 PM
// Design Name: 
// Module Name: PWM
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

module PWM # (
    parameter int Pulse_Period = 19'h61A80
    )
    (
    input clk_20MHz,
    input[18:0] Durration,
    output pulse
    );
    
    logic [$clog2(Pulse_Period + 1) - 1:0] count;
    
    always_ff @(posedge clk_20MHz) begin
        //Send a minimum throttle from the flight controller (FPGA) to the ESC to initialize
        //maybe I need to make an initialization module that the FPGA will run on startup that is 
        //seperate from this module so that it can send the minimum throttle right out the gate. 
        // Ask Justin about this
        count <= count + 1;
        if (count > Pulse_Period) 
        // get sample of desired speed from flight controller (FPGA) compare it to the ranges based
        // on number of bits sent, then send the desired pulse based on the speed range sent
            count <= 0;
    end
    // this is where the data actually gets sent to the ESC
    // so it will probably need to be modified when we know what kind of data we are getting
    //Something to ask Joel and Justin about
    assign pulse = count < Durration;
    
endmodule
