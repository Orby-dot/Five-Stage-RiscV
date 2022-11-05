module dmemory
(
  input wire    [31:0]    address,
  input wire              read_write,
  input wire    [31:0]    data_in,
  input wire   [1:0]     access_size, //<- if 0 is one byte, if 1 is half, if 2 is full word
  
  output wire   [31:0]    data_out
);

//8 byte chunks
reg [7:0] memory [`MEM_DEPTH]; //actual main memory

wire [31:0] trueAddr;
//address shift
assign trueAddr = (address-32'h01000000);

//loads the init values onto mem
integer x;
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
  
always @(*) begin
  //IF WRITE
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


  // combinational read
  assign data_out[7:0] = (memory[trueAddr]);
  assign data_out[15:8] = (memory[trueAddr + 1]);
  assign data_out[23:16] = (memory[trueAddr + 2]);
  assign data_out[31:24] = (memory[trueAddr + 3]);

endmodule
