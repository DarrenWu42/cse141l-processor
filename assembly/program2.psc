src_addr = 31
dest_addr = 1

for src_addr < 61:
    high_byte = mem[src_addr]
    low_byte = mem[src_addr-1]

    // calculate calculated parities
    supp_par[4] = ^high_byte[7:1]
    supp_par[3] = (^high_byte[7:4])^(^low_byte[7:5])
    supp_par[2] = (^high_byte[7:6, 3:2])^(^low_byte[7:6, 3])
    supp_par[1] = (^high_byte[7, 5, 3, 1])^(^low_byte[7, 5, 3])
    supp_par[0] = (^high_byte[7:1])^(^low_byte[7:5])^low_byte[3]^supp_par[4]^supp_par[3]^supp_par[2]^supp_par[1]

    // retrieve given parities
    given_par[4:0] = {high_byte[0], low_byte[4], low_byte[2], low_byte[1], low_byte[0]}

    // calculate position of error
    error_pos = supp_par[4:1]^given_par[4:1]

    new_high_byte
    new_low_byte

    if (^high_byte)^(^low_byte): // if reduction xor of high and low byte gives 1, 1 error
        new_high_byte[7:3] = 01000; // set status bits
        // invert error
        if error_pos >= 8:
            high_byte[error_pos - 8] = ~high_byte[error_pos - 8]
        else:
            low_byte[error_pos] = ~low_byte[error_pos]
    else if supp_par == given_par: // parities equal so 0 errors, do nothing
        new_high_byte[7:3] = 00000; // set status bits
    else:  // else 2 errors, give up
        new_high_byte[7:3] <= 5'b10000; // set status bits

    new_high_byte[2:0] = high_byte[7:5]
    new_low_byte = {high_byte[4:1], low_byte[7:5, 3]

    mem[dest_addr] = new_high_byte
    mem[dest_addr-1] = new_low_byte

    src_addr += 2
    dest_addr += 2