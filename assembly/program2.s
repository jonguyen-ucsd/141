@ ld, st, and, orr, xor, rxr, lsl, lsr

set r1 38 @ r1 = 38, 0010 0110
set r0 7 @r0 = 7, 0000 0111
and r2 @ 38 & 7 = 6, 0000 0110
orr r2 @ 38 | 7 = 39, 0010 0111
xor r2 @ 38 ^ 7 = 33, 0010 0001
rxr r2 @ ^r0 = 1

set r0 38 
set r1 2 
lsl r0 @ 152
lsr r0 @ 38 again

set r1 1
st r0 r1
ld r1 r1