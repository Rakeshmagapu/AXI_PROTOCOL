//---------------------------------------
//uvm_driver#(pera) - axi_drv
//---------------------------------------
class axi_drv extends uvm_driver#(axi_tx);
    `uvm_component_utils(axi_drv)

    virtual axi_if axi_vif;

    function new(string name="", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",axi_vif))
            `uvm_error(get_full_name,"FAILED TO RETRIVE VIF HANDLE FROM CONFIG_DB")
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        `uvm_info(get_full_name,"Run Phase is START",UVM_NONE)
        forever begin
            seq_item_port.get_next_item(req);
            req.print();
            drive_tx(req);
            seq_item_port.item_done();
        end
    endtask : run_phase

    task drive_tx(axi_tx tx);
        wait(axi_vif.aresetn == 1);
        if(tx.wr_rd == 1) begin
        `uvm_info("WRITE TX","Write is START",UVM_NONE)
            write_address_channel(tx);
            write_data_channel(tx);
            write_response_channel(tx);
        end
        else begin
            `uvm_info("READ TX","Read is START",UVM_NONE)
            read_address_channel(tx);
            read_data_response_channel(tx);
        end
    endtask : drive_tx

    task write_address_channel(axi_tx tx);
        `uvm_info("AW","write_address_channel Start", UVM_NONE)
        // driving the valid control and adders informations
        axi_vif.axi_drv_cb.awid <= tx.id;
        axi_vif.axi_drv_cb.awaddr <= tx.addr;
        axi_vif.axi_drv_cb.awlen <= tx.len;
        axi_vif.axi_drv_cb.awsize <= tx.size;
        axi_vif.axi_drv_cb.awburst <= tx.burst;

        // assert the valid to indicate the previous signals are contain valid information
        axi_vif.axi_drv_cb.awvalid <= 1;

        tx.print_aw("DRIVER");

        // waiting for the slave to issue ACK for the valid tx
        do begin
            @(axi_vif.axi_drv_cb);
        end while(axi_vif.axi_drv_cb.awready == 0);
        
        //de-asserting the valid
        axi_vif.axi_drv_cb.awvalid <= 0;
        `uvm_info("AW","write_address_channel Completed", UVM_NONE)
    endtask

    task write_data_channel(axi_tx tx);
        `uvm_info("W","write_data_channel Start", UVM_NONE)
        
        for(int i = 0; i < tx.len+1 ; i++) begin
            axi_vif.axi_drv_cb.wid <= tx.id;
            axi_vif.axi_drv_cb.wdata <= tx.wdata[i];
            axi_vif.axi_drv_cb.wstrb <= tx.strb;
            //axi_vif.axi_drv_cb.wlast <= (i == tx.len) ? 1'b1 : 1'b0;
            if(i == tx.len) begin
                axi_vif.axi_drv_cb.wlast <= 1;
                tx.wlast = 1;
                tx.print_w("DRIVER");
            end
            else begin
                axi_vif.axi_drv_cb.wlast <= 0;
                tx.wlast = 0;
            end
            axi_vif.axi_drv_cb.wvalid <= 1;

            do begin
                @(axi_vif.axi_drv_cb);
            end while(axi_vif.axi_drv_cb.wready == 0);
        end
            axi_vif.axi_drv_cb.wvalid <= 0;
            axi_vif.axi_drv_cb.wlast <= 0;
        `uvm_info("W","write_data_channel Completed", UVM_NONE)
    endtask

    task write_response_channel(axi_tx tx);
        `uvm_info("B","write_response_channel Start", UVM_NONE)
        
        axi_vif.axi_drv_cb.bready <= 1;

        do begin
            @(axi_vif.axi_drv_cb);
        end while(axi_vif.axi_drv_cb.bvalid == 0);

        tx.id = axi_vif.axi_drv_cb.bid;
        tx.resp = resp_t'(axi_vif.axi_drv_cb.bresp);

        tx.print_b("DRIVER");

        @(axi_vif.axi_drv_cb);
        axi_vif.axi_drv_cb.bready <= 0;

        `uvm_info("B","write_response_channel completed", UVM_NONE)

    endtask

    task read_address_channel(axi_tx tx);
        `uvm_info("AR","read_address_channel Start", UVM_NONE)
        // driving the valid control and adders informations
        axi_vif.axi_drv_cb.arid <= tx.id;
        axi_vif.axi_drv_cb.araddr <= tx.addr;
        axi_vif.axi_drv_cb.arlen <= tx.len;
        axi_vif.axi_drv_cb.arsize <= tx.size;
        axi_vif.axi_drv_cb.arburst <= tx.burst;

        // assert the valid to indicate the previous signals are contain valid information
        axi_vif.axi_drv_cb.arvalid <= 1;

        tx.print_ar("DRIVER");
        
        // waiting for the slave to issue ACK for the valid tx
        do begin
            @(axi_vif.axi_drv_cb);
        end while(axi_vif.axi_drv_cb.arready == 0);
        
        //de-asserting the valid
        axi_vif.axi_drv_cb.arvalid <= 0;
        `uvm_info("AR","read_address_channel Completed", UVM_NONE)
    endtask

    task read_data_response_channel(axi_tx tx);
        `uvm_info("R","read_data_response_channel Start", UVM_NONE)
        
        axi_vif.axi_drv_cb.rready <= 1;
        
        for(int i = 0; i < tx.len + 1; i++) begin
            do begin
                 @(axi_vif.axi_drv_cb);
            end while(axi_vif.axi_drv_cb.rvalid == 0);
            
            tx.id = axi_vif.axi_drv_cb.rid;
            tx.rdata[i] = axi_vif.axi_drv_cb.rdata;
            tx.rlast = axi_vif.axi_drv_cb.rlast;
            tx.resp = tx.rlast ? resp_t'(axi_vif.axi_drv_cb.rresp) : resp_t'(2'b11);
            if(tx.rlast)
                tx.print_r("DRIVER");
        end
        @(axi_vif.axi_drv_cb);
        axi_vif.axi_drv_cb.rready <= 0;
        
        `uvm_info("R","read_data_response_channel Completed", UVM_NONE)
    endtask

endclass : axi_drv

