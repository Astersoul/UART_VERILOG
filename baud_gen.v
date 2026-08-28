module baud_gen #(
    parameter CLK_FREQ  = 50000000,   // 50 MHz
    parameter BAUD_RATE = 9600
)(
    input  clk,
    input  rst_n,
    output reg baud_tick
);

    // Clock cycles required for one baud period
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;

    // Counter width = 13 bits for BAUD_DIV = 434
    reg [14:0] count;

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            count     <= 15'd0;
            baud_tick <= 1'b0;
        end
        else
        begin
            if (count == BAUD_DIV-1)
            begin
                count     <= 15'd0;
                baud_tick <= 1'b1;
            end
            else
            begin
                count     <= count + 1'b1;
                baud_tick <= 1'b0;
            end
        end
    end

endmodule
