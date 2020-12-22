class driver extends uvm_component;
    `uvm_component_utils(driver)

    virtual alu_bfm bfm;
    uvm_get_port #(random_command_transaction) command_port;
	
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            `uvm_fatal("DRIVER", "Failed to get BFM")
        command_port = new("command_port",this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        random_command_transaction command;
	    bit [2:0] alu_bit;
	    alu_op_t bad_alu_op = UNKNOWN;
	    
        forever begin : command_loop
            command_port.get(command);
	        
	        `uvm_info("DRIVER", $sformatf("DRIVER: A: %h  B: %h alu_op: %s test_op: %s crc4: %h",
	        		command.A, command.B, command.alu_op.name(), command.test_op.name(), command.crc4), UVM_HIGH)
		        
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
	        #1500;
        end : command_loop
    endtask : run_phase



endclass : driver