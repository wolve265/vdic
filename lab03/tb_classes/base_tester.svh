virtual class base_tester extends uvm_component;
	
	`uvm_component_utils(base_tester)

	virtual alu_bfm bfm;
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new
	
	function void build_phase(uvm_phase phase);
		if(!uvm_config_db#(virtual alu_bfm)::get(null, "*", "bfm", bfm))
			$fatal(1,"Failed to get BFM");
	endfunction : build_phase
	
	pure virtual function alu_op_t get_alu_op();
	
	pure virtual function test_op_t get_test_op();

	pure virtual function bit [31:0] get_data();
	
	task run_phase(uvm_phase phase);
		bit [31:0] A;
		bit [31:0] B;
		bit [3:0] crc4;
		alu_op_t alu_op;
		test_op_t test_op;
		integer counter = 1000;
		
		phase.raise_objection(this);
		
		bfm.do_rst();
		while(counter != 0) begin : tester_loop
			counter--;
			alu_op = get_alu_op();
			test_op = get_test_op();
			A = get_data();
			B = get_data();
			crc4 = bfm.get_CRC4_d68({B, A, 1'b1, alu_op});
			
			case(test_op)
				BAD_CRC: begin : case_bad_crc
					bfm.send_serial(A,B,alu_op,crc4+1);
				end
				BAD_DATA : begin : case_bad_data
					bfm.send_serial_7frames(A,B,alu_op,crc4+1);
				end
				BAD_OP : begin : case_bad_op
					bfm.send_serial(A,B,UNKNOWN,crc4);
				end
				RST: begin : case_rst
					counter++;
					bfm.do_rst();
				end
				default: begin : case_good
					bfm.send_serial(A,B,alu_op,crc4);
				end
			endcase
			#1500;
		end : tester_loop
		#2000;
		
		phase.drop_objection(this);
		
	endtask : run_phase
	
endclass : base_tester