`timescale 1ns/1ps

module tb_baud_gen;

    // Parameters
    parameter CLK_FREQ  = 50_000_000;
    parameter BAUD_RATE = 9600;

    // Testbench Signals
    reg clk;
    reg rst_n;
    wire baud_tick;

    // DUT Instantiation
    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) DUT (
        .clk(clk),
        .rst_n(rst_n),
        .baud_tick(baud_tick)
    );

    //=================================================
    // Clock Generation (50 MHz)
    //=================================================
    initial begin
        clk = 0;
        forever #10 clk = ~clk;     // 20 ns period
    end

    //=================================================
    // Test Stimulus
    //=================================================
    initial begin

        rst_n = 0;

        #100;
        rst_n = 1;

        // Run simulation long enough to observe
        // several baud_tick pulses
        #100000;

        $finish;

    end

    //=================================================
    // Monitor
    //=================================================
    initial begin
        $display("Time\tReset\tBaud Tick");
        $monitor("%0t\t%b\t%b", $time, rst_n, baud_tick);
    end

    //=================================================
    // Waveform Dump
    //=================================================
    initial begin
    $dumpfile("baud_gen.fsdb");
    $dumpvars(0, tb_baud_gen);
end
 


endmodule
