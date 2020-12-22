class minmax_command_transaction extends random_command_transaction;
	
	`uvm_object_utils(minmax_command_transaction)
	
	function new(string name="");
		super.new(name);
	endfunction : new
	
	constraint minmax_increase { A dist {32'h00_00_00_00:=10, [32'h00_00_00_01 : 32'hFF_FF_FF_FF]:/1, 32'hFF_FF_FF_FF:=10};
                      			 B dist {32'h00_00_00_00:=10, [32'h00_00_00_01 : 32'hFF_FF_FF_FF]:/1, 32'hFF_FF_FF_FF:=10}; }
	
endclass : minmax_command_transaction