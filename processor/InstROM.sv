// Create Date:    15:50:22 10/02/2019
// Project Name:   CSE141L
// Module Name:    InstROM 
// Description: Instruction ROM template preprogrammed with instruction values
// (see case statement)
//
// Revision:       2020.08.08
// Last Update:    2022.01.13

// Parameters:
//  A: Number of address bits in instruction memory
//  W: Width of instruction memory entry
module InstROM #(parameter A=10, W=9) (
    input [A-1:0] inst_addr,
    output [W-1:0] inst_out
);

// Declare 2-dimensional array, W bits wide, 2**A words deep
logic [W-1:0] ROM[2**A];

// reads are combinational
assign inst_out = ROM[inst_addr];

// Load the initial contents of memory
initial begin
    $readmemb("./instructions",ROM);
end

endmodule
