
`include "signals.h"

module top;
  wire clock, reset;
  clockgen clkg(
    .clk(clock),
    .rst(reset)
  );
  design_wrapper dut(
    .clock(clock),
    .reset(reset)
  );
  `ifdef VCD
  initial begin
    $dumpfile(`VCD_FILE);
    $dumpvars;
  end
  `endif

  `include "tracegen.v"
endmodule

module my_test(

  input clock,
  input reset);
  pd1 pd(.clock(clock),.reset(reset));
  initial begin

    #10 reset = 1'b1;
    #10 reset = 1'b0;
    #10 $finish;

  end
  endmodule