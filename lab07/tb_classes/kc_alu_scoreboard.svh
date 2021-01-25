/******************************************************************************
* DVT CODE TEMPLATE: coverage collector
* Created by kcislo on Jan 22, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_scoreboard
`define IFNDEF_GUARD_kc_alu_scoreboard

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_scoreboard
//
//------------------------------------------------------------------------------

class kc_alu_scoreboard extends uvm_component;

	// Configuration object
	protected kc_alu_config_obj m_config_obj;

	// Item collected from the command monitor
	protected kc_alu_cmd_item m_collected_cmd;
	
	// Item collected from the result monitor
	protected kc_alu_result_item m_collected_result;

	// Using suffix to handle more ports
	`uvm_analysis_imp_decl(_collected_cmd)
	`uvm_analysis_imp_decl(_collected_result)

	// Connection to the monitor
	uvm_analysis_imp_collected_cmd#(kc_alu_cmd_item, kc_alu_scoreboard) m_cmd_monitor_port;
	uvm_analysis_imp_collected_result#(kc_alu_result_item, kc_alu_scoreboard) m_result_monitor_port;

	`uvm_component_utils(kc_alu_scoreboard)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		m_cmd_monitor_port = new("m_cmd_monitor_port",this);
		m_result_monitor_port = new("m_result_monitor_port",this);

		// Get the configuration object
		if(!uvm_config_db#(kc_alu_config_obj)::get(this, "", "m_config_obj", m_config_obj))
			`uvm_fatal("NOCONFIG", {"Config object must be set for: ", get_full_name(), ".m_config_obj"})
	endfunction : build_phase

	function void write_collected_result(kc_alu_result_item result);

		m_collected_result = result;

	endfunction : write_collected_result

	function void write_collected_cmd(kc_alu_cmd_item cmd);
		
		kc_alu_result_item predicted;	
		m_collected_cmd = cmd;
		
		`uvm_info(get_full_name(), $sformatf("Command collected :\n%s", m_collected_cmd.sprint()), UVM_DEBUG)
		
		if(m_collected_cmd.test_op != RST) begin
			predicted = predict_results(m_collected_cmd);

			`uvm_info(get_full_name(), $sformatf("Predicted result :\n%s", predicted.sprint()), UVM_DEBUG)
			`uvm_info(get_full_name(), $sformatf("Result collected :\n%s", m_collected_result.sprint()), UVM_DEBUG)
			
			if(!predicted.compare(m_collected_result))
				`uvm_error("SCOREBOARD", "FAIL")
			else
				`uvm_info("SCOREBOARD", "PASS", UVM_DEBUG)
		end

	endfunction : write_collected_cmd

endclass : kc_alu_scoreboard

`endif // IFNDEF_GUARD_kc_alu_scoreboard
