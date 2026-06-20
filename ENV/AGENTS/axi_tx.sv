//------------------------------------
//uvm_sequence_item : axi_tx
//------------------------------------
class axi_tx extends uvm_sequence_item;
    //property
    rand bit [3:0] id;
    rand bit [`ADDR_WIDTH-1:0] addr;
    rand bit [3:0] len;
    rand bit [2:0] size;
    rand burst_t burst;
    rand bit [`DATA_WIDTH-1:0] wdata[];
    rand bit [`DATA_WIDTH-1:0] rdata[];
    rand bit [`STRB_WIDTH-1:0] strb;
         resp_t resp;
         bit wlast;
         bit rlast;
    rand bit wr_rd;
    
    //factory + field registeration
    `uvm_object_utils_begin(axi_tx)
        `uvm_field_int(wr_rd, UVM_ALL_ON)
        `uvm_field_int(id, UVM_ALL_ON)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(len, UVM_ALL_ON)
        `uvm_field_int(size, UVM_ALL_ON)
        `uvm_field_enum(burst_t, burst, UVM_ALL_ON)
        `uvm_field_array_int(wdata, UVM_ALL_ON)
        `uvm_field_array_int(rdata, UVM_ALL_ON)
        `uvm_field_int(strb, UVM_ALL_ON)
        `uvm_field_enum(resp_t, resp, UVM_ALL_ON)
        `uvm_field_int(wlast, UVM_ALL_ON)
        `uvm_field_int(rlast, UVM_ALL_ON)
        `uvm_field_int(id, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "axi_tx");
        super.new(name);
    endfunction

    //constraints
    constraint data_size_c{
        wdata.size() == len + 1;
        rdata.size() == len + 1;
    }
    
    constraint addr_c{
        addr inside {[0:4096]};
    }

    constraint wrap_addr_alignment{
        if(burst == WRAP ) {
            //addr[size-1:0] == 0;
            (addr & ((1 << size) -1)) == 0;
        }
    }

// channel specific print function
    function void print_aw(string name = "axi_tx");
        `uvm_info(
            {name,"_AXI_AW"},
            $sformatf("\n >>> AXI WR Address @ %t Channel <<< \n AWID = %0d \n AWADDR = %0d \n AWLEN = %0d \n AWSIZE =%0d \n AWBURST =%s",
                         $realtime,   id,     addr,   len,    size,   burst),
            UVM_NONE)
    endfunction

    function void print_w(string name = "axi_tx");
        `uvm_info(
            {name,"_AXI_W"},
            $sformatf("\n >>> AXI WR Data Channel @ %t <<< \n WID = %0d \n WSTRB = %0d \n WDATA = %p \n WLAST =%0d ",
                          $realtime,  id,     strb,   wdata,    wlast),
            UVM_NONE)
    endfunction

    function void print_b(string name = "axi_tx");
        `uvm_info(
            {name,"_AXI_B"},
            $sformatf("\n >>> AXI WR Response Channel @ %t <<< \n BID = %0d \n BRESP = %s ",
                            $realtime ,   id,     resp ),
            UVM_NONE)
    endfunction


    function void print_ar(string name="axi_tx");
        `uvm_info(
            {name,"_AXI_AR"},
            $sformatf("\n >>> AXI RD Address channel @ %t <<< \n ARID = %0d \n ARADDR = %0d \n ARLEN = %0d \n ARSIZE =%0d \n ARBURST =%s",
                         $realtime,   id,     addr,   len,    size,   burst),
            UVM_NONE)
    endfunction

    function void print_r(string name = "axi_tx");
        `uvm_info(
            {name,"_AXI_R"},
            $sformatf("\n >>> AXI WR Data Channel @ %t <<< \n RID = %0d \n RRESP = %0d \n RDATA = %p \n RLAST = %0d",
                          $realtime,  id,    resp,    rdata,    rlast ),
            UVM_NONE)
    endfunction

endclass
