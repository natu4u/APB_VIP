`ifndef APB3_SINGLE_TRANS_VIRT_SEQ_SV
`define APB3_SINGLE_TRANS_VIRT_SEQ_SV

class apb3_single_trans_virt_seq extends apb_base_virtual_sequence;

	apb_mst_single_wt_seq single_wt_seq;
	apb_mst_single_rd_seq single_rd_seq;
	apb_mst_wt_rd_seq wt_rd_seq;
	rand int test_num = 100;

	constraint cstr{
		soft test_num == 100;
	}

	`uvm_object_utils(apb3_single_trans_virt_seq)

	function new(string name = "apb3_single_trans_virt_seq");
		super.new(name);
	endfunction: new

	task body();
		bit[31:0] addr;
		super.body();
		this.wait_reset_release();
		this.wait_cycles(10);

		`uvm_info("VIRT_SEQ", "apb3_single_trans_virt_seq started", UVM_HIGH)

		repeat(test_num) begin
			addr = this.get_rand_addr();
			`uvm_do_with(single_wt_seq, {
				addr == local::addr;
				data == local::addr;
			})
			mem[addr] = addr;
		end

    repeat(test_num) begin
      addr = this.get_rand_addr();
      `uvm_do_with(single_rd_seq, {
				addr == local::addr;
			})
      if(single_rd_seq.trans_status == OK)
        void'(this.check_mem_data(addr, single_rd_seq.data));
    end
		
    repeat(test_num) begin
      addr = this.get_rand_addr();
      `uvm_do_with(wt_rd_seq, {
				addr == local::addr; 
				data == local::addr;
			})
      mem[addr] = addr;
      if(wt_rd_seq.trans_status == OK)
        void'(this.check_mem_data(addr, wt_rd_seq.data));
    end

		this.wait_cycles(10);
	endtask: body
endclass: apb3_single_trans_virt_seq

`endif