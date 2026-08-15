GHDL    ?= ghdl
STD      = --std=08
WORKDIR  = build
TOP      = timing_controller_tb
SRC      = src/timing_controller.vhd
TB       = test/timing_controller_tb.vhd
SIM      = $(WORKDIR)/$(TOP)
VCD      = $(WORKDIR)/timing_controller.vcd

.PHONY: all analyze elaborate test waveform clean

all: waveform

$(WORKDIR):
	mkdir -p $(WORKDIR)

analyze: $(WORKDIR)
	$(GHDL) -a $(STD) --workdir=$(WORKDIR) $(SRC)
	$(GHDL) -a $(STD) --workdir=$(WORKDIR) $(TB)

elaborate: analyze
	$(GHDL) -e $(STD) --workdir=$(WORKDIR) -o $(SIM) $(TOP)

test: elaborate
	$(SIM)

waveform: elaborate
	$(SIM) --vcd=$(VCD)

clean:
	rm -rf $(WORKDIR)
	rm -f $(TOP) e~$(TOP).o
