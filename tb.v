`timescale 1ns / 1ps
module tb;
    parameter CLK_PERIOD=10;
    parameter CLKS_PER_BIT=100000000/230400;

	reg clk=0;
	reg reset_n;
	wire rx_data_valid;
	reg tx_data_valid=0;
	wire [7:0] rx_data_byte;
	reg [7:0] tx_data_byte=0;
    wire tx_done;
    reg [7:0] img[157:0];
    reg [7:0] imgOut[157:0];
    reg [31:0] count=0;
    integer f;

	always @(posedge clk)
	begin
		if(rx_data_valid==1'b1)//Just a case used to indicate the end of the test when loaded from the test file.
		begin
           imgOut[count] <= rx_data_byte;
           count<=count+1;
           $writememh("imgOut.txt",imgOut);
          //$writememh("imgOut.txt",tb.dut.design_1_i.axi_bram_ctrl_0_bram.inst.native_mem_mapped_module.blk_mem_gen_v8_4_1_inst.memory);
		  //$write("%s",rx_data_byte);//To be sent to the terminal.
		end
	end
	always 
        #(CLK_PERIOD/2) clk<=~clk;
    initial 
    begin
        reset_n=0;
        #100 reset_n=1;
    end
    integer i;
    initial
    begin
        $readmemh("img.txt",img); 
        f=$fopen("imgOut.txt","w"); 
        #(100000)
        for(i=0;i<158;i=i+1)
        begin
            @(posedge clk);
            tx_data_valid <= 1'b1;
            tx_data_byte <= img[i];
            @(posedge clk);
            tx_data_valid <= 1'b0;
            @(posedge tx_done);
        end
    end
	design_1_wrapper #(.CLKS_PER_BIT(CLKS_PER_BIT)) dut
	(.clock(clk), .reset_rtl(reset_n),
	   .i_tx_data_0(tx_data_byte),
	   .i_tx_data_valid_0(tx_data_valid),
	   .o_tx_done_0(tx_done),
	   
	   .o_rx_data_0(rx_data_byte),
	   .o_rx_data_valid_0(rx_data_valid)
	);
endmodule