import sys
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# print 'Number of arguments:', len(sys.argv), 'arguments.'
# print 'Argument List:', str(sys.argv)

filename = sys.argv[1]
with open(filename+".csv", 'r') as f:
    reader = csv.reader(f, delimiter=',')
    headers = next(reader)
    data = np.array(list(reader)).astype(float)

print(headers)
print(data.shape)
print(data[:5])

# create fig
fig = plt.figure()
# style
plt.style.use('seaborn-whitegrid')
# Plot the data
plt.title(filename, loc='center', fontsize=12, fontweight=0, color='black')
# plt.axis('equal')
# plt.xlabel(headers[0])
# plt.ylabel(headers[2])
# plt.autoscale(enable=True, axis='x', tight=True)
plt.xlim(np.min(data[:, 0]),np.max(data[:, 0]))
plt.ylim(np.min(data[:, 4]),np.max(data[:, 4])*1.05)
plt.plot(data[:, 0], data[:, 3],marker='', color='blue', linewidth=1, alpha=1,label=headers[3])
plt.plot(data[:, 0],data[:, 4],marker='', color='red', linewidth=1, alpha=1,label=headers[4])
plt.xlabel('tau')
plt.ylabel('X')
# Add legend
plt.legend(loc=4, ncol=1)
plt.show()
fig.savefig(filename+".png", box_inches='tight')



# import numpy as np
# import matplotlib.pyplot as plt
# f = open('recombination_dominated_ND_out.csv', 'r')
# lines = f.readlines()
# t = [float(line.split()[0]) for line in lines]
# ci = [float(line.split()[1]) for line in lines]
# xi = [float(line.split()[2]) for line in lines]
# fig = plt.figure()
# ax1=fig.add_subplot(111)
# ax1.plot(x,u)
# ax1.set_title('gauss-seidel_10')
# ax1.set_xlabel('x')
# ax1.set_ylabel('u(x)')
# plt.grid()
# plt.show()
# fig.savefig("gauss-seidel_10.png", box_inches='tight')
# f.close()
