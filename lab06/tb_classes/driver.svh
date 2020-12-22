class driver extends uvm_driver #(sequence_item);
    `uvm_component_utils(driver)

    virtual alu_bfm bfm;
	
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("DRIVER", "Failed to get BFM")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        
        sequence_item command;
	    
	    bit [2:0] alu_bit;
	    alu_op_t bad_alu_op = UNKNOWN;
	    
	    void'(begin_tr(command));

        forever begin : command_loop

	        seq_item_port.get_next_item(command);

	        case(command.test_op)
				BAD_CRC: begin : case_bad_crc
					bfm.send_serial(command.A,command.B,command.alu_op,command.crc4+1);
				end
				BAD_DATA : begin : case_bad_data
					bfm.send_serial_7frames(command.A,command.B,command.alu_op,command.crc4);
				end
				BAD_OP : begin : case_bad_op
					$cast(alu_bit, bad_alu_op);
					command.crc4 = get_CRC4_d68({command.B, command.A, 1'b1, alu_bit});
					bfm.send_serial(command.A,command.B,bad_alu_op,command.crc4);
				end
				RST: begin : case_rst
					#1500;
					bfm.do_rst();
				end
				default: begin : case_good
					bfm.send_serial(command.A, command.B, command.alu_op, command.crc4);
				end
	        endcase
	        
	        seq_item_port.item_done();
	        #1500;
	        
        end : command_loop
        
        end_tr(command);
        
    endtask : run_phase

endclass : driver