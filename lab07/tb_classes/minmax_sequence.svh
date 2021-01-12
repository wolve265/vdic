class minmax_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(minmax_sequence)

    sequence_item command;
	
    function new(string name = "minmax_sequence");
        super.new(name);
    endfunction : new

    task body();
	    
        `uvm_info("SEQ_MINMAX","",UVM_MEDIUM)
        
        `uvm_create(command);
        
        `uvm_do_with(command, {test_op == RST;})
        
        repeat (1000) begin : minmax_loop
            `uvm_do_with(command, {A dist {32'h00_00_00_00:=1, [32'h00_00_00_01 : 32'hFF_FF_FF_FE]:/1, 32'hFF_FF_FF_FF:=1};
	           					   B dist {32'h00_00_00_00:=1, [32'h00_00_00_01 : 32'hFF_FF_FF_FE]:/1, 32'hFF_FF_FF_FF:=1};})
        end : minmax_loop
        
    endtask : body

endclass : minmax_sequence
