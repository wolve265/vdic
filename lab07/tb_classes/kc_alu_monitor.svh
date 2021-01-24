/******************************************************************************
* DVT CODE TEMPLATE: monitor
* Created by kcislo on Jan 22, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_monitor
`define IFNDEF_GUARD_kc_alu_monitor

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_monitor
//
//------------------------------------------------------------------------------

class kc_alu_monitor extends uvm_monitor;

	// The virtual interface to HDL signals.
	protected virtual kc_alu_if m_kc_alu_vif;

	// Configuration object
	protected kc_alu_config_obj m_config_obj;

	// Collected item
	protected kc_alu_cmd_item m_collected_item;

	// Collected item is broadcast on this port
	uvm_analysis_port #(kc_alu_cmd_item) m_collected_item_port;

	`uvm_component_utils(kc_alu_monitor)

	function new (string name, uvm_component parent);
		super.new(name, parent);

		// Allocate collected_item.
		m_collected_item = kc_alu_cmd_item::type_id::create("m_collected_item", this);

		// Allocate collected_item_port.
		m_collected_item_port = new("m_collected_item_port", this);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Get the interface
		if(!uvm_config_db#(virtual kc_alu_if)::get(this, "", "m_kc_alu_vif", m_kc_alu_vif))
			`uvm_fatal("NOVIF", {"virtual interface must be set for: ", get_full_name(), ".m_kc_alu_vif"})

		// Get the configuration object
		if(!uvm_config_db#(kc_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG",{"Config object must be set for: ",get_full_name(),".m_config_obj"})
	endfunction: build_phase

	virtual task run_phase(uvm_phase phase);
		process main_thread; // main thread
		process rst_mon_thread; // reset monitor thread

		// Start monitoring only after an initial reset pulse
		@(negedge m_kc_alu_vif.reset)
			do @(posedge m_kc_alu_vif.clock);
			while(m_kc_alu_vif.reset!==1);

		// Start monitoring
		forever begin
			fork
				// Start the monitoring thread
				begin
					main_thread=process::self();
					collect_items();
				end
				// Monitor the reset signal
				begin
					rst_mon_thread = process::self();
					@(negedge m_kc_alu_vif.reset) begin
						// Interrupt current item at reset
						if(main_thread) main_thread.kill();
						// Do reset
						reset_monitor();
					end
				end
			join_any

			if (rst_mon_thread) rst_mon_thread.kill();
		end
	endtask : run_phase

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
			
			`uvm_info(get_full_name(), $sformatf("Item collected :\n%s", m_collected_item.sprint()), UVM_MEDIUM)
			
			// Do not write collected item too fast - wait for sout_done
			while(m_kc_alu_vif.read_sout_done != 1'b1)
				@(posedge m_kc_alu_vif.clock);
			
			m_collected_item_port.write(m_collected_item);

			if (m_config_obj.m_checks_enable)
				perform_item_checks();
		end
	endtask : collect_items

	virtual protected function void perform_item_checks();
		// Perform item checks here
	endfunction : perform_item_checks

	virtual protected function void reset_monitor();
		// Reset monitor specific state variables (e.g. counters, flags, buffers, queues, etc.)
	endfunction : reset_monitor

endclass : kc_alu_monitor

`endif // IFNDEF_GUARD_kc_alu_monitor
