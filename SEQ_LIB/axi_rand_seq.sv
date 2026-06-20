class axi_rand_seq extends axi_base_seq;
    `uvm_object_utils(axi_rand_seq)

    axi_tx wr_tx_q[$];
    axi_tx rd_tx;

    function new(string name = "axi_rand_seq");
        super.new(name);
    endfunction

    task body();
        repeat(50) begin
            `uvm_do_with(req, {
                req.wr_rd == 1; 
                req.burst != RSVD; 
                req.addr  dist { [0:1023] :/ 33, [1024:3071] :/ 33, [3072:4096] :/ 34 };
                req.size  inside {[3'b000 : 3'b111]}; 
                req.len   dist { 0 :/ 20, [1:7] :/ 40, [8:15] :/ 40 };
                (req.addr + ((1 << req.size) * (req.len + 1))) <= 4096;
                req.addr[1:0] == 0;
            })
            
            wr_tx_q.push_back(req);

            rd_tx = wr_tx_q.pop_front();
            `uvm_do_with(req, {
                req.wr_rd == 0;
                req.addr  == rd_tx.addr;
                req.len   == rd_tx.len;
                req.size  == rd_tx.size;
                req.burst == rd_tx.burst;
                req.id    == rd_tx.id;
            })
        end
    endtask
endclass


