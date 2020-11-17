class scoreboard extends uvm_component;
	
	`uvm_component_utils(scoreboard)
	
	virtual alu_bfm bfm;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1,"Failed to get BFM");
	endfunction : build_phase

	task run_phase(uvm_phase phase);
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
			
				bfm.read_serial_in(in_status,in_A,in_B,in_alu_op,in_crc4);
				
				bfm.predict_results(in_status, in_A, in_B, in_alu_op, in_crc4,
									predicted_alu_status, predicted_C, predicted_flags,
									predicted_crc3, predicted_err_flags, predicted_parity);
				
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
	endtask : run_phase
	
endclass : scoreboard