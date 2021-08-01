`ifndef APB_MASTER_DRIVER_SV
`define APB_MASTER_DRIVER_SV

class apb_master_driver extends uvm_driver#(apb_transaction);

	virtual apb_if vif;
	apb_config cfg;

	`uvm_component_utils(apb_master_driver)

	function new(string name = "apb_master_driver", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	task run_phase(uvm_phase phase);
		fork
			get_and_drive();
			reset_listener();
		join_none
	endtask: run_phase

	task get_and_drive();
		if(cfg.apb_verison == APB2) begin
			forever begin
				seq_item_port.get_next_item(req);
				`uvm_info("APB_MST_DRV", "driver got next item", UVM_HIGH)
				this.drive_transaction_apb2(req);
				void'($cast(rsp, req.clone()));
				rsp.set_sequence_id(req.get_sequence_id());
				rsp.set_transaction_id(req.get_transaction_id());
				seq_item_port.item_done(rsp);
				`uvm_info("APB_MST_DRV", "driver item_done_triggered", UVM_HIGH)
			end
		end
		else if(cfg.apb_verison == APB3) begin
			forever begin
				seq_item_port.get_next_item(req);
				`uvm_info("APB_MST_DRV", "driver got next item", UVM_HIGH)
				this.drive_transaction_apb3(req);
				void'($cast(rsp, req.clone()));
				rsp.set_sequence_id(req.get_sequence_id());
				rsp.set_transaction_id(req.get_transaction_id());
				seq_item_port.item_done(rsp);
				`uvm_info("APB_MST_DRV", "driver item_done_triggered", UVM_HIGH)
			end
		end
		else if(cfg.apb_verison == APB4) begin
			forever begin
				seq_item_port.get_next_item(req);
				`uvm_info("APB_MST_DRV", "driver got next item", UVM_HIGH)
				this.drive_transaction_apb4(req);
				void'($cast(rsp, req.clone()));
				rsp.set_sequence_id(req.get_sequence_id());
				rsp.set_transaction_id(req.get_transaction_id());
				seq_item_port.item_done(rsp);
				`uvm_info("APB_MST_DRV", "driver item_done_triggered", UVM_HIGH)
			end
		end
	endtask: get_and_drive

	task drive_transaction_apb2(apb_transaction t);
		`uvm_info("APB_MST_DRV", "drive_transaction", UVM_HIGH)
		case(t.trans_kind)
			IDLE		: this.do_idle_apb2();
			WRITE 	: this.do_write_apb2(t);
			READ 		: this.do_read_apb2(t);
			default : `uvm_error("APB_MST_DRV", "unrecognized transaction type")
		endcase
	endtask: drive_transaction_apb2

	task do_write_apb2(apb_transaction t);
		`uvm_info("APB_MST_DRV", "do write", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.paddr <= t.addr;
		vif.cb_mst.pwrite <= 1;
		vif.cb_mst.psel <= 1;
		vif.cb_mst.penable <= 0;
		vif.cb_mst.pwdata <= t.data;
		@(vif.cb_mst);
		vif.cb_mst.penable <= 1;
		#1ps;
		t.trans_status = OK;
		repeat(t.idle_cycles) this.do_idle_apb2();
	endtask: do_write_apb2

	task do_read_apb2(apb_transaction t);
		`uvm_info("APB_MST_DRV", "do read", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.paddr <= t.addr;
		vif.cb_mst.pwrite <= 0;
		vif.cb_mst.psel <= 1;
		vif.cb_mst.penable <= 0;
		@(vif.cb_mst);
		vif.cb_mst.penable <= 1;
		#1ps;
		t.trans_status = OK;
		t.data = vif.prdata;
		repeat(t.idle_cycles) this.do_idle_apb2();
	endtask: do_read_apb2

	task do_idle_apb2();
		`uvm_info("APB_MST_DRV", "do idle", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.psel <= 0;
		vif.cb_mst.penable <= 0;
		vif.cb_mst.pwdata <= 0;
	endtask: do_idle_apb2

	task drive_transaction_apb3(apb_transaction t);
		`uvm_info("APB_MST_DRV", "drive_transaction", UVM_HIGH)
		case(t.trans_kind)
			IDLE		: this.do_idle_apb3();
			WRITE 	: this.do_write_apb3(t);
			READ 		: this.do_read_apb3(t);
			default : `uvm_error("APB_MST_DRV", "unrecognized transaction type")
		endcase
	endtask: drive_transaction_apb3

	task do_write_apb3(apb_transaction t);
		`uvm_info("APB_MST_DRV", "do write", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.paddr <= t.addr;
		vif.cb_mst.pwrite <= 1;
		vif.cb_mst.psel <= 1;
		vif.cb_mst.penable <= 0;
		vif.cb_mst.pwdata <= t.data;
		@(vif.cb_mst);
		vif.cb_mst.penable <= 1;
		#1ps;
		wait(vif.pready == 1);
		#1ps;
		if(vif.pslverr == 1) begin
			t.trans_status = ERROR;
			if(cfg.master_pslverr_status_severity == UVM_ERROR)
				`uvm_error("APB_MST_DRV", "write failed, pslverr")
			else
				`uvm_warning("APB_MST_DRV", "write failed, pslverr")
		end
		else begin
			t.trans_status = OK;
		end
		repeat(t.idle_cycles) this.do_idle_apb3();
	endtask: do_write_apb3

	task do_read_apb3(apb_transaction t);
		`uvm_info("APB_MST_DRV", "do read", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.paddr <= t.addr;
		vif.cb_mst.pwrite <= 0;
		vif.cb_mst.psel <= 1;
		vif.cb_mst.penable <= 0;
		@(vif.cb_mst);
		vif.cb_mst.penable <= 1;
		#1ps;
		wait(vif.pready == 1);
		#1ps;
		if(vif.pslverr == 1) begin
			t.trans_status = ERROR;
			if(cfg.master_pslverr_status_severity == UVM_ERROR)
				`uvm_error("APB_MST_DRV", "read failed, pslverr")
			else
				`uvm_warning("APB_MST_DRV", "read failed, pslverr")
		end
		else begin
			t.trans_status = OK;
		end
		t.data = vif.prdata;
		repeat(t.idle_cycles) this.do_idle_apb3();
	endtask: do_read_apb3

	task do_idle_apb3();
		`uvm_info("APB_MST_DRV", "do idle", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.psel <= 0;
		vif.cb_mst.penable <= 0;
		vif.cb_mst.pwdata <= 0;
	endtask: do_idle_apb3

	task drive_transaction_apb4(apb_transaction t);
		`uvm_info("APB_MST_DRV", "drive_transaction", UVM_HIGH)
		case(t.trans_kind)
			IDLE		: this.do_idle_apb4();
			WRITE 	: this.do_write_apb4(t);
			READ 		: this.do_read_apb4(t);
			default : `uvm_error("APB_MST_DRV", "unrecognized transaction type")
		endcase
	endtask: drive_transaction_apb4

	task do_write_apb4(apb_transaction t);
		`uvm_info("APB_MST_DRV", "do write", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.paddr <= t.addr;
		vif.cb_mst.pwrite <= 1;
		vif.cb_mst.psel <= 1;
		vif.cb_mst.penable <= 0;
		vif.cb_mst.pwdata <= t.data;
		vif.cb_mst.pprot <= t.prot;
		vif.cb_mst.pstrb <= t.strb;
		@(vif.cb_mst);
		vif.cb_mst.penable <= 1;
		#1ps;
		wait(vif.pready == 1);
		#1ps;
		if(vif.pslverr == 1) begin
			t.trans_status = ERROR;
			if(cfg.master_pslverr_status_severity == UVM_ERROR)
				`uvm_error("APB_MST_DRV", "write failed, pslverr")
			else
				`uvm_warning("APB_MST_DRV", "write failed, pslverr")
		end
		else begin
			t.trans_status = OK;
		end
		repeat(t.idle_cycles) this.do_idle_apb4();
	endtask: do_write_apb4

	task do_read_apb4(apb_transaction t);
		`uvm_info("APB_MST_DRV", "do read", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.paddr <= t.addr;
		vif.cb_mst.pwrite <= 0;
		vif.cb_mst.psel <= 1;
		vif.cb_mst.penable <= 0;
		vif.cb_mst.pstrb <= 4'b0;
		vif.cb_mst.pprot <= t.prot;
		@(vif.cb_mst);
		vif.cb_mst.penable <= 1;
		#1ps;
		wait(vif.pready == 1);
		#1ps;
		if(vif.pslverr == 1) begin
			t.trans_status = ERROR;
			if(cfg.master_pslverr_status_severity == UVM_ERROR)
				`uvm_error("APB_MST_DRV", "read failed, pslverr")
			else
				`uvm_warning("APB_MST_DRV", "read failed, pslverr")
		end
		else begin
			t.trans_status = OK;
		end
		t.data = vif.prdata;
		repeat(t.idle_cycles) this.do_idle_apb4();
	endtask: do_read_apb4

	task do_idle_apb4();
		`uvm_info("APB_MST_DRV", "do idle", UVM_HIGH)
		@(vif.cb_mst);
		vif.cb_mst.psel <= 0;
		vif.cb_mst.penable <= 0;
		vif.cb_mst.pwdata <= 0;
		vif.cb_mst.pstrb <= 0;
		vif.cb_mst.pprot <= 0;
	endtask: do_idle_apb4

	task reset_listener();
		`uvm_info("APB_MST_DRV", "reset listener", UVM_HIGH)
		if(cfg.apb_verison == APB2 || cfg.apb_verison == APB3) begin
			fork
				forever begin
					@(negedge vif.rstn);
					vif.paddr <= 0;
					vif.pwrite <= 0;
					vif.psel <= 0;
					vif.penable <= 0;
					vif.pwdata <= 0;
				end
			join_none
		end
		else if(cfg.apb_verison == APB4) begin
			fork
				forever begin
					@(negedge vif.rstn);
					vif.paddr <= 0;
					vif.pwrite <= 0;
					vif.psel <= 0;
					vif.penable <= 0;
					vif.pwdata <= 0;
					vif.pprot <= 0;
					vif.pstrb <= 0;
				end
			join_none
		end
	endtask: reset_listener

endclass: apb_master_driver

`endif