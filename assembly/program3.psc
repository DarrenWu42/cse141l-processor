curr_addr = 0
curr_byte = mem[curr_addr]
pattern = mem[32]

within_bounds_count = 0
byte_count = 0
without_bounds_count = 0

while 1:
    // within bounds section
    for i = 0 to 3:
        if curr_byte[7:3] == pattern[7:3]:
            within_bounds_count++
            without_bounds_count++
            if ~byte_count[7]:
                byte_count++
                byte_count[7] = 1
        curr_byte = curr_byte << 1
    byte_count[7] = 0
    
    curr_addr++
    if curr_addr = 33:
        break
    
    // without bounds section
    next_byte = mem[curr_addr]

        // this isn't in a for loop since at this point I run out of registers
        // and i refuse to resorting to storing and laoding variables
    curr_byte[7:3] = {curr_byte[7:4], next_byte[7]}
    if curr_byte[7:3] == pattern[7:3]:
        without_bounds_count++
    
    curr_byte[7:3] = {curr_byte[6:3], next_byte[6]}
    if curr_byte[7:3] == pattern[7:3]:
        without_bounds_count++

    curr_byte[7:3] = {curr_byte[6:3], next_byte[5]}
    if curr_byte[7:3] == pattern[7:3]:
        without_bounds_count++

    curr_byte[7:3] = {curr_byte[6:3], next_byte[4]}
    if curr_byte[7:3] == pattern[7:3]:
        without_bounds_count++
    
    curr_byte = next_byte // for next iteration

mem[33] = within_bounds_count
mem[34] = byte_count
mem[35] = without_bounds_count