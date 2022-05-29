
`ifndef BUS_SOURCE_SEQ_LIB_SV
`define BUS_SOURCE_SEQ_LIB_SV

//------------------------------------------------------------------------------
// SEQUENCE: default
//------------------------------------------------------------------------------
typedef class bus_trans;
typedef class bus_source_sequencer;

class bus_source_base_sequence extends uvm_sequence #(bus_trans);
  `uvm_object_utils(bus_source_base_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction : new
endclass : bus_source_base_sequence 


class bus_source_single_write_sequence extends bus_source_base_sequence;
  rand bit [31:0]      data;

  `uvm_object_utils(bus_source_single_write_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(),"Starting sequence", UVM_HIGH)
	`uvm_do_with(req, {trans_kind == WRITE; data == local::data;})
    get_response(rsp);
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_LOW)
  endtask: body

endclass: bus_source_single_write_sequence

class bus_source_burst_write_sequence extends bus_source_base_sequence;
  rand bit [31:0]      data;

  `uvm_object_utils(bus_source_burst_write_sequence)    
  function new(string name=""); 
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(),"Starting sequence", UVM_HIGH)
	`uvm_do_with(req, {trans_kind == WRITE; data == local::data;idle_cycles == 0;})
    get_response(rsp);
    `uvm_info(get_type_name(),$psprintf("Done sequence: %s",req.convert2string()), UVM_LOW)
  endtask: body

endclass: bus_source_burst_write_sequence
`endif // BUS_SOURCE_SEQ_LIB_SV

