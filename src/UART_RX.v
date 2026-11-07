`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/07 20:09:52
// Design Name: 
// Module Name: UART_RX
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


module UART_RX(
    SYSCLK,
    SYSRST,
    TICK,
    RXD,
    RX_DATA,
    RX_VALID,
    BAUD_CLR,
    HALF_CLR
    );

//------------------------------------------------------//
// Port
//------------------------------------------------------//
input        SYSCLK;
input        SYSRST;
input        TICK;
input        RXD;
output [7:0] RX_DATA;
output       RX_VALID;
output       BAUD_CLR;
output       HALF_CLR;

//------------------------------------------------------//
// reg / wire
//------------------------------------------------------//
reg [1:0] r_State;
reg [1:0] s_State;

reg       r_RxD_sync1;
reg       r_RxD_sync2;
reg       r_RxD_sync3;

reg [2:0] r_BitCnt;
reg [7:0] r_RxData;
reg       r_RxValid;
reg [7:0] r_RxOut;

wire      IDLE_CMD;
wire      START_CMD;
wire      DATA_CMD;
wire      STOP_CMD;

wire      RX_START;
wire      RX_INQ;
wire      REC_BYTE;
wire      RX_DONE;
//------------------------------------------------------//
// Parameter
//------------------------------------------------------//
parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;

//------------------------------------------------------//
// STATE MACHINE
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_State <= 2'd0;
    end else begin
        r_State <= s_State;
    end
end

always @( * ) begin
    case ( r_State )
        IDLE : begin
            if ( RX_START ) begin
                s_State = START;
            end else begin
                s_State = IDLE;
            end
        end
        START : begin
            if ( TICK && ~r_RxD_sync2 ) begin
                s_State = DATA;
            end else if ( TICK && r_RxD_sync2 ) begin
                s_State = IDLE;
            end else begin
                s_State = START;
            end
        end
        DATA : begin
            if ( REC_BYTE && TICK ) begin
                s_State = STOP;
            end else begin
                s_State = DATA;
            end
        end
        STOP : begin
            if ( TICK ) begin
                s_State = IDLE;
            end else begin
                s_State = STOP;
            end
        end
        default : s_State = IDLE;
    endcase
end

assign IDLE_CMD  = ( r_State == IDLE );
assign START_CMD = ( r_State == START );
assign DATA_CMD  = ( r_State == DATA );
assign STOP_CMD  = ( r_State == STOP );

assign BAUD_CLR  = IDLE_CMD && RX_START;
assign HALF_CLR  = START_CMD;
assign RX_INQ    = DATA_CMD && TICK;
assign RX_DONE   = STOP_CMD && TICK && r_RxD_sync2;

//------------------------------------------------------//
// SYNC RXD
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_RxD_sync1 <= 1'b1;
        r_RxD_sync2 <= 1'b1;
        r_RxD_sync3 <= 1'b1;
    end else begin
        r_RxD_sync1 <= RXD;
        r_RxD_sync2 <= r_RxD_sync1;
        r_RxD_sync3 <= r_RxD_sync2;
    end
end
assign RX_START = ~r_RxD_sync2 && r_RxD_sync3;

//------------------------------------------------------//
// BIT COUNT
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_BitCnt <= 3'd0;
    end else if ( IDLE_CMD ) begin
        r_BitCnt <= 3'd0;
    end else if ( RX_INQ ) begin
        r_BitCnt <= r_BitCnt + 3'b1;
    end
end
assign REC_BYTE = ( r_BitCnt == 3'd7 );

//------------------------------------------------------//
// RXD IN
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_RxData <= 8'd0;
    end else if ( RX_INQ ) begin
        r_RxData[r_BitCnt] <= r_RxD_sync2;
    end
end

//------------------------------------------------------//
// RX VALID
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_RxValid <= 1'b0;
    end else if ( RX_DONE ) begin
        r_RxValid <= 1'b1;
    end else begin
        r_RxValid <= 1'b0;
    end
end
assign RX_VALID = r_RxValid ;

//------------------------------------------------------//
// RX OUT
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_RxOut <= 8'd0;
    end else if ( RX_DONE ) begin
        r_RxOut <= r_RxData;
    end
end
assign RX_DATA = r_RxOut;

endmodule
