class random_test extends alu_base_test;
	
	`uvm_component_utils(random_test)
	
	random_sequence random_h;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		random_h = new("random_h");
	endfunction : new

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		random_h.start(sequencer_h);
		phase.drop_objection(this);
	endtask : run_phase

endclass : random_test