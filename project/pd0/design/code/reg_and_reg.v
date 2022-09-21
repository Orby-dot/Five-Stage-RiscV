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
  reg xin;
  reg yin;
  always @(posedge clock) begin
    if(reset) begin
      z <= 0;
      $display("Reset z=%u",z);
    end
    else
    begin
      xin <=x;
      yin <=y;
      z <= yin & xin;
      $display("z =%u , xin=%u, yin =%u , x= %u, y = %u",z,xin,yin,x,y);
    end
  end
endmodule
