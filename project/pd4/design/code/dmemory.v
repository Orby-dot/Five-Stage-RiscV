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

    if(read_write) begin
      memory[trueAddr] = data_in[7:0];      // always happens

      if (access_size > 0) begin 
        memory[trueAddr + 1] = data_in[15:8]; // if access_size = 1 or 2
      end

      if (access_size == 2) begin 
        memory[trueAddr + 2] = data_in[23:16];   // rest if access_size = 2
        memory[trueAddr + 3] = data_in[31:24];
      end
    end
    else begin
      memory[trueAddr] = memory[trueAddr];
    end
  end
  //end

  // combinational read

  assign data_out[7:0] = (memory[trueAddr]);
  assign data_out[15:8] = (memory[trueAddr + 1]);
  assign data_out[23:16] = (memory[trueAddr + 2]);
  assign data_out[31:24] = (memory[trueAddr + 3]);

endmodule
