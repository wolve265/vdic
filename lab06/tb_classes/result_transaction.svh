class result_transaction extends uvm_transaction;
	
	`uvm_object_utils(result_transaction)

   	status_t alu_status;
	bit [31:0] C;
	bit [3:0] flags;
	bit [2:0] crc3;
	bit [5:0] err_flags;
	bit parity;

   	function new(string name="");
      	super.new(name);
   	endfunction : new

   	virtual function void do_copy(uvm_object rhs);
      	result_transaction copied_transaction_h;
	   	
      	if(rhs == null) 
    		`uvm_fatal("RESULT TRANSACTION", "Tried to copy from a null pointer")
      	
      	super.do_copy(rhs); // copy all parent class data
      	
      	if(!$cast(copied_transaction_h,rhs))
			`uvm_fatal("RESULT TRANSACTION", "Tried to copy wrong type.")
      	
      	alu_status = copied_transaction_h.alu_status;
		C = copied_transaction_h.C;
		flags = copied_transaction_h.flags;
		crc3 = copied_transaction_h.crc3;
		err_flags = copied_transaction_h.err_flags;
		parity = copied_transaction_h.parity;
   	endfunction : do_copy

   	virtual function string convert2string();
      	string s;
      	s = $sformatf("alu_status: %s C: %h flags: %b crc3: %h err_flags: %b parity: %b",
	      				alu_status.name(), C, flags, crc3,
	      				err_flags, parity);
      	return s;
   	endfunction : convert2string

   	virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      	result_transaction compared_transaction_h;
      	bit    same;
      	if (rhs==null) `uvm_fatal("RESULT TRANSACTION", 
                                  "Tried to do comparison to a null pointer");

      	
		if (!$cast(compared_transaction_h,rhs))
        	same = 0;
      	else
      		same = 	super.do_compare(rhs, comparer) &&
      				(compared_transaction_h.alu_status == alu_status) &&
      				(compared_transaction_h.C == C) &&
      				(compared_transaction_h.flags == flags) &&
      				(compared_transaction_h.crc3 == crc3) &&
      				(compared_transaction_h.err_flags == err_flags) &&
      				(compared_transaction_h.parity == parity);
      	return same;
   	endfunction : do_compare

endclass : result_transaction