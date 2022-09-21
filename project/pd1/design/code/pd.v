module pd
#(parameter  MEM_DEPTH = 32'd1048576)
(
  input clock,
  input reset
);
reg address;
reg read_write;
reg data_in;
reg data_out;
imemory mem0 (
  .clock(clock),
  .address(address),
  .read_write(1'b0),//hard coded for pd1
  .data_in(data_in),
  data_out(data_out)

);
endmodule
