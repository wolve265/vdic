/******************************************************************************
* DVT CODE TEMPLATE: monitor
* Created by kcislo on Jan 22, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_cmd_monitor
`define IFNDEF_GUARD_kc_alu_cmd_monitor

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_cmd_monitor
//
//------------------------------------------------------------------------------

class kc_alu_cmd_monitor extends kc_alu_base_monitor;

	// Collected item
	protected kc_alu_cmd_item m_collected_item;

	// Collected item is broadcast on this port
	uvm_analysis_port #(kc_alu_cmd_item) m_collected_item_port;

	`uvm_component_utils(kc_alu_cmd_monitor)

	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Allocate collected_item.
		m_collected_item = kc_alu_cmd_item::type_id::create("m_collected_item", this);

		// Allocate collected_item_port.
		m_collected_item_port = new("m_collected_item_port", this);
	endfunction : new

	virtual protected task collect_items();
		forever begin
			status_t in_status;
			// Reading serial input
			m_kc_alu_vif.read_serial_in(in_status, m_collected_item.A, m_collected_item.B, m_collected_item.alu_op, m_collected_item.crc4);
			// Checking if BAD_DATA occurs
			if(in_status == ERROR)
				m_collected_item.test_op = BAD_DATA;
			else
				m_collected_item.test_op = GOOD;
			
			`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_NONE)
			
			// Do not write collected item too fast - wait for sout_done
			while(m_kc_alu_vif.read_sout_done != 1'b1)
				@(posedge m_kc_alu_vif.clock);
			
			m_collected_item_port.write(m_collected_item);

			if (m_config_obj.m_checks_enable)
				perform_item_checks();
		end
	endtask : collect_items

endclass : kc_alu_cmd_monitor

`endif // IFNDEF_GUARD_kc_alu_cmd_monitor
