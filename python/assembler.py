import sys
import re

# ignore comments
lines = []
with open(sys.argv[1], 'r') as f:
  for line in f:
      lines.append(line.split('@')[0].split())
print(lines)

output = open(sys.argv[2], 'w')
r = {"r0" : "0000", # registers
     "r1" : "0001",
     "r2" : "0010",
     "r3" : "0011",
     "r4" : "0100",
     "r5" : "0101",
     "r6" : "0110",
     "r7" : "0111",
     "r8" : "1000",
     "r9" : "1001",
     "r10" : "1010",
     "r11" : "1011",
     "r12" : "1100",
     "r13" : "1101",
     "r14" : "1110",
     "r15" : "1111",
}
ar = {"r0" : "0", # arithmetic registers
      "r1" : "1" 
}

for i, line in enumerate(lines):
  code = ""
  if len(line) > 1:
    arg = line[0]
    if arg == "set":                         # 00 0/1 xxxxxx
      code = "00"                            # instruction type
      code += ar[line[1]]                    # destination
      code += "{0:06b}".format(int(line[2])) # immediate value
    if arg == "ld":
      code = "01"         # instruction type
      code += "00"        # op-code
      code += ar[line[1]] # destination register
      code += r[line[2]]  # address
    if arg == "st":
      code = "01"         # instruction type
      code += "01"        # op-code
      code += ar[line[1]] # source register
      code += r[line[2]]  # address
    if arg == "mva":
      code = "01"         # instruction type
      code += "10"        # op-code
      code += ar[line[1]] # destination register
      code += r[line[2]]  # source register
    if arg == "mvs":
      code = "01"         # instruction type
      code += "11"        # op-code
      code += ar[line[1]] # source register
      code += r[line[2]]  # destination register
    if arg == "add":
      code = "10"         # instruction type
      code += "000"       # op-code
      code += r[line[1]]  # destination register 
    if arg == "sub":
      code = "10"         # instruction type
      code += "001"       # op-code
      code += r[line[1]]  # destination register
    if arg == "and":
      code = "10"         # instruction type
      code += "010"       # op-code
      code += r[line[1]]  # destination register
    if arg == "orr":
      code = "10"         # instruction type
      code += "011"       # op-code
      code += r[line[1]]  # destination register
    if arg == "xor":
      code = "10"         # instruction type
      code += "100"       # op-code
      code += r[line[1]]  # destination register
    if arg == "rxr":
      code = "10"         # instruction type
      code += "101"       # op-code
      code += r[line[1]]  # destination register
    if arg == "lsl":
      code = "10"         # instruction type
      code += "110"       # op-code
      code += r[line[1]]  # destination register
    if arg == "lsr":
      code = "10"         # instruction type
      code += "111"       # op-code
      code += r[line[1]]  # destination register
    if arg == "b":
      code = "11"         # instruction type
      code += "00"        # op-code
      
    if arg == "beq":
      code = "11"         # instruction type
      code += "01"        # op-code

    if arg == "blt":
      code = "11"         # instruction type
      code += "10"        # op-code

    if arg == "ble":
      code = "11"         # instruction type
      code += "11"        # op-code

    if arg == "define":
      r[line[1]] = r[line[2]] # set alias
    elif i != (len(lines) - 1):
      output.write(code.strip('') + '\n')
    else:
      output.write(code.strip(''))
output.close()