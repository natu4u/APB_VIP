`ifndef APB_MASTER_AGENT_SV
`define APB_MASTER_AGENT_SV

class apb_master_agent extends uvm_agent;

	virtual apb_if vif;
	apb_config cfg;

	apb_master_driver drv;
	apb_master_sequencer sqr;
	apb_master_monitor mon;

	`uvm_component_utils(apb_master_agent)

	function new(string name = "apb_master_agent", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		void'(uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif));
		if(this.vif == null)
			`uvm_error("APB_MST_AGT", "didn't get vif object from config db")
		void'(uvm_config_db#(apb_config)::get(this, "", "cfg", cfg));
		if(this.cfg == null)
			`uvm_error("APB_MST_AGT", "didn't get cfg object from config db")
		mon = apb_master_monitor::type_id::create("mon", this);
		mon.vif = this.vif;
		mon.cfg = this.cfg;
		if(this.cfg.is_active == UVM_ACTIVE) begin
			drv = apb_master_driver::type_id::create("drv", this);
			sqr = apb_master_sequencer::type_id::create("sqr", this);
			drv.vif = this.vif;
			drv.cfg = this.cfg;
			sqr.vif = this.vif;
			sqr.cfg = this.cfg;
		end
	endfunction: build_phase

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		if(this.cfg.is_active == UVM_ACTIVE)
			drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction: connect_phase

endclass: apb_master_agent

`endif