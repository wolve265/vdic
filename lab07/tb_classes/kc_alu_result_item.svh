/******************************************************************************
* DVT CODE TEMPLATE: sequence item
* Created by kcislo on Jan 24, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_result_item
`define IFNDEF_GUARD_kc_alu_result_item

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_result_item
//
//------------------------------------------------------------------------------

class  kc_alu_result_item extends uvm_sequence_item;

	// This bit should be set when you want all the fields to be
	// constrained to some default values or ranges at randomization
	rand bit default_values;
	
	status_t alu_status;
	bit [31:0] C;
	bit [3:0] flags;
	bit [2:0] crc3;
	bit [5:0] err_flags;
	bit parity;

	`uvm_object_utils_begin(kc_alu_result_item)
		`uvm_field_enum(status_t, alu_status, UVM_ALL_ON)
		`uvm_field_int(C, UVM_ALL_ON)
		`uvm_field_int(flags, UVM_ALL_ON)
		`uvm_field_int(crc3, UVM_ALL_ON)
		`uvm_field_int(err_flags, UVM_ALL_ON)
		`uvm_field_int(parity, UVM_ALL_ON)
	`uvm_object_utils_end

	function new (string name = "kc_alu_result_item");
		super.new(name);
	endfunction : new

//	// UVM field macros don't work with unions and structs, you may have to override kc_alu_result_item.do_copy().
//	virtual function void do_copy(uvm_object rhs);
//		super.do_copy(rhs);
//	endfunction : do_copy
//
//	// UVM field macros don't work with unions and structs, you may have to override kc_alu_result_item.do_pack().
//	virtual function void do_pack(uvm_packer packer);
//		super.do_pack(packer);
//	endfunction : do_pack
//
//	// UVM field macros don't work with unions and structs, you may have to override kc_alu_result_item.do_unpack().
//	virtual function void do_unpack(uvm_packer packer);
//		super.do_unpack(packer);
//	endfunction : do_unpack
//
//	// UVM field macros don't work with unions and structs, you may have to override kc_alu_result_item.do_print().
//	virtual function void do_print(uvm_printer printer);
//		super.do_print(printer);
//	endfunction : do_print

endclass :  kc_alu_result_item

`endif // IFNDEF_GUARD_kc_alu_result_item
