
`timescale 1ns/1ps

module uart_tx (
    input clk,
    input rst_n,
    input baud_tick,
    input tx_start,
    input [7:0] tx_data,

    output reg tx,
    output reg busy
);

    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    reg [1:0] state;
    reg [7:0] shift_reg;
    reg [2:0] bit_count;

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state     <= IDLE;
            shift_reg <= 8'h00;
            bit_count <= 3'd0;
            tx        <= 1'b1;
            busy      <= 1'b0;
        end

        else begin

            case (state)

                IDLE: begin
                    tx   <= 1'b1;
                    busy <= 1'b0;

                    if (tx_start) begin
                        shift_reg <= tx_data;
                        bit_count <= 3'd0;
                        busy      <= 1'b1;
                        state     <= START;
                    end
                end

                START: begin
                    tx <= 1'b0;

                    if (baud_tick) begin
                        state <= DATA;
                        tx    <= shift_reg[0];
                    end
                end

                DATA: begin

                    if (baud_tick) begin

                        if (bit_count == 3'd7) begin
                            state <= STOP;
                            tx    <= 1'b1;
                        end
                        else begin
                            bit_count <= bit_count + 1'b1;
                            shift_reg <= shift_reg >> 1;
                            tx        <= shift_reg[1];
                        end

                    end

                end

                STOP: begin
                    tx <= 1'b1;

                    if (baud_tick) begin
                        state <= IDLE;
                        busy  <= 1'b0;
                    end
                end

                default: begin
                    state <= IDLE;
                    tx    <= 1'b1;
                    busy  <= 1'b0;
                end

            endcase
        end
    end

endmodule
