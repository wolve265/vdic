/******************************************************************************
* DVT CODE TEMPLATE: testbench top module
* Created by kcislo on Jan 12, 2021
* uvc_company = kc, uvc_name = alu
*******************************************************************************/

module alu_tb_top;

	// Import the UVM package
	import uvm_pkg::*;

	// Import the UVC that we have implemented
	import kc_alu_pkg::*;

	// The interface
	kc_alu_if vif();

	// DUT
	mtm_Alu u_mtm_Alu (
		.clk 	(vif.clock),  	// posedge active clock
		.rst_n 	(vif.reset),	// synchronous reset active low
		.sin 	(vif.sin),	// serial data input
		.sout 	(vif.sout)	// serial data output
	);

	initial begin
		// Propagate the interface to all the components that need it
		uvm_config_db#(virtual kc_alu_if)::set(uvm_root::get(), "*", "m_kc_alu_vif", vif);
		// Start the test
		run_test();
	end
endmodule
