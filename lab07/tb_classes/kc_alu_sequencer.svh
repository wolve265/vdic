/******************************************************************************
* DVT CODE TEMPLATE: sequencer
* Created by kcislo on Jan 22, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

`ifndef IFNDEF_GUARD_kc_alu_sequencer
`define IFNDEF_GUARD_kc_alu_sequencer

//------------------------------------------------------------------------------
//
// CLASS: kc_alu_sequencer
//
//------------------------------------------------------------------------------

class kc_alu_sequencer extends uvm_sequencer #(kc_alu_cmd_item);
	
	`uvm_component_utils(kc_alu_sequencer)

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

endclass : kc_alu_sequencer

`endif // IFNDEF_GUARD_kc_alu_sequencer
