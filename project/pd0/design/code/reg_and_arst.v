/**
* Exercise 3.3 
* you can change the code below freely
  * */
module reg_and_arst(
  input  wire clock,
  input  wire areset,
  input  wire x,
  input  wire y,
  output reg  z
);

  always @(posedge clock, posedge areset) begin
    if(areset)begin
      z=0;
    end
    else
    begin
    z = x & y;
    end
  end
endmodule
