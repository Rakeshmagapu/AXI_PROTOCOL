//axi_fixed_burst_test

class axi_fixed_burst_test extends axi_base_test;
    `uvm_component_utils(axi_fixed_burst_test)

    function new(string name="axi_fixed_burst_test", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    task run_phase(uvm_phase phase);
        axi_fixed_burst_seq seq = axi_fixed_burst_seq::type_id::create("seq");
        `uvm_info("UVM_TEST_TOP","Run phase is started", UVM_NONE)

        phase.raise_objection(this);
        
        seq.start(axi_env_h.axi_agent_h.axi_sqr_h);
        phase.phase_done.set_drain_time(this,1000);
        
        phase.drop_objection(this);

        `uvm_info("UVM_TEST_TOP","Run_phase is ended", UVM_NONE)
    endtask

endclass




