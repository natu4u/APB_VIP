TOP 			= apb_tb
TEST 		 ?= apb4_single_trans_test
VERDI    ?= 0
GUI      ?= 0
COV      ?= 0
PARTCOMP ?= 1
SEED      = `date "+%m%d%H%M%S"`
OUT      ?= out
VERB     ?= UVM_HIGH#{UVM_NONE, UVM_LOW, UVM_MEDIUM, UVM_HIGH}
INCDIR    = +incdir+../{agts,cfg,env,seq_lib,seq_lib/apb3_seq_lib,seq_lib/apb4_seq_lib,tb,tests,tests/apb3_tests,tests/apb4_tests}
TESTLIST  = apb_single_trans_test

VCOMP     = vlogan $(INCDIR) -full64 -sverilog -ntb_opts uvm-1.2 -timescale=1ps/1ps -l $(OUT)/log/comp_$(TOP).log  
ELAB      = vcs -cpp g++-4.4 -cc gcc-4.4 -full64 -sverilog -ntb_opts uvm-1.2 -debug_acc+all -debug_region+cell+encrypt -l $(OUT)/log/elab_$(TOP).log -o $(OUT)/obj/apb_tb.simv
RUN       = $(OUT)/obj/apb_tb.simv +ntb_random_seed=$(SEED) +UVM_NO_RELNOTES +UVM_VERBOSITY=$(VERB) 
COV_OPTS  = -full64 -dir $(CM_DIR)
CM_DIR   ?= $(OUT)/cov.vdb
CM_NAME  ?= $(TEST)_$(SEED)

ifeq (1, $(strip $(PARTCOMP)))
  ELAB += -partcomp -fastpartcomp=j4 
endif

ifeq ($(VERDI),1)
	VCOMP  += -kdb
	RUN += -verdi
endif

ifeq ($(GUI),1)
	RUN += -gui
endif

ifeq ($(COV),1)
	ELAB  += -cm line+cond+fsm+tgl+branch+assert -cm_dir $(CM_DIR)
	RUN += -cm line+cond+fsm+tgl+branch+assert -covg_cont_on_error
endif

export SYNOPSYS_SIM_SETUP = ./synopsys_sim.setup

all: clean comp elab sim_all cov

prepare:
	mkdir -p $(OUT)/work
	mkdir -p $(OUT)/log
	mkdir -p $(OUT)/sim
	mkdir -p $(OUT)/obj
	mkdir -p .shadow

comp: prepare .shadow/compile_uvm
	$(VCOMP) ../env/apb_pkg.sv
	$(VCOMP) ../tb/apb_tb.sv

.shadow/compile_uvm:
	${VCOMP} -ntb_opts uvm-1.2
	@touch $@;

elab: comp
	$(ELAB) $(TOP)

run: 
	$(RUN) +UVM_TESTNAME=$(TEST) -l $(OUT)/sim/$(CM_NAME).log -cm_dir $(CM_DIR) -cm_name $(CM_NAME)

regr: 
	for t in $(TESTLIST); do \
		$(RUN) +UVM_TESTNAME=$$t -l $(OUT)/sim/$$t.log -cm_dir $(CM_DIR) -cm_name $(CM_NAME) +vpdfile+$(OUT)/sim/$$t_$(SEED)_$(VPDFILE); \
	done


mergecov:
	urg -format both $(COV_OPTS)

dvecov:
	dve $(COV_OPTS)

verdicov:
	verdi -cov -plan ../doc/vcs_vplan.hvp -covdir $(CM_DIR)

htmlcov:
	firefox urgReport/dashboard.html

clean:
	-rm -rf csrc DVEfiles ucli.key uvm_dpi.so vc_hdrs.h  *simv* *.vpd *.log *.sml *.fsdb work.* *.vdb
	-rm -rf AN.DB urgReport novas.conf verdiLog vdCovLog novas.rc $(OUT) .shadow
	-rm -rf eman* vhdl_objs_dir
	-rm -rf transcript vsim* regr_ucdb* work apb_tb apb_tb.vdb
	-rm -rf ._Vera* .synopsys_dve_rebuild.tcl stack* .inter.vpd.uvm .restartSimSession.tcl.old