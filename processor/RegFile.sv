// Create Date:    2019.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
// Revision:       2022.05.04
// Additional Comments: 	allows preloading with user constants

module RegFile #(parameter W=8, D=3)(   // W = data path width (leave at 8); D = address pointer width
    input clk,
            reset,
            write_en,
    input [D-1:0] src_addr,
                    dest_addr,
    input [W-1:0] data_in,
    output [W-1:0] data_out_src,
                    data_out_dest
);

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];

// combinational reads 
assign data_out_src = Registers[src_addr];
assign data_out_dest = Registers[dest_addr];

// sequential (clocked) writes 
always_ff @ (posedge clk) begin
    integer i;
    if (reset) begin
        for (i=0; i<2**D; i=i+1) Registers[i] <= '0;
    end 
    else if (write_en) Registers[dest_addr] <= data_in;
end

endmodule
