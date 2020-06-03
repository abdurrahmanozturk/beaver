import numpy as np
import pandas as pd
import math

#Material Properties For Nickel
T=773 #K
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
         'epsilon': 0.1,
         'N': 1e22,
         'a': 0.352e-9  }

# Parameter Calculations for the Eq. 5.2 in Gary Was textbook
data = Nickel
Cs = 1e20                     #sink density (1/m3)
l = 1e-9                      #length scale {m}
beta = l*l                    #{m^2}
w = beta/Di                   #time scale   {s}
omega = data['Atomic Volume'] #{m3}
xv_e = Cv_e                   #{unitless}
Xs   = omega*Cs               #{unitless}
riv = 10*data['a']            #{m}
K = 1e-3                      #{dpa/s}
Kiv = 4*np.pi*riv*(Di+Dv)     #recombination rate {1/s}
Kis = 4*np.pi*riv*Di          #Interstitial-sink reaction rate
Kvs = 4*np.pi*riv*Dv          #Vacancy-sink reaction rate
K_ND = w*K
Kiv_ND = Kiv*w/omega
Kis_ND = Kis*w/omega
Kvs_ND = Kvs*w/omega
KisXs_ND = Kis*w*Xs/omega
KvsXs_ND = Kvs*w*Xs/omega
Di_ND = Di*w/beta
Dv_ND = Dv*w/beta
print(data)
print("\nT\t= ", T)
print("length scale(l)\t= ", l)
print("time scale (w)\t= ", w)
print("Di\t= ", Di)
print("Dv\t= ", Dv)
print("K\t= ", K)
print("beta\t= ",beta)
print("omega\t= ",omega)
print("xv_e\t= ", xv_e)
print("riv\t= ", riv)
print("Cv_eq\t= ", Cv_e)
print("Cs\t= ", Cs)
print("Kiv\t= ",Kiv)
print("Kis\t= ",Kis)
print("Kvs\t= ",Kvs)
print("===================")
print("\nT\t= ", T)
print("l\t= ", l)
print("w\t= ", w)
print("riv\t= ", riv)
print("xv_e\t= ", xv_e)
print("Xs\t= ", Xs)
print("KisXs\t= ",KisXs_ND)
print("KvsXs\t= ",KvsXs_ND)
print("K_ND\t= ", K_ND)
print("Kiv_ND\t= ",Kiv_ND)
print("Kis_ND\t= ",Kis_ND)
print("Kvs_ND\t= ",Kvs_ND)
print("Di_ND\t= ", Di_ND)
print("Dv_ND\t= ", Dv_ND)
