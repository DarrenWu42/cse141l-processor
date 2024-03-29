// Create Date:    2017.01.25
// Design Name:    CSE141L
// Module Name:    DataMem
// Last Update:    2022.01.13

// Memory can only read _or_ write each cycle, so there is justi a single
// address pointer for both read and write operations.
//
// Parameters:
//  - A: Address Width. This controls the number of entries in memory
//  - W: Data Width. This controls the size of each entry in memory
// This memory can hold `(2**A) * W` bits of data.
module DataMem #(parameter W=8, A=8) (
    input clk,
            reset,
            write_en,
    input [A-1:0] data_addr,    // A-bit-wide pointer to 256-deep memory
    input [W-1:0] data_in,      // W-bit-wide data path, also
    output logic [W-1:0] data_out
);

// 8x256 two-dimensional array -- the memory itself
logic [W-1:0] Core[0:2**A-1];

// reads are combinational
always_comb data_out = Core[data_addr];

// writes are sequential
always_ff @ (posedge clk)
    if(write_en) Core[data_addr] <= data_in;
endmodule
