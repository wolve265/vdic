/******************************************************************************
* DVT CODE TEMPLATE: interface
* Created by kcislo on Jan 12, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

//------------------------------------------------------------------------------
//
// INTERFACE: kc_alu_if
//
//------------------------------------------------------------------------------

// Just in case you need them
`include "uvm_macros.svh"

interface kc_alu_if(clock, reset);

	// Just in case you need it
	import uvm_pkg::*;
	import kc_alu_pkg::*;
	
	// Clock and reset signals
	input clock;
	input reset;

	// Flags to enable/disable assertions and coverage
	bit checks_enable=1;
	bit coverage_enable=1;

	// Interface signals - DUT
	
	bit reset_dut = 1;
	bit sin = 1;
	bit sout;
	bit read_sout_done = 1;
	
	// Interface tasks
	
	task do_rst_dut();
		@(negedge clock);
		reset_dut = 1'b0;
		@(negedge clock);
		reset_dut = 1'b1;
	endtask
	
	task read_serial_in(
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
	
	task read_packet_in(
		output packet_t packet_type,
		output bit [7:0] d
		);
		//Detecting start bit
		while(sin != 0) @(posedge clock);
		
		//Defining if data or ctl
		@(posedge clock);
		if(sin == 0) begin
			packet_type = DATA;
		end
		else begin
			packet_type = CTL;
		end
		
		// Reading bits	
		for(int i=7; i>=0; i--) begin
			@(posedge clock);
			d[i] = sin;
		end
		@(posedge clock);
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
		while(sout != 0) @(negedge clock);
		
		//Defining if data or ctl
		@(negedge clock);
		if(sout == 0) begin
			packet_type = DATA;
		end
		else begin
			packet_type = CTL;
		end
		// Reading bits
		
		for(int i=7; i>=0; i--) begin
			@(negedge clock);
			d[i] = sout;
		end
		@(negedge clock);
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
			@(negedge clock) sin = d[i];
		end
	endtask

//	//You can add covergroups in interfaces
//	covergroup signal_coverage@(posedge clock);
//		//add coverpoints here
//	endgroup
//	// You must instantiate the covergroup to collect coverage
//	signal_coverage sc=new;
//
//	// You can add SV assertions in interfaces
//	my_assertion:assert property (
//			@(posedge clock) disable iff (reset === 1'b0 || !checks_enable)
//			valid |-> (data!==8'bXXXX_XXXX)
//		)
//	else
//		`uvm_error("ERR_TAG","Error")

endinterface : kc_alu_if
