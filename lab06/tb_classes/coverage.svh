class coverage extends uvm_subscriber #(sequence_item);
	
	`uvm_component_utils(coverage)
	
	protected alu_op_t cp_alu_op;
	protected test_op_t cp_test_op;
	protected bit[31:0] cp_A;
	protected bit[31:0] cp_B;
	protected bit cp_rst_before = 0;
	protected bit cp_carry;
	protected bit cp_overflow;
	protected bit cp_zero;
	protected bit cp_negative;
		
	protected status_t answer;
	
	covergroup op_cov;
		
		option.name = "cg_op_cov";
		
		rst_before_op: coverpoint cp_rst_before {
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
	
	function new(string name, uvm_component parent);
		super.new(name, parent);
		op_cov = new();
		error_cov = new();
		zero_ones_cov = new();
	endfunction : new
	
	function void write(sequence_item t);
			
		//predicted
		result_transaction predicted;
		
		//$display({"COVERAGE ", t.convert2string()});
		
		if(t.test_op == RST) begin
			cp_rst_before = 1'b1;
		end
		else begin : not_rst
		
			predicted = predict_results(t);
			
			//$display({"COVERAGE ", predicted.convert2string()});
			
			cp_A = t.A;
			cp_B = t.B;
			cp_alu_op = t.alu_op;
			cp_test_op = t.test_op;
			cp_negative = predicted.flags[0];
			cp_zero = predicted.flags[1];
			cp_overflow = predicted.flags[2];
			cp_carry = predicted.flags[3];
			
			if(predicted.err_flags[5] == 1'b1) begin : invalid_data
				cp_test_op = BAD_DATA;
			end : invalid_data
			else if(predicted.err_flags[4] == 1'b1) begin : invalid_crc
				cp_test_op = BAD_CRC;
			end : invalid_crc
			else if(predicted.err_flags[3] == 1'b1) begin : invalid_op
				cp_test_op = BAD_OP;
			end : invalid_op
			else begin : valid_data
				cp_test_op = GOOD;
			end : valid_data
			
			error_cov.sample();
			op_cov.sample();
			zero_ones_cov.sample();
			cp_rst_before = 1'b0;
			
		end : not_rst
		
	endfunction : write
	
endclass : coverage