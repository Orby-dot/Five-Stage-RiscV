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
  `ifdef VCD
  initial begin
    $dumpfile(`VCD_FILE);
    $dumpvars;
  end
  `endif

  `include "tracegen.v"
endmodule

module test
(
  input wire clock,
  input wire reset
);

  initial begin

    #10 reset = 1'b1;
    #10 reset = 1'b0;
    #10 $finish;

  end
  endmodule
