`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/07 13:53:54
// Design Name: 
// Module Name: UART_TX
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


module UART_TX(
    SYSCLK,
    SYSRST,
    TICK,
    TX_DATA,
    TX_VALID,
    TX_READY,
    TXD,
    BAUD_CLR
    );
    
//------------------------------------------------------//
// Port
//------------------------------------------------------//
input       SYSCLK;
input       SYSRST;
input       TICK;
input [7:0] TX_DATA;
input       TX_VALID;
output      TX_READY;
output      TXD;
output      BAUD_CLR;

//------------------------------------------------------//
// reg / wire
//------------------------------------------------------//
reg [1:0] r_State;
reg [1:0] s_State;
reg [7:0] r_TxData;
reg       r_TxD;
reg [2:0] r_BitCnt;

wire IDLE_CMD;
wire START_CMD;
wire DATA_CMD;
wire STOP_CMD;

wire TX_START;
wire TX_LSB;
wire TX_INQ;
wire TX_STOP;
wire SEND_BYTE;

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
            if ( TX_VALID ) begin
                s_State = START;
            end else begin
                s_State = IDLE;
            end
        end
        START : begin
            if ( TICK ) begin
                s_State = DATA;
            end else begin
                s_State = START;
            end
        end
        DATA : begin
            if ( TX_STOP ) begin
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

assign TX_READY  = IDLE_CMD;
assign BAUD_CLR  = IDLE_CMD && TX_VALID;
assign TX_START  = IDLE_CMD && TX_VALID;
assign TX_LSB    = START_CMD && TICK;
assign TX_INQ    = DATA_CMD && TICK;
assign TX_STOP   = DATA_CMD && SEND_BYTE && TICK;

//------------------------------------------------------//
// RATCH TX_DATA
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_TxData <= 8'd0;
    end else if ( TX_START ) begin
        r_TxData <= TX_DATA;
    end
end

//------------------------------------------------------//
// BIT COUNT
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_BitCnt <= 3'd0;
    end else if ( IDLE_CMD ) begin
        r_BitCnt <= 3'd0;
    end else if ( TX_INQ ) begin
        r_BitCnt <= r_BitCnt + 3'b1;
    end
end
assign SEND_BYTE = ( r_BitCnt == 3'd7 );

//------------------------------------------------------//
// TXD OUT
//------------------------------------------------------//
always @( posedge SYSCLK or posedge SYSRST ) begin
    if ( SYSRST ) begin
        r_TxD <= 1'b1;
    end else if ( TX_START ) begin
        r_TxD <= 1'b0;
    end else if ( IDLE_CMD || TX_STOP ) begin
        r_TxD <= 1'b1;
    end else if ( TX_LSB ) begin
        r_TxD <= r_TxData[ r_BitCnt ];
    end else if ( TX_INQ ) begin
        r_TxD <= r_TxData[ r_BitCnt + 3'd1 ];       
    end
end
assign TXD = r_TxD;


endmodule
