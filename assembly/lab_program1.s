define numSpaces r15
define tapPattern r14
define state r13
define i r12
define beforeParity r10
define address r9
define parityBit r8
define cmpRegister r11

  @ Load numspaces into r15, check it is greater than 10
  @ if (numSpaces < 10)
  @     numspaces = 10
  set r0 61
  ld r1 r0
  mvs r1 numSpaces 

  mva r0 numSpaces
  set r1 10
  sub cmpRegister
  bge if_ge_10 @ opposite logic
  set r1 10 @ num spaces is less than 10
  mvs r1 numSpaces

  @ branch if number of spaces less than 15
  @ if (numspaces > 15)
  @   numSpaces = 15
if_ge_10: 
  mva r0 numSpaces
  set r1 15
  sub cmpRegister
  ble if_le_15  @ check if numspaces <= 15
  set r0 15
  mvs r0 numSpaces

  @ Hello please load LFSR tap pattern
if_le_15:
  @ Load LFSR tap pattern into r14
  set r0 62 @ line 15
  ld r1 r0 
  mvs r1 tapPattern

  @ Load LFSR start state into r13
  set r0 63
  ld r1 r0
  mvs r1 state

  @ Initialize index i
  set r0 0 @line 21
  mvs r0 i

  @ for (int i = 0; i < numSpaces; ++i)
  @   data_mem[64+i] = state ^ 0x20 
  @   new_state[0] = ^state
  @   new_State[6:1] = start[5:0]
  @   state = new_state

for:
  mva r0 i
  mva r1 numSpaces
  sub cmpRegister
  bge end_for @ i >= numSpaces opposite logic to exit loop
  
  @ data_mem[64+i] = state ^ (0x20 - 0x20) 
  mva r0 state
  set r1 0
  xor beforeParity
  
  @ set r0 to 64 due to immediate limit being 63
  set r0 32
  set r1 1  @line 31
  lsl r0 @ r0 = 64
  mva r1 i @line 32
  add address @ = 64 + i

  mva r0 beforeParity @r0 = beforeParity = state ^ 0x20
  set r1 1
  lsl r0 @ delete top bit
  lsr r0
  rxr parityBit @ calculate parity of [6:0]

  mva r0 parityBit
  set r1 7
  lsl r0 @ = x0000000
  mva r1 beforeParity 
  orr r0
  st r0 address

  @ new_state[0] = ^(state&pattern)
  mva r0 state
  mva r1 tapPattern
  and r0
  rxr r2

  @ new_State[6:1] = start[5:0]
  mva r0 state
  set r1 2
  lsl r0
  set r1 1
  lsr r3
  mva r0 r3

  @ state = new_state
  mva r1 r2
  orr state

  @ ++i
  mva r0 i
  set r1 1
  add i

  b for

end_for:

@ for (int i = 0; i < 64-numSpaces; ++i)
@   data_mem[64+i+numSpaces] = (data_mem[i] - 0x20) ^ state
@   new_state[0] = ^state
@   new_State[6:1] = start[5:0]
@   state = new_state

@ Initialize index i
  set r0 0
  mvs r0 i

for_2: 
  set r0 63
  mva r1 numSpaces
  sub r0
  set r1 1
  add r1 @ r1 = 64 - numSpaces

  mva r0 i
  sub cmpRegister
  bge end_for_2 @ check if i >= 64 - numSpaces, opposite logic

  @ data_mem[64+i] = (data_mem[i] - 0x20) ^ state
  ld r0 i
  set r1 32
  sub r0
  mva r1 state
  xor beforeParity

  @ set r0 to 64 due to immediate limit being 63
  set r0 32
  set r1 1
  lsl r0 @ r0 = 64
  mva r1 i 
  add r0 @ r0 = 64 + i
  mva r1 numSpaces
  add address @ address = 64 + i + numSpaces

  mva r0 beforeParity @r0 = beforeParity = (data_mem[i] - 0x20) ^ state
  set r1 1
  lsl r0 @ delete top bit
  lsr r0
  rxr parityBit @ calculate parity of [6:0]

  mva r0 parityBit
  set r1 7
  lsl r0 @ = x0000000
  mva r1 beforeParity 
  orr r0
  st r0 address

@bottom
  @ new_state[0] = ^(state&pattern)
  mva r0 state
  mva r1 tapPattern
  and r0
  rxr r2

  @ new_State[6:1] = start[5:0]
  mva r0 state
  set r1 2
  lsl r0
  set r1 1
  lsr r3
  mva r0 r3

  @ state = new_state
  mva r1 r2
  orr state

  @ ++i
  mva r0 i
  set r1 1
  add i

  b for_2

end_for_2:

  halt please