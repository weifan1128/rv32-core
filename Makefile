root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
inc_dir := ./include
sim_dir_v0 := ./sim_v0
sim_dir_v1 := ./sim_v1
vip_dir := $(PWD)/vip
bld_dir := ./build
lib_dir := /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/verilog

FSDB_DEF :=
ifeq ($(FSDB),1)
FSDB_DEF := +FSDB
else ifeq ($(FSDB),2)
FSDB_DEF := +FSDB_ALL
endif
CYCLE=`grep -v '^$$' $(root_dir)/sim_v0/CYCLE`
MAX=`grep -v '^$$' $(root_dir)/sim_v0/MAX`

export vip_dir

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

# ============================================================
# v0: RTL simulation (irun, no AXI)
# ============================================================
rtlv0_all: clean_v0 rtlv0_0 rtlv0_1 rtlv0_2 rtlv0_3 rtlv0_4 rtlv0_5

rtlv0_0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog0 \
	+rdcycle=1

rtlv0_1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog1

rtlv0_2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+prog2$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog2

rtlv0_3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog3/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+prog3$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog3

rtlv0_4: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog4/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+prog4$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog4

rtlv0_5: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog5/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+prog5$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog5

# ============================================================
# v0: Post-Synthesis simulation (irun, no AXI)
# ============================================================
synv0_all: clean_v0 synv0_0 synv0_1 synv0_2 synv0_3 synv0_4 synv0_5

synv0_0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+SYN+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog0 \
	+rdcycle=1

synv0_1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+SYN+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog1

synv0_2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+SYN+prog2$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog2

synv0_3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog3/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+SYN+prog3$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog3

synv0_4: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog4/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+SYN+prog4$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog4 \
	+rdcycle=1

synv0_5: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v0)/prog5/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir_v0)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v0) \
	+define+SYN+prog5$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir_v0)/prog5 \
	+rdcycle=1

# ============================================================
# v1: RTL simulation (vcs, AXI4)
# ============================================================
rtlv1_all: clean_v1 rtlv1_0 rtlv1_1 rtlv1_2 rtlv1_3 rtlv1_4 rtlv1_5

rtlv1_0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog0/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+prog0$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog0 \
	+rdcycle=1

rtlv1_1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog1/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+prog1$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog1 \
	+rdcycle=1

rtlv1_2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog2/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+prog2$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog2 \
	+rdcycle=1

rtlv1_3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog3/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+prog3$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog3 \
	+rdcycle=1

rtlv1_4: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog4/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+prog4$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog4 \
	+rdcycle=1

rtlv1_5: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog5/; \
	cd $(bld_dir); \
	vcs -R -sverilog $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+prog5$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog5 \
	+rdcycle=1

# ============================================================
# v1: Post-Synthesis simulation (vcs, AXI4)
# ============================================================
synv1_all: clean_v1 synv1_0 synv1_1 synv1_2 synv1_3 synv1_4 synv1_5

synv1_0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog0/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+SYN+prog0$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog0 \
	+rdcycle=1

synv1_1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog1/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+SYN+prog1$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog1 \
	+rdcycle=1

synv1_2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog2/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+SYN+prog2$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog2 \
	+rdcycle=1

synv1_3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog3/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+SYN+prog3$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog3 \
	+rdcycle=1

synv1_4: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog4/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+SYN+prog4$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog4 \
	+rdcycle=1

synv1_5: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir_v1)/prog5/; \
	cd $(bld_dir); \
	vcs -R -sverilog +neg_tchk -negdelay -v $(lib_dir)/fsa0m_a_generic_core_21.lib.src $(root_dir)/$(sim_dir_v1)/top_tb.sv -debug_access+all -full64 -diag=sdf:verbose \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir_v1) \
	+define+SYN+prog5$(FSDB_DEF) \
	+define+CYCLE=$(CYCLE) \
	+define+MAX=$(MAX) \
	+prog_path=$(root_dir)/$(sim_dir_v1)/prog5 \
	+rdcycle=1

# ============================================================
# AXI VIP (JasperGold formal)
# ============================================================
vip_b: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_bridge.tcl

vip_m: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_master.tcl

vip_s: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_slave.tcl

# ============================================================
# Utilities
# ============================================================
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

dv: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -gui -no_home_init

synthesize: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -no_home_init -f ../script/synthesis.tcl

# Check file structure
BLUE=\033[1;34m
RED=\033[1;31m
NORMAL=\033[0m

check: clean
	@if [ -f StudentID ]; then \
		STUDENTID=$$(grep -v '^$$' StudentID); \
		if [ -z "$$STUDENTID" ]; then \
			echo -e "$(RED)Student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID_LEN=$$(expr length $$STUDENTID); \
			if [ $$ID_LEN -eq 9 ]; then \
				if [[ $$STUDENTID =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	else \
		echo -e "$(RED)StudentID file is not found$(NORMAL)"; \
		exit 1; \
	fi; \
	if [ $$(ls -1 *.docx 2>/dev/null | wc -l) -eq 0 ]; then \
		echo -e "$(RED)Report file is not found$(NORMAL)"; \
		exit 1; \
	elif [ $$(ls -1 *.docx 2>/dev/null | wc -l) -gt 1 ]; then \
		echo -e "$(RED)More than one docx file is found, please delete redundant file(s)$(NORMAL)"; \
		exit 1; \
	elif [ ! -f $${STUDENTID}.docx ]; then \
		echo -e "$(RED)Report file name should be $$STUDENTID.docx$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Report file name pass$(NORMAL)"; \
	fi; \
	if [ $$(basename $(PWD)) != $$STUDENTID ]; then \
		echo -e "$(RED)Main folder name should be \"$$STUDENTID\"$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Main folder name pass$(NORMAL)"; \
	fi

tar: check
	STUDENTID=$$(basename $(PWD)); \
	cd ..; \
	tar cvf $$STUDENTID.tar $$STUDENTID

.PHONY: clean clean_v0 clean_v1

clean: clean_v0 clean_v1
	rm -rf $(bld_dir)

clean_v0:
	rm -rf $(sim_dir_v0)/prog*/result*.txt; \
	make -C $(sim_dir_v0)/prog0/ clean; \
	make -C $(sim_dir_v0)/prog1/ clean; \
	make -C $(sim_dir_v0)/prog2/ clean; \
	make -C $(sim_dir_v0)/prog3/ clean; \
	make -C $(sim_dir_v0)/prog4/ clean; \
	make -C $(sim_dir_v0)/prog5/ clean

clean_v1:
	rm -rf $(sim_dir_v1)/prog*/result*.txt; \
	make -C $(sim_dir_v1)/prog0/ clean; \
	make -C $(sim_dir_v1)/prog1/ clean; \
	make -C $(sim_dir_v1)/prog2/ clean; \
	make -C $(sim_dir_v1)/prog3/ clean; \
	make -C $(sim_dir_v1)/prog4/ clean; \
	make -C $(sim_dir_v1)/prog5/ clean
