import numpy as np
import pandas as pd
import math
import sys
import re
#import materials from database.py # TTD : CREATE a class and put all material data as member variable!!!!!

# -------------------------------------------------------------------------------------------------------------- #
# ============================================================================================================== #
#            Pyhton script to calculate material properties for MOOSE radiation damage simulations               #
# ============================================================================================================== #
# -----------------------------------------------------------------------------------------------------eigenturk #

#Constant Parameters
kB = 8.617e-5 # ev/K
NA = 6.02e23 # Avagadro's number
#Default Parameters
T=773       #Temperature {K} #user defined temperature, TTD : CHECK T dependent parameters(Ef, Em,...)!!!
l = 1e-09   #length scale {m}
K0 = 1e-3   #{dpa/s}
Cs = 1e18   #sink density (1/m3)
#User Defined Parameters
for i in range(1,len(sys.argv)):
    if re.search("=",sys.argv[i]):
        if sys.argv[i].split('=')[0]=='T':
            T=float(sys.argv[i].split('=')[1])
        elif sys.argv[i].split('=')[0]=='K0':
            K0=float(sys.argv[i].split('=')[1])
        elif sys.argv[i].split('=')[0]=='l':
            l=float(sys.argv[i].split('=')[1])
        elif sys.argv[i].split('=')[0]=='Cs':
            Cs=float(sys.argv[i].split('=')[1])

#Material Properties For Nickel
Ni ={'M': 58.6934, #amu Molar Mass g/mol http://nist.gov
     'Emi': 0.3,  #ev  migration energy for Interstitial  [Shijun Zhao]
     'Efi': 4.27, #ev  formation energy for Interstitial  [Shijun Zhao]
     'Di0': 1e-7, #m2/s http://www.seas.ucla.edu/matrix/papers/1995/d-j-NG-theory.pdf
     'Emv': 1.3,  #ev  migration energy for vacancy       [Shijun Zhao]
     'Efv': 1.6,  #ev  formation energy for vacancy       [Shijun Zhao]
     'Dv0': 6e-5, #m2/s http://www.seas.ucla.edu/matrix/papers/1995/d-j-NG-theory.pdf
     'rho': 8908, #kg/m3
     'Atomic Volume': 1.206e-29, #m3 http://www.seas.ucla.edu/matrix/papers/1995/d-j-NG-theory.pdf
     'riv' : 3.52e-9, # ~10*lattice parameter Fundementals of Radiation Materials Science, Gary S. Was
     'ris' : 3.52e-9, #
     'rvs' : 1.5e-9, # http://www.seas.ucla.edu/matrix/papers/1995/d-j-NG-theory.pdf
     'a': 0.352e-9}

#Material Properties For Iron
Fe ={'M': 55.845, #amu Molar Mass g/mol http://nist.gov
     'Emi': 0.15,   #ev      http://refhub.elsevier.com/S0022-3115(15)30250-6/sref27
     'Efi': 3.3, #ev        http://refhub.elsevier.com/S0022-3115(15)30250-6/sref27
     'Di0': 5.34e-8, #m2/s  http://refhub.elsevier.com/S0022-3115(15)30250-6/sref27
     'Emv': 0.66,  #ev      http://refhub.elsevier.com/S0022-3115(15)30250-6/sref27
     'Efv': 1.8,  #ev       http://refhub.elsevier.com/S0022-3115(15)30250-6/sref27
     'Dv0': 7.87e-7, #m2/s  http://refhub.elsevier.com/S0022-3115(15)30250-6/sref27
     'rho': 7874,  #kg/m3   http://dx.doi.org/10.1016/j.jnucmat.2015.10.002
     'Atomic Volume': 1.93559e-37*T**2+2.68634e-34*T +0.0116954e-27, # m3 http://dx.doi.org/10.1016/j.jnucmat.2015.10.002
     'riv' : 2.86e-9, # ~10*lattice parameter Fundementals of Radiation Materials Science, Gary S. Was
     'ris' : 3.6e-9, # http://dx.doi.org/10.1016/j.jnucmat.2015.10.002
     'rvs' : 1.2e-9, # http://dx.doi.org/10.1016/j.jnucmat.2015.10.002
     'a': 0.286e-9}  # http://dx.doi.org/10.1016/j.jnucmat.2015.10.002

#Material Properties For Copper
Cu ={'M': 63.546, #amu Molar Mass g/mol http://nist.gov
     'Emi':0.084,   #ev      http://dx.doi.org/10.1103/PhysRevB.84.104102
     'Efi': 3.24, #ev        http://dx.doi.org/10.1103/PhysRevB.84.104102
     'Di0': 8.7165e-8, #m2/s  http://dx.doi.org/10.1103/PhysRevB.84.104102
     'Emv': 0.69,  #ev      http://dx.doi.org/10.1103/PhysRevB.84.104102
     'Efv': 1.26,  #ev       http://dx.doi.org/10.1103/PhysRevB.84.104102
     'Dv0': 4.3909e-6, #m2/s  http://dx.doi.org/10.1103/PhysRevB.84.104102
     'rho': 8960,  #kg/m3   http://dx.doi.org/10.1016/j.jnucmat.2015.10.002
     'Atomic Volume': 1.182e-29, # m3 https://www.copper.org/resources/properties/atomic_properties.html
     'riv' : 3.615e-9, # ~10*lattice parameter   Fundementals of Radiation Materials Science, Gary S. Was
     'ris' : 3.615e-9,
     'rvs' : 3.615e-9,
     'a': 0.3615e-9}  # http://dx.doi.org/10.1103/PhysRevB.84.104102

material = {'Ni':Ni,
            'Fe':Fe,
            'Cu':Cu,}

data = material[sys.argv[1]]

Di = data['Di0']*np.exp(-data['Emi']/(kB*T))  #m2/s
Dv = data['Dv0']*np.exp(-data['Emv']/(kB*T))  #m2/s
Cv_e = np.exp(-data['Efv']/(kB*T))  # formation energy at 773K, check value for other Temperatures
Ci_e = np.exp(-data['Efi']/(kB*T))  # formation energy at 773K, check value for other Temperatures

# Parameter Calculations for the Eq. 5.2 in Gary Was textbook
beta = l*l                    #{m^2}
w = beta/Di                   #time scale   {s}
omega = data['Atomic Volume'] #{m3}
xv_e = Cv_e          #{unitless}
xi_e = Ci_e           #{unitless}
Xs   = omega*Cs               #{unitless}
Kiv = 4*np.pi*data['riv']*(Di+Dv) #recombination rate {m3/s}
Kis = 4*np.pi*data['ris']*Di      #Interstitial-sink reaction rate {m3/s}
Kvs = 4*np.pi*data['rvs']*Dv      #Vacancy-sink reaction rate {m3/s}
K0_ND = w*K0
Kiv_ND = w*Kiv/omega
Kis_ND = w*Kis/omega
Kvs_ND = w*Kvs/omega
KisXs_ND = w*Kis*Cs
KvsXs_ND = w*Kvs*Cs
Di_ND = Di*w/beta
Dv_ND = Dv*w/beta
print('\033[92m'+"\nMaterial Properties for "+sys.argv[1]+'\033[0m')
print(data)
print('\033[93m'+"\nData for "+sys.argv[1]+'\033[0m')
print("T\t= "+str(T))
print("Di\t= "+str(Di))
print("Dv\t= "+str(Dv))
print("K0\t= "+str(K0))
print("Cv_eq\t= "+str(Cv_e))
print("Ci_eq\t= "+str(Ci_e))
print("Cs\t= "+str(Cs))
print("Kiv\t= "+str(Kiv))
print("Kis\t= "+str(Kis))
print("Kvs\t= "+str(Kvs))
print('\033[94m'+"\nNondimensionalization Parameters"+'\033[0m')
print("length scale(l)\t= "+str(l))
print("time scale (w)\t= "+str(w))
print("beta\t= "+str(beta))
print("omega\t= "+str(omega))
print('\033[93m'+"\nNondimensionalized Data for "+sys.argv[1]+'\033[0m')
print("T\t= "+str(T))
print("xi_e\t= "+str(xi_e))
print("xv_e\t= "+str(xv_e))
print("xs\t= "+str(Xs))
print("K0_ND\t= "+str(K0_ND))
print("Kiv_ND\t= "+str(Kiv_ND))
print("Kis_ND\t= "+str(Kis_ND))
print("Kvs_ND\t= "+str(Kvs_ND))
print("Di_ND\t= "+str(Di_ND))
print("Dv_ND\t= "+str(Dv_ND))
