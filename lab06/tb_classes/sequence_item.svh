class sequence_item extends uvm_sequence_item;

	function new(string name="sequence_item");
		super.new(name);
	endfunction : new
	
	rand bit [31:0] A;
	rand bit [31:0] B;
	rand alu_op_t 	alu_op;
	rand test_op_t 	test_op;
	bit [3:0] 		crc4;
	
	constraint data { A dist {32'h00_00_00_00:=1, [32'h00_00_00_01 : 32'hFF_FF_FF_FF]:=1, 32'hFF_FF_FF_FF:=1};
                      B dist {32'h00_00_00_00:=1, [32'h00_00_00_01 : 32'hFF_FF_FF_FF]:=1, 32'hFF_FF_FF_FF:=1}; }
	
	constraint alu  { alu_op dist {AND:=1, OR:=1, ADD:=1, SUB:=1, UNKNOWN:=0}; }
	
	constraint test { test_op dist {GOOD:=5, RST:=2, BAD_OP:=1, BAD_CRC:=1, BAD_DATA:=1}; }
	
	`uvm_object_utils_begin(sequence_item)
        `uvm_field_int(A, UVM_ALL_ON)
        `uvm_field_int(B, UVM_ALL_ON)
        `uvm_field_enum(alu_op_t, alu_op, UVM_ALL_ON)
        `uvm_field_enum(test_op_t, test_op, UVM_ALL_ON)
        `uvm_field_int(crc4, UVM_ALL_ON)
	`uvm_object_utils_end
	
	function string convert2string();
      	string s;
      	s = $sformatf("A: %h  B: %h alu_op: %s test_op: %s crc4: %h",
	      				A, B, alu_op.name(), test_op.name(), crc4);
      	return s;
   	endfunction : convert2string

endclass : sequence_item