import numpy as np
import pandas as pd
import math

#Material Properties For Nickel
T=773 #K
kB = 8.617e-5 # ev/K
Emi = 0.3 #ev  migration energy for Interstitial  [Shijun Zhao]
Efi = 4.27#ev  formation energy for Interstitial  [Shijun Zhao]
Di0 = 1e-7 #m2/s
Emv = 1.3 #ev  migration energy for vacancy       [Shijun Zhao]
Efv = 1.6 #ev  formation energy for vacancy       [Shijun Zhao]
Dv0 = 6e-5 #m2/s
Di = Di0*np.exp(-Emi/(kB*T))  #m2/s
Dv = Dv0*np.exp(-Emv/(kB*T))  #m2/s
Cv_e = np.exp(-Efv/(kB*T))
Ci_e = np.exp(-Efi/(kB*T))
Nickel ={'Di': Di,
         'Dv': Dv,
         'Cv_e': Cv_e,
         'Ci_e': Ci_e,
         'b': 2.5e-10,
         'Atomic Volume': 1.206e-29,
         'B': 0.1,
         'delta_B': 0.005,
         'rv_0': 1.5e-9,
         'rho_n': 1e14,
         'epsilon': 0.1,
         'N': 1e22,
         'a': 0.352e-9}

# Parameter Calculations for the Eq. 5.2 in Gary Was textbook
data = Nickel
l = 1e-09                     #length scale {m}
K0 = 1e-3                     #{dpa/s}
Cs = 1e18                     #sink density (1/m3)
beta = l*l                    #{m^2}
w = beta/Di                   #time scale   {s}
omega = data['Atomic Volume'] #{m3}
xv_e = data['Cv_e']           #{unitless}
xi_e = data['Ci_e']           #{unitless}
Xs   = omega*Cs               #{unitless}
riv = 10*data['a']            #{m}
Kiv = 4*np.pi*riv*(data['Di']+data['Dv']) #recombination rate {1/s}
Kis = 4*np.pi*riv*data['Di']              #Interstitial-sink reaction rate
Kvs = 4*np.pi*riv*data['Dv']              #Vacancy-sink reaction rate
K0_ND = w*K0
Kiv_ND = Kiv*w/omega
Kis_ND = Kis*w/omega
Kvs_ND = Kvs*w/omega
KisXs_ND = Kis*w*Xs/omega
KvsXs_ND = Kvs*w*Xs/omega
Di_ND = data['Di']*w/beta
Dv_ND = data['Dv']*w/beta
print(data)
print("\nT\t= ", T)
print("length scale(l)\t= ", l)
print("time scale (w)\t= ", w)
print("Di\t= ", Di)
print("Dv\t= ", Dv)
print("K0\t= ", K0)
print("beta\t= ",beta)
print("omega\t= ",omega)
print("riv\t= ", riv)
print("Cv_eq\t= ", Cv_e)
print("Ci_eq\t= ", Ci_e)
print("Cs\t= ", Cs)
print("Kiv\t= ",Kiv)
print("Kis\t= ",Kis)
print("Kvs\t= ",Kvs)
print("===================")
print("\nT\t= ", T)
print("l\t= ", l)
print("w\t= ", w)
print("riv\t= ", riv)
print("xi_e\t= ", xi_e)
print("xv_e\t= ", xv_e)
print("Xs\t= ", Xs)
print("KisXs\t= ",KisXs_ND)
print("KvsXs\t= ",KvsXs_ND)
print("K0_ND\t= ", K0_ND)
print("Kiv_ND\t= ",Kiv_ND)
print("Kis_ND\t= ",Kis_ND)
print("Kvs_ND\t= ",Kvs_ND)
print("Di_ND\t= ", Di_ND)
print("Dv_ND\t= ", Dv_ND)
