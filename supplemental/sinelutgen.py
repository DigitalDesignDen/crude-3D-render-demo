import numpy as np

for i in range (0, 64):
    arg = i*np.pi/2/63
    sine_value= np.sin(arg)
    print(f"to_sfixed({sine_value}, 10, -8),")