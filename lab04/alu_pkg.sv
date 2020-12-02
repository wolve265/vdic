`timescale 1ns/1ps

package alu_pkg;
	
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	typedef enum bit[2:0] {
	   	AND  		= 3'b000,
		OR 			= 3'b001,
	  	ADD 		= 3'b100,
	  	SUB 		= 3'b101,
	  	UNKNOWN		= 3'b111
	} alu_op_t;
		
	typedef enum bit[2:0] {
		GOOD		= 3'b000,
		RST			= 3'b001,
		BAD_OP		= 3'b010,
		BAD_DATA	= 3'b011,
		BAD_CRC		= 3'b100
	} test_op_t;
		
	typedef enum bit {
	   	DATA  		= 1'b0,
		CTL 		= 1'b1
	} packet_t;
		
	typedef enum bit {
		OK 			= 1'b0,
		ERROR 		= 1'b1		
	} status_t;
	
	typedef struct packed {
		bit [31:0] A;
		bit [31:0] B;
		alu_op_t alu_op;
		test_op_t test_op;
		bit [3:0] crc4;
	} command_s;
	
	typedef struct packed {
		status_t alu_status;
		bit [31:0] C;
		bit [3:0] flags;
		bit [2:0] crc3;
		bit [5:0] err_flags;
		bit parity;
	} result_s;
	
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
	
	function  result_s predict_results(command_s command);
		
		result_s predicted;
		bit [3:0] crc4;
		bit [2:0] alu_bit;
		
		predicted.alu_status = OK;
		predicted.C = '0;
		predicted.flags = '0;
		predicted.crc3 = '0;
		predicted.err_flags = '0;
		predicted.parity = '0;
		crc4 = '0;
				
		if(command.test_op == BAD_DATA) begin : invalid_data
			predicted.alu_status = ERROR;
			predicted.err_flags[5] = 1'b1;
			predicted.err_flags[2:0] = predicted.err_flags[5:3];
			predicted.parity = 1'b1;
		end
		else begin : valid_data
			
			case(command.alu_op)
				AND: begin : and_op
					predicted.C = command.B&command.A;
					predicted.flags[0] = predicted.C[31];//negative
					predicted.flags[1] = (predicted.C == 0);//zero
					predicted.flags[2] = 0;//overflow
					predicted.flags[3] = 0;//carry
					predicted.crc3 = get_CRC3_d37({predicted.C, 1'b0, predicted.flags});
					
				end
				OR: begin : or_op
					predicted.C = command.B|command.A;
					predicted.flags[0] = predicted.C[31];//negative
					predicted.flags[1] = (predicted.C == 0);//zero
					predicted.flags[2] = 0;//overflow
					predicted.flags[3] = 0;//carry
					predicted.crc3 = get_CRC3_d37({predicted.C, 1'b0, predicted.flags});
				end
				ADD: begin : add_op
					{predicted.flags[3],predicted.C} = command.B+command.A;
					predicted.flags[0] = predicted.C[31];//negative
					predicted.flags[1] = (predicted.C == 0);//zero
					predicted.flags[2] = ~(command.A[31] ^ command.B[31] ^ 1'b0) && (command.A[31] ^ predicted.C[31]);//overflow
					predicted.crc3 = get_CRC3_d37({predicted.C, 1'b0, predicted.flags});
				end
				SUB: begin : sub_op
					{predicted.flags[3],predicted.C} = command.B-command.A;
					predicted.flags[0] = predicted.C[31];//negative
					predicted.flags[1] = (predicted.C == 0);//zero
					predicted.flags[2] = (((~predicted.C[31]) && (~command.A[31]) && command.B[31]) || (predicted.C[31] && command.A[31] && (~command.B[31])));//overflow
					predicted.crc3 = get_CRC3_d37({predicted.C, 1'b0, predicted.flags});
				end
				UNKNOWN: begin: invalid_op
					predicted.alu_status = ERROR;
					predicted.err_flags = 6'b001001;
					predicted.parity = 1'b1;
				end
			endcase // case(command.alu_op)
			$cast(alu_bit, command.alu_op);
			crc4 = get_CRC4_d68({command.B, command.A, 1'b1, alu_bit});
			if(command.crc4 != crc4) begin : invalid_crc
				predicted.alu_status = ERROR;
				predicted.err_flags[4] = 1'b1;
				predicted.err_flags[2:0] = predicted.err_flags[5:3];
				predicted.parity = 1'b1;
			end : invalid_crc
		end : valid_data
		return predicted;
	endfunction : predict_results
	
	`include "coverage.svh"
	`include "base_tester.svh"
	`include "random_tester.svh"
	`include "min_max_tester.svh"
	`include "scoreboard.svh"
	`include "result_monitor.svh"
	`include "command_monitor.svh"
	`include "driver.svh"
	
	`include "env.svh"
	
	`include "random_test.svh"
	`include "min_max_test.svh"

endpackage : alu_pkg