module imemory
(
  input wire              clock,
  input wire    [31:0]    address,
  input wire    [31:0]    read_write,
  input wire    [31:0]    data_in,
  output wire   [31:0]    data_out
);

//8 byte chunks
reg [7:0] memory [MEM_DEPTH]; //actual main memory

  // load binary
  initial begin
    // temp array
    [type] temp_array;

    // load data into temp array
    readmemh(`MEM_PATH, temp_array);
    
    // move data into main memory


  end

  // choose to read or write
  always @(posedge clock) begin
  if (address) begin
    if (read_write) begin
      //write
      //so this is kinda messy because of little endian
      /* i think its possible to do something like:
      memory[address + 3 : address] = data
      ^would be easy and pretty cool but idk just yet
      */
      memory[address] <= data_in[7:0];
      memory[address + 1] <= data_in[15:8];
      memory[address+ 2] <= data_in[23:16];
      memory[address + 3] <= data_in[31:24];
    end else begin
      // read
    end
  end

  end
endmodule
