module tester(alu_bfm bfm);
	import alu_pkg::*;
	
	//-----------------------------------
	// Random data generation functions
	
	function alu_op_t get_alu_op();
		bit [1:0] alu_op_choice;
		alu_op_choice = $random;
		case(alu_op_choice)
			2'b00: return AND;
			2'b01: return OR;
			2'b10: return ADD;
			2'b11: return SUB;
		endcase
	endfunction
	
	function test_op_t get_test_op();
		bit [3:0] test_op_choice;
		test_op_choice = $random;
		case(test_op_choice)
			4'b0000: return RST;
			4'b0001: return RST;
			4'b0010: return RST;
			4'b0011: return RST;
			4'b0100: return BAD_OP;  
			4'b0101: return BAD_CRC; 
			4'b0110: return BAD_DATA;
			4'b0111: return GOOD;
			4'b1000: return GOOD;
			4'b1001: return GOOD;
			4'b1010: return GOOD;
			4'b1011: return GOOD;
			4'b1100: return GOOD;
			4'b1101: return GOOD;
			4'b1110: return GOOD;
			4'b1111: return GOOD;
		endcase
	endfunction
	
	function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = $random;
		if(zero_ones == 2'b00)
			return 32'h00_00_00_00;
		else if(zero_ones == 2'b11)
			return 32'hFF_FF_FF_FF;
		else
			return $random;
	endfunction
	
	initial begin : tester_core
		bit [31:0] A;
		bit [31:0] B;
		bit [3:0] crc4;
		alu_op_t alu_op;
		test_op_t test_op;
		
		bfm.do_rst();
		repeat(1000) begin : tester_loop
			
			alu_op = get_alu_op();
			test_op = get_test_op();
			A = get_data();
			B = get_data();
			crc4 = bfm.get_CRC4_d68({B, A, 1'b1, alu_op});
			
			case(test_op)
				BAD_CRC: begin : case_bad_crc
					bfm.send_serial(A,B,alu_op,crc4+1);
				end
				BAD_DATA : begin : case_bad_data
					bfm.send_serial_7frames(A,B,alu_op,crc4+1);
				end
				BAD_OP : begin : case_bad_op
					bfm.send_serial(A,B,UNKNOWN,crc4);
				end
				RST: begin : case_rst
					bfm.do_rst();
				end
				default: begin : case_good
					bfm.send_serial(A,B,alu_op,crc4);
				end
			endcase
			#1500;
		end : tester_loop
		#20000;
		$finish;
	end	: tester_core
endmodule : tester