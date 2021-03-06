/******************************************************************************
* DVT CODE TEMPLATE: configuration object
* Created by kcislo on Jan 12, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_config_obj
`define IFNDEF_GUARD_kc_alu_config_obj

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_config_obj
//
//------------------------------------------------------------------------------

class kc_alu_config_obj extends uvm_object;

	// Agent id
	int unsigned m_agent_id = 0;

	// Active/passive
	uvm_active_passive_enum m_is_active = UVM_ACTIVE;

	// Enable/disable checks
	bit m_checks_enable = 1;

	// Enable/disable coverage
	bit m_coverage_enable = 1;

	// Add other configuration parameters that you might need
	

	// It's very important that you use these macros on all the configuration fields. If you miss any field it will not be propagated correctly.
	`uvm_object_utils_begin(kc_alu_config_obj)
		`uvm_field_int(m_agent_id, UVM_DEFAULT)
		`uvm_field_enum(uvm_active_passive_enum, m_is_active, UVM_DEFAULT)
		`uvm_field_int(m_checks_enable, UVM_DEFAULT)
		`uvm_field_int(m_coverage_enable, UVM_DEFAULT)
	`uvm_object_utils_end

	function new(string name = "kc_alu_config_obj");
		super.new(name);
	endfunction: new

endclass : kc_alu_config_obj

`endif // IFNDEF_GUARD_kc_alu_config_obj
