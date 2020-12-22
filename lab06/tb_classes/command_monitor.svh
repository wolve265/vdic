class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    virtual alu_bfm bfm;
    uvm_analysis_port #(random_command_transaction) ap;
	
    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
        	`uvm_fatal("COMMAND MONITOR", "Failed to get BFM")

        bfm.command_monitor_h = this;
		ap                    = new("ap",this);

    endfunction : build_phase

    function void write_to_monitor(random_command_transaction cmd);
        `uvm_info("COMMAND MONITOR", $sformatf("COMMAND MONITOR: A: %h  B: %h alu_op: %s test_op: %s crc4: %h",
	        		cmd.A, cmd.B, cmd.alu_op.name(), cmd.test_op.name(), cmd.crc4), UVM_HIGH)
        ap.write(cmd);
    endfunction : write_to_monitor

endclass : command_monitor