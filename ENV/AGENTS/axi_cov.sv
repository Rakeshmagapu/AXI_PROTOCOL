//--------------------------------------------
//uvm_subscriber:- axi_cov
//--------------------------------------------
class axi_cov extends uvm_subscriber#(axi_tx);
    `uvm_component_utils(axi_cov)
    axi_tx tx; 
    covergroup axi_cg (axi_tx tx);
        option.per_instance = 1;
        ADDR: coverpoint tx.addr{
            bins low    = {[0:1023]};
            bins mid    = {[1024:3071]};
            bins high   = {[3072:4096]};
        }
        LEN: coverpoint tx.len {
            bins single = {0};
            bins short = {[1:7]};
            bins long  = {[8:15]};
        }
        SIZE: coverpoint tx.size {
            bins s_1  = {3'b000};
            bins s_2  = {3'b001};
            bins s_3  = {3'b010};
            illegal_bins s_4  = {3'b011};
            illegal_bins s_5  = {3'b100};
            illegal_bins s_6  = {3'b101};
            illegal_bins s_7  = {3'b110};
            illegal_bins s_8  = {3'b111};
        }
        BURST: coverpoint tx.burst {
            bins fixed = {0}; 
            bins incr  = {1};
            bins wrap  = {2};
        }
        RW_OP: coverpoint tx.wr_rd {
            bins write = {1};
            bins read  = {0};
        }
        CROSS_BURST_SIZE: cross BURST, SIZE;
        CROSS_RW_BURST: cross RW_OP, BURST;
    endgroup
    
    function new(string name="", uvm_component parent);
        super.new(name,parent);
        tx = new();
        axi_cg = new(tx);
    endfunction
    
    function void write(axi_tx t);
        this.tx.copy(t);
        axi_cg.sample();
        `uvm_info(get_type_name(), 
        $sformatf("Coverage Sampled for ID:%0d Addr:%0h", t.id, t.addr), 
        UVM_HIGH)
    endfunction
endclass
