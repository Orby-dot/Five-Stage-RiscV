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