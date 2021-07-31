`ifndef APB_SLAVE_SEQUENCER_SV
`define APB_SLAVE_SEQUENCER_SV

class apb_slave_sequencer extends uvm_sequencer#(apb_transaction);

	virtual apb_if vif;
	apb_config cfg;

	`uvm_component_utils(apb_slave_sequencer)

	function new(string name = "apb_slave_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction: new

endclass: apb_slave_sequencer

`endif