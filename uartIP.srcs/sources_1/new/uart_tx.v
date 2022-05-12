`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2022 09:34:21 AM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx #(parameter CLKS_PER_BIT=100000000/230400)(
    input clk,
    input reset_n,
    input i_tx_data_valid,
    input [7:0] i_tx_data,
    output reg o_tx_active=0,
    output reg o_tx_serial_data=0,
    output reg o_tx_done=0
    );
    parameter IDLE = 'd0,
    TX_START_BIT='d1,
    TX_DATA='d2,
    TX_STOP_BIT='d3,
    TX_CLEANUP='d4;
    reg [2:0] r_current_state=IDLE;
    reg [31:0] r_clocks_count=0;
    reg [2:0] r_bit_index=0;
    reg [7:0] r_tx_data=0;

    always @(posedge clk)
    begin
        case(r_current_state)
        IDLE:
        begin
            o_tx_serial_data<=1;
            o_tx_done<=0;
            r_clocks_count <=0;
            r_bit_index<=0;
            if(i_tx_data_valid)
            begin
                o_tx_active <= 1;
                r_tx_data<=i_tx_data;
                r_current_state<=TX_START_BIT;
            end
            else
                r_current_state<=IDLE;     
        end
        TX_START_BIT:
        begin
            o_tx_serial_data<=0;
            if(r_clocks_count<CLKS_PER_BIT-1)
            begin
                r_clocks_count<=r_clocks_count+1;
                r_current_state<=TX_START_BIT;
            end
            else
            begin
                r_clocks_count<=0;
                r_current_state<=TX_DATA;
            end
        end
        TX_DATA:
        begin
            o_tx_serial_data<=r_tx_data[r_bit_index];
            if(r_clocks_count<CLKS_PER_BIT)
            begin
                r_clocks_count<=r_clocks_count+1;
                r_current_state<=TX_DATA;
            end
            else
            begin
                r_clocks_count<=0;
                if(r_bit_index<7)
                begin
                    r_bit_index<=r_bit_index+1;
                    r_current_state<=TX_DATA;
                end
                else
                begin
                    r_bit_index<=0;
                    r_current_state<=TX_STOP_BIT;
                end
            end
        end
        TX_STOP_BIT:
        begin
            o_tx_serial_data<=1;
            if(r_clocks_count<CLKS_PER_BIT)
            begin
                r_clocks_count<=r_clocks_count+1;
                r_current_state<=TX_STOP_BIT;
            end
            else
            begin
                o_tx_done<=1;
                r_clocks_count<=0;
                r_current_state<=TX_CLEANUP;
                o_tx_active<=0;
            end
        end
        TX_CLEANUP:
        begin
            o_tx_done<=1;
            r_current_state<=IDLE;
        end
        default:
            r_current_state<=IDLE;
        endcase
        
    end
endmodule
