class min_max_tester extends random_tester;
	
	`uvm_component_utils(min_max_tester)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = $random;
		if(zero_ones[1] == 1'b0)
			return 32'h00_00_00_00;
		else if(zero_ones[1] == 1'b1)
			return 32'hFF_FF_FF_FF;
	endfunction : get_data
	
endclass : min_max_tester