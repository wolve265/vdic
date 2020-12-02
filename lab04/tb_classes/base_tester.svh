virtual class base_tester extends uvm_component;
	
	`uvm_component_utils(base_tester)
	
	uvm_put_port #(command_s) command_port;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase
	
	pure virtual function alu_op_t get_alu_op();
	
	pure virtual function test_op_t get_test_op();

	pure virtual function bit [31:0] get_data();
	
	task run_phase(uvm_phase phase);
		
		command_s command;
		integer counter = 1000;
		bit [2:0] alu_bit;
		
		phase.raise_objection(this);
		command.test_op = RST;
		command_port.put(command);
		while(counter != 0) begin : tester_loop
			counter--;
			command.alu_op = get_alu_op();
			command.test_op = get_test_op();
			if(command.test_op == RST) begin
				counter++;
			end
			command.A = get_data();
			command.B = get_data();
			$cast(alu_bit, command.alu_op);
			command.crc4 = get_CRC4_d68({command.B, command.A, 1'b1, alu_bit});
			command_port.put(command);
		end : tester_loop
		
		#2000;
		
		phase.drop_objection(this);
		
	endtask : run_phase
	
endclass : base_tester