`timescale 1ns/1ps

module tb_uart_tx;

    //=====================================================
    // Parameters
    //=====================================================
    parameter CLK_PERIOD = 20;

    //=====================================================
    // Testbench Signals
    //=====================================================
    reg clk;
    reg rst_n;
    reg baud_tick;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire busy;

    //=====================================================
    // Instantiate DUT
    //=====================================================
    uart_tx DUT (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .busy(busy)
    );

    //=====================================================
    // Clock Generation (50 MHz)
    //=====================================================
    always #(CLK_PERIOD/2) clk = ~clk;

    //=====================================================
    // Baud Tick Generation
    //=====================================================
    initial begin
        baud_tick = 0;
        forever begin
            #80 baud_tick = 1;
            #20 baud_tick = 0;
        end
    end

    //=====================================================
    // Stimulus
    //=====================================================
    initial begin

        clk      = 0;
        rst_n    = 0;
        tx_start = 0;
        tx_data  = 8'h00;

        #100;
        rst_n = 1;

        //-------------------------------------------------
        // Test Case 1
        //-------------------------------------------------
        #50;
        tx_data  = 8'hA5;
        tx_start = 1;

        #20
        tx_start = 0;

        wait(busy == 0);

        //-------------------------------------------------
        // Test Case 2
        //-------------------------------------------------
        #200;

        tx_data  = 8'h3C;
        tx_start = 1;

        #20;
        tx_start = 0;

        wait(busy == 0);

        //-------------------------------------------------
        // Test Case 3
        //-------------------------------------------------
        #200;

        tx_data  = 8'hFF;
        tx_start = 1;

        #20;
        tx_start = 0;

        wait(busy == 0);

        #500;

        $finish;

    end

    //=====================================================
    // Monitor
    //=====================================================
    initial begin
        $monitor("Time=%0t | TX=%b | Busy=%b | Data=%h",
                  $time, tx, busy, tx_data);
    end

    //=====================================================
    // Dump Waveform
    //=====================================================
    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);
    end
    initial begin
	$dumpfile("uart_tx.fsdb");
        $dumpvars(1);
    end
 


endmodule
