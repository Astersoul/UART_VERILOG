
`timescale 1ns/1ps

module uart_rx(
    input clk,
    input rst_n,
    input baud_tick,
    input rx,

    output reg [7:0] rx_data,
    output reg rx_done
);

    parameter IDLE  = 3'd0;
    parameter START = 3'd1;
    parameter DATA  = 3'd2;
    parameter STOP  = 3'd3;
    parameter DONE  = 3'd4;

    reg [2:0] state;
    reg [2:0] bit_count;
    reg [7:0] shift_reg;

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            state     <= IDLE;
            bit_count <= 3'd0;
            shift_reg <= 8'd0;
            rx_data   <= 8'd0;
            rx_done   <= 1'b0;
        end
        else
        begin
            rx_done <= 1'b0;

            case(state)

                //-----------------------------------
                // IDLE
                //-----------------------------------
                IDLE:
                begin
                    if(rx == 1'b0)
                        state <= START;
                end

                //-----------------------------------
                // START BIT
                //-----------------------------------
                START:
                begin
                    if(baud_tick)
                    begin
                        bit_count <= 3'd0;
                        state <= DATA;
                    end
                end

                //-----------------------------------
                // RECEIVE DATA
                //-----------------------------------
                DATA:
                begin
                    if(baud_tick)
                    begin
                        shift_reg[bit_count] <= rx;

                        if(bit_count == 3'd7)
                            state <= STOP;

                        bit_count <= bit_count + 1'b1;
                    end
                end

                //-----------------------------------
                // STOP BIT
                //-----------------------------------
                STOP:
                begin
                    if(baud_tick)
                    begin
                        if(rx == 1'b1)
                        begin
                            rx_data <= shift_reg;
                            state <= DONE;
                        end
                        else
                        begin
                            state <= IDLE;
                        end
                    end
                end

                //-----------------------------------
                // DONE
                //-----------------------------------
                DONE:
                begin
                    rx_done <= 1'b1;
                    state <= IDLE;
                end

                //-----------------------------------
                // DEFAULT
                //-----------------------------------
                default:
                begin
                    state <= IDLE;
                end

            endcase
        end
    end

endmodule
