/******************************************************************************
* DVT CODE TEMPLATE: sequence item
* Created by kcislo on Jan 22, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_item
`define IFNDEF_GUARD_kc_alu_item

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_item
//
//------------------------------------------------------------------------------

class  kc_alu_item extends uvm_sequence_item;

	// This bit should be set when you want all the fields to be
	// constrained to some default values or ranges at randomization
	rand bit default_values;

	// Declare fields here
	
	rand bit [31:0] A;
	rand bit [31:0] B;
	rand alu_op_t 	alu_op;
	rand test_op_t 	test_op;
	bit [3:0] 		crc4;

	// it is a good practice to define a c_default_values_*
	// constraint for each field in which you constrain the field to some
	// default value or range. You can disable these constraints using
	// set_constraint_mode() before you call the randomize() function
	
	constraint data { A dist {[32'h00_00_00_00 : 32'hFF_FF_FF_FF]:=1};
                      B dist {[32'h00_00_00_00 : 32'hFF_FF_FF_FF]:=1}; }
	
	constraint alu  { alu_op dist {AND:=1, OR:=1, ADD:=1, SUB:=1, UNKNOWN:=0}; }
	
	constraint test { test_op dist {GOOD:=5, RST:=2, BAD_OP:=1, BAD_CRC:=1, BAD_DATA:=1}; }

	`uvm_object_utils_begin(kc_alu_item)
		`uvm_field_int(A, UVM_ALL_ON)
		`uvm_field_int(B, UVM_ALL_ON)
		`uvm_field_enum(alu_op_t, alu_op, UVM_ALL_ON)
		`uvm_field_enum(test_op_t, test_op, UVM_ALL_ON)
		`uvm_field_int(crc4, UVM_ALL_ON)
	`uvm_object_utils_end

	function new (string name = "kc_alu_item");
		super.new(name);
	endfunction : new

//	// UVM field macros don't work with unions and structs, you may have to override kc_alu_item.do_copy().
//	virtual function void do_copy(uvm_object rhs);
//		super.do_copy(rhs);
//	endfunction : do_copy
//
//	// UVM field macros don't work with unions and structs, you may have to override kc_alu_item.do_pack().
//	virtual function void do_pack(uvm_packer packer);
//		super.do_pack(packer);
//	endfunction : do_pack
//
//	// UVM field macros don't work with unions and structs, you may have to override kc_alu_item.do_unpack().
//	virtual function void do_unpack(uvm_packer packer);
//		super.do_unpack(packer);
//	endfunction : do_unpack
//
//	// UVM field macros don't work with unions and structs, you may have to override kc_alu_item.do_print().
//	virtual function void do_print(uvm_printer printer);
//		super.do_print(printer);
//	endfunction : do_print

endclass :  kc_alu_item

`endif // IFNDEF_GUARD_kc_alu_item
