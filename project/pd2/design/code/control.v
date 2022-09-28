//To decode instru

//i am going to build this a bit more than we need for the future
/*
---------CONSTANTS------------
@NOTE: We will copy all of these values but we can decide not to use them per instuction
[RD]
rd = [11:7]

[R1]
rs1 = [19:15]

[RS2]
rs2 = [24:20]

[FUNCT3]
funct3 = [14:12]

[FUNCT7]
funct7 = [31:25]

[OPCODE]
opcode = [6:0]

[SHAMT]
shamt = [24:20]


---------TYPE-----------------
if 01100xx or 01100xx then R
if 11000xx then B
if 00000xx or 00100xx or 11001xx then I
if 11011xx or 011011 or 00111 then U
if 11100xx then ECALL
------------------------------

---------FOR R TYPE-----------

[BSEL]
if x1xxxxx then Bsel = 0 
else Bsel = 1

[REG W/E]
RegW/E = 1

[DMEM W/R]
DMEM W/R = R

[WBSEL]
WBSEL = 1

[PCSEL]
PCSel = 0

[ALU]
*To do later*

[IMM]
NONE
-------------------------------

---------FOR I TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
*

[DMEM W/R]
DMEM W/R = R

[WBSEL]
*

[PCSEL]
if 0xxxxxxx then PCSel = 0
else PCSel = 1

[ALU]
*To do later*

[IMM]
immsel = 2
-------------------------------

---------FOR J TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
RedW/E = 1

[DMEM W/R]
DMEM W/R = R

[WBSEL]
1

[PCSEL]
PCSel = 1

[ALU]
add

[IMM]
imm sel = 0
-------------------------------

---------FOR B TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
RedW/E = 0

[DMEM W/R]
DMEM W/R = R

[WBSEL]
1

[PCSEL]
*

[ALU]
add

[IMM]
imm sel = 3
-------------------------------
---------FOR U TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
RedW/E = 1

[DMEM W/R]
DMEM W/R = R

[WBSEL]
1

[PCSEL]
0

[ALU]
add

[IMM]
imm sel = 1
-------------------------------

---------FOR S TYPE-----------

[BSEL]
Bsel = 1

[REG W/E]
RedW/E = 0

[DMEM W/R]
DMEM W/R = W

[WBSEL]
doesnt matter

[PCSEL]
0

[ALU]
add

[IMM]
imm sel = 4
-------------------------------


*/

/*
NOTE: old garbage MAY NOT USE

 if x1xxxxx then reg2 is used: 
----------FOR DW/E------------
 if 010xxxxx then DW/E = Write
 -----------------------------

----------FOR PC SELECT-------
 if 0xxxxxxx then PC select is 0
    -> if not then need to do a compare/check
------------------------------


----------FOR IMM SEL---------
 if xx101xx then imm sel = 1
 if xx011xx then imm sel = 0

 if xx100xx then
    if funct3 = 001 or 101 imm sel = 5
    else immsel = 2

 if xx000xx then
    if 01000xx then imm sel 4
    if 00000xx then imm sel 2
    if 11000xx then imm sel 3
------------------------------


*/

module control (
    //input wire inst_rdy,
    input wire [31:0] inst

    output wire [6:0] opcode,
    output wire [4:0] rd,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [2:0] funct3,
    output wire [6:0] funct7,
    output wire [31:0] imm,
    output wire [4:0] shamt
);

assign opcode = inst[6:0];
assign rd =     inst[11:7];
assign rs1 =    inst[19:15];
assign rs2 =    inst[24:20];
assign funct3 = inst[14:12];
assign funct7 = inst[31:25];
assign shamt =  inst[24:20];

assign imm = ((opcode & 7'b100 0000 > 0) && (!opcode & 7'b001 0100 > 1 ) ) ? {19{inst[31]},inst[11],inst[30:25],inst[11:8],1'b0}: //B
            ((opcode & 7'b001 0100 > 0) && (!opcode & 7'b100 0000 > 1 ) ) ? {inst[31],inst[30:20],inst[19:12],12{1'b0}}://U
            ((opcode & 7'b100 0100 > 0) && (!opcode & 7'b001 0000 > 1 )) ? {11{inst[31]}, inst[19:12], inst[20],inst[30:25],inst[24:21],1'b0}: //j
            ((opcode[6:3] & 7'b010> 0) && (!opcode[6:3] & 7'b101> 1 )) ? {19{inst[31]},inst[30:25],inst[11:8],inst[7]}://s
            ((opcode[6:3] & 3'b111> 0) ?: 31{1'b0}:// ecall
            {19{inst[31]},inst[30:25],inst[24:21],inst[20]};



/*
@always()begin
    //i think i might be able to do this with combinational logic
    case (opcode[6:2]) 
        5'b01100,5'b00100: ;            //rtype
        5'b11000: ;                     //b type
        5'b00000, 5'b00100, 5'b11001: ; // i type
        5'b11011, 5'b01101, 5'b00111: ; //u type
        5'11100: ;  //ecall
        default:
    endcase
end
*/
endmodule
