// axi_slave_mem_1
module axi_slave_mem(
    
    //GlOBAL signal
    input aclk,
    input aresetn,  //active_low
    
    //Write address channel
    input [3:0] awid,
    input [`ADDR_WIDTH-1:0] awaddr,
    input [3:0] awlen,
    input [2:0] awsize,
    input [1:0] awburst,
    input awvalid,
    output reg awready,

    //write data channel
    input [3:0] wid,
    input [`DATA_WIDTH-1:0] wdata,
    input [`STRB_WIDTH-1:0] wstrb,
    input wlast,
    input wvalid,
    output reg wready,

    //Write response channel
    output reg [3:0] bid,
    output reg [1:0] bresp,
    output reg bvalid,
    input bready,

    //read address channel
    input [3:0] arid,
    input [`ADDR_WIDTH-1:0] araddr,
    input [3:0] arlen,
    input [2:0] arsize,
    input [1:0] arburst,
    input  arvalid,
    output reg arready,

    // read data & response channel
    output reg [3:0] rid,
    output wire [`DATA_WIDTH-1:0] rdata,
    output reg [1:0] rresp,
    output reg rlast,
    output wire rvalid,
    input rready
);


//AXI MEMORY SUPPORTS BYTE ADDRESSED MEMORY
reg [7:0] mem [4095:0];

//FIFO (Meant for AXBURST AS FIXED) //fifo status signals which can be used it as the axi resp processing
wire fifo_full, fifo_empty;
wire fifo_wr_error, fifo_rd_error;

wire fifo_wr_en, fifo_rd_en; //flag for the AXI to know when Axburst is of FIXED FIFO MEMORY should be enabled
wire [`DATA_WIDTH-1:0] fifo_rdata;
reg [`DATA_WIDTH-1:0] incr_rdata;

sync_fifo u_sync_fifo(
            .clk(aclk),
            .rst_n(aresetn),
            .wr_en(fifo_wr_en),
            .wdata(wdata),
            .full(fifo_full),
            .rd_en(fifo_rd_en),
            .rdata(fifo_rdata),
            .empty(fifo_empty),
            .wr_error(fifo_wr_error),
            .rd_error(fifo_rd_error)
            );


reg wr_active, rd_active; // indicates when to start write DATA phase

//local veriables needed to be captured during AW phase 
// and these veriables will be used by slave to process W phase and B phase
reg [`ADDR_WIDTH-1:0]wr_addr, rd_addr , wrap_wr_start_addr, wrap_rd_start_addr;
reg [3:0]wr_len, rd_len, rd_beat;
reg [1:0]wr_burst, rd_burst;
reg [3:0]wr_id, rd_id;
reg [2:0]wr_size, rd_size;

// internal for loop variables
integer i;
integer strb, rd_strb;
integer len;

function [`ADDR_WIDTH-1:0] next_addr(input [1:0] burst_t,input [2:0] size_t, input [`ADDR_WIDTH-1:0] current_addr,input [`ADDR_WIDTH-1:0] start_addr, input [3:0] len_t);
    
    //function local variables should declare before the begin....end
    reg [`ADDR_WIDTH-1:0] wrap_base;
    integer total_bytes;
    begin 
        case(burst_t)
            2'b00 : begin
                $display("BURST Type is FIXED");
                next_addr = current_addr;
            end
            2'b01 : begin
                $display("BURST Type is INCR");
                next_addr = current_addr + (1 << size_t); //current_addr = prev_addr + 2**awsize
            end
            2'b10 : begin
                $display("BURST Type is WRAP");
                total_bytes = ((1 << size_t) * (len_t + 1)); // total no of bytes transferred
                wrap_base = ( start_addr / total_bytes ) * total_bytes; // make sure that lower n bits are 0
                                                                        // here start
                                                                        // start_addr is master initiated address during wr/rd
                next_addr = current_addr + (1 << size_t);
                if(next_addr >= (wrap_base + total_bytes)) begin
                    next_addr = wrap_base; // when the upper limit is reached next_addr should be the wrap_base
                end
            end
            2'b11 : begin
                $display("BURST Type is RESERVED");
            end
        endcase
    end
endfunction 

assign rvalid = rd_active;
assign rdata = rd_burst == 2'b00 ? fifo_rdata : incr_rdata;
//fifo_wr_en need to be asserted only when master issues a vaild data information 
//                                                             and salve is ready 
//                                                             and burst type of FIXED
assign fifo_wr_en = ( wr_active || (wvalid && wready)) && (wr_burst == 2'b00);

assign fifo_rd_en = ( rd_active || (rvalid && rready)) && (rd_burst == 2'b00);

//write tx
always@(posedge aclk) begin
    if(aresetn == 0) begin
        for(i=0;i <= 4096; i = i+1) begin
            mem[i] = 0;
        end
        awready = 0;
        wready = 0;
        bid = 0;
        bresp = 0;
        bvalid = 0;
        wr_active = 0;
    end
    else begin
        //WRITE ADDRESS PHASE
        if(awvalid == 1) begin
            awready = 1;
            wr_active = 1; // WRITE DATA Phase is present
            // capture aw signals that are required for processing of w and b channels
            // slave collects the addr and contral info
            // wr_id = awid; // need in axi4
            wrap_wr_start_addr = awaddr;
            wr_addr = awaddr;
            wr_len = awlen;
            wr_size = awsize;
            wr_burst = awburst;
            
        end

        else begin
            awready = 0;
        end

        //WRITE DATA PHASE
        if(wr_active == 1 && wvalid == 1) begin
            wready = 1;
            wr_id = wid;
            if(fifo_wr_en == 0) begin // whenever the fifo write en is asserted - slave should perfoe writ to FIFO
                                  // whenever fifo_wr_en is de-asserted - slave should perform write to normal seq mem
                // chack the WSTRB bits to be valid then store the respective byte lane to the AXI memory
                for(strb = 0; strb < `STRB_WIDTH; strb =strb+1) begin
                    if(wstrb[strb]) begin
                        // store the data into the mem
                        //mem[wr_addr + strb] = wdata[(8*strb)+7 : (8*strb)];
                        mem[wr_addr + strb] = wdata[(8*strb) +: 8];
                    end
                end
                // next addr calculation function 
                wr_addr = next_addr(wr_burst, wr_size, wr_addr, wrap_wr_start_addr, wr_len);
            end
            if(wlast == 1) begin
                bvalid = 1;
                wr_active = 0;
            end
        end
        else begin
            wready = 0;
        end

        //WRITE RESPONSE PHASE
        if(bvalid ==1 && bready == 1) begin
            bid = wr_id;
            bresp = 2'b00; //OKAY
            bvalid = 0;
        end
    end
end

//READ TX
always@(posedge aclk) begin
    if(aresetn == 0) begin
        rd_beat = 0;
        arready = 0;
        rid = 0;
        rresp = 0;
        rlast = 0;
    end
    else begin
        //READ ADDRESS PHASE
        if(arvalid == 1) begin
            arready = 1;
            rd_active = 1;
            rd_addr = araddr;
            wrap_rd_start_addr = araddr;
            rd_len = arlen;
            rd_size = arsize;
            rd_burst = arburst;
            rd_id = arid;
            rd_beat = 0;
        end
        else begin
            arready = 0;
        end

        //READ DATA & RESPONSE PHASE
        if(rd_active && rready && rvalid) begin
            if(fifo_rd_en == 0) begin
                //read the data from memory wrt byte lanes
                for(rd_strb = 0; rd_strb < `STRB_WIDTH; rd_strb = rd_strb + 1)begin
                    //incr_rdata[(8*rd_strb)+7 : (8*rd_strb)] = mem[rd_addr + rd_strb];
                    incr_rdata[(8*rd_strb) +: 8] = mem[rd_addr + rd_strb];
                end
                rd_addr = next_addr(rd_burst, rd_size, rd_addr, wrap_rd_start_addr, rd_len);
            end
            rid = rd_id;
            rlast = (rd_beat == rd_len);
            rresp = 2'b00;
            if(rlast == 1) begin
                rd_active = 0;
            end
            rd_beat = rd_beat + 1;
        end
    end
end 
endmodule






