vlog list.svh +incdir+C:/questasim64_2024.1/verilog_src/uvm-1.2/src \
+incdir+C:/Users/taddi/Desktop/UVM/AXI-Protocol/AXI-2/RTL \
+incdir+C:/Users/taddi/Desktop/UVM/AXI-Protocol/AXI-2/TB/TEST_LIB \
+incdir+C:/Users/taddi/Desktop/UVM/AXI-Protocol/AXI-2/TB/SEQ_LIB \
+incdir+C:/Users/taddi/Desktop/UVM/AXI-Protocol/AXI-2/TB/ENV \
+incdir+C:/Users/taddi/Desktop/UVM/AXI-Protocol/AXI-2/TB/ENV/AGENTS \
+incdir+C:/Users/taddi/Desktop/UVM/AXI-Protocol/AXI-2/TB/TOP \
+incdir+C:/Users/taddi/Desktop/UVM/AXI-Protocol/AXI-2/TB/ENV/SBD 
vsim -novopt -suppress 12110 top \
-sv_lib C:/questasim64_2024.1/uvm-1.2/win64/uvm_dpi +UVM_TESTNAME=axi_fixed_burst_test
#add wave -position insertpoint sim:/top/u_axi_slave_mem/*
run -all
coverage save fixed.ucdb


#by using these code coverage should be implememt
#vlog list.svh
#vopt tb +cover=fcbest -o 1WR
#vsim -coverage 1WR +test_name=1WR
#coverage save -onexit 1WR.ucdb
#add wave -r sim:/tb/pif/*
#run -all

