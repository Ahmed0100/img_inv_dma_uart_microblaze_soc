module uart_rx #(parameter CLKS_PER_BIT=100000000/230400)
(
	input clk,
	input reset_n,
	input i_rx_serial_data,
	output reg o_rx_data_valid = 0,
	output reg [7:0] o_rx_data = 0
);
	parameter IDLE=3'b0,
	RX_START_BIT=3'b001,
	RX_DATA_BITS=3'b010,
	RX_STOP_BIT=3'b011,
	CLEAN_UP = 3'b100;

	reg [2:0] current_state = 0;
	reg [31:0] clk_count = 0;
	reg [2:0] bit_index = 0;

	wire uart_dout;

	always @(posedge clk)
	begin
		case(current_state)
		IDLE:
		begin
			o_rx_data_valid <= 0;
			clk_count <= 0;
			bit_index <= 0;
			if(i_rx_serial_data == 1'b0)
				current_state <= RX_START_BIT;
			else
				current_state <= IDLE;
		end
		RX_START_BIT:
		begin
			if(clk_count == (CLKS_PER_BIT-1)/2)
			begin
				if(i_rx_serial_data == 1'b0)
				begin
					clk_count <= 0;
					current_state <= RX_DATA_BITS;
				end
				else
					current_state<= IDLE;
			end
			else
			begin
				clk_count <= clk_count +1;
				current_state <= RX_START_BIT;
			end
		end
		RX_DATA_BITS:
		begin
			if(clk_count < CLKS_PER_BIT -1)
			begin
				clk_count <= clk_count + 1;
				current_state <= RX_DATA_BITS;
			end
			else
			begin
				clk_count<=0;
				o_rx_data[bit_index] <= i_rx_serial_data;
				if(bit_index<7)
				begin
					bit_index<=bit_index+1;
					current_state<=RX_DATA_BITS;
				end
				else
				begin
					bit_index <= 0;
					current_state <= RX_STOP_BIT;
				end
			end
		end
		RX_STOP_BIT:
		begin
			if(clk_count < CLKS_PER_BIT-1)
			begin
				clk_count<=clk_count+1;
				current_state<=RX_STOP_BIT;
			end
			else
			begin
				o_rx_data_valid <= 1;
				clk_count<=0;
				current_state <= CLEAN_UP;
			end
		end
		CLEAN_UP:
		begin
			current_state<=IDLE;
			o_rx_data_valid <= 0;
		end
		default:
			current_state<=IDLE;
		endcase
	end
//	always @(posedge clk)
//	begin
//		if(o_rx_data_valid==1'b1)//Just a case used to indicate the end of the test when loaded from the test file.
//		begin
//			$write("%s",o_rx_data);//To be sent to the terminal.
//		end
//	end
endmodule