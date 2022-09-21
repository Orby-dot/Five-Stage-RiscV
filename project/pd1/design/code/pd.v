module pd
(
  input clock,
  input reset
);
reg [31:0]    address;
reg           read_write;
reg [31:0]    data_in;
reg [31:0]    data_out;
imemory mem0 (
  .clock(clock),
  .address(address),
  .read_write(1'b0),//hard coded for pd1
  .data_in(data_in),
  .data_out(data_out)

);

initial begin
  address = 32'h01000000;
end

always @(posedge clock) begin
  if(reset)
    address = 32'h01000000;

  else
    address = address - 4;
end
endmodule
