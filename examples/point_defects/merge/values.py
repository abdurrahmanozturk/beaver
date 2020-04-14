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
         'rho_n': 1e15,
         'K': 1e-3,
         'epsilon': 0.1,
         'N': 1e22 }


# #--- Non-dimensionalization scaling parameters ---
data = Nickel
alpha =  1e-9    #recombination rate
ZiN = 1+data['B']
ZiI = ZiN
ZiV = ZiN
ZvI = 1
ZvN = 1
ZvV = 1
ZvC = 1
ZiC = 1
lambda_v = data['Dv']*ZvN*data['rho_n']
gamma = alpha/lambda_v
P = gamma*data['K']/lambda_v
Di_bar = data['Di']/lambda_v
Dv_bar = data['Dv']/lambda_v
B = data['B']
mu = data['Di']/data['Dv']
tau_i = data['b']*alpha*data['rho_n']/2*np.pi*data['N']*data['Dv']
tau_v = data['b']*data['rv_0']*data['rho_n']*gamma
# tau_c = (alpha*data['rho_n']*data['rho_n'])/((4*np.pi*data['Nc'])*(4*np.pi*data['Nc'])*data['Dv'])
xvL = gamma*Cv_e
print(data)
print("\nalpha\t= ",alpha)
print("gamma\t= ",gamma)
print("lambda_v\t= ",lambda_v)
print("\nP\t= ", P)
print("Di_bar\t= ", Di_bar)
print("Dv_bar\t= ", Dv_bar)
print("mu\t= ", mu)
print("B\t= ", B)
print("tau_i\t= ", tau_i)
print("tau_v\t= ", tau_v)
# print("tau_c\t= ", tau_c)
print("epsilon\t= ", data['epsilon'])
print("xvL\t= ", xvL)
