define lfsrStorage r15
define tapPattern r14
define startState r13
define state r12
define i r11
define j r10
define truePattern r9
define cmpRegister r8
define parityBit r7
define result r6
define address r5
define ctr r4

  @ Load LFSR start state into r13
  set r0 32
  set r1 1
  lsl r0 @ r0 = 64
  ld r1 r0
  mvs r1 startState

  set r0 32
  set r1 2
  lsl lfsrStorage @ r0 = 128

  @ tap pattern 0x60
  set r0 48
  set r1 1
  lsl r0
  mva r1 lfsrStorage
  st r0 r1

  @ tap pattern 0x48
  set r0 36
  set r1 1
  lsl tapPattern
  mva r0 lfsrStorage
  set r1 1
  add r1
  mva r0 tapPattern
  st r0 r1

  @ tap pattern 0x78
  @   <<60
  set r0 60
  set r1 1
  lsl tapPattern
  mva r0 lfsrStorage
  set r1 2
  add r1
  mva r0 tapPattern
  st r0 r1
  
  @ tap pattern 0x72 (114)
  @   <<57
  set r0 57
  set r1 1
  lsl tapPattern
  mva r0 lfsrStorage
  set r1 3
  add r1
  mva r0 tapPattern
  st r0 r1

  @ tap pattern 0x6A
  @   <<53
  set r0 53
  set r1 1
  lsl tapPattern
  mva r0 lfsrStorage
  set r1 4
  add r1
  mva r0 tapPattern
  st r0 r1
  
  @ tap pattern 0x69
  @   <<52 + 1
  set r0 57
  set r1 1
  lsl r0
  add tapPattern
  mva r0 lfsrStorage
  set r1 5
  add r1
  mva r0 tapPattern
  st r0 r1

  @ tap pattern 0x5C
  @   <<46
  set r0 46
  set r1 1
  lsl tapPattern
  mva r0 lfsrStorage
  set r1 6
  add r1
  mva r0 tapPattern
  st r0 r1

  @ tap pattern 0x7E
  @   <<63
  set r0 63
  set r1 1
  lsl tapPattern
  mva r0 lfsrStorage
  set r1 7
  add r1
  mva r0 tapPattern
  st r0 r1

  @ tap pattern 0x7B
  @   <<61 + 1   
  set r0 61
  set r1 1
  lsl r0
  add tapPattern
  mva r0 lfsrStorage
  set r1 8
  add r1
  mva r0 tapPattern
  st r0 r1

@ Start of finding LFSR TRUE pattern

  @ Start i loop
  set r0 0
  mvs r0 i

for_i:

  @ state = startState
  mva r0 startState 
  mvs r0 state

  @   tapPattern = data_mem[128+i]
  mva r0 lfsrStorage
  mva r1 i
  add r1
  ld r0 r1
  mvs r0 tapPattern
  
  @ Start j loop
  set r0 0
  mvs r0 j

for_j:
  
  @     result = state
  mva r0 state
  mvs r0 result

  @     result[7] = ^state
  rxr parityBit

  mva r0 parityBit
  set r1 7
  lsl r0 @ = x0000000
  mva r1 result
  orr result

  @     new_state[0] = ^state
  @     new_State[6:1] = start[5:0]
  @     state = new_state
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
  
  
@ if (data_mem[64+j] == result)
@   if (j == 9)
@     truePattern = tapPattern
@     go to end
@ else 
@   go to j end
  
  set r0 32
  set r1 1
  lsl r0
  mva r1 j
  add r1
  ld r0 r1
  mva r1 result
  sub cmpRegister
  bne for_j_end

  set r0 9
  mva r1 j
  sub cmpRegister
  bne j_upkeep

  mva r0 tapPattern
  mvs r0 truePattern
  b for_i_end
  
j_upkeep:

  @J upkeep
  mva r0 j
  set r1 1
  add j
  mva r0 j
  set r1 10
  sub cmpRegister
  @End j?
  blt for_j


for_j_end:

  @ I upkeep
  mva r0 i
  set r1 1
  add i
  mva r0 i
  set r1 9
  sub cmpRegister
  @ End i?
  blt for_i

for_i_end:

  mva r0 startState 
  mvs r0 state

  set r0 0
  mvs r0 i

  set r0 0
  mvs r0 ctr

THE_final_for:

  set r0 32
  set r1 1
  lsl r0 @64
  mva r1 i 
  add address @64 + i
  
  @mask w/ 127
  @xor it
  @compare with parity bit
  @if we're not good:
  @     insert error character 0x80
  @ otherwise we decrypt:
  @     if character is space:
  @         ignore character
  @     else
  @         writeback
  set r0 63
  set r1 1
  lsl r0
  add r1 @mask = 127
  ld r0 address @load in character at index
  and r0 @and with mask
  rxr parityBit @rxr 7 bits to isolate
  
  set r0 32
  set r1 2 
  lsl r0 @ 128
  ld r1 address
  and r0 @ and contents of r1 w/ mask to isolate parity bit
  @ X10101010
  set r1 7
  lsr r0 @positioning parity bit
  mva r1 parityBit
  sub cmpRegister
  beq We_Gucci

  @insert error character, 0x80
  set r0 32
  set r1 2 
  lsl r0 @ 128
  st r0 ctr

  mva r0 ctr
  set r1 1
  add ctr

  b i_comparison
  
  @   else
We_Gucci:
  @       if (character is space)
  @         skip character
  @         i++
  @         continue
  @       character = state ^ character
  @       character = character + 32
  @       data_mem[ctr] = character
  @       ctr++
  @       i++
  ld r0 address
  mva r1 state
  xor r0
  set r1 32
  add result

  @ Get rid of parity bit before writing back
  set r0 63
  set r1 1
  lsl r0
  add r0
  mva r1 result
  and result

  @ Check if space, if true -> i_comparison
  mva r0 result
  set r1 32
  sub cmpRegister
  beq i_comparison 
  
  @If character is not a space, writeback, increment counter
  mva r0 result
  st r0 ctr

  mva r0 ctr
  set r1 1
  add ctr

i_comparison:

  @ new_state[0] = ^state
  @ new_State[6:1] = start[5:0]
  @ state = new_state
  @ new_state[0] = ^(state&pattern)
  mva r0 state
  mva r1 truePattern
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

  mva r0 i
  set r1 1
  add i

  set r0 63
  set r1 1
  add r1

  mva r0 i

  sub cmpRegister
  @ End i?
  blt THE_final_for

end_THE_final_for:
  @ while (i < 64)
  @   character = data_mem[64+i]
  @   if (character's parity bit is wrong)
  @       data_mem[ctr] = 0x80
  @       ctr++
  @       i++
  @   else
  @       if (character is space)
  @         skip character
  @         i++
  @         continue
  @       character = state ^ character
  @       character = character + 32
  @       data_mem[ctr] = character
  @       ctr++
  @       i++
          
  halt please