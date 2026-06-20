//axi_base_seq
class axi_base_seq extends uvm_sequence#(axi_tx);
    `uvm_object_utils(axi_base_seq)

    function new(string name = "axi_base_seq");
        super.new(name);
    endfunction

    task body();
        `uvm_info(get_full_name,"Starting axi_base_seq", UVM_NONE)
        //randomizing req
        `uvm_do_with(req, {req.wr_rd == 1;
                           req.burst == INCR; //burst type from M->S
                           req.strb == 4'b1111; //wstrb indicates how many byte lanes are valid in WDATA
                           req.size == 3'h2; // indicates no.of bytes transferred per beat
                           })
    endtask

endclass


