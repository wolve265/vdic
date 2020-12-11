class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

    virtual alu_bfm bfm;
    uvm_analysis_port #(result_transaction) ap;
	
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
	    
	    alu_agent_config alu_agent_config_h;
	    
        if(!uvm_config_db #(alu_agent_config)::get(this, "","config", alu_agent_config_h))
        	`uvm_fatal("RESULT MONITOR", "Failed to get CONFIG")
            
        alu_agent_config_h.bfm.result_monitor_h = this;
    	
		ap = new("ap",this);
        
    endfunction : build_phase

    function void write_to_monitor(result_transaction result);
        ap.write(result);
    endfunction : write_to_monitor

endclass : result_monitor