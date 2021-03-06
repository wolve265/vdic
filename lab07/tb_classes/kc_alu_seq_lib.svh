/******************************************************************************
* DVT CODE TEMPLATE: sequence library
* Created by kcislo on Jan 22, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_seq_lib
`define IFNDEF_GUARD_kc_alu_seq_lib

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_base_sequence
//
//------------------------------------------------------------------------------

virtual class kc_alu_base_sequence extends uvm_sequence#(kc_alu_cmd_item);
	
	`uvm_declare_p_sequencer(kc_alu_sequencer)

	function new(string name="kc_alu_base_sequence");
		super.new(name);
	endfunction : new

	virtual task pre_body();
		uvm_phase starting_phase = get_starting_phase();
		if (starting_phase!=null) begin
			`uvm_info(get_type_name(),
				$sformatf("%s pre_body() raising %s objection",
					get_sequence_path(),
					starting_phase.get_name()), UVM_MEDIUM)
			starting_phase.raise_objection(this);
		end
	endtask : pre_body

	virtual task post_body();
		uvm_phase starting_phase = get_starting_phase();
		if (starting_phase!=null) begin
			`uvm_info(get_type_name(),
				$sformatf("%s post_body() dropping %s objection",
					get_sequence_path(),
					starting_phase.get_name()), UVM_MEDIUM)
			starting_phase.drop_objection(this);
		end
	endtask : post_body

endclass : kc_alu_base_sequence

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_example_sequence
//
//------------------------------------------------------------------------------

class kc_alu_random_sequence extends kc_alu_base_sequence;

	// Add local random fields and constraints here

	`uvm_object_utils(kc_alu_random_sequence)

	function new(string name="kc_alu_random_sequence");
		super.new(name);
	endfunction : new

	virtual task body();
		// HINT Do not forget to reset the dut
		
		// dut reset first
		`uvm_do_with(req, {test_op == RST;})
		
		repeat(2000) begin : random_loop
			`uvm_rand_send(req)
		end : random_loop
		
//		get_response(rsp);
	endtask : body

endclass : kc_alu_random_sequence

class kc_alu_minmax_sequence extends kc_alu_base_sequence;

	// Add local random fields and constraints here

	`uvm_object_utils(kc_alu_minmax_sequence)

	function new(string name="kc_alu_minmax_sequence");
		super.new(name);
	endfunction : new

	virtual task body();
		// HINT Do not forget to reset the dut
		
		// dut reset first
		`uvm_do_with(req, {test_op == RST;})
		
		repeat(1000) begin : random_loop
			`uvm_do_with(req, {A dist {32'h00_00_00_00:=1, [32'h00_00_00_01 : 32'hFF_FF_FF_FE]:/1, 32'hFF_FF_FF_FF:=1};
	           				   B dist {32'h00_00_00_00:=1, [32'h00_00_00_01 : 32'hFF_FF_FF_FE]:/1, 32'hFF_FF_FF_FF:=1};})
		end : random_loop
		
//		get_response(rsp);
	endtask : body

endclass : kc_alu_minmax_sequence

`endif // IFNDEF_GUARD_kc_alu_seq_lib
