`ifndef APB_BASE_TEST_SV
`define APB_BASE_TEST_SV

class apb_base_test extends uvm_test;

	apb_env env;
	apb_config cfg;

	`uvm_component_utils(apb_base_test);

	function new(string name = "apb_base_test", uvm_component parent);
		super.new(name, parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction: build_phase

endclass: apb_base_test

`endif