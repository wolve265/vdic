class coverage;
	
	virtual alu_bfm bfm;
	protected alu_op_t cp_alu_op;
	protected test_op_t cp_test_op;
	protected bit[31:0] cp_A;
	protected bit[31:0] cp_B;
	protected bit rst_before;
	protected bit cp_carry;
	protected bit cp_overflow;
	protected bit cp_zero;
	protected bit cp_negative;
		
	protected status_t answer;
	
	covergroup op_cov;
		
		option.name = "cg_op_cov";
		
		rst_before_op: coverpoint rst_before {
			bins false = {1'b0};
			bins true = {1'b1};		
		}
		
		alu_ops: coverpoint cp_alu_op {
			bins and_op = {AND};
			bins or_op = {OR};
			bins add_op = {ADD};
			bins sub_op = {SUB};
			ignore_bins unknown_op = {UNKNOWN};
		}
		
		test_ops: coverpoint cp_test_op {
			bins good_op = {GOOD};
			bins good_good = (GOOD [*2]);
			ignore_bins not_good_ops = {RST, BAD_OP, BAD_CRC, BAD_DATA};
		}
		
		all_test_ops: cross alu_ops, test_ops {
			
			//A1 test all operations
			bins A1_and_op = binsof(alu_ops.and_op) && binsof(test_ops.good_op);
			bins A1_or_op  = binsof(alu_ops.or_op)  && binsof(test_ops.good_op);
			bins A1_add_op = binsof(alu_ops.add_op) && binsof(test_ops.good_op);
			bins A1_sub_op = binsof(alu_ops.sub_op) && binsof(test_ops.good_op);
			
			//A2 all operations twice in a row
			bins A2_and2_op = binsof(alu_ops.and_op) && binsof(test_ops.good_good);
			bins A2_or2_op  = binsof(alu_ops.or_op)  && binsof(test_ops.good_good);
			bins A2_add2_op = binsof(alu_ops.add_op) && binsof(test_ops.good_good);
			bins A2_sub2_op = binsof(alu_ops.sub_op) && binsof(test_ops.good_good);
		}
		
		rst_before_good_op: cross rst_before_op, alu_ops, test_ops {	
			//A3 reset before all operations
			bins A3_and_rst_op = binsof(alu_ops.and_op) && binsof(test_ops.good_op);
			bins A3_or_rst_op  = binsof(alu_ops.or_op)  && binsof(test_ops.good_op);
			bins A3_add_rst_op = binsof(alu_ops.add_op) && binsof(test_ops.good_op);
			bins A3_sub_rst_op = binsof(alu_ops.sub_op) && binsof(test_ops.good_op);
		}
		
		c: coverpoint cp_carry {
			bins off = {1'b0};
			bins on = {1'b1};	
		}
		
		o: coverpoint cp_overflow {
			bins off = {1'b0};
			bins on = {1'b1};	
		}
		
		n: coverpoint cp_negative {
			bins off = {1'b0};
			bins on = {1'b1};	
		}
		
		z: coverpoint cp_zero {
			bins off = {1'b0};
			bins on = {1'b1};	
		}
		
		//A4 set all flags
		A4_carry: cross alu_ops, test_ops, c {
			ignore_bins and_on = binsof(alu_ops.and_op) && binsof(c.on);
			ignore_bins or_on = binsof(alu_ops.or_op) && binsof(c.on);
		}
		
		A4_overflow: cross alu_ops, test_ops, o {
			ignore_bins and_on = binsof(alu_ops.and_op) && binsof(o.on);
			ignore_bins or_on = binsof(alu_ops.or_op) && binsof(o.on);
		}
		
		A4_negative: cross alu_ops, test_ops, n {
			ignore_bins not_good_ops = binsof(test_ops.not_good_ops) && binsof(n.on);
		}
		
		A4_zero: cross alu_ops, test_ops, z {
			ignore_bins not_good_ops = binsof(test_ops.not_good_ops) && binsof(z.on);
		}
		
	endgroup
	
	covergroup zero_ones_cov;
		option.name = "cg_zero_ones";
		
		alu_ops: coverpoint cp_alu_op {
			bins and_op = {AND};
			bins or_op = {OR};
			bins add_op = {ADD};
			bins sub_op = {SUB};
			ignore_bins unknown_op = {UNKNOWN};
		}
		
		test_ops: coverpoint cp_test_op {
			bins good_op = {GOOD};
			ignore_bins not_good_ops = {RST, BAD_OP, BAD_CRC, BAD_DATA};
		}
		
		a_leg: coverpoint cp_A {
			bins zeros = {32'h00_00_00_00};
			bins others = {[32'h00_00_00_01:32'hFF_FF_FF_FE]};
			bins ones = {32'hFF_FF_FF_FF};
		}
		
		b_leg: coverpoint cp_B {
			bins zeros = {32'h00_00_00_00};
			bins others = {[32'h00_00_00_01:32'hFF_FF_FF_FE]};
			bins ones = {32'hFF_FF_FF_FF};
		}
		
		good_op_00_FF: cross alu_ops, test_ops, a_leg, b_leg {
			
			//B1 All zeros on input for all operations
			bins B1_and_00 = binsof(alu_ops.and_op) && binsof(test_ops.good_op) &&
							(binsof (b_leg.zeros) || binsof (a_leg.zeros));
			bins B1_or_00 = binsof(alu_ops.or_op) && binsof(test_ops.good_op) &&
							(binsof (b_leg.zeros) || binsof (a_leg.zeros));
			bins B1_add_00 = binsof(alu_ops.add_op) && binsof(test_ops.good_op) &&
							(binsof (b_leg.zeros) || binsof (a_leg.zeros));
			bins B1_sub_00 = binsof(alu_ops.sub_op) && binsof(test_ops.good_op) &&
							(binsof (b_leg.zeros) || binsof (a_leg.zeros));
			
			//B2 All ones on input for all operations
			bins B2_and_FF = binsof(alu_ops.and_op) && binsof(test_ops.good_op) &&
							(binsof (b_leg.ones) || binsof (a_leg.ones));
			bins B2_or_FF = binsof(alu_ops.or_op) && binsof(test_ops.good_op) &&
							(binsof (b_leg.ones) || binsof (a_leg.ones));
			bins B2_add_FF = binsof(alu_ops.add_op) && binsof(test_ops.good_op) &&
							(binsof (b_leg.ones) || binsof (a_leg.ones));
			bins B2_sub_FF = binsof(alu_ops.sub_op) && binsof(test_ops.good_op) &&
							(binsof (b_leg.ones) || binsof (a_leg.ones));
			
			ignore_bins others = binsof(a_leg.others) && binsof(b_leg.others);
			
		}
		
	endgroup
	
	covergroup error_cov;
		
		option.name = "cg_error_cov";
		
		errors: coverpoint cp_test_op {
			
			//C1 provide wrong number of data frames
			bins C1_error_data = {BAD_DATA};
			
			//C2 provide wrong crc
			bins C2_error_crc = {BAD_CRC};
			
			//C3 provide unknown ALU operation code
			bins C3_error_op = {BAD_OP};
			
			ignore_bins no_error = {GOOD, RST};
			
		}
		
	endgroup
	
	function new(virtual alu_bfm b);
		op_cov = new();
		error_cov = new();
		zero_ones_cov = new();
		bfm = b;
	endfunction : new
	
	protected task monitor_rst();
		forever begin
			@(posedge bfm.clk)
			if(bfm.rst_n == 1'b0) begin
				rst_before = 1'b1;
			end
		end
	endtask : monitor_rst
	
	protected task coverage_sample();
		if(answer == ERROR) begin
			error_cov.sample();
		end
		else begin
			op_cov.sample();
			zero_ones_cov.sample();
		end
		@(negedge bfm.clk);
		rst_before = 1'b0;
	endtask : coverage_sample
	
	task execute();
		//in
		status_t in_status;
		bit [3:0] crc4;
		bit [3:0] in_crc4;
		//predicted
		status_t predicted_alu_status;
		bit [31:0] predicted_C;
		bit [3:0] predicted_flags;
		bit [2:0] predicted_crc3;
		bit [5:0] predicted_err_flags;
		bit predicted_parity;
	
		fork
			monitor_rst();
		join_none 
		
		forever begin : result_predict_loop
			
			bfm.read_serial_in(in_status,cp_A,cp_B,cp_alu_op,in_crc4);
			
			bfm.predict_results(in_status, cp_A, cp_B, cp_alu_op, in_crc4,
								predicted_alu_status, predicted_C, {cp_carry, cp_overflow, cp_zero, cp_negative},
								predicted_crc3, predicted_err_flags, predicted_parity);
			
			if(predicted_err_flags[5] == 1'b1) begin : invalid_data
				cp_test_op = BAD_DATA;
				answer = ERROR;
			end : invalid_data
			else if(predicted_err_flags[4] == 1'b1) begin : invalid_crc
				cp_test_op = BAD_CRC;
				answer = ERROR;
			end : invalid_crc
			else if(predicted_err_flags[3] == 1'b1) begin : invalid_op
				cp_test_op = BAD_OP;
				answer = ERROR;
			end : invalid_op
			else begin : valid_data
				cp_test_op = GOOD;
				answer = OK;
			end : valid_data
			
			coverage_sample();
			@(negedge bfm.clk);
		end : result_predict_loop

	endtask : execute
	
endclass : coverage