`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/07 01:00:20
// Design Name: 
// Module Name: BAUD_GEN
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


module TX_BAUD_GEN(
    SYSCLK,
    SYSRST,
    BAUD_CLR,
    TICK
    );

//------------------------------------------------------//
// Port
//------------------------------------------------------//
input  SYSCLK;
input  SYSRST;
input  BAUD_CLR;
output TICK;

//------------------------------------------------------//
// reg / wire
//------------------------------------------------------//
reg [9:0]tick_cnt;
wire tick_clr;

assign tick_clr = ( tick_cnt == 10'd867 );
assign TICK     = tick_clr && ~BAUD_CLR;

//------------------------------------------------------//
// TICK COUNT
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST) begin
    if ( SYSRST ) begin
        tick_cnt <= 10'd0;
    end else if ( BAUD_CLR ) begin
        tick_cnt <= 10'd0;
    end else if ( tick_clr ) begin
        tick_cnt <= 10'd0;
    end else begin
        tick_cnt <= tick_cnt + 10'd1;
    end
end
endmodule
