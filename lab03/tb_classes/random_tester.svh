class random_tester extends base_tester;
	
	`uvm_component_utils(random_tester)
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function alu_op_t get_alu_op();
		bit [1:0] alu_op_choice;
		alu_op_choice = $random;
		case(alu_op_choice)
			2'b00: return AND;
			2'b01: return OR;
			2'b10: return ADD;
			2'b11: return SUB;
		endcase
	endfunction : get_alu_op
	
	function test_op_t get_test_op();
		bit [3:0] test_op_choice;
		test_op_choice = $random;
		case(test_op_choice)
			4'b0000: return RST;
			4'b0001: return RST;
			4'b0010: return RST;
			4'b0011: return RST;
			4'b0100: return BAD_OP;  
			4'b0101: return BAD_CRC; 
			4'b0110: return BAD_DATA;
			4'b0111: return GOOD;
			4'b1000: return GOOD;
			4'b1001: return GOOD;
			4'b1010: return GOOD;
			4'b1011: return GOOD;
			4'b1100: return GOOD;
			4'b1101: return GOOD;
			4'b1110: return GOOD;
			4'b1111: return GOOD;
		endcase
	endfunction : get_test_op

	function bit [31:0] get_data();
		bit [1:0] zero_ones;
		zero_ones = $random;
		if(zero_ones == 2'b00)
			return 32'h00_00_00_00;
		else if(zero_ones == 2'b11)
			return 32'hFF_FF_FF_FF;
		else
			return $random;
	endfunction : get_data
	
endclass : random_tester