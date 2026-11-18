`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Justin Hutchens
// 
// Create Date: 11/04/2026 10:23:35 AM
// Design Name: 
// Module Name: UART_RX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: UART RX...
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module UART_RX(
    input clk_20MHz,
    
    input RX,
    
    output logic [7:0] rData,    
    input rReady,
    output logic rValid
    );
    
    localparam logic [7:0] Sample_Point1 = 8'h2B;
    localparam logic [7:0] Sample_Point2 = 8'h57;
    localparam logic [7:0] Sample_Point3 = 8'h82;

    
    logic [1:0] Data_point;
    
    logic [9:0] data;
    
    logic [3:0] cycle;
    
    logic [7:0] bauder; // slow down clock to 3X baud rate to read.
    logic [1:0] state = 0; 
            // states: 
            // 0b00 await ready (when waiting for parrent to confirm data is recieved)
            // 0b01 wait for negedge of RX
            // 0b10 recive data
            // 0b11 load new data into rdata and move
    logic [1:0] next_state = 0;
    
    logic RX_sync_buf, RX_sync;
    logic Data_majority; // most agreed upon value for RX in that cylce.
    
    always_ff @(posedge clk_20MHz) begin
        // bauder
        if (bauder > 8'hAD) begin
            bauder <= 0;
        end else bauder ++;
        
        // update some values
        RX_sync_buf <= RX;
        RX_sync <= RX_sync_buf;
        state <= next_state;
        
        // next_state (self_updates).
        next_state <= (state == 2'b11) ? 2'b00 :
                      ((rReady & rValid) ? 2'b01 
                      : next_state);
        
        // values that don't need to be in a state-matchine
        rValid <= (state == 2'b00);                         
        rData <= (state == 2'b11) ? data[8:1] : rData;
        Data_majority <= (Data_point[0] & Data_point[1]) |
                         (Data_point[0] & RX_sync)       |
                         (Data_point[1] & RX_sync)       ;
        
        
        // State actions:
        if (state == 2'b10) begin     // Data_Read State
            if (bauder == Sample_Point1) Data_point[0] <= RX_sync;
            if (bauder == Sample_Point2) Data_point[1] <= RX_sync;
            if (bauder == Sample_Point3) data[cycle] <= Data_majority;
            if (bauder == 8'hAD) begin
                if (cycle == 9) 
                    next_state <= 2'b11;
                cycle ++;
            end
        end
        
        if (state == 2'b01) begin
            if (~RX_sync) begin
                bauder <= 0;
                next_state <= 2'b10;
                cycle <=0;
                
            end    
        end
    end    
    
endmodule
