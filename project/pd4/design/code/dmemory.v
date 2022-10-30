module dmemory
(
  input wire    [31:0]    address,
  input wire              read_write,
  input wire    [31:0]    data_in,
  input wire   [1:0]     access_size, //<- if 0 is one byte, if 1 is half, if 2 is full word
  output wire   [31:0]    data_out
);
/*THINGS TO DO
- allow half word and byte writes
- i can deal with reads outside of this module
- 

*/

//8 byte chunks
reg [7:0] memory [`MEM_DEPTH]; //actual main memory

wire [31:0] trueAddr;
assign trueAddr = (address-32'h01000000);
integer x;
  
  always @(*) begin
    // $display("Addr %h", address);
    // $display("TrueAddr %h", trueAddr);

    if (read_write) begin
      //write
      memory[trueAddr] = data_in[7:0];
      memory[trueAddr + 1] = data_in[15:8];
      memory[trueAddr+ 2] = data_in[23:16];
      memory[trueAddr + 3] = data_in[31:24];
    end
  //end

  // combinational read

  assign data_out[7:0] = (memory[trueAddr] & {8{!read_write}} );
  assign data_out[15:8] = (memory[trueAddr + 1] & {8{!read_write}} );
  assign data_out[23:16] = (memory[trueAddr + 2] & {8{!read_write}} );
  assign data_out[31:24] = (memory[trueAddr + 3] & {8{!read_write}} );

  end
endmodule
