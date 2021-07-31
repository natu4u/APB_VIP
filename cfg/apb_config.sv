`ifndef APB_CONFIG_SV
`define APB_CONFIG_SV

class apb_config extends uvm_object;

	// config APB verison: APB2 APB3 APB4
	apb_verison_t apb_verison = APB3;

	// config parameter
	uvm_active_passive_enum is_active = UVM_ACTIVE;

	// master config parameter
	uvm_severity master_pslverr_status_severity = UVM_WARNING;

	// slave config parameter
	rand bit slave_pready_random = 0;
	rand bit slave_pslverr_random = 0;
	rand bit slave_pready_default_value = 0;

	`uvm_object_utils(apb_config)

	function new(string name = "apb_config");
		super.new(name);
	endfunction: new

	virtual function get_pready_additional_cycles();
		if(slave_pready_random)
			return $urandom_range(0,2);
		else
			return 0;
	endfunction: get_pready_additional_cycles

	virtual function get_pslverr_status();
		if(slave_pslverr_random && $urandom_range(0, 20) == 0)
			return 1;
		else
			return 0;
	endfunction: get_pslverr_status

endclass: apb_config

`endif