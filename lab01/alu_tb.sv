module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

typedef enum bit[2:0] {
   	AND  = 3'b000,
	OR = 3'b001,
  	ADD = 3'b100,
  	SUB = 3'b101
} op_t;
	
typedef enum bit[1:0] {
   	DATA  = 2'b00,
	CTL = 2'b01,
  	ERR = 2'b10
} packet_t;
	
	
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

   
//------------------------
// Tester main

initial begin : tester
	
   	bit [31:0] A;
	bit [31:0] B;
	bit [3:0] crc4;
	op_t op;
	
	#20 rst_n = 1'b1;
	#30;
	//repeat(1000) begin :tester_loop
		// A = getA();
		// B = getB();
		// op = getOP();
		do_crc4({B, A, 1'b1, op}, crc4);
		
		send_serial(A,B,op,crc4);
	//end : tester_loop
	#2000;
	$finish;
	
end : tester

task do_crc4(
	input bit[67:0] d,
	output bit [3:0] crc
	);
	bit [3:0] c;
	c = '1;
	crc[0] = d[66] ^ d[64] ^ d[63] ^ d[60] ^ d[56] ^ d[55] ^ d[54] ^ d[53] ^ d[51] ^ d[49] ^ d[48] ^ d[45] ^ d[41] ^ d[40] ^ d[39] ^ d[38] ^ d[36] ^ d[34] ^ d[33] ^ d[30] ^ d[26] ^ d[25] ^ d[24] ^ d[23] ^ d[21] ^ d[19] ^ d[18] ^ d[15] ^ d[11] ^ d[10] ^ d[9] ^ d[8] ^ d[6] ^ d[4] ^ d[3] ^ d[0] ^ c[0] ^ c[2];
    crc[1] = d[67] ^ d[66] ^ d[65] ^ d[63] ^ d[61] ^ d[60] ^ d[57] ^ d[53] ^ d[52] ^ d[51] ^ d[50] ^ d[48] ^ d[46] ^ d[45] ^ d[42] ^ d[38] ^ d[37] ^ d[36] ^ d[35] ^ d[33] ^ d[31] ^ d[30] ^ d[27] ^ d[23] ^ d[22] ^ d[21] ^ d[20] ^ d[18] ^ d[16] ^ d[15] ^ d[12] ^ d[8] ^ d[7] ^ d[6] ^ d[5] ^ d[3] ^ d[1] ^ d[0] ^ c[1] ^ c[2] ^ c[3];
    crc[2] = d[67] ^ d[66] ^ d[64] ^ d[62] ^ d[61] ^ d[58] ^ d[54] ^ d[53] ^ d[52] ^ d[51] ^ d[49] ^ d[47] ^ d[46] ^ d[43] ^ d[39] ^ d[38] ^ d[37] ^ d[36] ^ d[34] ^ d[32] ^ d[31] ^ d[28] ^ d[24] ^ d[23] ^ d[22] ^ d[21] ^ d[19] ^ d[17] ^ d[16] ^ d[13] ^ d[9] ^ d[8] ^ d[7] ^ d[6] ^ d[4] ^ d[2] ^ d[1] ^ c[0] ^ c[2] ^ c[3];
    crc[3] = d[67] ^ d[65] ^ d[63] ^ d[62] ^ d[59] ^ d[55] ^ d[54] ^ d[53] ^ d[52] ^ d[50] ^ d[48] ^ d[47] ^ d[44] ^ d[40] ^ d[39] ^ d[38] ^ d[37] ^ d[35] ^ d[33] ^ d[32] ^ d[29] ^ d[25] ^ d[24] ^ d[23] ^ d[22] ^ d[20] ^ d[18] ^ d[17] ^ d[14] ^ d[10] ^ d[9] ^ d[8] ^ d[7] ^ d[5] ^ d[3] ^ d[2] ^ c[1] ^ c[3];
endtask

task send_serial(
	input bit [31:0] A,
	input bit [31:0] B,
	input op_t op,
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
	
	packet_t packet_type;
	op_t op_type;
	bit [31:0] C;
	bit [3:0] flags;
	bit [2:0] crc3;
	bit [5:0] err_flags;
	bit parity;
	#50;
	read_serial_out(packet_type, op_type, C, flags, crc3, err_flags, parity);
	
end : scoreboard

task read_serial_out(
	output packet_t packet_type,
	output op_t op_type,
	output bit [31:0] C,
	output bit [3:0] flags,
	output bit [2:0] crc3,
	output bit [5:0] err_flags,
	output bit parity
	);
	bit [7:0] temp_d;
	read_packet(packet_type, temp_d);
	if(packet_type == CTL) begin : read_error_packet
		packet_type = ERR;
		err_flags = temp_d[6:1];
		parity = temp_d[0];
	end
	else begin : read_correct_packets
		C[31:24] = temp_d;
		read_packet(packet_type, C[23:16]);
		read_packet(packet_type, C[15:8]);
		read_packet(packet_type, C[7:0]);
		read_packet(packet_type, temp_d);
		flags = temp_d[6:3];
		crc3 = temp_d[2:0];
	end
endtask

task read_packet(
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
	@(negedge clk);
	for(int i=7; i>=0; i--) begin
		d[i] = sout;
		@(negedge clk);
	end
endtask

endmodule : top
