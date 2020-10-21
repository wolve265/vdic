module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

   	typedef enum bit[2:0] {and_op  = 3'b000,
                          or_op = 3'b001,
                          add_op = 3'b100,
                          sub_op = 3'b101,
                          rst_op = 3'b111} operation_t;
   	bit [31:0]   	A;
   	bit [31:0]   	B;
	bit [3:0]		CRC_4bit;		
   	bit          	clk;
   	bit          	rst_n;
   	bit          	sin;
	bit 			done;
   	wire         	sout;
   	bit [31:0]  	C;
	bit [3:0]		flags;
	bit [2:0]		CRC_3bit;
   	operation_t  	op_set;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

   mtm_Alu DUT (.sin, .sout, .clk, .rst_n);

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

   	covergroup op_cov;

      	option.name = "cg_op_cov";

		coverpoint op_set {
			
		 	// #A1 test all operations
		 	bins A1_all_ops[] = {[and_op : sub_op], rst_op};
			
	 		// #A2 test all operations after reset
		 	bins A2_rst_ops[] = (rst_op => [and_op : sub_op]);
			
		 	// #A3 test reset after all operations
		 	bins A3_ops_rst[] = ([and_op : sub_op] => rst_op);
			
		 	// #A4 two operations in row
		 	bins A4_twoops[] = ([and_op : sub_op] [* 2]);

		}

   	endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint op_set {
         ignore_bins null_ops = {rst_op};
      }

      a_leg: coverpoint A {
         bins zeros = {'h00000000};
         bins others= {['h00000001:'hFFFFFFFE]};
         bins ones  = {'hFFFFFFFF};
      }

      b_leg: coverpoint B {
         bins zeros = {'h00000000};
         bins others= {['h00000001:'hFFFFFFFE]};
         bins ones  = {'hFFFFFFFF};
      }

      B_op_00_FF:  cross a_leg, b_leg, all_ops {

         // #B1 simulate all zero input for all the operations

         bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_or_00 = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_sub_00 = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         // #B2 simulate all one input for all the operations

         bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_or_FF = binsof (all_ops) intersect {or_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_sub_FF = binsof (all_ops) intersect {sub_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

   endgroup

   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;

   initial begin : coverage
   
      oc = new();
      c_00_FF = new();
   
      forever begin : sample_cov
         @(negedge clk);
         oc.sample();
         c_00_FF.sample();
      end
   end : coverage

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

   initial begin : clk_gen
      clk = 0;
      forever begin : clk_frv
         #10;
         clk = ~clk;
      end
   end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

   function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
        3'b000 : return and_op;
        3'b001 : return or_op;
        3'b010 : return add_op;
        3'b011 : return sub_op;
        3'b100 : return rst_op;
        3'b101 : return rst_op;
        3'b110 : return rst_op;
        3'b111 : return rst_op;
      endcase // case (op_choice)
   endfunction : get_op

//---------------------------------
   function int get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 32'h00000000;
      else if (zero_ones == 2'b11)
        return 32'hFFFFFFFF;
      else
        return $random;
   endfunction : get_data

//------------------------

//---------------------------------
	function bit [3:0] get_CRC4_D68(bit [67:0] data);
		 // polynomial: x^4 + x^1 + 1
		 // data width: 68
		 
	endfunction : get_CRC4_D68
	
	function bit [2:0] get_CRC3_D37(bit [36:0] data);
		 // polynomial: x^4 + x^1 + 1
		 // data width: 68
	endfunction : get_CRC3_D37

//------------------------
// Tester main
   
   	initial begin : tester
  		done = 1'b0;
	  	sin = 1'b1;
      	rst_n = 1'b0;
      	@(negedge clk);
      	@(negedge clk);
      	rst_n = 1'b1;
      	repeat (1000) begin : tester_main
	     	done = 1'b0;
         	@(negedge clk);
         	op_set = get_op();
         	A = get_data();
         	B = get_data();
	     	CRC_4bit = get_CRC4_D68({B, A, 1'b1, op_set});
         	case (op_set) // handle the start signal
	           	rst_op: begin : case_rst_op
	              	rst_n = 1'b0;
	              	@(negedge clk);
	              	rst_n = 1'b1;
	           	end
	           	default: begin : case_send_packets_and_receive
	           		for(int i=4; i>0; i--) begin : send_B_data
	              		sin = 1'b0;
		           		@(negedge clk);
		           		sin = 1'b0;
		           		@(negedge clk);
		           		for(int j=0; j<8; j++) begin : send_byte
			           		sin = B[8*i-j-1];
			           		@(negedge clk);
		           		end
		           		sin = 1'b1;
		           		@(negedge clk);
	           		end
	           		for(int i=4; i>0; i--) begin : send_A_data
	              		sin = 1'b0;
		           		@(negedge clk);
		           		sin = 1'b0;
		           		@(negedge clk);
		           		for(int j=0; j<8; j++) begin : send_byte
			           		sin = A[8*i-j-1];
			           		@(negedge clk);
		           		end
		           		sin = 1'b1;
		           		@(negedge clk);
	           		end
	           		begin : send_ctl
	           			sin = 1'b0;
		           		@(negedge clk);
		           		sin = 1'b1;
		           		@(negedge clk);
		           		sin = 1'b0;
		           		@(negedge clk);
		           		for(int i=2; i>=0; i--) begin : send_op
			           		sin = op_set[i];
			           		@(negedge clk);
		           		end
		           		for(int i=3; i>=0; i--) begin : send_crc
			           		sin = CRC_4bit[i];
			           		@(negedge clk);
		           		end
		           		sin = 1'b1;
		           		@(negedge clk);
	           		end
	           		begin : receive_packets
		           		@(negedge sout);
		           		@(negedge clk);
		           		if(sout == 1'b1) begin : receive_error_ctl
			           		@(negedge clk);
			           		@(negedge clk);
			           		for(int i=3; i>=0; i--) begin : receive_flags
				           		flags[i] = sout;
				           		@(negedge clk);
			           		end
			           		for(int i=2; i>=0; i--) begin : receive_crc
				           		CRC_3bit[i] = sout;
				           		@(negedge clk);
			           		end
		           		end
		           		else begin : receive_data
			           		@(negedge clk);
			           		for(int j=0; j<8; j++) begin : receive_1byte
				           		C[32-j-1] = sout;
				           		@(negedge clk);
			           		end
			           		@(negedge clk);
			           		for(int i=3; i>0; i--) begin : receive_3bytes
				           		@(negedge sout);
				           		@(negedge clk);
				           		@(negedge clk);
				           		for(int j=0; j<8; j++) begin
					           		C[8*i-j-1] = sout;
					           		@(negedge clk);
				           		end
				           		@(negedge clk);
			           		end
			           		@(negedge sout);
			           		@(negedge clk);
			           		@(negedge clk);
			           		@(negedge clk);
			           		for(int i=3; i>=0; i--) begin : receive_flags
				           		flags[i] = sout;
				           		@(negedge clk);
			           		end
			           		for(int i=2; i>=0; i--) begin : receive_crc
				           		CRC_3bit[i] = sout;
				           		@(negedge clk);
			           		end
		           		end
		           		done = 1'b1;
	           		end
	       		end
         	endcase // case (op_set)
         	// print coverage after each loop
         	// can also be used to stop the simulation when cov=100%
         	// $strobe("%0t %0g",$time, $get_coverage());
      	end
      	$finish;
	end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

   	always @(posedge done) begin : scoreboard
		int predicted_C;
	  	bit [3:0] predicted_flags;
	   	bit [2:0] predicted_CRC_3bit;
   		
      	#1;
      	case (op_set)
        	and_op: predicted_C = A & B;
        	or_op:  predicted_C = A | B;
        	add_op: predicted_C = A + B;
        	sub_op: predicted_C = A - B;
      	endcase // case (op_set)
      	
      	predicted_flags[1] <= (predicted_C == 0) ? 1'b1 : 1'b0;
      	predicted_flags[0] <= (predicted_C[31] == 1'b1) ? 1'b1 : 1'b0;
      	predicted_CRC_3bit = get_CRC3_D37({predicted_C, 1'b0, predicted_flags});

      	if (op_set != rst_op)
        	if (predicted_C != C)
          	$error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                  	A, B, op_set.name(), C);

   	end : scoreboard
   
endmodule : top
