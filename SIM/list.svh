// UVM_RELATED FILES
`include "uvm_pkg.svh"
import uvm_pkg::*;

`include "common.sv"
//RTL
`include "axi_mem_slave.v"
`include "sync_fifo.v"

`include "axi_if.sv"

//TX
`include "axi_tx.sv"

//SQR,DRV,MON,COV
`include "axi_sqr.sv"
`include "axi_drv.sv"
`include "axi_mon.sv"
`include "axi_cov.sv"
`include "axi_agent.sv"

//SBD
`include "axi_sbd.sv"

//ENV
`include "axi_env.sv"

//SEQ_LIB
`include "axi_base_seq.sv"
`include "axi_fixed_burst_seq.sv"
`include "axi_incr_burst_seq.sv"
`include "axi_wrap_burst_seq.sv"
`include "axi_rand_seq.sv"

//TEST_LIB
`include "axi_base_test.sv"
`include "axi_fixed_burst_test.sv"
`include "axi_incr_burst_test.sv"
`include "axi_wrap_burst_test.sv"
`include "axi_rand_test.sv"
`include "top.sv"



