`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2022 11:22:58 AM
// Design Name: 
// Module Name: tb
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

module uart_tb();
    parameter CLKS_PER_BIT=100000000/230400;
    parameter CLK_PERIOD=10;
    parameter BIT_PERIOD=CLKS_PER_BIT*CLK_PERIOD;
    
    reg clk=0;
    reg reset_n;
    
    reg r_tx_data_valid=0;
    reg [7:0] r_tx_data=0;
    reg r_rx_serial_data=1;
    wire [7:0] w_rx_data;
    
    wire w_tx_serial_data;
    wire w_tx_done;
    
    task UART_WRITE_BYTE;
        input [7:0] i_data;
        integer i;
        begin
            r_rx_serial_data <= 0;
            #(BIT_PERIOD);
            #1000;
            for(i=0;i<8;i=i+1)
            begin
                r_rx_serial_data<=i_data[i];
                #(BIT_PERIOD);
            end
            
            r_rx_serial_data<=1;
            #(BIT_PERIOD);
        end
    endtask
    always 
        #(CLK_PERIOD/2) clk<=~clk;
    initial 
    begin
        reset_n=0;
        #100 reset_n=1;
    end
    initial 
    begin
        @(posedge clk);
        @(posedge clk);
        r_tx_data_valid <= 1'b1;
        r_tx_data <= 8'hAB;
        @(posedge clk);
        r_tx_data_valid <= 1'b0;
        @(posedge w_tx_done);
        @(posedge clk);
        UART_WRITE_BYTE(8'ha3);
        @(posedge clk);
        if(w_rx_data==8'ha3)
            $write("TEST PASSED");
        else 
            $write("TEST FAILED");
    end
 uart #(.CLKS_PER_BIT(CLKS_PER_BIT)) uart_inst 
 (
        .clk(clk),
        .reset_n(reset_n),
        .i_rx_serial_data(r_rx_serial_data),
        .o_rx_data_valid(),
        .o_rx_data(w_rx_data),
       
        .i_tx_data_valid(r_tx_data_valid),
        .i_tx_data(r_tx_data),
        .o_tx_active(),
        .o_tx_serial_data(w_tx_serial_data),
        .o_tx_done(w_tx_done)
        );
       
endmodule
