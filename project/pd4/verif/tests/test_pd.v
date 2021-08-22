// DO NOT rely on this file, it will be changed with a fresh one
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

  `include "tracegen.v"
endmodule
