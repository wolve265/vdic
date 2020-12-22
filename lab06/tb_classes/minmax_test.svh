class minmax_test extends random_test;
	
	`uvm_component_utils(minmax_test)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		random_command_transaction::type_id::set_type_override(minmax_command_transaction::get_type());
	endfunction : build_phase

endclass : minmax_test