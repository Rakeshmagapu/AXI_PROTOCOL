//axi_fixed_burst_seq
class axi_fixed_burst_seq extends axi_base_seq;
    `uvm_object_utils(axi_fixed_burst_seq)
    axi_tx wr_tx[$];
    axi_tx rd_tx;
    function new(string name = "axi_fixed_burst_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_full_name,"Starting axi_fixed_burst_seq", UVM_NONE)
        //randomizing req
        repeat(10) begin
            //WR
            `uvm_do_with(req, {req.wr_rd == 1;
                               req.burst == FIXED; //burst type from M->S
                               req.strb == 4'b1111; //wstrb indicates how many byte lanes are valid in WDATA
                               req.addr  dist { [0:1023] :/ 33, [1024:3071] :/ 33, [3072:4096] :/ 34 };
                               req.size  inside {[3'b000 : 3'b111]}; 
                               req.len   dist { 0 :/ 20, [1:7] :/ 40, [8:15] :/ 40 };
                               })
            wr_tx.push_back(req);
            
            //RD
            rd_tx = wr_tx.pop_front();
            `uvm_do_with(req, {req.wr_rd == 0;
                               req.burst == rd_tx.burst; //burst type from M->S
                               req.strb == rd_tx.strb; //wstrb indicates how many byte lanes are valid in WDATA
                               req.size == rd_tx.size; // indicates no.of bytes transferred per beat
                               req.addr == rd_tx.addr;
                               req.id == rd_tx.id;
                               req.len == rd_tx.len;
                               })
        end
    endtask

endclass : axi_fixed_burst_seq


