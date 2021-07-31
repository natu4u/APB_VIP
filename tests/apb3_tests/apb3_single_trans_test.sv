`ifndef APB3_SINGLE_TRANS_TEST_SV
`define APB3_SINGLE_TRANS_TEST_SV

class apb3_single_trans_test extends apb_base_test;

	`uvm_component_utils(apb3_single_trans_test)

	function new(string name = "apb3_single_trans_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		cfg = apb_config::type_id::create("cfg");
		uvm_config_db#(apb_config)::set(this, "env.*", "cfg", cfg);
		env = apb_env::type_id::create("env", this);
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		apb3_single_trans_virt_seq seq = new();
		phase.raise_objection(this);
		super.run_phase(phase);
		seq.start(env.mst.sqr);
		phase.drop_objection(this);
	endtask: run_phase
endclass: apb3_single_trans_test

`endif