`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/07 18:04:37
// Design Name: 
// Module Name: UART_TOP
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


module UART_TOP(
    clk,
    rst,
    txd
    );

//------------------------------------------------------//
// Port
//------------------------------------------------------//    
input      clk;
input      rst;
output     txd;

//------------------------------------------------------//
// reg / wire
//------------------------------------------------------//
wire       w_tx_baud_clr;
wire       w_tx_tick;

wire       w_rx_baud_clr;
wire       w_rx_half_clr;
wire       w_rx_tick;

wire [7:0] w_tx_data;
wire       w_tx_valid;
wire       w_tx_ready;
wire       w_txd;

wire [7:0] w_rx_data;
wire       w_rx_valid;
wire       w_rxd;

assign w_tx_data  = 8'h55;
assign w_tx_valid = w_tx_ready;
assign txd        = w_txd;
assign w_rxd      = w_txd;

//------------------------------------------------------//
// TX BAUD GENERATOR
//------------------------------------------------------//
TX_BAUD_GEN tx_baud_gen(
    .SYSCLK      ( clk           ),
    .SYSRST      ( rst           ),
    .BAUD_CLR    ( w_tx_baud_clr ),
    .TICK        ( w_tx_tick     )
);

//------------------------------------------------------//
// RX BAUD GENERATOR
//------------------------------------------------------//
RX_BAUD_GEN rx_baud_gen(
    .SYSCLK      ( clk           ),
    .SYSRST      ( rst           ),
    .BAUD_CLR    ( w_rx_baud_clr ),
    .HALF_CLR    ( w_rx_half_clr ),
    .TICK        ( w_rx_tick     )
);

//------------------------------------------------------//
// UART TX
//------------------------------------------------------//
UART_TX uart_tx(
    .SYSCLK      ( clk           ),
    .SYSRST      ( rst           ),
    .TICK        ( w_tx_tick     ),
    .TX_DATA     ( w_tx_data     ),
    .TX_VALID    ( w_tx_valid    ),
    .TX_READY    ( w_tx_ready    ),
    .TXD         ( w_txd         ),
    .BAUD_CLR    ( w_tx_baud_clr )
);

//------------------------------------------------------//
// UART RX
//------------------------------------------------------//
UART_RX uart_rx(
    .SYSCLK      ( clk           ),
    .SYSRST      ( rst           ),
    .TICK        ( w_rx_tick     ),
    .RX_DATA     ( w_rx_data     ),
    .RX_VALID    ( w_rx_valid    ),
    .RXD         ( w_rxd         ),
    .BAUD_CLR    ( w_rx_baud_clr ),
    .HALF_CLR    ( w_rx_half_clr )
);
endmodule
