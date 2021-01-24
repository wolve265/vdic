/******************************************************************************
* DVT CODE TEMPLATE: package
* Created by kcislo on Jan 12, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

package kc_alu_pkg;

	// UVM macros
	`include "uvm_macros.svh"
	// UVM class library compiled in a package
	import uvm_pkg::*;
	
	// Typedefs
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
	
	// Functions CRC
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
	
	// Configuration object
	`include "kc_alu_config_obj.svh"
	// Sequence command item
	`include "kc_alu_cmd_item.svh"
	// Command monitor
	`include "kc_alu_monitor.svh"
	// Coverage Collector
	`include "kc_alu_coverage_collector.svh"
	// Driver
	`include "kc_alu_driver.svh"
	// Sequencer
	`include "kc_alu_sequencer.svh"
	// Agent
	`include "kc_alu_agent.svh"
	// Environment
	`include "kc_alu_env.svh"
	// Sequence library
	`include "kc_alu_seq_lib.svh"
	// Base test
	`include "kc_alu_base_test.svh"
	// Example test
	`include "kc_alu_example_test.svh"

endpackage : kc_alu_pkg
