`ifndef APB_ENV_SV
`define APB_ENV_SV

class apb_env extends uvm_env;

	apb_master_agent mst;
	apb_slave_agent slv;
	
	`uvm_component_utils(apb_env)

	function new(string name = "apb_env", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		mst = apb_master_agent::type_id::create("mst", this);
		slv = apb_slave_agent::type_id::create("slv", this);
	endfunction: build_phase

endclass: apb_env

`endif