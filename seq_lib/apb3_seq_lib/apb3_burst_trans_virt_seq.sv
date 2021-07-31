`ifndef APB3_BURST_TRANS_VIRT_SEQ_SV
`define APB3_BURST_TRANS_VIRT_SEQ_SV

class apb3_burst_trans_virt_seq extends apb_base_virtual_sequence;

	apb_mst_burst_wt_seq burst_wt_seq;
	apb_mst_burst_rd_seq burst_rd_seq;
	rand int test_num = 100;

	constraint cstr{
		soft test_num == 100;
	}

	`uvm_object_utils(apb3_burst_trans_virt_seq)

	function new(string name = "apb3_burst_trans_virt_seq");
		super.new(name);
	endfunction: new

	task body();
		bit[31:0] addr;
		super.body();
		this.wait_reset_release();
		this.wait_cycles(10);

		repeat(test_num) begin
			addr = this.get_rand_addr();
			`uvm_do_with(burst_wt_seq, {
				addr == local::addr;
			})
			foreach(burst_wt_seq.data[i]) begin
				mem[addr+(i<<2)] = burst_wt_seq.data[i];
			end
			`uvm_do_with(burst_rd_seq, {
				addr == local::addr;
				data.size() == burst_wt_seq.data.size();
			})
      foreach(burst_rd_seq.data[i]) begin
        void'(this.check_mem_data(addr+(i<<2), burst_wt_seq.data[i]));
      end
    end
			
		this.wait_cycles(10);
	endtask: body
endclass: apb3_burst_trans_virt_seq

`endif