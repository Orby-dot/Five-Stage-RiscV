/**
* Exercise 3.4
* you can change the code below freely
  * */
module reg_and_reg(
  input wire clock,
  input wire reset,
  input wire x,
  input wire y,
  output reg z
);
  always @(*) begin
    z = x & y;
  end
endmodule
