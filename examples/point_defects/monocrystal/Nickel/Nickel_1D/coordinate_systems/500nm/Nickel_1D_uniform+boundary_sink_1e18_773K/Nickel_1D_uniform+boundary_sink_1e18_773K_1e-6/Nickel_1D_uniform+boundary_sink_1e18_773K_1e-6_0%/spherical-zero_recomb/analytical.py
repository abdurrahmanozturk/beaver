import matplotlib.pyplot as plt
import numpy as np
import math
Cs=1.206e-11
Di=1
Dv=0.00018119003349692062
k0=9.036600512379032e-16
kis=3667.79639822092
kvs=0.6645681522535332
a=5000
ki=(kis*Cs/Di)**0.5
kv=(kvs*Cs/Dv)**0.5
x=[]
ci=[]
cv=[]
for i in range(1,5000):
    print(i)
    x.append(i)
    ci.append((k0/(Di*ki*ki))*(1-a*math.sinh(ki*x[i])/(x[i]*math.sinh(ki*a))))
    cv.append((k0/(Dv*kv*kv))*(1-a*math.sinh(kv*x[i])/(x[i]*math.sinh(kv*a))))

fig = plt.figure(figsize=(5, 5))
plt.plot(x,ci)
plt.plot(x,cv)
