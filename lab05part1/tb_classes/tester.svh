virtual class tester extends uvm_component;
	
	`uvm_component_utils(tester)
	
	uvm_put_port #(random_command_transaction) command_port;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase
	
	task run_phase(uvm_phase phase);
		
		random_command_transaction command;
		integer counter = 1000;
		bit [2:0] alu_bit;
		
		phase.raise_objection(this);
		
		command = new("command");
		command.test_op = RST;
		command_port.put(command);
		
		while(counter != 0) begin : tester_loop
			counter--;
			command = random_command_transaction::type_id::create("command");
			if(!command.randomize())
				`uvm_fatal("TESTER", "Randomization failed");
			
			if(command.test_op == RST) begin
				counter++;
			end

			$cast(alu_bit, command.alu_op);
			command.crc4 = get_CRC4_d68({command.B, command.A, 1'b1, alu_bit});
			command_port.put(command);
		end : tester_loop
		
		#2000;
		
		phase.drop_objection(this);
		
	endtask : run_phase
	
endclass : tester