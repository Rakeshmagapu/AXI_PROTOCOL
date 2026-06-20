//axi_agent
class axi_agent extends uvm_agent;
    `uvm_component_utils(axi_agent)
    
    axi_sqr axi_sqr_h;
    axi_drv axi_drv_h;
    axi_mon axi_mon_h;
    axi_cov axi_cov_h;

    function new(string name="", uvm_component parent);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_mon_h = axi_mon::type_id::create("axi_mon_h", this);
        axi_cov_h = axi_cov::type_id::create("axi_cov_h", this);
        axi_drv_h = axi_drv::type_id::create("axi_drv_h", this);
        axi_sqr_h = axi_sqr::type_id::create("axi_sqr_h", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axi_drv_h.seq_item_port.connect(axi_sqr_h.seq_item_export);
        axi_mon_h.axi_ap_h.connect(axi_cov_h.analysis_export);
    endfunction

endclass : axi_agent
