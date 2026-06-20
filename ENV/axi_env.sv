//axi_env

class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)

    axi_agent axi_agent_h;
    axi_sbd axi_sbd_h;

    function new(string name="", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_agent_h = axi_agent::type_id::create("axi_agent_h", this);
        axi_sbd_h = axi_sbd::type_id::create("axi_sbd_h", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        //connect the monitor to sbd
        axi_agent_h.axi_mon_h.axi_ap_h.connect(axi_sbd_h.fifo_h.analysis_export);
    endfunction
    

endclass



