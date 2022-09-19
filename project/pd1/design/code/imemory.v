module imemory(
  input wire              clock,
  input wire    [31:0]    address,
  input wire    [31:0]    read_write,
  input wire    [31:0]    data_in,
  output wire   [31:0]    data_out
);

  // load binary
  initial begin
    // temp array
    [type] temp_array;

    // load data into temp array
    readmemh(MEM_PATH, temp_array);
    
    // move data into main memory


  end

  // choose to read or write
  always @(posedge clock) begin
  if (address) begin
    if (read_write) begin
      //write
    end else begin
      // read
    end
  end

  end
endmodule
