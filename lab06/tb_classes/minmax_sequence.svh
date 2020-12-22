class minmax_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(minmax_sequence)

    sequence_item command;

    function new(string name = "minmax_sequence");
        super.new(name);
    endfunction : new

    task body();
	    
        `uvm_info("SEQ_MINMAX","",UVM_MEDIUM)
        
        `uvm_create(command);
        
        repeat (1000) begin : random_loop
           `uvm_do_with(command, {A == 32'h00_00_00_00 || A == 32'hFF_FF_FF_FF; B == 32'h00_00_00_00 || B == 32'hFF_FF_FF_FF;})
        end : random_loop
        
    endtask : body

endclass : minmax_sequence
