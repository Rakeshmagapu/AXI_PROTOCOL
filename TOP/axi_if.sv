interface axi_if(input logic aclk,aresetn);
    
    //Write address channel
    logic [3:0] awid;
    logic [`ADDR_WIDTH-1:0] awaddr;
    logic [3:0] awlen;
    logic [2:0] awsize;
    logic [1:0] awburst;
    logic awvalid;
    logic awready;

    //write data channel
    logic [3:0] wid;
    logic [`DATA_WIDTH-1:0] wdata;
    logic [`STRB_WIDTH-1:0] wstrb;
    logic wlast;
    logic wvalid;
    logic wready;

    //Write response channel
    logic [3:0] bid;
    logic [1:0] bresp;
    logic bvalid;
    logic bready;

    //read address channel
    logic [3:0] arid;
    logic [`ADDR_WIDTH-1:0] araddr;
    logic [3:0] arlen;
    logic [2:0] arsize;
    logic [1:0] arburst;
    logic arvalid;
    logic arready;

    // read data & response channel
    logic [3:0] rid;
    logic [`DATA_WIDTH-1:0] rdata;
    logic [1:0] rresp;
    logic rlast;
    logic rvalid;
    logic rready;
    
    //clocking blocks
    // drv cb
    clocking axi_drv_cb@(posedge aclk);
        default input #0 output #1;
        
        //Write address channel
        output awid;
        output awaddr;
        output awlen;
        output awsize;
        output awburst;
        output awvalid;
        input awready;

        //write data channel
        output wid;
        output wdata;
        output wstrb;
        output wlast;
        output wvalid;
        input wready;

        //Write response channel
        input bid;
        input bresp;
        input #1 bvalid;
        output bready;

        //read address channel
        output arid;
        output araddr;
        output arlen;
        output arsize;
        output arburst;
        output arvalid;
        input arready;

        // read data & response channel
        input rid;
        input rdata;
        input rresp;
        input rlast;
        input #1 rvalid;
        output rready;
    
    endclocking

    // mon cb
    clocking axi_mon_cb@(posedge aclk);
        default input #0 output #0;
        
        //Write address channel
        input awid;
        input awaddr;
        input awlen;
        input awsize;
        input awburst;
        input awvalid;
        input awready;

        //write data channel
        input wid;
        input wdata;
        input wstrb;
        input wlast;
        input wvalid;
        input wready;

        //Write response channel
        input bid;
        input bresp;
        input #1 bvalid;
        input bready;

        //read address channel
        input arid;
        input araddr;
        input arlen;
        input arsize;
        input arburst;
        input arvalid;
        input arready;

        // read data & response channel
        input rid;
        input rdata;
        input rresp;
        input rlast;
        input #1 rvalid;
        input rready;    
    endclocking
endinterface
