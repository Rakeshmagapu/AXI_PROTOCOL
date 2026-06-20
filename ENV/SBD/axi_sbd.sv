//----------------------------
// UVM_component: axi_sbd
//----------------------------
class axi_sbd extends uvm_component;
    `uvm_component_utils(axi_sbd)
    
    //TLM FIFO
    uvm_tlm_analysis_fifo #(axi_tx) fifo_h;
    
    //AA memory for INCR
    bit [7:0] mem_AA [int];
    
    //AA Q memory for FIXED
    bit [31:0] mem_AA_Q [int][$];

    int match_count;
    int miss_match_count;

    bit [`DATA_WIDTH-1:0] exp_data;

    axi_tx tx;

    function new(string name = "axi_sbd", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        //create fifo
        fifo_h = new("fifo_h", this);
    endfunction

    task run_phase(uvm_phase phase);
        `uvm_info(get_type_name(),"Run phase is started", UVM_NONE);
        forever begin
            // Monitor will tale the responsibility of the putting the tx into the monitor port
            // SBD should receive this monitor tx by calling the get method of the fifo
            fifo_h.get(tx);

            //process the tx
            process_tx(tx);
        end
        `uvm_info(get_type_name(),"Run phase is ended", UVM_NONE);
    endtask
    
    task process_tx(axi_tx tx);         
        bit [`ADDR_WIDTH-1:0]curr_addr;
        //check for wr/rd operation
        //WR
        if(tx.wr_rd == 1) begin
            curr_addr = tx.addr;
            case(tx.burst)
                INCR: begin
                    for(int i = 0; i < tx.len+1; i++) begin
                        for(int strb = 0; strb < `STRB_WIDTH; strb++) begin
                            if(tx.strb[strb]) begin
                                mem_AA[curr_addr + strb] = tx.wdata[i][(8*strb) +: 8];
                            end
                        end
                        //next addr calculation logic
                        curr_addr = curr_addr + (1 << tx.size);
                    end
                end
                FIXED: begin
                    for(int i = 0; i < tx.len+1; i++) begin
                        mem_AA_Q[curr_addr].push_back(tx.wdata[i]); //loading all the 32 bits to the q
                        //next addr calculation logic
                        curr_addr = curr_addr;
                    end
                end
                WRAP: begin
                    int total_bytes = (1 << tx.size) * (tx.len + 1);
                    int wrap_base = (tx.addr / total_bytes) * total_bytes;
                    for(int i = 0; i < tx.len + 1; i++) begin
                        for(int strb = 0; strb < `STRB_WIDTH; strb++) begin
                            if(tx.strb[strb]) begin
                                mem_AA[curr_addr + strb] = tx.wdata[i][(8*strb) +: 8];
                            end
                        end
                        curr_addr = curr_addr + (1 << tx.size);
                        if(curr_addr >= (wrap_base + total_bytes)) curr_addr = wrap_base;
                    end
                end
                RSVD:begin
                    `uvm_error(get_type_name, "THIS BURST TYPE IS RESERVED FOR THE ANY ADDING NEW FEATURE FOR THE AXI PROTOCAL")
                end
            endcase
        end
        //RD
        else begin
            curr_addr = tx.addr;
            case(tx.burst)
                INCR: begin
                    for(int i = 0; i < tx.len+1; i++) begin
                        //collecting 32 bit data from mem_AA and comparing it with tx.rdata(act_data)
                        exp_data = {mem_AA[curr_addr+3],
                                    mem_AA[curr_addr+2],
                                    mem_AA[curr_addr+1],
                                    mem_AA[curr_addr]
                                   };
                        if(exp_data == tx.rdata[i]) begin
                            match_count++;
                            `uvm_info(get_type_name(),
                                        $sformatf("AT ADDR =%h EXP_DATA = %h Matching with ACT_DATA = %h", 
                                                   curr_addr, exp_data, tx.rdata[i]), UVM_NONE)
                        end
                        else begin
                            miss_match_count++;
                            `uvm_error(get_type_name(),
                                        $sformatf("AT ADDR =%h EXP_DATA = %h NOT Matching with ACT_DATA = %h", 
                                                  curr_addr, exp_data, tx.rdata[i]))
                        end
                        //next addr calculation logic
                        curr_addr = curr_addr + (1 << tx.size);
                    end
                end
                FIXED: begin
                    for(int i = 0; i < tx.len+1; i++) begin
                        exp_data = mem_AA_Q[curr_addr].pop_front();
                        
                        if(exp_data == tx.rdata[i]) begin
                            match_count++;
                            `uvm_info(get_type_name(),
                                        $sformatf("AT ADDR =%h EXP_DATA = %h Matching with ACT_DATA = %h", 
                                                   curr_addr, exp_data, tx.rdata[i]), UVM_NONE)
                        end
                        else begin
                            miss_match_count++;
                            `uvm_error(get_type_name(),
                                        $sformatf("AT ADDR =%h EXP_DATA = %h NOT Matching with ACT_DATA = %h", 
                                                  curr_addr, exp_data, tx.rdata[i]))
                        end
                        //next addr calculation logic
                        curr_addr = curr_addr;
                    end
                end
                WRAP: begin
                    int total_bytes = (1 << tx.size) * (tx.len + 1);
                    int wrap_base = (tx.addr / total_bytes) * total_bytes;
                    for(int i = 0; i < tx.len + 1; i++) begin
                        exp_data = {mem_AA[curr_addr+3], mem_AA[curr_addr+2], mem_AA[curr_addr+1], mem_AA[curr_addr]};
                        if(exp_data == tx.rdata[i]) begin
                            match_count++;
                            `uvm_info(get_type_name(), $sformatf("MATCH: ADDR=%h EXP=%h ACT=%h", curr_addr, exp_data, tx.rdata[i]), UVM_NONE)
                        end else begin
                            miss_match_count++;
                            `uvm_error(get_type_name(), $sformatf("MISMATCH: ADDR=%h EXP=%h ACT=%h", curr_addr, exp_data, tx.rdata[i]))
                        end
                        curr_addr = curr_addr + (1 << tx.size);
                        if(curr_addr >= (wrap_base + total_bytes)) curr_addr = wrap_base;
                    end
                end
                RSVD:begin
                    `uvm_error(get_type_name, "THIS BURST TYPE IS RESERVED FOR THE ANY ADDING NEW FEATURE FOR THE AXI PROTOCAL")
                end
            endcase
        end
    endtask

    function void report_phase(uvm_phase phase);
        if(miss_match_count == 0 && match_count > 0)begin
            `uvm_info("TEST_STATUS","TEST_PASSED", UVM_NONE)
        end
        else begin
            `uvm_fatal("TEST_STATUS","TEST_FAILED")
        end
    endfunction
endclass


