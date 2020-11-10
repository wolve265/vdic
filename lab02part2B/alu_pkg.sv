package alu_pkg;
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
endpackage : alu_pkg