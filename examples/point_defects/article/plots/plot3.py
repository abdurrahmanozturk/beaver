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
figname=filename[:-4]+".png"
with open(filename, 'r') as f:
    reader = csv.reader(f, delimiter=',')
    headers = next(reader)
    data = np.array(list(reader)).astype(float)
df=pd.DataFrame(data,columns=headers)

#Figure Settings
fig = plt.figure()
ax = Axes3D(fig)
palette = plt.get_cmap('Set1')  # Color Scale, {Set1,Set2,Set3,Dark2,tab10},tab20,Pastel1}
cmaps= ['Greys', 'Purples', 'Blues', 'Greens', 'Oranges', 'Reds',
        'YlOrBr', 'YlOrRd', 'OrRd', 'PuRd', 'RdPu', 'BuPu',
        'GnBu', 'PuBu', 'YlGnBu', 'PuBuGn', 'BuGn', 'YlGn']
ax.set_xlabel(sys.argv[2])
ax.set_ylabel(sys.argv[3])
# ax.set_zlabel(sys.argv[4])
ax.set_xlabel('Grain Size (nm)')
ax.set_ylabel('Production Bias (%)')
ax.set_zlabel('logC$_{i,center}$')
# ax.set_zlabel('Total GB Sink Strength (1/m^2)')

#Create meshgrid from dataframe
x=df[sys.argv[2]].to_list()
y=df[sys.argv[3]].to_list()
# z=df[sys.argv[4]].to_list()
x=sorted(set(x))
y=sorted(set(y))
X,Y = np.meshgrid(x,y)
for id in range(4,len(sys.argv)):
    Z = X*0
    for i in range(len(y)):
        for j in range(len(x)):
            for index, row in df.iterrows():
                if row[sys.argv[2]]==X[i][j] and row[sys.argv[3]]==Y[i][j]:
                    Z[i][j]=row[sys.argv[id]]
    # surf = ax.plot_wireframe(X, Y, np.log10(Z), label=r'log-${}_{}^2$'.format(sys.argv[id][0],sys.argv[id][1]), cmap=cmaps[id-4], linewidth=1, color=palette(id-4), antialiased=False)
    surf = ax.plot_surface(X, Y, np.log10(Z), label=r'log-${}_{}^2$'.format(sys.argv[id][0],sys.argv[id][1]), cmap=cm.coolwarm, linewidth=1, antialiased=True)

# ax.set_xscale('log',basex=10)
# ax.set_yscale('log',basex=10)
# ax.set_zscale('log',basex=10)
# ax.set_zlim(-1.01, 1.01)
# ax.zaxis.set_major_locator(LinearLocator(10))
# ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))
# fig.colorbar(surf, shrink=0.5, aspect=5)
# plt.legend(loc=0, ncol=1,fontsize='medium')
plt.show()
fig.savefig(figname, bbox_inches='tight',dpi=150, transparent=False)
