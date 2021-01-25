/******************************************************************************
* DVT CODE TEMPLATE: monitor
* Created by kcislo on Jan 22, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_result_monitor
`define IFNDEF_GUARD_kc_alu_result_monitor

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_result_monitor
//
//------------------------------------------------------------------------------

class kc_alu_result_monitor extends kc_alu_base_monitor;

	// Collected item
	protected kc_alu_result_item m_collected_item;

	// Collected item is broadcast on this port
	uvm_analysis_port #(kc_alu_result_item) m_collected_item_port;

	`uvm_component_utils(kc_alu_result_monitor)

	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Allocate collected_item.
		m_collected_item = kc_alu_result_item::type_id::create("m_collected_item", this);

		// Allocate collected_item_port.
		m_collected_item_port = new("m_collected_item_port", this);
	endfunction : new

	virtual protected task collect_items();
		@(negedge m_kc_alu_vif.clock);
		@(negedge m_kc_alu_vif.clock);
		forever begin
			
			m_kc_alu_vif.read_sout_done = 1'b0;
			m_kc_alu_vif.read_serial_out(m_collected_item.alu_status, m_collected_item.C, m_collected_item.flags, 
										 m_collected_item.crc3, m_collected_item.err_flags, m_collected_item.parity);
			m_kc_alu_vif.read_sout_done = 1'b1;
			
			@(negedge m_kc_alu_vif.clock);
			@(negedge m_kc_alu_vif.clock);
			
			`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_NONE)
			
			m_collected_item_port.write(m_collected_item);

			if (m_config_obj.m_checks_enable)
				perform_item_checks();
		end
	endtask : collect_items

endclass : kc_alu_result_monitor

`endif // IFNDEF_GUARD_kc_alu_result_monitor
