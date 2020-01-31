# Import libraries
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import matplotlib.backends.backend_pdf

# Open data file
file = open('csvfiles.txt')
lines = file.readlines()
f1 = open('gauss-seidel_1000.txt', 'r')
f2 = open('jacobi_1000.txt', 'r')
f3 = open('cg_data_N_1000.txt', 'r')
f4 = open('pcg-diag_data_N_1000.txt', 'r')
f5 = open('pcg-ichol_data_N_1000.txt', 'r')

# Read data from file and store
lines1 = f1.readlines()
lines2 = f2.readlines()
lines3 = f3.readlines()
lines4 = f4.readlines()
lines5 = f5.readlines()
x = [float(line.split()[0]) for line in lines1]
u1 = [float(line.split()[1]) for line in lines1]
u2 = [float(line.split()[1]) for line in lines2]
u3 = [float(line.split()[1]) for line in lines3]
u4 = [float(line.split()[1]) for line in lines4]
u5 = [float(line.split()[1]) for line in lines5]

# Make a data frame
df=pd.DataFrame({'x': x, 'Gauss-Seidel': u1, 'Jacobi': u2, 'Eigen::cg': u3, 'Eigen::pcg-diag': u4, 'Eigen::pcg-ichol': u5})

# create fig
fig = plt.figure()
# style
plt.style.use('seaborn-whitegrid')

# create a color palette
palette = plt.get_cmap('Set2')

# multiple line plot
num=0
for column in df.drop('x', axis=1):
    num+=1
    plt.plot(df['x'], df[column], marker='', color=palette(num), linewidth=1, alpha=0.9, label=column)

# Add legend
plt.legend(loc=2, ncol=1)

# Add titles
plt.title("Results", loc='center', fontsize=12, fontweight=0, color='black')
plt.xlabel("x")
plt.ylabel("u(x)")
plt.xlim([np.min(df['x']),np.max(df['x'])])
plt.show()
fig.savefig("plots.png", box_inches='tight')

#close files
f1.close()
f2.close()
f3.close()

#Plot single data

# import numpy as np
# import matplotlib.pyplot as plt
# f = open('recombination_dominated_ND_out.csv', 'r')
# lines = f.readlines()
# t = [float(line.split()[0]) for line in lines]
# x = [float(line.split()[1]) for line in lines]
# fig = plt.figure()
# ax1=fig.add_subplot(111)
# ax1.plot(x,u)
# ax1.set_title('gauss-seidel_10')
# ax1.set_xlabel('x')
# ax1.set_ylabel('u(x)')
# plt.grid()
# plt.show()
# fig.savefig("recombination_dominated_ND_out.png", box_inches='tight')
# f.close()
