import sys
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

cve = 3.7e-11   #vacancy equilibrium concentration
scale = 9.036600512379032e-12 # for 1D l-1e-10m   for time scale
# scale = 1e-1 #for length scale
# omega = 1.206e-29 # Atomic volume for Nickel

def getHelp():
    print('\033[96m'+"\n# ------------------------------------------------------- #\n"
          "# ======================================================= #\n"
          "# Pyhton script to plot data from MOOSE csv output files. #\n"
          "# ======================================================= #\n"
          "# ----------------------------------------------eigenturk #\n"+'\033[0m')
    print("This script is a tool for plotting csv files based on specified column numbers.\n\n"
          "Usage: plot [filename] [column_number1] [column_number2] ... [-f] [-s]\n\n"
          "Arguments:\n\n"
          "\tfilename\t\tName of the data file with extension\n"
          "\tcolumn_number\t\tThe column number of the data in csv file\n\n"
          "Optional arguments:\n\n"
          "  -h, Show this help message and exit.\n"
          "  -f, Multiple file mode, data from multiple files will be pllotted on the same figure.\n"
          "  -s, Save only mode, plot wont be shown.\n\n"
          '\033[4m'+'\033[1m'+"Manual for commands :\n\n"+'\033[0m'
          "Note  : To make using this script easy, create 'plot' command by adding following line to bash profile.\n"
          '\033[91m'+"\tCheck script file path(e.g. projects/scripts/plot.py)\n"+'\033[0m'
          '\033[91m'+"\talias plot=\"python projects/scripts/plot.py\"\n"+'\033[0m'
          "\n1. Plotting multiple y values from same csv file\n"
          '\033[93m'+"\tplot filename column_number(x) column_number(y1) column_number(y2)....column_number(yn)\n"+'\033[0m'
          "\n2. Plotting multiple y values from multiple csv files\n"
          '\033[91m'+"\tAppend name of all csv files to a seperate file,then use it in command. (e.g. csvfiles)\n"
          '\033[93m'+"\tplot csvfiles column_number(x) column_number(y) -f\n"+'\033[0m'
          "\n3. Save a plot without showing it\n"
          '\033[91m'+"\tAdd -s to end of the command\n"
          '\033[93m'+"\tplot . . . -s")+'\033[0m'
    sys.exit()

def getSinkStrength(data,defect):
    if defect=="i":
        C = data[-1,1]
        J = data[-1,3]
        D = data[-1,9]
    elif defect=="v":
        C = data[-1,2]
        J = data[-1,4]
        D = data[-1,10]
    print(C,J,D)
    return J/(D*C)

def getSuperSaturation(data,cve):
    Ci = data[-1,1]
    Cv = data[-1,2]
    Cve= cve
    Di = data[-1,9]
    Dv = data[-1,10]
    print(Ci,Cv,Cve,Di,Dv)
    return (Dv*Cv-Di*Ci)/(Dv*Cve)

# ------------------------------------------------------- #
# ======================================================= #
# Pyhton script to plot data from MOOSE csv output files. #
# ======================================================= #
# ----------------------------------------------eigenturk #

# print 'Number of arguments:', len(sys.argv), 'arguments.'
# print 'Argument List:', str(sys.argv)

if sys.argv[-1]=="-"+"h":
    getHelp()

filename = sys.argv[1]
figname=filename[:-4]+".png"
csvfile = [filename]
n=len(sys.argv)
smode=False
if sys.argv[-2]=="-"+"s" or sys.argv[-1]=="-"+"s":
    print("-s mode : save only mode, plot wont be shown")
    smode = True
    n=n-1
fmode=False
if sys.argv[-2]=="-"+"f" or sys.argv[-1]=="-"+"f":
    print("-f mode : multiple file mode, multiple files will be shown on the same plot")
    fmode = True
    n=n-1
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
    # print(csvfile)
    with open(csvfile[fid], 'r') as f:
        reader = csv.reader(f, delimiter=',')
        headers = next(reader)
        data = np.array(list(reader)).astype(float)

    # Back Scaling
    data[:,0] *= scale
    # data[:,1] /= omegategrid')

for fid in range(0,len(csvfile)):
    print(csvfile[fid][-30:])
    with open(csvfile[fid], 'r') as f:
        reader = csv.reader(f, delimiter=',')
        headers = next(reader)
        data = np.array(list(reader)).astype(float)

    # Back Scaling
    data[:,0] *= scale
    # data[:,1] /= omega
    # data[:,2] /= omega

    # print(headers)
    # print(data.shape)
    # print(data[:5])

    # Make a data frame
    df=pd.DataFrame(data,columns=headers)

    # Read Command Line Arguments
    # print(sys.argv)
    log = [0]*n
    for i in range(2,n):
        c=0
        if isinstance(sys.argv[i][0],str):
            if len(sys.argv[i])>2 and sys.argv[i][0]+sys.argv[i][1]+sys.argv[i][2]+sys.argv[i][3]=="log-":
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

    # print(sys.argv)

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
            plt.semilogy(data[:, int(sys.argv[2])], data[:, int(sys.argv[column])],marker='', color=palette(num+fid), linewidth=1.5, alpha=1,label=lbl)
        else:
            plt.plot(data[:, int(sys.argv[2])], data[:, int(sys.argv[column])],marker='', color=palette(num+fid), linewidth=1.5, alpha=1,label=lbl)
        if log[2]==1:
            plt.xscale('log',basex=10)
        if np.min(data[:, int(sys.argv[column])])<ymin:
            ymin=np.min(data[:, int(sys.argv[column])])
            plt.ylim(ymin,ymax)
        if np.max(data[:, int(sys.argv[column])])*1.05>ymax:
            ymax=np.max(data[:, int(sys.argv[column])])*1.05
            plt.ylim(ymin,ymax)

    #Sink Strength Calculations
    ssi = getSinkStrength(data,'i')      # Interstitial sink strength
    ssv = getSinkStrength(data,'v')      # Vacancy sink strength
    ss_str = "Zi: "+str(ssi)+" m\nZv: "+str(ssv)+" m"
    print('\033[93m'+ss_str+'\033[0m')
    Sv = getSuperSaturation(data,cve)   # Average Vacancy supersaturation
    S_str = "Vacancy Supersaturation: "+str(Sv)+"\n"
    print('\033[93m'+S_str+'\033[0m')

print(headers)

# Plot Settings
# Title
plt.title(filename, loc='center', fontsize=14, fontweight=0, color='black')
# Labels
plt.xlim(xmin,xmax)
plt.xlabel(xlbl)
plt.ylabel(ylbl)
# plt.axis('equal')               # fix x and y axis
# plt.autoscale(enable=True, axis='x', tight=True)   #autoscale x and y axis
# Add Legend
plt.legend(loc=0, ncol=1, fontsize=14)
plt.text(1e-2, 5e-13, ss_str , size=10,
         ha="right", va="top",
         bbox=dict(boxstyle="square", ec=(1., 0.5, 0.5),fc=(1., 0.8, 0.8),))
if smode == True: #save only
    fig.savefig(figname, box_inches='tight',dpi=150)
else:
    plt.show()
    fig.savefig(figname, box_inches='tight',dpi=150)
