class min_max_test extends random_test;
	
	`uvm_component_utils(min_max_test)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		random_tester::type_id::set_type_override(min_max_tester::get_type());
	endfunction : build_phase

endclass : min_max_test