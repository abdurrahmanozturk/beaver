import sys
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

print 'Number of arguments:', len(sys.argv), 'arguments.'
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
print(sys.argv)
log = [0]*len(sys.argv)
for i in range(2,len(sys.argv)):
    c=0
    if isinstance(sys.argv[i][0],str):
        if len(sys.argv[i])>1 and sys.argv[i][0]+sys.argv[i][1]+sys.argv[i][2]+sys.argv[i][3]=="log-":
            sys.argv[i]=sys.argv[i][4:len(sys.argv[i])]
            log[i]=1
        for j in range(0,len(headers)):
            c=0
            if len(headers[j])==len(sys.argv[i]):
                for k in range(0,len(headers[j])):
                    if headers[j][k]==sys.argv[i][k]:
                        c+=1
                if c==len(headers[j]):
                    sys.argv[i]=str(j)
                    break
print(sys.argv)
# create fig
fig = plt.figure()
# create a color palette
palette = plt.get_cmap('Set2')
# style
plt.style.use('seaborn-whitegrid')

# Plot the data

# #Using DataFrame
# num=0
# for column in df.drop(arg[2], axis=1):
#     num+=1
#     plt.plot(df[arg[2], df[column], marker='', color=palette(num), linewidth=1, alpha=0.9, label=column)


# Plot the data
# Multiple lines plot
num=0
for column in range(3,len(sys.argv)):
    num+=1
    if log[column]==1:
        plt.semilogy(data[:, int(sys.argv[2])], data[:, int(sys.argv[column])],marker='', color=palette(num), linewidth=1, alpha=1,label=headers[int(sys.argv[column])])
    else:
        plt.plot(data[:, int(sys.argv[2])], data[:, int(sys.argv[column])],marker='', color=palette(num), linewidth=1, alpha=1,label=headers[int(sys.argv[column])])
    if log[2]==1:
        plt.xscale('log',basex=10)
    plt.xlim(np.min(data[:, int(sys.argv[2])]),np.max(data[:, int(sys.argv[2])]))
    plt.ylim(np.min(data[:, int(sys.argv[column])]),np.max(data[:, int(sys.argv[column])])*1.05)

# Plot settings
# title
plt.title(filename, loc='center', fontsize=12, fontweight=0, color='black')
# labels
plt.xlabel(headers[int(sys.argv[2])])
plt.ylabel(headers[int(sys.argv[3])])
# plt.xlabel('x [unit]')          # define x label manually
# plt.ylabel('y(x) [unit]')       # define y label manually
# axis options
# plt.axis('equal')               # fix x and y axis
# plt.autoscale(enable=True, axis='x', tight=True)   #autoscale x and y axis
# Add legend
plt.legend(loc=4, ncol=1)
plt.show()
fig.savefig(filename+".png", box_inches='tight')
