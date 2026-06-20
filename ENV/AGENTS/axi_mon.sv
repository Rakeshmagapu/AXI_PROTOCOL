//--------------------------------------------
//uvm_monitor:- axi_mon
//--------------------------------------------
class axi_mon extends uvm_monitor;
    `uvm_component_utils(axi_mon)

    virtual axi_if axi_vif;

    uvm_analysis_port#(axi_tx) axi_ap_h;

    axi_tx wr_tx[int];
    axi_tx rd_tx[int];

    function new(string name="", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_ap_h = new("axi_ap_h",this);
        if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",axi_vif))
            `uvm_error(get_full_name,"FAILED TO RETRIVE VIF HANDLE FROM CONFIG_DB")
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name,"monitor run_phase is start", UVM_NONE)
        fork
            write_channel();
            read_channel();
        join
        `uvm_info(get_type_name,"monitor run_phase is ended", UVM_NONE)
    endtask

    task write_channel();
        int aw_id;
        int w_id;
        int b_id;
        bit [`DATA_WIDTH-1:0]wdata_q[$];
        
        forever begin
            @(axi_vif.axi_mon_cb)

            // collecting aw signals
            if(axi_vif.axi_mon_cb.awvalid && axi_vif.axi_mon_cb.awready) begin
                //first assign the awid to local variable id
                aw_id = axi_vif.axi_mon_cb.awid;
                
                //creating the wr_tx[id]
                wr_tx[aw_id] = axi_tx::type_id::create($sformatf("wr_ts[%0d]",aw_id));
                
                //updata the tx wr_rd bit to WR operation
                wr_tx[aw_id].wr_rd = 1;

                //collect the inetrface AW signals into wr_tx[id]
                wr_tx[aw_id].id = axi_vif.axi_mon_cb.awid;
                wr_tx[aw_id].addr = axi_vif.axi_mon_cb.awaddr;
                wr_tx[aw_id].len = axi_vif.axi_mon_cb.awlen;
                wr_tx[aw_id].size = axi_vif.axi_mon_cb.awsize;
                wr_tx[aw_id].burst = burst_t'(axi_vif.axi_mon_cb.awburst);
                
                //print the aw channel
                wr_tx[aw_id].print_aw("MONITOR");
                
            end

            // collecting W signals
            if(axi_vif.axi_mon_cb.wvalid && axi_vif.axi_mon_cb.wready) begin
                w_id = axi_vif.axi_mon_cb.wid;
                
                //check the W id already exisit in the AA
                if(wr_tx.exists(w_id)) begin
                    //TRUE : collect the W channel signals
                    wr_tx[w_id].id = axi_vif.axi_mon_cb.wid;
                    
                    //pushing the wdata to local queue
                    wdata_q.push_back(axi_vif.axi_mon_cb.wdata);

                    wr_tx[w_id].strb = axi_vif.axi_mon_cb.wstrb;

                    // check for the wlast - once asserted assign the tx wdata with wdata_q
                    if(axi_vif.axi_mon_cb.wlast) begin
                        wr_tx[w_id].wlast = axi_vif.axi_mon_cb.wlast;
                        wr_tx[w_id].wdata = wdata_q; // whole array copy operation
                        
                        //delete the queue so that the current WR data will not to be present in the queue when collecting the next wr tx
                        wdata_q.delete();

                        //print the w channel information
                        wr_tx[w_id].print_w("MONITOR");
                    end
                end
            end

            // collecting B signals
            if(axi_vif.axi_mon_cb.bvalid && axi_vif.axi_mon_cb.bready) begin
                b_id = axi_vif.axi_mon_cb.bid;

                //check the B id already exisit in the AA
                if(wr_tx.exists(b_id)) begin

                    //TRUE: collect the  B channel signals
                    wr_tx[b_id].id = axi_vif.axi_mon_cb.bid;
                    wr_tx[b_id].resp = resp_t'(axi_vif.axi_mon_cb.bresp);

                    // call the write method of monitor uvm_analysis_port - TODO
                    axi_ap_h.write(wr_tx[b_id]);
                    
                    //print the b channel
                    wr_tx[b_id].print_b("MONITOR");
                end
            end
        end
    endtask : write_channel

    task read_channel();
        int ar_id;
        int r_id;

        bit [`DATA_WIDTH-1:0] rdata_q[$];

        forever begin
            @(axi_vif.axi_mon_cb)

            // collecting ar signals
            if(axi_vif.axi_mon_cb.arvalid && axi_vif.axi_mon_cb.arready) begin
                //first assign the awid to local variable id
                ar_id = axi_vif.axi_mon_cb.arid;
                
                //creating the wr_tx[id]
                rd_tx[ar_id] = axi_tx::type_id::create($sformatf("rd_tx[%0d]",ar_id));

                //updata the tx wr_rd bit to WR operation
                rd_tx[ar_id].wr_rd = 0;

                //collect the inetrface AW signals into wr_tx[id]
                rd_tx[ar_id].id = axi_vif.axi_mon_cb.arid;
                rd_tx[ar_id].addr = axi_vif.axi_mon_cb.araddr;
                rd_tx[ar_id].len = axi_vif.axi_mon_cb.arlen;
                rd_tx[ar_id].size = axi_vif.axi_mon_cb.arsize;
                rd_tx[ar_id].burst = burst_t'(axi_vif.axi_mon_cb.arburst);
                
                //print the aw channel
                rd_tx[ar_id].print_ar("MONITOR");
                
            end

            // collecting W signals
            if(axi_vif.axi_mon_cb.rvalid && axi_vif.axi_mon_cb.rready) begin
                r_id = axi_vif.axi_mon_cb.rid;
                
                //check the W id already exisit in the AA
                if(rd_tx.exists(r_id)) begin
                    //TRUE : collect the W channel signals
                    rd_tx[r_id].id = axi_vif.axi_mon_cb.rid;
                    
                    //pushing the wdata to local queue
                    rdata_q.push_back(axi_vif.axi_mon_cb.rdata);
                    
                    // check for the rlast - once asserted assign the tx wdata with wdata_q
                    if(axi_vif.axi_mon_cb.rlast) begin
                        rd_tx[r_id].rlast = axi_vif.axi_mon_cb.rlast;
                        rd_tx[r_id].rdata = rdata_q; // whole array copy operation

                        //delete teh queue so that the current RD data will not to be present in the queue when collecting the next rd tx
                        rdata_q.delete();
                        rd_tx[r_id].resp = resp_t'(axi_vif.axi_mon_cb.rresp);
                        //call the write method of uvm_analysis_port in monitor -- TODO
                        axi_ap_h.write(rd_tx[r_id]);
                        //print the w channel information
                        rd_tx[r_id].print_r("MONITOR");
                    end
                end
            end
        end
    endtask : read_channel

endclass
