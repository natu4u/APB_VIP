`ifndef APB_SLAVE_MONITOR_SV
`define APB_SLAVE_MONITOR_SV

class apb_slave_monitor extends uvm_monitor;

	virtual apb_if vif;
	apb_config cfg;
	apb_transaction trans_collected;

	uvm_analysis_port#(apb_transaction) item_slv_mon_ana_port;

	`uvm_component_utils(apb_slave_monitor)

	function new(string name = "apb_slave_monitor", uvm_component parent);
		super.new(name, parent);
		item_slv_mon_ana_port = new("item_slv_mon_ana_port", this);
		trans_collected = new("trans_collected");
	endfunction: new

	task run_phase(uvm_phase phase);
		fork
			monitor_trans();
		join_none
	endtask: run_phase

	task monitor_trans();
		if(cfg.apb_verison == APB2) begin
			forever begin
				collect_trans_apb2();
				item_slv_mon_ana_port.write(trans_collected);
			end
		end
		else if(cfg.apb_verison == APB3) begin
			forever begin
				collect_trans_apb3();
				item_slv_mon_ana_port.write(trans_collected);
			end
		end
		else if(cfg.apb_verison == APB4) begin
			forever begin
				collect_trans_apb4();
				item_slv_mon_ana_port.write(trans_collected);
			end
		end
	endtask: monitor_trans

	task collect_trans_apb2();
		void'(this.begin_tr(trans_collected));
  	@(vif.cb_mon);
  	void'(this.begin_tr(trans_collected));
  	this.end_tr(trans_collected);
	endtask: collect_trans_apb2

	task collect_trans_apb3();
		void'(this.begin_tr(trans_collected));
  	@(vif.cb_mon);
  	void'(this.begin_tr(trans_collected));
  	this.end_tr(trans_collected);
	endtask: collect_trans_apb3

	task collect_trans_apb4();
		void'(this.begin_tr(trans_collected));
  	@(vif.cb_mon);
  	void'(this.begin_tr(trans_collected));
  	this.end_tr(trans_collected);
	endtask: collect_trans_apb4

endclass: apb_slave_monitor

`endif