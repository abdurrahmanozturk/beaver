import sys
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# print 'Number of arguments:', len(sys.argv), 'arguments.'
# print 'Argument List:', str(sys.argv)

# Read Data from file
filename = sys.argv[1]
with open(filename+".csv", 'r') as f:
    reader = csv.reader(f, delimiter=',')
    headers = next(reader)
    data = np.array(list(reader)).astype(float)

print(headers)
print(data.shape)
print(data[:5])

# Make a data frame
df=pd.DataFrame(data,columns=headers)

# # Read Command Line Arguments
# arg = sys.argv
# col = []
# log = []
# for i in range(2,len(arg)):
#     print(arg[i])
#     if isinstance(arg[i][0],str):
#         str1=""
#         str2=""
#         if len(arg[i])>1 and arg[i][0]+arg[i][1]+arg[i][2]+arg[i][3]=="log-":
#             arg[i]=arg[i][4:len(arg[i])]
#             log.append(1)
#         for j in range(0,len(headers)):
#             if len(arg[i])==len(headers[j]):
#                 for k in range(0,len(headers[j])):
#                     str1+=headers[j][k]
#                     str2+=arg[i][k]
#                     if str1==str2:
#                         col.append(j)
#                     else:
#                         print("Requested variable is not exist.")
#     else:
#         col.append(int(arg[i]))

# Read Command Line Arguments
arg = sys.argv
log = [0]*len(arg)
for i in range(2,len(arg)):
    if isinstance(arg[i][0],str):
        str1=""
        str2=""
        if len(arg[i])>1 and arg[i][0]+arg[i][1]+arg[i][2]+arg[i][3]=="log-":
            arg[i]=arg[i][4:len(arg[i])]
            log[i]=1
        for j in range(0,len(headers)):
            if len(arg[i])==len(headers[j]):
                for k in range(0,len(headers[j])):
                    str1+=headers[j][k]
                    str2+=arg[i][k]
                    if str1==str2:
                        arg[i]=j
# create fig
fig = plt.figure()
# style
plt.style.use('seaborn-whitegrid')

# create a color palette
palette = plt.get_cmap('Set2')

# create fig
fig = plt.figure()

# style
plt.style.use('seaborn-whitegrid')

# Plot the data
#
# #from DataFrame
# num=0
# for column in df.drop(arg[2], axis=1):
#     num+=1
#     plt.plot(df[arg[2], df[column], marker='', color=palette(num), linewidth=1, alpha=0.9, label=column)


# multiple lines plot
num=0
for column in range(3,len(sys.argv)):
    num+=1
    if log[column]==1:
        plt.semilogy(data[:, int(sys.argv[2])-1], data[:, int(sys.argv[column])-1],marker='', color=palette(num), linewidth=1, alpha=1,label=headers[int(sys.argv[column])-1])
    else:
        plt.plot(data[:, int(sys.argv[2])-1], data[:, int(sys.argv[column])-1],marker='', color=palette(num), linewidth=1, alpha=1,label=headers[int(sys.argv[column])-1])
    if log[2]==1:
        plt.xscale('log',basex=10)
    plt.xlim(np.min(data[:, int(sys.argv[2])-1]),np.max(data[:, int(sys.argv[2])-1]))
    plt.ylim(np.min(data[:, int(sys.argv[column])-1]),np.max(data[:, int(sys.argv[column])-1])*1.05)

# Plot settings
plt.title(filename, loc='center', fontsize=12, fontweight=0, color='black')
plt.xlabel(headers[int(sys.argv[2])-1])
plt.ylabel(headers[int(sys.argv[3])-1])
# plt.xlabel('x [unit]')
# plt.ylabel('y(x) [unit]')

# plt.axis('equal')   #fix x and y axis
# plt.autoscale(enable=True, axis='x', tight=True)

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
