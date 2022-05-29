`timescale 1ps/1ps
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "bus_tests.svh"
`include "bus_if.sv"
module bus_tb;
  bit clk, rst;
  initial begin
    fork
      begin 
        forever #5ns clk = !clk;
      end
      begin
        #10ns;
        rst <= 1'b1;
        #12ns;
        rst <= 1'b0;
        #10ns;
        rst <= 1'b1;
      end
    join_none
  end

  bus_if intf(clk, rst);

  initial begin
    uvm_config_db#(virtual bus_if)::set(uvm_root::get(), "uvm_test_top.env.src_agent", "vif", intf);
    uvm_config_db#(virtual bus_if)::set(uvm_root::get(), "uvm_test_top.env.dtn_agent", "vif", intf);
    run_test("bus_transaction_test");
  end

endmodule
