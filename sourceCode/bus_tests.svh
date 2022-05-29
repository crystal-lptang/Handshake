
`ifndef BUS_TESTS_SV
`define BUS_TESTS_SV

import bus_pkg::*;

class bus_env extends uvm_env;
  bus_source_agent src_agent;
  bus_destination_agent dtn_agent;
  `uvm_component_utils(bus_env)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    src_agent = bus_source_agent::type_id::create("src_agent", this);
    dtn_agent = bus_destination_agent::type_id::create("dtn_agent", this);
  endfunction
endclass

class bus_base_test extends uvm_test;
  bus_env env;
  `uvm_component_utils(bus_base_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = bus_env::type_id::create("env", this);
  endfunction
endclass

class bus_base_test_sequence extends uvm_sequence #(bus_trans);
  `uvm_object_utils(bus_base_test_sequence)
  function new(string name=""); 
    super.new(name);
  endfunction : new
  task wait_reset_release();
    @(negedge bus_tb.rst);
    @(posedge bus_tb.rst);
  endtask

  task wait_cycles(int n);
    repeat(n) @(posedge bus_tb.clk);
  endtask

  function bit[31:0] get_rand_data();
	bit [31:0] data;
	void'(std::randomize(data) with {data[31:11] == 0; data[1:0] == 0;});//limit the data 
    return data;
  endfunction: get_rand_data
endclass

class bus_transaction_sequence extends bus_base_test_sequence;
  bus_source_single_write_sequence source_single_seq;
  bus_source_burst_write_sequence source_burst_seq;

  rand int test_num = 50;
  constraint cstr{
    soft test_num == 50;
  }
  `uvm_object_utils(bus_transaction_sequence)
  
  function new(string name=""); 
    super.new(name);
  endfunction : new
  
  task body();
    bit [31:0] data;
    this.wait_reset_release();
    
    // TEST write transaction
    `uvm_info(get_type_name(), "TEST single transaction...", UVM_LOW)
    repeat(test_num) begin
      data = this.get_rand_data();
      `uvm_do_with(source_single_seq, {data == local::data;})
    end
	
	this.wait_cycles(5);

	// TEST burst transaction
    `uvm_info(get_type_name(), "TEST burst transaction...", UVM_LOW)
    repeat(test_num) begin
      data = this.get_rand_data();
      `uvm_do_with(source_burst_seq, {data == local::data;})
    end

    this.wait_cycles(2);
  endtask
endclass: bus_transaction_sequence

class bus_transaction_test extends bus_base_test;
  `uvm_component_utils(bus_transaction_test)
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
    bus_transaction_sequence seq = new();
    phase.raise_objection(this);
    super.run_phase(phase);
    seq.start(env.src_agent.sequencer);
    phase.drop_objection(this);
  endtask
endclass: bus_transaction_test


`endif // BUS_TESTS_SV
