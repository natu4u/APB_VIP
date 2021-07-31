`ifndef APB_MASTER_SEQ_LIB_SV
`define APB_MASTER_SEQ_LIB_SV

class apb_master_base_sequence extends uvm_sequence#(apb_transaction);

	`uvm_object_utils(apb_master_base_sequence)

	function new(string name = "apb_master_base_sequence");
		super.new(name);
	endfunction: new

endclass: apb_master_base_sequence

class apb_mst_single_wt_seq extends apb_master_base_sequence;
	rand bit[31:0]  	addr;
	rand bit[31:0]		data;
	rand bit[3:0] 		strb;
	rand bit[2:0]			prot;
	apb_trans_status	trans_status;

	`uvm_object_utils(apb_mst_single_wt_seq)

	function new(string name = "apb_mst_single_wt_seq");
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info("APB_MST_SEQ", "apb_mst_single_wt_seq started", UVM_HIGH)
		`uvm_do_with(req, {
			trans_kind == WRITE;
			addr == local::addr;
			data == local::data;
			strb == local::strb;
			prot == local::prot;
		})
		get_response(rsp);
		trans_status = rsp.trans_status;
		`uvm_info("APB_MST_SEQ", "apb_mst_single_wt_seq finished", UVM_HIGH)
	endtask: body

endclass: apb_mst_single_wt_seq

class apb_mst_single_rd_seq extends apb_master_base_sequence;
	rand bit[31:0] 		addr;
	rand bit[31:0]		data;
	bit[3:0] 					strb = 4'b0;
	rand bit[2:0]			prot;
	apb_trans_status 	trans_status;

	`uvm_object_utils(apb_mst_single_rd_seq)

	function new(string name = "apb_mst_single_rd_seq");
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info("APB_MST_SEQ", "apb_mst_single_rd_seq started", UVM_HIGH)
		`uvm_do_with(req, {
			trans_kind == READ;
			addr == local::addr;
			strb == local::strb;
			prot == local::prot;
		})
		get_response(rsp);
		trans_status = rsp.trans_status;
		data = rsp.data;
		`uvm_info("APB_MST_SEQ", "apb_mst_single_rd_seq finished", UVM_HIGH)
	endtask: body

endclass: apb_mst_single_rd_seq

class apb_mst_wt_rd_seq extends apb_master_base_sequence;
	rand bit[31:0] 		addr;
	rand bit[31:0] 		data;
	rand bit[3:0] 		strb;
	rand bit[2:0]			prot;
	rand int 					idle_cycles;
	apb_trans_status 	trans_status;
	constraint cstr{
		idle_cycles == 0;
	}

	`uvm_object_utils(apb_mst_wt_rd_seq)

	function new(string name = "apb_mst_wt_rd_seq");
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info("APB_MST_SEQ", "apb_mst_wt_rd_seq started", UVM_HIGH)
		`uvm_do_with(req, {
			trans_kind == WRITE;
			addr == local::addr;
			data == local::data;
			strb == local::strb;
			prot == local::prot;
			idle_cycles == local::idle_cycles;
		})
		get_response(rsp);
		`uvm_do_with(req, {
			trans_kind == READ;
			addr == local::addr;
			strb == 4'b0;
			prot == local::prot;
		})
		get_response(rsp);
		data = rsp.data;
		trans_status = rsp.trans_status;
		`uvm_info("APB_MST_SEQ", "apb_mst_wt_rd_seq finished", UVM_HIGH)
	endtask: body

endclass: apb_mst_wt_rd_seq

class apb_mst_burst_wt_seq extends apb_master_base_sequence;
	rand bit[31:0] 		addr;
	rand bit[31:0] 		data[];
	rand bit[3:0] 		strb[];
	rand bit[2:0]			prot[];
	apb_trans_status 	trans_status;

	constraint cstr{
		soft data.size() inside {4,8,16,32};
		strb.size() == data.size();
		prot.size() == data.size();
		foreach(data[i]) soft data[i] == addr + (i << 2);
	}

	`uvm_object_utils(apb_mst_burst_wt_seq)

	function new(string name = "apb_mst_burst_wt_seq");
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info("APB_MST_SEQ", "apb_mst_burst_wt_seq started", UVM_HIGH)
		trans_status = OK;
		foreach(data[i]) begin
			`uvm_do_with(req, {
				trans_kind == WRITE;
				addr == local::addr + (i<<2);
				data == local::data[i];
				strb == local::strb[i];
				prot == local::prot[i];
				idle_cycles == 0;
			})
		get_response(rsp);
		end
		`uvm_do_with(req, {
			trans_kind == IDLE;
		})
		get_response(rsp);
		trans_status = rsp.trans_status == ERROR ? ERROR : trans_status;
		`uvm_info("APB_MST_SEQ", "apb_mst_burst_wt_seq finished", UVM_HIGH)
	endtask: body
endclass: apb_mst_burst_wt_seq

class apb_mst_burst_rd_seq extends apb_master_base_sequence;
	rand bit[31:0] 		addr;
	rand bit[31:0] 		data[];
	rand bit[2:0]			prot[];
	apb_trans_status 	trans_status;

	constraint cstr{
		soft data.size() inside {4,8,16,32};
		prot.size() == data.size();
	}

	`uvm_object_utils(apb_mst_burst_rd_seq)

	function new(string name = "apb_mst_burst_rd_seq");
		super.new(name);
	endfunction: new

	virtual task body();
		`uvm_info("APB_MST_SEQ", "apb_mst_burst_rd_seq started", UVM_HIGH)
		trans_status = OK;
		foreach(data[i]) begin
			`uvm_do_with(req, {
				trans_kind == READ;
				addr == local::addr + (i<<2);
				strb == 4'b0;
				prot == local::prot[i];
				idle_cycles == 0;
			})
			get_response(rsp);
			data[i] = rsp.data;
		end
		`uvm_do_with(req, {
			trans_kind == IDLE;
		})
		get_response(rsp);
		trans_status = rsp.trans_status == ERROR ? ERROR : trans_status;
		`uvm_info("APB_MST_SEQ", "apb_mst_burst_rd_seq finished", UVM_HIGH)
	endtask: body
endclass: apb_mst_burst_rd_seq

`endif