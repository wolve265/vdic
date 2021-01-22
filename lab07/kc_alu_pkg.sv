/******************************************************************************
* DVT CODE TEMPLATE: package
* Created by kcislo on Jan 12, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

package kc_alu_pkg;

	

	// UVM macros
	`include "uvm_macros.svh"
	// UVM class library compiled in a package
	import uvm_pkg::*;

	// Configuration object
	`include "kc_alu_config_obj.svh"
	// Sequence item
	`include "kc_alu_item.svh"
	// Monitor
	`include "kc_alu_monitor.svh"
	// Coverage Collector
	`include "kc_alu_coverage_collector.svh"
	// Driver
	`include "kc_alu_driver.svh"
	// Sequencer
	`include "kc_alu_sequencer.svh"
	// Agent
	`include "kc_alu_agent.svh"
	// Environment
	`include "kc_alu_env.svh"
//	// Sequence library
//	`include "kc_alu_seq_lib.svh"

endpackage : kc_alu_pkg
