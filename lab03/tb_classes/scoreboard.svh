class scoreboard;
	
	virtual alu_bfm bfm;
	
	function new(virtual alu_bfm b);
		bfm = b;
	endfunction : new
	
	task execute();
		forever begin
			status_t result;
			//in
			status_t in_status;
			bit [31:0] in_A;
			bit [31:0] in_B;
			alu_op_t in_alu_op;
			bit [3:0] crc4;
			bit [3:0] in_crc4;
			//out
			status_t alu_status;
			bit [31:0] C;
			bit [3:0] flags;
			bit [2:0] crc3;
			bit [5:0] err_flags;
			bit parity;
			//predicted
			status_t predicted_alu_status;
			bit [31:0] predicted_C;
			bit [3:0] predicted_flags;
			bit [2:0] predicted_crc3;
			bit [5:0] predicted_err_flags;
			bit predicted_parity;
	
			result = OK;
			//clear predictions
			repeat(1000) begin : score_loop
				
				predicted_alu_status = OK;
				predicted_C = '0;
				predicted_flags = '0;
				predicted_crc3 = '0;
				predicted_err_flags = '0;
				predicted_parity = '0;
			
				bfm.read_serial_in(in_status,in_A,in_B,in_alu_op,in_crc4);
				
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
							crc4 = bfm.get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
							predicted_flags[0] = predicted_C[31];//negative
							predicted_flags[1] = (predicted_C == 0);//zero
							predicted_flags[2] = 0;//overflow
							predicted_flags[3] = 0;//carry
							predicted_crc3 = bfm.get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
						end
						OR: begin : or_op
							predicted_C = in_B|in_A;
							crc4 = bfm.get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
							predicted_flags[0] = predicted_C[31];//negative
							predicted_flags[1] = (predicted_C == 0);//zero
							predicted_flags[2] = 0;//overflow
							predicted_flags[3] = 0;//carry
							predicted_crc3 = bfm.get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
						end
						ADD: begin : add_op
							{predicted_flags[3],predicted_C} = in_B+in_A;
							crc4 = bfm.get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
							predicted_flags[0] = predicted_C[31];//negative
							predicted_flags[1] = (predicted_C == 0);//zero
							predicted_flags[2] = ~(in_A[31] ^ in_B[31] ^ 1'b0) && (in_A[31] ^ predicted_C[31]);//overflow
							predicted_crc3 = bfm.get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
						end
						SUB: begin : sub_op
							crc4 = bfm.get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
							{predicted_flags[3],predicted_C} = in_B-in_A;
							predicted_flags[0] = predicted_C[31];//negative
							predicted_flags[1] = (predicted_C == 0);//zero
							predicted_flags[2] = (((~predicted_C[31]) && (~in_A[31]) && in_B[31]) || (predicted_C[31] && in_A[31] && (~in_B[31])));//overflow
							predicted_crc3 = bfm.get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
						end
						default: begin: invalid_op
							predicted_alu_status = ERROR;
							predicted_err_flags[4] = 1'b1;
							predicted_err_flags[2:0] = predicted_err_flags[5:3];
							predicted_parity = 1'b1;
						end
					endcase
					if(in_crc4 != crc4) begin : invalid_crc
						predicted_alu_status = ERROR;
						predicted_err_flags[4] = 1'b1;
						predicted_err_flags[2:0] = predicted_err_flags[5:3];
						predicted_parity = 1'b1;
					end
				end
				
				bfm.read_serial_out(alu_status,C,flags,crc3,err_flags, parity);
				
				if((predicted_alu_status == alu_status) && (alu_status == OK)) begin : alu_ok
					if(predicted_C != C) begin : bad_data_match
						result = ERROR;
					end
					else if(predicted_flags != flags) begin : bad_flags_match
						result = ERROR;
					end
					else if(predicted_crc3 != crc3) begin : bad_crc3_match
						result = ERROR;
					end
				end
				else begin : alu_error
					if((predicted_err_flags != err_flags) || (predicted_parity != parity)) begin : bad_error_match
						result = ERROR;
					end
				end
				#200;
				
			end : score_loop
	
			if(result == OK) begin
				$display("PASSED");
			end
			else begin
				$display("FAILED");
			end
			
			#500;
			
		end
	endtask : execute
	
endclass : scoreboard