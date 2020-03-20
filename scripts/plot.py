import sys
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

# ------------------------------------------------------- #
# ======================================================= #
# Pyhton script to plot data from MOOSE csv output files. #
# ======================================================= #
# ----------------------------------------------eigenturk #

# print 'Number of arguments:', len(sys.argv), 'arguments.'
# print 'Argument List:', str(sys.argv)
filename = sys.argv[1]
figname=filename[:-4]+".png"
csvfile = [filename]
fmode=0
n=len(sys.argv)
if sys.argv[-1]=="-"+"f":
    print("-f mode on")
    fmode = 1
    n=len(sys.argv)-1
    # Read file names from file
    file = open(filename)
    csvfile = file.readlines()
    for i in range(0,len(csvfile)):
        csvfile[i]=csvfile[i][:-1]

# Create fig
fig = plt.figure()
# Create a color palette
palette = plt.get_cmap('Set2')
# Style
plt.style.use('seaborn-whitegrid')

for fid in range(0,len(csvfile)):
    print(csvfile)
    with open(csvfile[fid], 'r') as f:
        reader = csv.reader(f, delimiter=',')
        headers = next(reader)
        data = np.array(list(reader)).astype(float)

    print(headers)
    print(data.shape)
    print(data[:5])

    # Make a data frame
    df=pd.DataFrame(data,columns=headers)

    # Read Command Line Arguments
    print(sys.argv)
    log = [0]*n
    for i in range(2,n):
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

    #Labels
    xlbl = headers[int(sys.argv[2])]
    ylbl = headers[int(sys.argv[3])]
    # xlbl = "x [unit]"          # define x label manually
    # ylbl = "y(x) [unit]"       # define y label manually

    #Axis Limits
    xmin=np.min(data[:, int(sys.argv[2])])
    xmax=np.max(data[:, int(sys.argv[2])])
    ymin=np.min(data[:, int(sys.argv[3])])
    ymax=np.max(data[:, int(sys.argv[3])])*1.05

    # Plot the data  ::  CHECK THIS !!!

    # #Using DataFrame
    # num=0
    # for column in df.drop(arg[2], axis=1):
    #     num+=1
    #     plt.plot(df[arg[2], df[column], marker='', color=palette(num), linewidth=1, alpha=0.9, label=column)


    # PLOT DATA
    # Multiple lines plot
    num=0
    # lbl=""
    for column in range(3,n):
        num+=1
        if fmode==1:
            lbl = csvfile[fid]#[-28:-21]     ## CHANGE THIS ACCORDING TO PARAMETER IN THE END OF FILENAME
            figname = ylbl
        else:
            lbl = headers[int(sys.argv[column])]
        if log[column]==1:
            plt.semilogy(data[:, int(sys.argv[2])], data[:, int(sys.argv[column])],marker='', color=palette(num+fid), linewidth=1, alpha=1,label=lbl)
        else:
            plt.plot(data[:, int(sys.argv[2])], data[:, int(sys.argv[column])],marker='', color=palette(num+fid), linewidth=1, alpha=1,label=lbl)
        if log[2]==1:
            plt.xscale('log',basex=10)
        if np.min(data[:, int(sys.argv[column])])<ymin:
            ymin=np.min(data[:, int(sys.argv[column])])
            plt.ylim(ymin,ymax)
        if np.max(data[:, int(sys.argv[column])])*1.05>ymax:
            ymax=np.max(data[:, int(sys.argv[column])])*1.05
            plt.ylim(ymin,ymax)

# Plot Settings
# Title
plt.title(filename, loc='center', fontsize=12, fontweight=0, color='black')
# Labels
plt.xlim(xmin,xmax)
plt.xlabel(xlbl)
plt.ylabel(ylbl)
# plt.axis('equal')               # fix x and y axis
# plt.autoscale(enable=True, axis='x', tight=True)   #autoscale x and y axis
# Add Legend
plt.legend(loc=0, ncol=1)
plt.show()
fig.savefig(figname, box_inches='tight')
