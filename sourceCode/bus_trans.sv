
`ifndef BUS_TRANS_SV
`define BUS_TRANS_SV

typedef enum {WRITE, IDLE} bus_trans_kind;

class bus_trans extends uvm_sequence_item;
  rand bit [31:0] data;
  rand int idle_cycles;
  rand bus_trans_kind trans_kind;
  
  
  constraint cstr{
    soft idle_cycles == 1;
  };

  `uvm_object_utils_begin(bus_trans)
	`uvm_field_int(data, UVM_ALL_ON)
	`uvm_field_int(idle_cycles, UVM_ALL_ON)
	`uvm_field_enum(bus_trans_kind, trans_kind, UVM_ALL_ON)
  `uvm_object_utils_end
  
  function new(string name = "bus_trans");
	super.new(name);
  endfunction: new
  
endclass: bus_trans

`endif	//BUS_TRANS_SV