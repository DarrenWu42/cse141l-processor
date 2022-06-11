src_addr = 1
dest_addr = 31

for src_addr < 31:
    high_byte = mem[src_addr]
    low_byte = mem[src_addr-1]

    p0 = (^high_byte)^(^low_byte)

    new_high_byte[7:1] = {high_byte[2:0],low_byte[7:4]}

    p8 = (^high_byte)^(^low_byte[7:4])
    p0 = p0^p8
    new_high_byte[0] = p8

    mem[dest_addr] = new_high_byte

    new_low_byte[7:5] = low_byte[4:2]
    new_low_byte[3] = low_byte[0]

    p4 = (^high_byte)^(^low_byte[7, 3:1])
    p0 = p0^4
    new_low_byte[4] = p4

    p2 = (^high_byte[2:1])^(^low_byte[6:5, 3:2, 0])
    p0 = p0^p2
    new_low_byte[2] = p2

    p1 = (^high_byte[2, 0])^(^low_byte[6, 4:3, 1:0])
    p0 = p0^p1
    new_low_byte[1] = p1

    new_low_byte[0] = p0
    mem[dest_addr-1] = new_low_byte

    src_addr += 2
    dest_addr += 2