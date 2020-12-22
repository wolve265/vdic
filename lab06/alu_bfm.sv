interface alu_bfm;
	
	import alu_pkg::*;
	
	bit clk;
	bit rst_n;
	bit sin = 1;
	bit sout;
	bit read_sout_done = 0;
	
	initial begin : clk_gen
	  	clk = 0;
	  	forever begin : clk_frv
	     	#10;
	     	clk = ~clk;
	  	end
	end
	
	initial begin : do_initial_rst
		do_rst();
	end
	
	task do_rst();
		@(negedge clk);
		rst_n = 1'b0;
		@(negedge clk);
		rst_n = 1'b1;
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

	command_monitor command_monitor_h;
	
	initial begin : serial_in_monitor
		sequence_item cmd;
		status_t in_status;
		cmd = new("cmd");
		forever begin
			read_serial_in(in_status, cmd.A, cmd.B, cmd.alu_op, cmd.crc4);
			if(in_status == ERROR)
				cmd.test_op = BAD_DATA;
			else
				cmd.test_op = GOOD;
			while(read_sout_done != 1'b1)
				@(posedge clk);
			command_monitor_h.write_to_monitor(cmd);
		end
	end : serial_in_monitor
	
	always @(negedge rst_n) begin : rst_monitor
		sequence_item cmd;
		cmd = new("cmd");
		cmd.test_op = RST;
		if(command_monitor_h != null) //guard againts VCS time 0 negedge
			command_monitor_h.write_to_monitor(cmd);
	end : rst_monitor
	
	result_monitor result_monitor_h;
	
	initial begin : serial_out_monitor
		result_transaction result;
		result = new("result");
		@(negedge clk);
		@(negedge clk);
		forever begin
			read_sout_done = 1'b0;
			read_serial_out(result.alu_status, result.C, result.flags, result.crc3, result.err_flags, result.parity);
			read_sout_done = 1'b1;
			@(negedge clk);
			@(negedge clk);
			result_monitor_h.write_to_monitor(result);
		end
	end : serial_out_monitor
endinterface : alu_bfm