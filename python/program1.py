message = "Mr. Watson, come here. I want to see you."
dataMem = []

# null fill dataMem
for i in range(128):
  dataMem.append('')

# set padding
mSize = min(len(message), 52)
# Preamble length
dataMem[61] = 52 - mSize
# Set pattern
dataMem[62] = 0x60
# Set initial state
dataMem[63] = 0x1

# write in message
for i in range(mSize):
  dataMem[i] = message[i]

# TODO: Add code to check if space length between 10-15

# for i in range(dataMem[61]):
#   dataMem[i] = ' '

class LFSR():
  def __init__(self, start, taps):
    self.state = start
    self.taps = taps

  def cycle(self):
    self.state = ((self.state << 1) | self.reduction_xor(self.state & self.taps)) & 0x7F

  def reduction_xor(self, x):
    r = 0
    for i in range(7):
      r = r ^ ((x >> i) & 1)
    return r

#print(dataMem)
# Create LFSR
lfsr = LFSR(dataMem[63], dataMem[62])
start_index = 64

# Encrypt prepended spaces
for i in range(dataMem[61]):
  dataMem[start_index + i] = (lfsr.state ^ 0x20) - 0x20
  lfsr.cycle()

start_index += dataMem[61]
print(mSize)

# Encrypt message
for i in range(mSize):
  dataMem[start_index + i] = (lfsr.state ^ ord(dataMem[i])) - 0x20
  lfsr.cycle()
  print(i)
  

start_index += mSize

# Encrypt appended spaces
for i in range(start_index, 128):
  dataMem[i] = (lfsr.state ^ 0x20) - 0x20
  lfsr.cycle()

print(dataMem)

