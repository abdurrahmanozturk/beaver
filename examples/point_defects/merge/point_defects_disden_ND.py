import numpy as np
import pandas as pd
import math

#Material Properties For Nickel
T=873 #K
kB = 8.617e-5 # ev/K
Qi = 0.3 #ev
Di0 = 1e-7 #m2/s
Qv = 1.3 #ev
Dv0 = 6e-5 #m2/s
Di = Di0*np.exp(-Qi/(kB*T))  #m2/s
Dv = Dv0*np.exp(-Qv/(kB*T))  #m2/s
Cv_e = np.exp(-1.6/(kB*T))
Nickel= {'Di': Di,
         'Dv': Dv,
         'Cv_e': Cv_e,
         'b': 2.5e-10,
         'Atomic Volume': 1.206e-29,
         'B': 0.1,
         'delta_B': 0.005,
         'rv_0': 1.5e-9,
         'rho_n': 1e14,
         'K': 1e-3,
         'epsilon': 0.1,
         'N': 1e22 }

# Parameter Calculations
data = Nickel
ZiN = 1+data['B']
ZiI = ZiN
ZiV = ZiN
ZvN = 1
ZvI = ZvN
ZvV = ZvN
ZvC = ZvN
ZiC = ZvN
l = 1e-9            #length scale {m}
beta = l*l          #{m^2}
w = beta/data['Di'] #time scale   {s}
alpha =  1e-9       #recombination rate {1/s}
gamma = w*alpha     #{unitless}
B = data['B']       #{unitless}
xvL = gamma*Cv_e    #{unitless}
Zix = ZiN #ZiI=ZiN=ZiV=1+B           #{unitless}
Zvx = ZvN #ZvI=ZvN=ZvV=ZvC=ZiC = 1   #{unitless}
K = data['K']            #{dpa/s}
N = data['N']            #{1/m^3}
rho_n = data['rho_n']    #{1/m^2}
Rv = data['rv_0']    #{m}
b = data['b']    #{m}
print(data)
print("\nl\t= ", l)
print("w\t= ", w)
print("Di\t= ", Di)
print("Dv\t= ", Dv)
print("K\t= ", K)
print("alpha\t= ",alpha)
print("beta\t= ",beta)
print("gamma\t= ",gamma)
print("B\t= ", B)
print("Zix\t= ", Zix)
print("Zvx\t= ", Zvx)
print("epsilon\t= ", data['epsilon'])
print("N\t= ", N)
print("xvL\t= ", xvL)
print("rho_n\t= ", rho_n)
print("Rv\t= ", Rv)
print("b\t= ", b)
