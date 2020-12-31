import sys
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import cm
from matplotlib.ticker import LinearLocator, FormatStrFormatter
from mpl_toolkits.mplot3d import Axes3D

#Read File
filename = sys.argv[1]
with open(filename, 'r') as f:
    reader = csv.reader(f, delimiter=',')
    headers = next(reader)
    data = np.array(list(reader)).astype(float)
df=pd.DataFrame(data,columns=headers)

#Create meshgrid from dataframe
x=df[sys.argv[2]].to_list()
y=df[sys.argv[3]].to_list()
z=df[sys.argv[4]].to_list()
x=sorted(set(x))
y=sorted(set(y))
X,Y = np.meshgrid(x,y)
Z = X*0
for i in range(len(y)):
    for j in range(len(x)):
        for index, row in df.iterrows():
            if row[sys.argv[2]]==X[i][j] and row[sys.argv[3]]==Y[i][j]:
                Z[i][j]=row[sys.argv[4]]

fig = plt.figure()
ax = Axes3D(fig)
surf = ax.plot_surface(X, Y, np.log10(Z), rstride=1, cstride=1, cmap=cm.coolwarm,linewidth=1, antialiased=False)
ax.set_xlabel(sys.argv[2])
ax.set_ylabel(sys.argv[3])
ax.set_zlabel(sys.argv[4])

# ax.set_xscale('log',basex=10)
# ax.set_yscale('log',basex=10)
# ax.set_zscale('log',basex=10)

# ax.set_zlim(-1.01, 1.01)
# ax.zaxis.set_major_locator(LinearLocator(10))
# ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))
# fig.colorbar(surf, shrink=0.5, aspect=5)
plt.show()
