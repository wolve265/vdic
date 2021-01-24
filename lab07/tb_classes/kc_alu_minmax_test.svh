/******************************************************************************
* DVT CODE TEMPLATE: example test
* Created by kcislo on Jan 22, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_minmax_test
`define IFNDEF_GUARD_kc_alu_minmax_test

class  kc_alu_minmax_test extends kc_alu_base_test;

	`uvm_component_utils(kc_alu_minmax_test)

	function new(string name = "kc_alu_minmax_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	virtual function void build_phase(uvm_phase phase);
		uvm_config_db#(uvm_object_wrapper)::set(this,
			"m_env.m_kc_alu_agent.m_sequencer.run_phase",
			"minmax_sequence",
			kc_alu_minmax_sequence::type_id::get());

       	// Create the env
		super.build_phase(phase);
	endfunction

endclass

//// Define the default sequence
//class default_sequence_class extends kc_alu_base_sequence;
//
//	// Declare fields for this sequence
//	
//
//	`uvm_object_utils(default_sequence_class)
//
//	function new(string name = "default_sequence_class");
//		super.new(name);
//	endfunction : new
//
//	virtual task body();
//		// implement sequence body
//	endtask : body
//
//endclass : default_sequence_class

`endif // IFNDEF_GUARD_kc_alu_minmax_test
