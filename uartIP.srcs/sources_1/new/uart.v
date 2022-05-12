`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2022 11:04:44 AM
// Design Name: 
// Module Name: uart
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


module uart #(parameter CLKS_PER_BIT=100000000/230400)(
    input clk,
    input reset_n,
    input i_rx_serial_data,
    output o_rx_data_valid,
    output [7:0] o_rx_data,
   
    input i_tx_data_valid,
    input [7:0] i_tx_data,
    output o_tx_active,
    output o_tx_serial_data,
    output o_tx_done
    );
    uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) rx_inst
    (
        .clk(clk),
        .reset_n(reset_n),
        .i_rx_serial_data(i_rx_serial_data),
        .o_rx_data_valid(o_rx_data_valid),
        .o_rx_data(o_rx_data)
    );
    uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) tx_inst
    (
        .clk(clk),
        .reset_n(reset_n),
        .i_tx_data_valid(i_tx_data_valid),
        .i_tx_data(i_tx_data),
        .o_tx_active(o_tx_active),
        .o_tx_serial_data(o_tx_serial_data),
        .o_tx_done(o_tx_done)
        );
endmodule
