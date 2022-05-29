
`ifndef BUS_DESTINATION_AGENT_SV
`define BUS_DESTINATION_AGENT_SV

class bus_destination_driver extends uvm_driver #(bus_trans);
  `uvm_component_utils(bus_destination_driver)
  virtual bus_if vif;
  mailbox #(bit[31:0]) fifo;	//FIFO 32bits width and 32deepth
  int fifo_bound = 16;
  
  function new(string name, uvm_component parent);
	super.new(name, parent);
	this.fifo = new(fifo_bound);
  endfunction: new
  
  task run_phase(uvm_phase phase);
    fork 
	  do_consume();
	  do_receive();
	  reset_listener();
	join
  endtask: run_phase
 
  
  task do_receive();
	forever begin
	  if((this.fifo_bound - this.fifo.num()) < 1)begin
		#1ps;
		vif.ready <= 0;		    	  
	  end
	  else begin
		#1ps;
		vif.ready <= 1;	
		wait(vif.valid === 1 );
	    //#100ps;
		@(negedge vif.cb_dtn);
	    this.fifo.put(vif.data);
	    `uvm_info(get_type_name(), "do_receive", UVM_HIGH)
	    //@(vif.cb_dtn);
	  end
	end
  endtask:do_receive
  
  task do_consume();
    bit [31:0] data;
	forever begin
	  void'(this.fifo.try_get(data));
	  repeat(3) @(vif.cb_dtn);
	end
  endtask: do_consume
  
  task reset_listener();
    fork
	  forever begin
		@(vif.cb_dtn);
		if(vif.rst === 0)
		  vif.ready <= 0;
	  end
	join_none
  endtask: reset_listener
endclass: bus_destination_driver

class bus_destination_sequencer extends uvm_sequencer#(bus_trans);
  virtual bus_if vif;
  `uvm_component_utils(bus_destination_sequencer)
  function new(string name, uvm_component parent);
	super.new(name, parent);
  endfunction: new
   
endclass: bus_destination_sequencer


class bus_destination_monitor extends uvm_monitor;
  virtual bus_if vif;
  `uvm_component_utils(bus_destination_monitor)
  function new(string name, uvm_component parent);
	super.new(name, parent);
  endfunction: new
   
endclass: bus_destination_monitor

class bus_destination_agent extends uvm_agent;
  bus_destination_driver driver;
  bus_destination_sequencer sequencer;
  bus_destination_monitor monitor;
  virtual bus_if vif;
  `uvm_component_utils(bus_destination_agent)

  function new(string name, uvm_component parent);
	super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
	super.build_phase(phase);
    // get virtual interface
	if( !uvm_config_db#(virtual bus_if)::get(this,"","vif", vif)) begin
		`uvm_fatal("GETVIF","cannot get vif handle from config DB")
	end
	monitor = bus_destination_monitor::type_id::create("monitor",this);
    sequencer = bus_destination_sequencer::type_id::create("sequencer",this);
    driver = bus_destination_driver::type_id::create("driver",this);
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

endclass: bus_destination_agent

`endif // BUS_DESTINATION_SV

