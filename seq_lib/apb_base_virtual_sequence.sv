`ifndef APB_BASE_VIRTUAL_SEQUENCE_SV
`define APB_BASE_VIRTUAL_SEQUENCE_SV

class apb_base_virtual_sequence extends uvm_sequence;

  virtual apb_if vif;
	bit[31:0] mem[bit[31:0]];

	`uvm_object_utils(apb_base_virtual_sequence)
  `uvm_declare_p_sequencer(apb_master_sequencer)

	function new(string name = "apb_base_virtual_sequence");
		super.new(name);
	endfunction: new

  task body();
    vif = p_sequencer.vif;
  endtask: body

	function bit check_mem_data(bit[31:0] addr, bit[31:0] data);
		if(mem.exists(addr)) begin
			if(data != mem[addr]) begin
        `uvm_error("VIRT_SEQ", $sformatf("addr 32'h%8x, READ DATA expected 32'h%8x != actual 32'h%8x", addr, mem[addr], data))
				return 0;
			end
			else begin
        `uvm_info("VIRT_SEQ", $sformatf("addr 32'h%8x, READ DATA 32'h%8x comparing success!", addr, data), UVM_LOW)
        return 1;
      end
    end
    else begin
      if(data != DEFAULT_READ_VALUE) begin
        `uvm_error("VIRT_SEQ", $sformatf("addr 32'h%8x, READ DATA expected 32'h%8x != actual 32'h%8x", addr, DEFAULT_READ_VALUE, data))
        return 0;
      end
      else begin
        `uvm_info("VIRT_SEQ", $sformatf("addr 32'h%8x, READ DATA 32'h%8x comparing success!", addr, data), UVM_LOW)
        return 1;
      end
    end
	endfunction: check_mem_data

  task wait_reset_release();
    @(negedge vif.rstn);
    @(posedge vif.rstn);
  endtask: wait_reset_release

  task wait_cycles(int n);
    repeat(n) @(posedge vif.clk);
  endtask: wait_cycles

  function bit[31:0] get_rand_addr();
    bit[31:0] addr;
    void'(std::randomize(addr) with {addr[31:8] == 0; addr[1:0] == 0; addr != 0;});
    return addr;
	endfunction: get_rand_addr

  function bit[3:0] get_rand_strb();
    bit[3:0] strb;
    void'(std::randomize(strb));
    return strb;
  endfunction: get_rand_strb

endclass: apb_base_virtual_sequence

`endif