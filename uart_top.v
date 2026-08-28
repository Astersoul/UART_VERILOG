`timescale 1ns/1ps

module uart_top(

    input clk,
    input rst_n,

    input tx_start,
    input [7:0] tx_data,

    output [7:0] rx_data,
    output rx_done,

    output tx,
    output tx_busy

);

wire baud_tick;
wire serial_line;

/////////////////////////////////////////////////
// Baud Generator
/////////////////////////////////////////////////

baud_gen #(
    .CLK_FREQ(50000000),
    .BAUD_RATE(9600)
)
BG
(
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick(baud_tick)
);

/////////////////////////////////////////////////
// UART Transmitter
/////////////////////////////////////////////////

uart_tx TX
(
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick(baud_tick),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .tx(serial_line),
    .busy(tx_busy)
);

/////////////////////////////////////////////////
// UART Receiver
/////////////////////////////////////////////////

uart_rx RX
(
    .clk(clk),
    .rst_n(rst_n),
    .baud_tick(baud_tick),
    .rx(serial_line),
    .rx_data(rx_data),
    .rx_done(rx_done)
);

assign tx = serial_line;

endmodule
