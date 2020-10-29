module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

typedef enum bit[2:0] {
   	AND  		= 3'b000,
	OR 			= 3'b001,
  	ADD 		= 3'b100,
  	SUB 		= 3'b101,
  	UNKNOWN		= 3'b111
} alu_op_t;
	
typedef enum bit[2:0] {
	GOOD		= 3'b000,
	RST			= 3'b001,
	BAD_OP		= 3'b010,
	BAD_DATA	= 3'b011,
	BAD_CRC		= 3'b100
} test_op_t;
	
typedef enum bit {
   	DATA  		= 1'b0,
	CTL 		= 1'b1
} packet_t;
	
typedef enum bit {
	OK 			= 1'b0,
	ERROR 		= 1'b1		
} status_t;
	
	bit clk;
	bit rst_n;
	bit sin = 1;
	wire sout;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

mtm_Alu u_mtm_Alu (
	.clk  (clk), //posedge active clock
	.rst_n(rst_n), //synchronous reset active low
	.sin  (sin), //serial data input
	.sout (sout) //serial data output
);

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

alu_op_t cp_alu_op;
test_op_t cp_test_op;
bit[31:0] cp_A;
bit[31:0] cp_B;
bit rst_before;
bit cp_carry;
bit cp_overflow;
bit cp_zero;
bit cp_negative;
	
status_t answer;
status_t sample = ERROR;

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

initial begin : result_predict
	//in
	status_t in_status;
	bit [3:0] crc4;
	bit [3:0] in_crc4;
	//predicted
	bit [31:0] predicted_C;

	//clear predictions
	repeat(1000) begin : result_predict_loop
		sample = ERROR;
		predicted_C = '0;
		cp_carry = 1'b0;
		cp_overflow = 1'b0;
		cp_negative = 1'b0;
		cp_zero = 1'b0;
	
		read_serial_in(in_status,cp_A,cp_B,cp_alu_op,in_crc4);
		
		if(in_status == ERROR) begin : invalid_data
			cp_test_op = BAD_DATA;
			answer = ERROR;
		end
		else begin : valid_data
			cp_test_op = GOOD;
			answer = OK;
			case(cp_alu_op)
				AND: begin : and_op
					predicted_C = cp_B&cp_A;
					crc4 = get_CRC4_d68({cp_B, cp_A, 1'b1, cp_alu_op});
					cp_negative = predicted_C[31];//negative
					cp_zero = (predicted_C == 0);//zero
					cp_overflow = 0;//overflow
					cp_carry = 0;//carry
				end
				OR: begin : or_op
					predicted_C = cp_B|cp_A;
					crc4 = get_CRC4_d68({cp_B, cp_A, 1'b1, cp_alu_op});
					cp_negative = predicted_C[31];//negative
					cp_zero = (predicted_C == 0);//zero
					cp_overflow = 0;//overflow
					cp_carry = 0;//carry
				end
				ADD: begin : add_op
					{cp_carry,predicted_C} = cp_B+cp_A;
					crc4 = get_CRC4_d68({cp_B, cp_A, 1'b1, cp_alu_op});
					cp_negative = predicted_C[31];//negative
					cp_zero = (predicted_C == 0);//zero
					cp_overflow = ~(cp_A[31] ^ cp_B[31] ^ 1'b0) && (cp_A[31] ^ predicted_C[31]);//overflow
				end
				SUB: begin : sub_op
					crc4 = get_CRC4_d68({cp_B, cp_A, 1'b1, cp_alu_op});
					{cp_carry,predicted_C} = cp_B-cp_A;
					cp_negative = predicted_C[31];//negative
					cp_zero = (predicted_C == 0);//zero
					cp_overflow = (((~predicted_C[31]) && (~cp_A[31]) && cp_B[31]) || (predicted_C[31] && cp_A[31] && (~cp_B[31])));//overflow
				end
				default: begin: invalid_op
					cp_test_op = BAD_OP;
					answer = ERROR;
				end
			endcase
			if(in_crc4 != crc4) begin : invalid_crc
				cp_test_op = BAD_CRC;
				answer = ERROR;
			end
		end
		sample = OK;
		@(negedge clk);
	end : result_predict_loop
	
end : result_predict

always@(posedge clk) begin
	if(rst_n == 1'b0) begin
		rst_before <= 1;
	end
end

op_cov cg_op_cov;
error_cov cg_error_cov;
zero_ones_cov cg_0_F_cov;

initial begin : coverage
	
	cg_op_cov = new();
	cg_error_cov = new();
	cg_0_F_cov = new();
	
	forever begin : sample_cov
		@(negedge sample);
		if(answer == ERROR) begin
			cg_error_cov.sample();
		end
		else begin
			cg_op_cov.sample();
			cg_0_F_cov.sample();
		end
		@(negedge clk);
		rst_before = 1'b0;
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

//-----------------------------------
// Random data generation functions

function alu_op_t get_alu_op();
	bit [1:0] alu_op_choice;
	alu_op_choice = $random;
	case(alu_op_choice)
		2'b00: return AND;
		2'b01: return OR;
		2'b10: return ADD;
		2'b11: return SUB;
	endcase
endfunction

function test_op_t get_test_op();
	bit [3:0] test_op_choice;
	test_op_choice = $random;
	case(test_op_choice)
		4'b0000: return RST;
		4'b0001: return RST;
		4'b0010: return RST;
		4'b0011: return RST;
		4'b0100: return BAD_OP;  
		4'b0101: return BAD_CRC; 
		4'b0110: return BAD_DATA;
		4'b0111: return GOOD;
		4'b1000: return GOOD;
		4'b1001: return GOOD;
		4'b1010: return GOOD;
		4'b1011: return GOOD;
		4'b1100: return GOOD;
		4'b1101: return GOOD;
		4'b1110: return GOOD;
		4'b1111: return GOOD;
	endcase
endfunction

function bit [31:0] get_data();
	bit [1:0] zero_ones;
	zero_ones = $random;
	if(zero_ones == 2'b00)
		return 32'h00_00_00_00;
	else if(zero_ones == 2'b11)
		return 32'hFF_FF_FF_FF;
	else
		return $random;
endfunction

//--------------------------
// Crc4 computing function

function bit [3:0] get_CRC4_d68(bit [67:0] d);
	bit [3:0] c;
	bit [3:0] crc;
	
	c = '0;
	crc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
    crc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
    crc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
    crc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
	return crc;
	
endfunction

function bit [3:0] get_CRC3_d37(bit [36:0] d);
	bit [2:0] c;
	bit [2:0] crc;
	
	c = '0;
	crc[0] = d[35] ^ d[32] ^ d[31] ^ d[30] ^ d[28] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[18] ^ d[17] ^ d[16] ^ d[14] ^ d[11] ^ d[10] ^ d[9] ^ d[7] ^ d[4] ^ d[3] ^ d[2] ^ d[0] ^ c[1];
	crc[1] = d[36] ^ d[35] ^ d[33] ^ d[30] ^ d[29] ^ d[28] ^ d[26] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[16] ^ d[15] ^ d[14] ^ d[12] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[2] ^ d[1] ^ d[0] ^ c[1] ^ c[2];
	crc[2] = d[36] ^ d[34] ^ d[31] ^ d[30] ^ d[29] ^ d[27] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[17] ^ d[16] ^ d[15] ^ d[13] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[3] ^ d[2] ^ d[1] ^ c[0] ^ c[2];
	return crc;
	
endfunction

//--------------
// Tester main

initial begin : tester
	
   	bit [31:0] A;
	bit [31:0] B;
	bit [3:0] crc4;
	alu_op_t alu_op;
	test_op_t test_op;
	
	@(negedge clk);
	rst_n = 1'b1;
	repeat(1000) begin :tester_loop
		
		alu_op = get_alu_op();
		test_op = get_test_op();
		A = get_data();
		B = get_data();
		crc4 = get_CRC4_d68({B, A, 1'b1, alu_op});
		
		case(test_op)
			BAD_CRC: begin : case_bad_crc
				send_serial(A,B,alu_op,crc4+1);
			end
			BAD_DATA : begin : case_bad_data
				send_serial_7frames(A,B,alu_op,crc4+1);
			end
			BAD_OP : begin : case_bad_op
				send_serial(A,B,UNKNOWN,crc4);
			end
			RST: begin : case_rst
				@(negedge clk);
				rst_n = 1'b0;
				@(negedge clk);
				rst_n = 1'b1;
			end
			default: begin : case_good
				send_serial(A,B,alu_op,crc4);
			end
		endcase
		#1500;
	end : tester_loop
	#5000;
	$finish;
	
end : tester

task send_serial(
	input bit [31:0] A,
	input bit [31:0] B,
	input alu_op_t op,
	input bit [3:0] crc4
	);
	bit [3:0] op_bit;
	$cast(op_bit, op);
	send_data_packet(B[31:24]);
	send_data_packet(B[23:16]);
	send_data_packet(B[15:8]);
	send_data_packet(B[7:0]);
	send_data_packet(A[31:24]);
	send_data_packet(A[23:16]);
	send_data_packet(A[15:8]);
	send_data_packet(A[7:0]);
	send_ctl_packet({1'b0, op_bit, crc4});
endtask

task send_serial_7frames(
	input bit [31:0] A,
	input bit [31:0] B,
	input alu_op_t op,
	input bit [3:0] crc4
	);
	bit [3:0] op_bit;
	$cast(op_bit, op);
	send_data_packet(B[31:24]);
	send_data_packet(B[23:16]);
	send_data_packet(B[15:8]);
	send_data_packet(B[7:0]);
	send_data_packet(A[31:24]);
	send_data_packet(A[23:16]);
	send_data_packet(A[15:8]);
	send_ctl_packet({1'b0, op_bit, crc4});
endtask

task send_data_packet(
	input bit[7:0] d
	);
	send_packet({2'b00, d, 1'b1});
endtask

task send_ctl_packet(
	input bit[7:0] d
	);
	send_packet({2'b01, d, 1'b1});
endtask

task send_packet(
	input bit[10:0] d
	);
	for(int i=10; i>=0; i--) begin
		@(negedge clk) sin = d[i];
	end
endtask

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

initial begin : scoreboard
	status_t result;
	//in
	status_t in_status;
	bit [31:0] in_A;
	bit [31:0] in_B;
	alu_op_t in_alu_op;
	bit [3:0] crc4;
	bit [3:0] in_crc4;
	//out
	status_t alu_status;
	bit [31:0] C;
	bit [3:0] flags;
	bit [2:0] crc3;
	bit [5:0] err_flags;
	bit parity;
	//predicted
	status_t predicted_alu_status;
	bit [31:0] predicted_C;
	bit [3:0] predicted_flags;
	bit [2:0] predicted_crc3;
	bit [5:0] predicted_err_flags;
	bit predicted_parity;

	
	//clear predictions
	repeat(1000) begin : score_loop
		result = OK;
		predicted_alu_status = OK;
		predicted_C = '0;
		predicted_flags = '0;
		predicted_crc3 = '0;
		predicted_err_flags = '0;
		predicted_parity = '0;
	
		
		read_serial_in(in_status,in_A,in_B,in_alu_op,in_crc4);
		
		if(in_status == ERROR) begin : invalid_data
			predicted_alu_status = in_status;
			predicted_err_flags[5] = 1'b1;
			predicted_err_flags[2:0] = predicted_err_flags[5:3];
			predicted_parity = 1'b1;
		end
		else begin : valid_data
			case(in_alu_op)
				AND: begin : and_op
					predicted_C = in_B&in_A;
					crc4 = get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
					predicted_flags[0] = predicted_C[31];//negative
					predicted_flags[1] = (predicted_C == 0);//zero
					predicted_flags[2] = 0;//overflow
					predicted_flags[3] = 0;//carry
					predicted_crc3 = get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
				end
				OR: begin : or_op
					predicted_C = in_B|in_A;
					crc4 = get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
					predicted_flags[0] = predicted_C[31];//negative
					predicted_flags[1] = (predicted_C == 0);//zero
					predicted_flags[2] = 0;//overflow
					predicted_flags[3] = 0;//carry
					predicted_crc3 = get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
				end
				ADD: begin : add_op
					{predicted_flags[3],predicted_C} = in_B+in_A;
					crc4 = get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
					predicted_flags[0] = predicted_C[31];//negative
					predicted_flags[1] = (predicted_C == 0);//zero
					predicted_flags[2] = ~(in_A[31] ^ in_B[31] ^ 1'b0) && (in_A[31] ^ predicted_C[31]);//overflow
					predicted_crc3 = get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
				end
				SUB: begin : sub_op
					crc4 = get_CRC4_d68({in_B, in_A, 1'b1, in_alu_op});
					{predicted_flags[3],predicted_C} = in_B-in_A;
					predicted_flags[0] = predicted_C[31];//negative
					predicted_flags[1] = (predicted_C == 0);//zero
					predicted_flags[2] = (((~predicted_C[31]) && (~in_A[31]) && in_B[31]) || (predicted_C[31] && in_A[31] && (~in_B[31])));//overflow
					predicted_crc3 = get_CRC3_d37({predicted_C, 1'b0, predicted_flags});
				end
				default: begin: invalid_op
					predicted_alu_status = ERROR;
					predicted_err_flags[4] = 1'b1;
					predicted_err_flags[2:0] = predicted_err_flags[5:3];
					predicted_parity = 1'b1;
				end
			endcase
			if(in_crc4 != crc4) begin : invalid_crc
				predicted_alu_status = ERROR;
				predicted_err_flags[4] = 1'b1;
				predicted_err_flags[2:0] = predicted_err_flags[5:3];
				predicted_parity = 1'b1;
			end
		end
	
		read_serial_out(alu_status,C,flags,crc3,err_flags, parity);
		
		if((predicted_alu_status == alu_status) && (alu_status == OK)) begin : alu_ok
			if(predicted_C != C) begin : bad_data_match
				result = ERROR;
			end
			else if(predicted_flags != flags) begin : bad_flags_match
				result = ERROR;
			end
			else if(predicted_crc3 != crc3) begin : bad_crc3_match
				result = ERROR;
			end
		end
		else begin : alu_error
			if((predicted_err_flags != err_flags) || (predicted_parity != parity)) begin : bad_error_match
				result = ERROR;
			end
		end
		#200;
	end : score_loop
	
	if(result == OK) begin
		$display("PASSED");
	end
	else begin
		$display("FAILED");
	end
	
end : scoreboard

task automatic read_serial_in(
	output status_t in_status,
	output bit [31:0] A,
	output bit [31:0] B,
	output alu_op_t alu_op,
	output bit [3:0] crc4
	);
	
	bit [7:0] temp_d [0:7];
	packet_t packet_type;
	
	packet_type = DATA;
	in_status = OK;
	
	for(int i=7; i>=0; i--) begin : read_8_data_packets
		read_packet_in(packet_type, temp_d[i]);
		if(packet_type == CTL) begin : read_error_packet
			in_status = ERROR;
		end
	end
	
	if(in_status == OK) begin : read_good_packets
		B[31:24] = temp_d[7];
		B[23:16] = temp_d[6];
		B[15:8] = temp_d[5];
		B[7:0] = temp_d[4];
		A[31:24] = temp_d[3];
		A[23:16] = temp_d[2];
		A[15:8] = temp_d[1];
		A[7:0] = temp_d[0];
		read_packet_in(packet_type, temp_d[0]);
		case(temp_d[0][6:4])
			3'b000: alu_op = AND;
			3'b001: alu_op = OR;
			3'b100: alu_op = ADD;
			3'b101: alu_op = SUB;
			default: alu_op = UNKNOWN;
		endcase
		crc4 = temp_d[0][3:0];
	end

endtask

task automatic read_packet_in(
	output packet_t packet_type,
	output bit [7:0] d
	);
	//Detecting start bit
	while(sin != 0) @(posedge clk);
	
	//Defining if data or ctl
	@(posedge clk);
	if(sin == 0) begin
		packet_type = DATA;
	end
	else begin
		packet_type = CTL;
	end
	
	// Reading bits	
	for(int i=7; i>=0; i--) begin
		@(posedge clk);
		d[i] = sin;
	end
	@(posedge clk);
endtask

task read_serial_out(
	output status_t alu_status,
	output bit [31:0] C,
	output bit [3:0] flags,
	output bit [2:0] crc3,
	output bit [5:0] err_flags,
	output bit parity
	);
	
	bit [7:0] temp_d;
	packet_t packet_type;
	
	read_packet_out(packet_type, temp_d);
	if(packet_type == CTL) begin : read_error_packet
		alu_status = ERROR;
		err_flags = temp_d[6:1];
		parity = temp_d[0];
		C = '0;
		flags = '0;
		crc3 = '0;
	end
	else begin : read_correct_packets
		alu_status = OK;
		err_flags = '0;
		parity = '0;
		C[31:24] = temp_d;
		read_packet_out(packet_type, C[23:16]);
		read_packet_out(packet_type, C[15:8]);
		read_packet_out(packet_type, C[7:0]);
		read_packet_out(packet_type, temp_d);
		flags = temp_d[6:3];
		crc3 = temp_d[2:0];
	end
endtask

task read_packet_out(
	output packet_t packet_type,
	output bit [7:0] d
	);
	//Detecting start bit
	while(sout != 0) @(negedge clk);
	
	//Defining if data or ctl
	@(negedge clk);
	if(sout == 0) begin
		packet_type = DATA;
	end
	else begin
		packet_type = CTL;
	end
	// Reading bits
	
	for(int i=7; i>=0; i--) begin
		@(negedge clk);
		d[i] = sout;
	end
	@(negedge clk);
endtask

endmodule : top
