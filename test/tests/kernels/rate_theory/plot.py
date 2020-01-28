import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

filename = 'recombination_dominated_ND_out'
with open(filename+".csv", 'r') as f:
    reader = csv.reader(f, delimiter=',')
    headers = next(reader)
    data = np.array(list(reader)).astype(float)

print(headers)
print(data.shape)
print(data[:3])

# create fig
fig = plt.figure()
# style
plt.style.use('seaborn-whitegrid')
# Plot the data
plt.title(filename, loc='center', fontsize=12, fontweight=0, color='black')
plt.axis('equal')
plt.xlabel(headers[0])
plt.ylabel(headers[2])
plt.xlim(np.min(data[:, 0]),np.max(data[:, 0]))
plt.ylim(np.min(data[:, 2]),np.max(data[:, 2]))
plt.plot(data[:, 0], data[:, 2],marker='', color='blue', linewidth=1, alpha=1)
plt.show()
fig.savefig(filename+".png", box_inches='tight')

#
# plt.plot(data[:, 0],data[:, 1])
# plt.xlabel(headers[0])
# plt.ylabel(headers[1])
# plt.show()


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
