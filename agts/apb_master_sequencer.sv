`ifndef APB_MASTER_SEQUENCER_SV
`define APB_MASTER_SEQUENCER_SV

class apb_master_sequencer extends uvm_sequencer#(apb_transaction);

	virtual apb_if vif;
	apb_config cfg;

	`uvm_component_utils(apb_master_sequencer)

	function new(string name = "apb_master_sequencer", uvm_component parent);
		super.new(name, parent);
	endfunction: new

endclass: apb_master_sequencer

`endif