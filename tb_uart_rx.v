`timescale 1ns/1ps

module tb_uart_rx;

    //====================================================
    // Testbench Signals
    //====================================================
    reg clk;
    reg rst_n;
    reg baud_tick;
    reg rx;

    wire [7:0] rx_data;
    wire rx_done;

    //====================================================
    // Instantiate DUT
    //====================================================
    uart_rx DUT (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .rx(rx),
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    //====================================================
    // Clock Generation (50 MHz)
    //====================================================
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    //====================================================
    // Baud Tick Generation
    //===================================================
    initial begin
        baud_tick = 0;
        forever begin
            #80 baud_tick = 1;
            #20 baud_tick = 0;
        end
    end

    //====================================================
    // UART Byte Transmission Task
    //====================================================
    task send_byte;
        input [7:0] data;
        integer i;

        begin

            // Idle
            rx = 1;
            @(posedge baud_tick);

            // Start Bit
            rx = 0;
            @(posedge baud_tick);

            // Data Bits (LSB First)
            for(i=0; i<8; i=i+1)
            begin
                rx = data[i];
                @(posedge baud_tick);
            end

            // Stop Bit
            rx = 1;
            @(posedge baud_tick);

        end
    endtask

    //====================================================
    // Stimulus
    //====================================================
    initial begin

        rst_n = 0;
        rx    = 1;

        #100;
        rst_n = 1;

        send_byte(8'hA5);

        #500;

        send_byte(8'h3C);

        #500;

        send_byte(8'hF0);

        #1000;

        $finish;

    end

    //====================================================
    // Monitor
    //====================================================
    initial begin
        $monitor("Time=%0t  RX=%b  RX_DATA=%h  RX_DONE=%b",
                  $time, rx, rx_data, rx_done);
    end

    //====================================================
    // Waveform Dump
    //====================================================
    initial begin
        $dumpfile("uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);
    end
    initial begin
	$dumpfile("uart_rx.fsdb");
        $dumpvars(1);
    end
 


endmodule
