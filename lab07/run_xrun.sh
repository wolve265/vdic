xrun \
	-F dut.f \
	-F tb.f \
	-uvm \
	-uvmhome /cad/XCELIUM1909/tools/methodology/UVM/CDNS-1.2/sv \
	+UVM_TESTNAME=kc_alu_example_test \
	"$@"
	
#	-clean\