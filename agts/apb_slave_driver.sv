`ifndef APB_SLAVE_DRIVER_SV
`define APB_SLAVE_DRIVER_SV

class apb_slave_driver extends uvm_driver#(apb_transaction);

	virtual apb_if vif;
	apb_config cfg;

	bit[31:0] mem [bit[31:0]];

	`uvm_component_utils(apb_slave_driver)

	function new(string name = "apb_slave_driver", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	task run_phase(uvm_phase phase);
		fork
			get_and_drive();
			reset_listener();
			drive_response();
		join_none
	endtask: run_phase

	task get_and_drive();
		forever begin
			seq_item_port.get_next_item(req);
			`uvm_info("APB_SLV_DRV", "sequencer got next item", UVM_HIGH)
			void'($cast(rsp, req.clone()));
			rsp.set_sequence_id(req.get_sequence_id());
			rsp.set_transaction_id(req.get_transaction_id());
			seq_item_port.item_done(rsp);
			`uvm_info("APB_SLV_DRV", "sequencer item_done_triggered", UVM_HIGH)
		end
	endtask: get_and_drive

	task reset_listener();
		`uvm_info("APB_SLV_DRV", "reset listener", UVM_HIGH)
		if(cfg.apb_verison == APB2) begin
			fork
				forever begin
					@(negedge vif.rstn);
					vif.prdata <= 0;
					this.mem.delete();
				end
			join_none
		end
		else if(cfg.apb_verison == APB3 || cfg.apb_verison == APB4) begin
			fork
				forever begin
					@(negedge vif.rstn);
					vif.prdata <= 0;
					vif.pslverr <= 0;
					vif.pready <= cfg.slave_pready_default_value;
					this.mem.delete();
				end
			join_none
		end
	endtask: reset_listener

	task drive_response();
		`uvm_info("APB_SLV_DRV", "drive response", UVM_HIGH)
		if(cfg.apb_verison == APB2) begin
			forever begin
				@(vif.cb_slv);
				if(vif.cb_slv.psel == 1 && vif.cb_slv.penable == 0) begin
					case(vif.cb_slv.pwrite)
						1: this.do_write_apb2();
						0: this.do_read_apb2();
						default: `uvm_error("APB_SLV_DRV", "pwrite is x or z")
					endcase
				end
				else begin
					this.do_idle_apb2();
				end
			end
		end
		else if(cfg.apb_verison == APB3) begin
			forever begin
				@(vif.cb_slv);
				if(vif.cb_slv.psel == 1 && vif.cb_slv.penable == 0) begin
					case(vif.cb_slv.pwrite)
						1: this.do_write_apb3();
						0: this.do_read_apb3();
						default: `uvm_error("APB_SLV_DRV", "pwrite is x or z")
					endcase
				end
				else begin
					this.do_idle_apb3();
				end
			end
		end
		else if(cfg.apb_verison == APB4) begin
			forever begin
				@(vif.cb_slv);
				if(vif.cb_slv.psel == 1 && vif.cb_slv.penable == 0) begin
					case(vif.cb_slv.pwrite)
						1: this.do_write_apb4();
						0: this.do_read_apb4();
						default: `uvm_error("APB_SLV_DRV", "pwrite is x or z")
					endcase
				end
				else begin
					this.do_idle_apb4();
				end
			end
		end
	endtask: drive_response

	task do_idle_apb2();
		`uvm_info("APB_SLV_DRV", "do idle", UVM_HIGH)
		vif.cb_slv.prdata <= 0;
	endtask: do_idle_apb2
		
	task do_write_apb2();
		bit[31:0] addr;
		bit[31:0] data;
		`uvm_info("APB_SLV_DRV", "do write", UVM_HIGH)
		wait(vif.penable == 1);
		addr = vif.cb_slv.paddr;
		data = vif.cb_slv.pwdata;
		mem[addr] = data;
		#1ps;
	endtask: do_write_apb2

	task do_read_apb2();
		bit[31:0] addr;
		bit[31:0] data;
		`uvm_info("APB_SLV_DRV", "do read", UVM_HIGH)
		wait(vif.penable == 1);
		addr = vif.cb_slv.paddr;
		if(mem.exists(addr))
			data = mem[addr];
		else
			data = DEFAULT_READ_VALUE;
		#1ps;
		vif.prdata <= data;
	endtask: do_read_apb2

	task do_idle_apb3();
		`uvm_info("APB_SLV_DRV", "do idle", UVM_HIGH)
		vif.cb_slv.prdata <= 0;
		vif.cb_slv.pready <= cfg.slave_pready_default_value;
		vif.cb_slv.pslverr <= 0;
	endtask: do_idle_apb3

	task do_write_apb3();
		bit[31:0] addr;
		bit[31:0] data;
		int pready_add_cycles = cfg.get_pready_additional_cycles();
		bit pslverr_status = cfg.get_pslverr_status();
		`uvm_info("APB_SLV_DRV", "do write", UVM_HIGH)
		wait(vif.penable == 1);
		addr = vif.cb_slv.paddr;
		data = vif.cb_slv.pwdata;
		mem[addr] = data;
		if(pready_add_cycles > 0) begin
			#1ps;
			vif.pready <= 0;
			repeat(pready_add_cycles) @(vif.cb_slv);
		end
		#1ps;
		vif.pready <= 1;
		vif.pslverr <= pslverr_status;
		fork
			begin
				@(vif.cb_slv);
				vif.cb_slv.pready <= cfg.slave_pready_default_value;
				vif.cb_slv.pslverr <= 0;
			end
		join_none
	endtask: do_write_apb3

	task do_read_apb3();
		bit[31:0] addr;
		bit[31:0] data;
		int pready_add_cycles = cfg.get_pready_additional_cycles();
		bit pslverr_status = cfg.get_pslverr_status();
		`uvm_info("APB_SLV_DRV", "do read", UVM_HIGH)
		wait(vif.penable == 1);
		addr = vif.cb_slv.paddr;
		if(mem.exists(addr))
			data = mem[addr];
		else
			data = DEFAULT_READ_VALUE;
		if(pready_add_cycles > 0) begin
			#1ps;
			vif.pready <= 0;
			repeat(pready_add_cycles) @(vif.cb_slv);
		end
		#1ps;
		vif.pready <= 1;
		vif.pslverr <= pslverr_status;
		vif.prdata <= data;
		fork
			begin
				@(vif.cb_slv);
				vif.cb_slv.pready <= cfg.slave_pready_default_value;
				vif.cb_slv.pslverr <= 0;
			end
		join_none
	endtask: do_read_apb3

	task do_idle_apb4();
		`uvm_info("APB_SLV_DRV", "do idle", UVM_HIGH)
		vif.cb_slv.prdata <= 0;
		vif.cb_slv.pready <= cfg.slave_pready_default_value;
		vif.cb_slv.pslverr <= 0;
	endtask: do_idle_apb4

	task do_write_apb4();
		bit[31:0] addr;
		bit[31:0] data;
		bit[3:0]  strb;
		bit[2:0]  prot;
		int pready_add_cycles = cfg.get_pready_additional_cycles();
		bit pslverr_status = cfg.get_pslverr_status();
		`uvm_info("APB_SLV_DRV", "do write", UVM_HIGH)
		wait(vif.penable == 1);
		addr = vif.cb_slv.paddr;
		strb = vif.cb_slv.pstrb;
		prot = vif.cb_slv.pprot;
		for(int i=0; i<4; i++) begin
			if(strb[i]) data[8*i+7-:8] = vif.cb_slv.pwdata[8*i+7-:8];
			else data[8*i+7-:8] = 8'b0;
		end
		mem[addr] = data;
		if(pready_add_cycles > 0) begin
			#1ps;
			vif.pready <= 0;
			repeat(pready_add_cycles) @(vif.cb_slv);
		end
		#1ps;
		vif.pready <= 1;
		vif.pslverr <= pslverr_status;
		fork
			begin
				@(vif.cb_slv);
				vif.cb_slv.pready <= cfg.slave_pready_default_value;
				vif.cb_slv.pslverr <= 0;
			end
		join_none
	endtask: do_write_apb4

	task do_read_apb4();
		bit[31:0] addr;
		bit[31:0] data;
		bit[2:0]  prot;
		int pready_add_cycles = cfg.get_pready_additional_cycles();
		bit pslverr_status = cfg.get_pslverr_status();
		`uvm_info("APB_SLV_DRV", "do read", UVM_HIGH)
		wait(vif.penable == 1);
		addr = vif.cb_slv.paddr;
		prot = vif.cb_slv.pprot;
		if(mem.exists(addr))
			data = mem[addr];
		else
			data = DEFAULT_READ_VALUE;
		if(pready_add_cycles > 0) begin
			#1ps;
			vif.pready <= 0;
			repeat(pready_add_cycles) @(vif.cb_slv);
		end
		#1ps;
		vif.pready <= 1;
		vif.pslverr <= pslverr_status;
		vif.prdata <= data;
		fork
			begin
				@(vif.cb_slv);
				vif.cb_slv.pready <= cfg.slave_pready_default_value;
				vif.cb_slv.pslverr <= 0;
			end
		join_none
	endtask: do_read_apb4

endclass: apb_slave_driver

`endif