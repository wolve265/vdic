class scoreboard extends uvm_subscriber #(result_transaction);
	
	`uvm_component_utils(scoreboard)

	uvm_tlm_analysis_fifo #(sequence_item) cmd_f;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		cmd_f = new("cmd_f", this);
	endfunction : build_phase

	function void write(result_transaction t);
		string data_str;
		//in
		sequence_item cmd;
		//predicted
		result_transaction predicted;
		
		predicted = new("predicted");
		cmd = new("cmd");

		do
			if(!cmd_f.try_get(cmd))
				`uvm_fatal("SCOREBOARD", "Missing command in scoreboard")
		while(cmd.test_op == RST);
		
		`uvm_info("SCOREBOARD", {"KOMENDA ZARAZ PO GET: ",cmd.convert2string()}, UVM_HIGH)

		predicted = predict_results(cmd);
		
		data_str = {cmd.convert2string(), " ==> Actual ", t.convert2string(), " / Predicted ", predicted.convert2string()};
		
		if(!predicted.compare(t))
			`uvm_error("SCOREBOARD", {"FAIL: ",data_str})
		else
			`uvm_info("SCOREBOARD", {"PASS: ",data_str}, UVM_HIGH)
		
	endfunction : write
	
endclass : scoreboard