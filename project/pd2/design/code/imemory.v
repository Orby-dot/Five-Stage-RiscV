module imemory
(
  input wire              clock,
  input wire    [31:0]    address,
  input wire              read_write,
  input wire    [31:0]    data_in,
  output reg   [31:0]    data_out
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
  always @(posedge clock)begin
    if (read_write) begin
      //write
      memory[trueAddr] = data_in[7:0];
      memory[trueAddr + 1] = data_in[15:8];
      memory[trueAddr+ 2] = data_in[23:16];
      memory[trueAddr + 3] = data_in[31:24];
    end
  end

  //read
  always @(*) begin
    // $display("Addr %h", address);
    // $display("TrueAddr %h", trueAddr);
    if (!read_write) begin
      data_out = {memory[trueAddr + 3],memory[trueAddr + 2],memory[trueAddr + 1],memory[trueAddr]};
    end
  end
endmodule
