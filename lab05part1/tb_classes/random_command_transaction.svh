class random_command_transaction extends uvm_transaction;
	
	`uvm_object_utils(random_command_transaction)
	
	function new(string name="");
		super.new(name);
	endfunction : new
	
	rand bit [31:0] A;
	rand bit [31:0] B;
	rand alu_op_t 	alu_op;
	rand test_op_t 	test_op;
	bit [3:0] 		crc4;
	
	constraint data { A dist {32'h00_00_00_00:=1, [32'h00_00_00_01 : 32'hFF_FF_FF_FF]:/1, 32'hFF_FF_FF_FF:=1};
                      B dist {32'h00_00_00_00:=1, [32'h00_00_00_01 : 32'hFF_FF_FF_FF]:/1, 32'hFF_FF_FF_FF:=1}; }
	
	constraint alu  { alu_op dist {AND:=1, OR:=1, ADD:=1, SUB:=1}; }
	
	constraint test { test_op dist {GOOD:=10, RST:=3, BAD_OP:=1, BAD_CRC:=1, BAD_DATA:=1}; }
	
	virtual function void do_copy(uvm_object rhs);
		random_command_transaction copied_transaction_h;

  		if(rhs == null) 
    		`uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")
      
  		super.do_copy(rhs); // copy all parent class data

  		if(!$cast(copied_transaction_h,rhs))
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

  		A = copied_transaction_h.A;
  		B = copied_transaction_h.B;
  		alu_op = copied_transaction_h.alu_op;
  		test_op = copied_transaction_h.test_op;
  		crc4 = copied_transaction_h.crc4;
   	endfunction : do_copy

   	virtual function random_command_transaction clone_me();
      	random_command_transaction clone;
      	uvm_object tmp;

      	tmp = this.clone();
      	$cast(clone, tmp);
      	return clone;
   	endfunction : clone_me
   	
   	virtual function string convert2string();
      	string s;
      	s = $sformatf("A: %h  B: %h alu_op: %s test_op: %s crc4: %h",
	      				A, B, alu_op.name(), test_op.name(), crc4);
      	return s;
   	endfunction : convert2string
   	
   	virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      	random_command_transaction compared_transaction_h;
      	bit   same;
      
      	if (rhs==null) `uvm_fatal("COMMAND TRANSACTION", 
                                  "Tried to do comparison to a null pointer");
      
      	if (!$cast(compared_transaction_h,rhs))
        	same = 0;
      	else
        	same = 	super.do_compare(rhs, comparer) && 
               	   	(compared_transaction_h.A == A) &&
					(compared_transaction_h.B == B) &&
					(compared_transaction_h.alu_op == alu_op) &&
	   				(compared_transaction_h.test_op == test_op) &&
	 	   			(compared_transaction_h.crc4 == crc4);
               
      	return same;
   	endfunction : do_compare
   	

	
endclass : random_command_transaction