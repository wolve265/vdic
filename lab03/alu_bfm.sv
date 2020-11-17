interface alu_bfm;
	import alu_pkg::*;
	
	bit clk;
	bit rst_n;
	bit sin = 1;
	bit sout;
	
	initial begin : clk_gen
	  	clk = 0;
	  	forever begin : clk_frv
	     	#10;
	     	clk = ~clk;
	  	end
	end
	
	function bit [3:0] get_CRC4_d68(bit [67:0] d);
		bit [3:0] c;
		bit [3:0] crc;
		
		c = '0;
		crc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
	    crc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
	    crc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
	    crc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
		return crc;
		
	endfunction
	
	function bit [3:0] get_CRC3_d37(bit [36:0] d);
		bit [2:0] c;
		bit [2:0] crc;
		
		c = '0;
		crc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
		crc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
		crc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
		return crc;
		
	endfunction
	
	task do_rst();
		@(negedge clk);
		rst_n = 1'b0;
		@(negedge clk);
		rst_n = 1'b1;
	endtask
	
	task automatic read_serial_in(
		output status_t in_status,
		output bit [31:0] A,
		output bit [31:0] B,
		output alu_op_t alu_op,
		output bit [3:0] crc4
		);
		
		bit [7:0] temp_d [0:7];
		packet_t packet_type;
		
		packet_type = DATA;
		in_status = OK;
		
		for(int i=7; i>=0; i--) begin : read_8_data_packets
			read_packet_in(packet_type, temp_d[i]);
			if(packet_type == CTL) begin : read_error_packet
				in_status = ERROR;
			end
		end
		
		if(in_status == OK) begin : read_good_packets
			B[31:24] = temp_d[7];
			B[23:16] = temp_d[6];
			B[15:8] = temp_d[5];
			B[7:0] = temp_d[4];
			A[31:24] = temp_d[3];
			A[23:16] = temp_d[2];
			A[15:8] = temp_d[1];
			A[7:0] = temp_d[0];
			read_packet_in(packet_type, temp_d[0]);
			case(temp_d[0][6:4])
				3'b000: alu_op = AND;
				3'b001: alu_op = OR;
				3'b100: alu_op = ADD;
				3'b101: alu_op = SUB;
				default: alu_op = UNKNOWN;
			endcase
			crc4 = temp_d[0][3:0];
		end
	
	endtask
	
	task automatic read_packet_in(
		output packet_t packet_type,
		output bit [7:0] d
		);
		//Detecting start bit
		while(sin != 0) @(posedge clk);
		
		//Defining if data or ctl
		@(posedge clk);
		if(sin == 0) begin
			packet_type = DATA;
		end
		else begin
			packet_type = CTL;
		end
		
		// Reading bits	
		for(int i=7; i>=0; i--) begin
			@(posedge clk);
			d[i] = sin;
		end
		@(posedge clk);
	endtask

	task read_serial_out(
		output status_t alu_status,
		output bit [31:0] C,
		output bit [3:0] flags,
		output bit [2:0] crc3,
		output bit [5:0] err_flags,
		output bit parity
		);
		
		bit [7:0] temp_d;
		packet_t packet_type;
		
		read_packet_out(packet_type, temp_d);
		if(packet_type == CTL) begin : read_error_packet
			alu_status = ERROR;
			err_flags = temp_d[6:1];
			parity = temp_d[0];
			C = '0;
			flags = '0;
			crc3 = '0;
		end
		else begin : read_correct_packets
			alu_status = OK;
			err_flags = '0;
			parity = '0;
			C[31:24] = temp_d;
			read_packet_out(packet_type, C[23:16]);
			read_packet_out(packet_type, C[15:8]);
			read_packet_out(packet_type, C[7:0]);
			read_packet_out(packet_type, temp_d);
			flags = temp_d[6:3];
			crc3 = temp_d[2:0];
		end
	endtask
	
	task read_packet_out(
		output packet_t packet_type,
		output bit [7:0] d
		);
		//Detecting start bit
		while(sout != 0) @(negedge clk);
		
		//Defining if data or ctl
		@(negedge clk);
		if(sout == 0) begin
			packet_type = DATA;
		end
		else begin
			packet_type = CTL;
		end
		// Reading bits
		
		for(int i=7; i>=0; i--) begin
			@(negedge clk);
			d[i] = sout;
		end
		@(negedge clk);
	endtask
	
	task send_serial(
		input bit [31:0] A,
		input bit [31:0] B,
		input alu_op_t op,
		input bit [3:0] crc4
		);
		bit [3:0] op_bit;
		$cast(op_bit, op);
		send_data_packet(B[31:24]);
		send_data_packet(B[23:16]);
		send_data_packet(B[15:8]);
		send_data_packet(B[7:0]);
		send_data_packet(A[31:24]);
		send_data_packet(A[23:16]);
		send_data_packet(A[15:8]);
		send_data_packet(A[7:0]);
		send_ctl_packet({1'b0, op_bit, crc4});
	endtask
	
	task send_serial_7frames(
		input bit [31:0] A,
		input bit [31:0] B,
		input alu_op_t op,
		input bit [3:0] crc4
		);
		bit [3:0] op_bit;
		$cast(op_bit, op);
		send_data_packet(B[31:24]);
		send_data_packet(B[23:16]);
		send_data_packet(B[15:8]);
		send_data_packet(B[7:0]);
		send_data_packet(A[31:24]);
		send_data_packet(A[23:16]);
		send_data_packet(A[15:8]);
		send_ctl_packet({1'b0, op_bit, crc4});
	endtask
	
	task send_data_packet(
		input bit[7:0] d
		);
		send_packet({2'b00, d, 1'b1});
	endtask
	
	task send_ctl_packet(
		input bit[7:0] d
		);
		send_packet({2'b01, d, 1'b1});
	endtask
	
	task send_packet(
		input bit[10:0] d
		);
		for(int i=10; i>=0; i--) begin
			@(negedge clk) sin = d[i];
		end
	endtask
	
	task automatic predict_results(
		input status_t in_status,
		input bit [31:0] in_A,
		input bit [31:0] in_B,
		input alu_op_t in_alu_op,
		input bit [3:0] in_crc4,
		output status_t predicted_alu_status,
		output bit [31:0] predicted_C,
		output bit [3:0] predicted_flags,
		output bit [2:0] predicted_crc3,
		output bit [5:0] predicted_err_flags,
		output bit predicted_parity
		);
		
		bit [3:0] crc4;
		
		predicted_alu_status = OK;
		predicted_C = '0;
		predicted_flags = '0;
		predicted_crc3 = '0;
		predicted_err_flags = '0;
		predicted_parity = '0;
				
		if(in_status == ERROR) begin : invalid_data
			predicted_alu_status = in_status;
			predicted_err_flags[5] = 1'b1;
			predicted_err_flags[2:0] = predicted_err_flags[5:3];
			predicted_parity = 1'b1;
		end
		else begin : valid_data
			case(in_alu_op)
				AND: begin : and_op
					predicted_C = in_B&in_A;
					crc4 = get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
					predicted_flags[0] = predicted_C[31];//negative
					predicted_flags[1] = (predicted_C == 0);//zero
					predicted_flags[2] = 0;//overflow
					predicted_flags[3] = 0;//carry
					predicted_crc3 = get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
				end
				OR: begin : or_op
					predicted_C = in_B|in_A;
					crc4 = get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
					predicted_flags[0] = predicted_C[31];//negative
					predicted_flags[1] = (predicted_C == 0);//zero
					predicted_flags[2] = 0;//overflow
					predicted_flags[3] = 0;//carry
					predicted_crc3 = get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
				end
				ADD: begin : add_op
					{predicted_flags[3],predicted_C} = in_B+in_A;
					crc4 = get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
					predicted_flags[0] = predicted_C[31];//negative
					predicted_flags[1] = (predicted_C == 0);//zero
					predicted_flags[2] = ~(in_A[31] ^ in_B[31] ^ 1'b0) && (in_A[31] ^ predicted_C[31]);//overflow
					predicted_crc3 = get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
				end
				SUB: begin : sub_op
					crc4 = get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
					{predicted_flags[3],predicted_C} = in_B-in_A;
					predicted_flags[0] = predicted_C[31];//negative
					predicted_flags[1] = (predicted_C == 0);//zero
					predicted_flags[2] = (((~predicted_C[31]) && (~in_A[31]) && in_B[31]) || (predicted_C[31] && in_A[31] && (~in_B[31])));//overflow
					predicted_crc3 = get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
				end
				default: begin: invalid_op
					predicted_alu_status = ERROR;
					predicted_err_flags[3] = 1'b1;
					predicted_err_flags[2:0] = predicted_err_flags[5:3];
					predicted_parity = 1'b1;
				end
			endcase // case(in_alu_op)
			if(in_crc4 != crc4) begin : invalid_crc
				predicted_alu_status = ERROR;
				predicted_err_flags[4] = 1'b1;
				predicted_err_flags[2:0] = predicted_err_flags[5:3];
				predicted_parity = 1'b1;
			end
		end : valid_data
		
	endtask : predict_results

endinterface : alu_bfm