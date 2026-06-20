//axi_base_tst

class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)

    axi_env axi_env_h;

    function new(string name="", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_env_h = axi_env::type_id::create("axi_env_h", this);
    endfunction

    task run_phase(uvm_phase phase);
        axi_base_seq seq = axi_base_seq::type_id::create("seq");
        `uvm_info(get_type_name(),"Run phase is started", UVM_NONE)

        phase.raise_objection(this);
        
        seq.start(axi_env_h.axi_agent_h.axi_sqr_h);
        phase.phase_done.set_drain_time(this,1000);
        
        phase.drop_objection(this);

        `uvm_info(get_type_name,"Run_phase is ended", UVM_NONE)
    endtask

endclass




