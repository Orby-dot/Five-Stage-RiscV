/*
I know i can do this in pd.v but i wanna do it here for better var names. 
Might move this back into pd.v
*/

module bypass_excute(

    //reg values
    input wire [4:0]    rs1_decode,
    input wire [4:0]    rs2_decode,
    input wire [4:0]    rd_memory,
    input wire [4:0]    rd_write_back,

    input wire [31:0]   rs1_data_decode,
    input wire [31:0]   rs2_data_decode,
    input wire [31:0]   rd_data_memory,
    input wire [31:0]   rd_data_write_back,

    input wire [31:0]   pc,
    input wire [31:0]   imm,
    input wire [31:0]   shamt,

    //control signals
    input wire          pc_reg1_sel,
    input wire [1:0]    imm_rs2_shamt_sel,

    output reg [31:0]   rs1_data_out,
    output reg [31:0]   rs2_data_out


);
//in_a
always@(*) begin
    if(pc_reg1_sel)
        rs1_data_out = pc;

    else begin
        if(rs1_decode == rd_memory && rs1_decode !=0 )
            rs1_data_out = rd_data_memory;
        
        else if (rs1_decode == rd_write_back && rs1_decode !=0 )
            rs1_data_out = rd_data_write_back;

        else
            rs1_data_out = rs1_data_decode;
    end

end
//in_b
always@(*) begin
    case (imm_rs2_shamt_sel)
        2'b10, 2'b11 : rs2_data_out = imm;
        2'b01: rs2_data_out = shamt;
        default: begin 
            if(rs2_decode == rd_memory && rs2_decode !=0 )
                rs2_data_out = rd_data_memory;
            else if (rs2_decode == rd_write_back && rs2_decode !=0 )
                rs2_data_out = rd_data_write_back;
            else
                rs2_data_out = rs2_data_decode;
        end 

    endcase

end
endmodule