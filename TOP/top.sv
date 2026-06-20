//top
module top;
    
    logic aclk;
    logic aresetn;

    initial aclk = 0;
    always #5 aclk=~aclk;

    initial begin
        apply_dut_reset(3);
    end

    task apply_dut_reset(input int num_cycles);
        `uvm_info("TOP", "DUT RST START", UVM_NONE)
        aresetn = 0;
        repeat(num_cycles)@(posedge aclk);
        aresetn = 1;    
        //wr_addr
        axi_pif.awid <= 0;
        axi_pif.awaddr <= 0;
        axi_pif.awlen <= 0;
        axi_pif.awsize <= 0;
        axi_pif.awburst <= 0;
        axi_pif.awvalid <= 0;

        //wr_data
        axi_pif.wid <= 0;
        axi_pif.wdata <= 0;
        axi_pif.wstrb <= 0;
        axi_pif.wlast <= 0;
        axi_pif.wvalid <= 0;

        //wr_res
        axi_pif.bready <= 0;

        //rd_addr
        axi_pif.arid <= 0;
        axi_pif.araddr <= 0;
        axi_pif.arlen <= 0;
        axi_pif.arsize <= 0;
        axi_pif.arburst <= 0;
        axi_pif.arvalid <= 0;

        //rd_data_res
        axi_pif.rready <= 0;

        
        `uvm_info("TOP", "DUT RST END", UVM_NONE)
    endtask

    axi_if axi_pif(aclk,aresetn);

    axi_slave_mem u_axi_slave_mem(
    

    //global
    .aclk(axi_pif.aclk),
    .aresetn(axi_pif.aresetn), 

    //wr_addr
    .awid(axi_pif.awid),
    .awaddr(axi_pif.awaddr),
    .awlen(axi_pif.awlen),
    .awsize(axi_pif.awsize),
    .awburst(axi_pif.awburst),
    .awvalid(axi_pif.awvalid),
    .awready(axi_pif.awready),

    //wr_data
    .wid(axi_pif.wid),
    .wdata(axi_pif.wdata),
    .wstrb(axi_pif.wstrb),
    .wlast(axi_pif.wlast),
    .wvalid(axi_pif.wvalid),
    .wready(axi_pif.wready),

    //wr_res
    .bid(axi_pif.bid),
    .bresp(axi_pif.bresp),
    .bvalid(axi_pif.bvalid),
    .bready(axi_pif.bready),

    //rd_addr
    .arid(axi_pif.arid),
    .araddr(axi_pif.araddr),
    .arlen(axi_pif.arlen),
    .arsize(axi_pif.arsize),
    .arburst(axi_pif.arburst),
    .arvalid(axi_pif.arvalid),
    .arready(axi_pif.arready),

    //rd_data_res
    .rid(axi_pif.rid),
    .rdata(axi_pif.rdata),
    .rresp(axi_pif.rresp),
    .rlast(axi_pif.rlast),
    .rvalid(axi_pif.rvalid),
    .rready(axi_pif.rready)
);

    initial begin
        run_test("axi_base_test");
    end

    initial begin
        uvm_config_db#(virtual axi_if)::set(null, "*", "vif", axi_pif);
    end

endmodule





