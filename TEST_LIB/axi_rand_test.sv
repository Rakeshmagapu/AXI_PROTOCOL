class axi_rand_test extends axi_base_test;
    `uvm_component_utils(axi_rand_test)

    function new(string name="axi_rand_test", uvm_component parent);
        super.new(name,parent);
    endfunction

    task run_phase(uvm_phase phase);
        axi_rand_seq seq = axi_rand_seq::type_id::create("seq");
        
        phase.raise_objection(this);
        seq.start(axi_env_h.axi_agent_h.axi_sqr_h);
        phase.phase_done.set_drain_time(this, 500);
        phase.drop_objection(this);
    endtask
endclass
