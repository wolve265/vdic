class driver extends uvm_component;
    `uvm_component_utils(driver)

    virtual alu_bfm bfm;
    uvm_get_port #(command_s) command_port;

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
        command_port = new("command_port",this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        command_s command;
        shortint result;

        forever begin : command_loop
            command_port.get(command);
	        case(command.test_op)
				BAD_CRC: begin : case_bad_crc
					bfm.send_serial(command.A,command.B,command.alu_op,command.crc4+1);
				end
				BAD_DATA : begin : case_bad_data
					bfm.send_serial_7frames(command.A,command.B,command.alu_op,command.crc4);
				end
				BAD_OP : begin : case_bad_op
					bfm.send_serial(command.A,command.B,UNKNOWN,command.crc4);
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

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : driver