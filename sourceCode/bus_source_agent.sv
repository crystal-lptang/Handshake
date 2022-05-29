
`ifndef BUS_SOURCE_AGENT_SV
`define BUS_SOURCE_AGENT_SV


class bus_source_driver extends uvm_driver #(bus_trans);
  `uvm_component_utils(bus_source_driver)
  virtual bus_if vif;
  
  function new(string name, uvm_component parent);
	super.new(name, parent);
  endfunction: new
  
  task run_phase(uvm_phase phase);
    fork 
	  get_and_drive();
	  reset_listener();
	join
  endtask: run_phase
  
  task get_and_drive();
	forever begin
	  seq_item_port.get_next_item(req);  
	  `uvm_info(get_type_name(), "sequencer get_next_item", UVM_HIGH)
	  drive_trans(req);
	  void'($cast(rsp, req.clone()));
	  rsp.set_sequence_id(req.get_sequence_id());
	  rsp.set_transaction_id(req.get_transaction_id());
	  seq_item_port.item_done(rsp);
	  `uvm_info(get_type_name(), "sequencer item_done_triggered", UVM_HIGH)	  
	end
  endtask: get_and_drive
  
  task drive_trans(bus_trans t);
	`uvm_info(get_type_name, "drive_trans", UVM_HIGH)
	case(t.trans_kind)
	  IDLE:		this.do_idle();
	  WRITE:	this.do_write(t);
	  default:	`uvm_error("ERRTYPE", "unrecognized trans type")
	endcase
  endtask: drive_trans
  
  task do_idle();
	`uvm_info(get_type_name(), "do_idle", UVM_HIGH)
	@(vif.cb_src);
	vif.cb_src.valid <=0;
	vif.cb_src.data <=0;
  endtask:do_idle
  
  task do_write(bus_trans t);
  	`uvm_info(get_type_name(), "do_write", UVM_HIGH)
	@(vif.cb_src);
	vif.cb_src.valid <=1;
	vif.cb_src.data <= t.data;
	//@(negedge vif.cb_src);
	#10ps;
	wait(vif.ready === 1);
	`uvm_info(get_type_name(), $sformatf("send data 'h%8x", t.data), UVM_HIGH)   
	repeat(t.idle_cycles) this.do_idle();
  endtask:do_write
  
  
  task reset_listener();
    fork
	  forever begin
		@(vif.cb_src);
		if(vif.rst === 0)begin
		  vif.data <= 0;
		  vif.valid <= 0;
		end 
	  end
	join_none
  endtask: reset_listener
endclass: bus_source_driver

class bus_source_sequencer extends uvm_sequencer#(bus_trans);
  virtual bus_if vif;
  `uvm_component_utils(bus_source_sequencer)
  function new(string name, uvm_component parent);
	super.new(name, parent);
  endfunction: new
   
endclass: bus_source_sequencer


class bus_source_monitor extends uvm_monitor;
  virtual bus_if vif;
  `uvm_component_utils(bus_source_monitor)
  function new(string name, uvm_component parent);
	super.new(name, parent);
  endfunction: new
   
endclass: bus_source_monitor

class bus_source_agent extends uvm_agent;
  bus_source_driver driver;
  bus_source_sequencer sequencer;
  bus_source_monitor monitor;
  virtual bus_if vif;
  `uvm_component_utils(bus_source_agent)

  function new(string name, uvm_component parent);
	super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
    // get virtual interface
	if( !uvm_config_db#(virtual bus_if)::get(this,"","vif", vif)) begin
		`uvm_fatal("GETVIF","cannot get vif handle from config DB")
	end
    driver = bus_source_driver::type_id::create("driver",this);
    sequencer = bus_source_sequencer::type_id::create("sequencer",this);
	monitor = bus_source_monitor::type_id::create("monitor",this);
  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
  	super.connect_phase(phase);
	assign_vi(vif);
	driver.seq_item_port.connect(sequencer.seq_item_export);       
  endfunction : connect_phase
  
  function void assign_vi(virtual bus_if vif);
	monitor.vif = vif;
	sequencer.vif = vif; 
	driver.vif = vif; 
  endfunction : assign_vi

endclass: bus_source_agent

`endif // BUS_SOURCE_SV

