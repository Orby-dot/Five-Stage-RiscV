module imemory
(
  input wire              clock,
  input wire    [31:0]    address,
  input wire              read_write,
  input wire    [31:0]    data_in,
  output wire   [31:0]    data_out
);

//8 byte chunks
reg [7:0] memory [`MEM_DEPTH]; //actual main memory

wire [31:0] trueAddr;
assign trueAddr = (address-32'h01000000);
integer x;
  // load binary
  initial begin
    // temp array
    reg [31:0]temp_array [`LINE_COUNT];

    // load data into temp array
    $readmemh(`MEM_PATH, temp_array);
    
    // move data into main memory
    for(x= 0 ; x < `LINE_COUNT ; x = x +1)begin
      memory[x*4] = temp_array[x][7:0];
      memory[x*4 + 1] = temp_array[x][15:8];
      memory[x*4+ 2] = temp_array[x][23:16];
      memory[x*4 + 3] = temp_array[x][31:24];
    end

  end

  // choose to read or write
  always @(*) begin
    // $display("Addr %h", address);
    // $display("TrueAddr %h", trueAddr);
  //if (address) begin
    if (read_write) begin
      //write
      //so this is kinda messy because of little endian
      /* i think its possible to do something like:
      memory[address + 3 : address] = data
      ^would be easy and pretty cool but idk just yet
      */
      memory[trueAddr] = data_in[7:0];
      memory[trueAddr + 1] = data_in[15:8];
      memory[trueAddr+ 2] = data_in[23:16];
      memory[trueAddr + 3] = data_in[31:24];
    end else begin
      // read
      data_out[7:0] = memory[trueAddr];
      data_out[15:8] = memory[trueAddr + 1];
      data_out[23:16] = memory[trueAddr + 2];
      data_out[31:24] = memory[trueAddr + 3];
    end
  //end

  end
endmodule
