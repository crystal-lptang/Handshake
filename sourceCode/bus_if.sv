
`ifndef BUS_IF_SV
`define BUS_IF_SV

interface bus_if (input clk, input rst);

  logic [31:0] data;
  logic        valid;
  logic        ready;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  
  // source clocking block 
  clocking cb_src @(posedge clk);
    default input #1ps output #1ps;
    output data, valid;
    input ready;
  endclocking : cb_src

  // destination clocking block 
  clocking cb_dtn @(posedge clk);
    default input #1ps output #1ps;
    output ready;
    input data, valid;
  endclocking : cb_dtn

  clocking cb_mon @(posedge clk);
   // USER: Add clocking block detail
    default input #1ps output #1ps;
    input ready, valid, data;
  endclocking : cb_mon


endinterface : bus_if

`endif // BUS_IF_SV
