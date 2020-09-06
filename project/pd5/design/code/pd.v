module pd(
  input clock,
  input reset
);
  reg [31:0] pc;
  always @(posedge clock) begin
    if(reset) pc <= 0;
    else pc <= pc + 1;
  end
endmodule
