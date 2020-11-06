import numpy as np
import math
Cs=1e18
Di=1.1066108307323346e-09
Dv=2.0050685348844685e-13
k0=1e-6
kis=4.8949408023459335e-17
kvs=8.869144879425032e-21
a=500
ki=(kis*Cs/Di)**0.5
kv=(kvs*Cs/Dv)**0.5
x=[]
ci=[]
cv=[]
for i in range(0,500):
    print(i)
    x.append(i)
    ci.append((k0/(Di*ki*ki))*(1-a*math.sinh(ki*x[i])/(x[i]*math.sinh(ki*a))))
    cv.append((k0/(Dv*kv*kv))*(1-a*math.sinh(kv*x[i])/(x[i]*math.sinh(kv*a))))

print(ci,cv)
