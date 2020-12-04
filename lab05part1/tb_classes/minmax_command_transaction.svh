class minmax_command_transaction extends random_command_transaction;
	
	`uvm_component_utils(minmax_command_transaction)
	
	function new(string name="");
		super.new(name);
	endfunction : new
	
	constraint minmax_increase { A dist {8'h00:=10, [8'h01 : 8'hFE]:=2, 8'hFF:=10};
                 				 B dist {8'h00:=10, [8'h01 : 8'hFE]:=2, 8'hFF:=10};} 
	
endclass : minmax_command_transaction