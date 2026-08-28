
`timescale 1ns/1ps

module tb_uart_top;

    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg [7:0]  tx_data;

    wire       tx;
    wire       tx_busy;
    wire [7:0] rx_data;
    wire       rx_done;

    integer pass_count;
    integer fail_count;

    //====================================================
    // DUT
    //====================================================

    uart_top DUT (
        .clk      (clk),
        .rst_n    (rst_n),
        .tx_start (tx_start),
        .tx_data  (tx_data),
        .tx       (tx),
        .tx_busy  (tx_busy),
        .rx_data  (rx_data),
        .rx_done  (rx_done)
    );

    //====================================================
    // Clock Generation
    // 50 MHz -> 20 ns period
    //====================================================

    initial begin
        clk = 1'b0;

        forever #10 clk = ~clk;
    end

    //====================================================
    // Test Task
    //====================================================

    task send_and_check;
        input [7:0] data;

        begin

            // Wait until transmitter is free
            wait(tx_busy == 1'b0);

            // Apply data
            @(posedge clk);
            tx_data  = data;
            tx_start = 1'b1;

            @(posedge clk);
            tx_start = 1'b0;

            // Wait for receiver to finish
            wait(rx_done == 1'b1);

            // Check received data
            if(rx_data == data)
            begin
                $display(
                    "PASS: TX_DATA = %h, RX_DATA = %h",
                    data,
                    rx_data
                );

                pass_count = pass_count + 1;
            end
            else
            begin
                $display(
                    "FAIL: TX_DATA = %h, RX_DATA = %h",
                    data,
                    rx_data
                );

                fail_count = fail_count + 1;
            end

            // Allow rx_done to return low
            @(posedge clk);

        end
    endtask

    //====================================================
    // Test Sequence
    //====================================================

    initial begin

        // Initialize
        rst_n    = 1'b0;
        tx_start = 1'b0;
        tx_data  = 8'h00;

        pass_count = 0;
        fail_count = 0;

        // Reset
        #100;
        rst_n = 1'b1;

        #100;

        //================================================
        // Required Assignment Test Patterns
        //================================================

        send_and_check(8'h55);
        send_and_check(8'hAA);
        send_and_check(8'h00);
        send_and_check(8'hFF);
        send_and_check(8'hA5);
        send_and_check(8'h3C);

        //================================================
        // Final Result
        //================================================

        #500;

        $display("----------------------------------------");
        $display("UART TEST COMPLETE");
        $display("PASSED = %0d", pass_count);
        $display("FAILED = %0d", fail_count);
        $display("----------------------------------------");

        if(fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");

        $finish;

    end

    //====================================================
    // Waveform Dump
    //====================================================

    initial begin
        $dumpfile("uart_top.vcd");
        $dumpvars(0, tb_uart_top);
    end
    initial begin
	$dumpfile("uart_top.fsdb");
        $dumpvars(1);
    end
 


endmodule
