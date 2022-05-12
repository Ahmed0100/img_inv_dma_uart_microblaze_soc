`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2022 07:55:41 PM
// Design Name: 
// Module Name: imgInversionIP
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


module imgInversionIP #(parameter DATA_WIDTH=32)(
    input axis_clk,
    input axis_reset_n,
    //AXI4 STREAM SLAVE INTERFACE
    input s_axis_valid,
    input [DATA_WIDTH-1:0] s_axis_data,
    output s_axis_ready,
    //AXI4 STREAM MASTER INTERFACE
    output reg m_axis_valid,
    input m_axis_ready,
    output reg [DATA_WIDTH-1:0] m_axis_data
    );
 
    always@(posedge axis_clk)
    begin
        if(!axis_reset_n)
            m_axis_data <= 0;
        else if(s_axis_valid && s_axis_ready)
        begin
            for(integer i=0;i<DATA_WIDTH/8;i=i+1)
            begin
                m_axis_data[i*8+:8] <= 255 - s_axis_data[i*8+:8];
            end
        end
    end
    assign s_axis_ready = m_axis_ready;
    always @(posedge axis_clk)
    begin
        if(!axis_reset_n)
            m_axis_valid <= 0;
        else
            m_axis_valid <= s_axis_valid;
    end
endmodule
