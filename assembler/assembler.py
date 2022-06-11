import os
import sys

# define helper functions
def to_number(operand, n = 8):
    """Turns a given string/int number into an n-bit binary representation of that number

    Args:
        operand (string, int): The number to turn into an n-bit binary representation
        n (int, optional): The number of bits to return. If binary number greater than n,
        returns the n LSB of the number. Defaults to 8.

    Returns:
        int: An n-bit binary representation of the given number
    """
    if isinstance(operand, int):
        type = 'd'
        number = operand
    else:
        type = operand[0:1]
        number = operand[1:]

    if type == 'b':
        pass
    elif type == 'd':
        number = bin(int(number))[2:]
    elif type == 'h':
        number = bin(int(number, 16))[2:]

    return number.zfill(8)[-n:]

def clean_line(line):
    """Cleans a given line of assembly code by removing comments and replacing commas with spaces

    Args:
        line (string): A string that represents a line of assembly code

    Returns:
        string: A comment and punctuation free string of the line of assembly code
    """
    # remove comments
    cleaned = line
    for comment_identifier in comment_identifiers:
        cleaned = cleaned.split(comment_identifier)[0]
    
    # remove whitespace and punctuation
    cleaned = cleaned.strip().replace(",", " ")

    return cleaned

# define important contants
comment_identifiers = ["//", "#"]
label_identifiers = ["."]
imm_r_functs = ["LSH", "RSH", "ASR"]
control_functs = ["BEQ", "BNE", "BLT", "BRK"]
m_functs_dict = {
    "CMP":"0",
    "MOV":"1",
}
r_functs_dict = {
    "ADD":"0000",
    "SUB":"0001",
    "LSH":"0010",
    "RSH":"0011",
    "XOR":"0100",
    "AND":"0101",
    "ORR":"0110",
    "PAR":"0111",
    "BEQ":"1000",
    "BNE":"1001",
    "BLT":"1010",
    "BRK":"1011",
    "STR":"1100",
    "LOD":"1101",
    "TGB":"1110",
    "ASR":"1111",
}
registers = {
    "r0": "000",
    "r1": "001",
    "r2": "010",
    "r3": "011",
    "r4": "100",
    "r5": "101",
    "r6": "110",
    "r7": "111",
}

# define dynamic variables
inst_addr = 0
labels_dict = {}

cwd = os.path.dirname(os.path.abspath(__file__))

# retrieve filepath and build translated file path
filepath = sys.argv[1]
filename = os.path.basename(filepath).split(".")[0]
translated_filepath = f"{cwd}/translated/{filename}"

# creates translated directory if missing
if not os.path.exists(f"{cwd}/translated"):
    os.makedirs(f"{cwd}/translated")

with open(filepath, "r") as assembly:
    # first parse all labels from file and fill in labels dictionary
    for line in assembly:
        cleaned = clean_line(line)

        # if empty skip
        if not cleaned: continue

        # if label mark down and continue
        if cleaned[0] == ".":
            label = cleaned[:cleaned.find(":")]
            if label in labels_dict:
                print("Can't have two of the same label in a program!")
                sys.exit(1)
            labels_dict[label] = inst_addr
            continue

        # determine command and operands
        command, *operands = cleaned.split()
        command = command.upper()
        
        inst_addr += 2 if command in control_functs else 1

    # debug line
    # print(labels_dict)

    # return read cursor back to beginning of file
    assembly.seek(0)

    with open(translated_filepath, "w") as bytefile:
        for line_number, line in enumerate(assembly):
            cleaned = clean_line(line)
            
            # if empty, skip
            if not cleaned: continue
            
            # if label, skip
            if cleaned[0] == ".": continue
            
            # determine command and operands
            command, *operands = cleaned.split()
            command = command.upper()

            # debug line
            # print(f"command: {command} | operands: {operands}")

            try:
                if command == "SET":
                    instruction = f"1{to_number(operands[0])}\n"
                elif command in m_functs_dict:
                    instruction = f"01{m_functs_dict[command]}{registers[operands[0]]}{registers[operands[1]]}\n"
                elif command in imm_r_functs:
                    instruction = f"00{r_functs_dict[command]}{to_number(operands[0], 3)}\n"
                elif command in control_functs:
                    instruction = f"1{to_number(labels_dict[operands[0]])}\n"
                    bytefile.write(instruction)
                    instruction = f"00{r_functs_dict[command]}000\n"
                elif command in r_functs_dict:
                    instruction = f"00{r_functs_dict[command]}{registers[operands[0]]}\n"
                else:
                    print(f"Invalid command {command} with operands {operands} at line {line_number} in file {filepath}\n")
                    sys.exit(2)
            except:
                print(f"Invalid command {command} with operands {operands} at line {line_number} in file {filepath}\n")
                sys.exit(2)

            if instruction == "000000000":
                print(f"Illegal command at line {line_number} in file {filepath}\n")
            
            bytefile.write(instruction)
        
        # end program
        bytefile.write("000000000")
