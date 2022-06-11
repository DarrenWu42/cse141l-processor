`timescale 1ns/ 1ps

// Test bench
// Arithmetic Logic Unit
module ALU_tb;

// Define signals to interface with the ALU module
logic [7:0] input_a;    // data inputs
logic [7:0] input_b;
logic [3:0] op;         // ALU opcode
logic op_cmp;
wire [7:0] out;
wire zero;
wire less_than;

// Define a helper wire for comparison
logic [7:0] expected_out;
logic expected_zero;
logic expected_less_than;

// Instatiate and connect the Unit Under Test
ALU DUT(
    .input_a(input_a),
    .input_b(input_b),
    .op(op),
    .op_cmp(op_cmp),
    .out(out),
    .zero(zero),
    .less_than(less_than)
);

// The actual testbench logic
initial begin
    // test several comparisons
    op_cmp = 1;

    input_a = 0;
    input_b = 0;
    test_alu_func; // void function call
    #5;

    input_a = 1;
    input_b = 1;
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 10;
    test_alu_func; // void function call
    #5;

    input_a = 255;
    input_b = 255;
    test_alu_func; // void function call
    #5;

    input_a = 0;
    input_b = 1;
    test_alu_func; // void function call
    #5;

    input_a = 0;
    input_b = 10;
    test_alu_func; // void function call
    #5;

    input_a = 1;
    input_b = 10;
    test_alu_func; // void function call
    #5;

    input_a = 1;
    input_b = 255;
    test_alu_func; // void function call
    #5;

    input_a = 1;
    input_b = 0;
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 0;
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 1;
    test_alu_func; // void function call
    #5;

    input_a = 255;
    input_b = 1;
    test_alu_func; // void function call
    #5;

    // test each ALU operation
    op_cmp = 0;

    input_a = 0;
    input_b = 0;
    op= 'b0000; // ADD
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 1;
    op= 'b0000; // AND
    test_alu_func; // void function call
    #5;

    input_a = 0;
    input_b = 0;
    op= 'b0001; // SUB
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 1;
    op= 'b0001; // SUB
    test_alu_func; // void function call
    #5;

    input_a = 0;
    input_b = 1;
    op= 'b0010; // LSH
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 1;
    op= 'b0010; // LSH
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 2;
    op= 'b0010; // LSH
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 1;
    op= 'b0010; // RSH
    test_alu_func; // void function call
    #5;

    input_a = 10;
    input_b = 2;
    op= 'b0010; // RSH
    test_alu_func; // void function call
    #5;

    input_a = 'b01;
    input_b = 'b10;
    op= 'b0011; // XOR
    test_alu_func; // void function call
    #5;

    input_a = 'b10;
    input_b = 'b10;
    op= 'b0011; // XOR
    test_alu_func; // void function call
    #5;

    input_a = 'b01;
    input_b = 'b10;
    op= 'b0100; // AND
    test_alu_func; // void function call
    #5;

    input_a = 'b10;
    input_b = 'b10;
    op= 'b0100; // AND
    test_alu_func; // void function call
    #5;

    input_a = 'b01;
    input_b = 'b10;
    op= 'b0101; // ORR
    test_alu_func; // void function call
    #5;

    input_a = 'b10;
    input_b = 'b10;
    op= 'b0101; // ORR
    test_alu_func; // void function call
    #5;

    input_a = 'b10101010;
    input_b = 'b0;
    op= 'b0110; // PAR
    test_alu_func; // void function call
    #5;

    input_a = 'b10101011;
    input_b = 'b0;
    op= 'b0110; // PAR
    test_alu_func; // void function call
    #5;

    input_a = 'b10101010;
    input_b = 0;
    op= 'b1110; // TGB
    test_alu_func; // void function call
    #5;

    input_a = 'b10101010;
    input_b = 1;
    op= 'b1110; // TGB
    test_alu_func; // void function call
    #5;

    input_a = 'b10101010;
    input_b = 1;
    op= 'b1111; // ASR
    test_alu_func; // void function call
    #5;

    input_a = 'b10101010;
    input_b = 2;
    op= 'b1111; // ASR
    test_alu_func; // void function call
    #5;

    input_a = 'b00101010;
    input_b = 1;
    op= 'b1111; // ASR
    test_alu_func; // void function call
    #5;

    input_a = 'b00101010;
    input_b = 2;
    op= 'b1111; // ASR
    test_alu_func; // void function call
    #5;
end

task test_alu_func;
    if(op_cmp) begin
        expected_zero = (input_a == input_b);
        expected_less_than = (input_b < input_a);
        #1;
        if(expected_zero == zero && expected_less_than == less_than) begin
            $display("%t YAY!! inputs = %h %h, op_cmp = %b, zero %b, less_than %b",$time, input_a, input_b, op_cmp, zero, less_than);
        end 
        else begin
            $display("%t FAIL! inputs = %h %h, op_cmp = %b, zero %b, less_than %b",$time, input_a, input_b, op_cmp, zero, less_than);
        end
    end
    else begin
        case (op)
            0 : expected_out = input_b + input_a;
            1 : expected_out = input_a + (~input_b) + 1;
            2 : expected_out = input_b << input_a;
            3 : expected_out = input_b >> input_a;
            4 : expected_out = input_b ^ input_a;
            5 : expected_out = input_b & input_a;
            6 : expected_out = input_b | input_a;
            7 : expected_out = ^input_a;
            14 : begin
                expected_out = input_b;
                expected_out[input_a] = ~input_b[input_a];
            end
            15 : expected_out = input_b >>> input_a;
            default : expected_out = input_a;
        endcase
        #1;
        if(expected_out == out) begin
            $display("%t YAY!! inputs = %h %h, op_cmp = %b, opcode = %b",$time, input_a, input_b, op_cmp, op);
        end 
        else begin
            $display("%t FAIL! inputs = %h %h, op_cmp = %b, opcode = %b",$time, input_a, input_b, op_cmp, op);
        end
    end
endtask

initial begin
    $dumpfile("alu.vcd");
    $dumpvars();
    $dumplimit(104857600); // 2**20*100 = 100 MB, plenty.
end

endmodule
