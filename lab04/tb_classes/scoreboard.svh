class scoreboard extends uvm_subscriber #(result_s);
	
	`uvm_component_utils(scoreboard)

	uvm_tlm_analysis_fifo #(command_s) cmd_f;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		cmd_f = new("cmd_f", this);
	endfunction : build_phase

	function void write(result_s t);
		forever begin
			status_t result;
			//in
			status_t in_status;
			command_s cmd;
			//predicted
			result_s predicted;
			
			cmd.A = 0;
			cmd.B = 0;
			cmd.crc4 = 0;
			cmd.alu_op = UNKNOWN;
			cmd.test_op = RST;
			result = OK;
			do
				if(!cmd_f.try_get(cmd))
					$fatal(1, "Missing command in self checker");
			while(cmd.test_op == RST);

			predicted = predict_results(cmd);
			
			if((predicted.alu_status == t.alu_status) && (t.alu_status == OK)) begin : alu_ok
				if(predicted.C != t.C) begin : bad_data_match
					result = ERROR;
				end
				else if(predicted.flags != t.flags) begin : bad_flags_match
					result = ERROR;
				end
				else if(predicted.crc3 != t.crc3) begin : bad_crc3_match
					result = ERROR;
				end
			end
			else begin : alu_error
				if((predicted.err_flags != t.err_flags) || (predicted.parity != t.parity)) begin : bad_error_match
					result = ERROR;
				end
			end
				
			if(result == OK) begin
				$display("PASSED");
			end
			else begin
				$display("FAILED");
			end
		end
	endfunction : write
	
endclass : scoreboard