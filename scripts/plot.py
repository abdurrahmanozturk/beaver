import re
import sys
import csv
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


# -------------------------------------------------------------------------------------------------------------- #
# ============================================================================================================== #
#                           Pyhton script to plot data from MOOSE csv output files.                              #
# ============================================================================================================== #
# -----------------------------------------------------------------------------------------------------eigenturk #


def getHelp():
    print('\033[96m'+"\n# ------------------------------------------------------- #\n"
          "# ======================================================= #\n"
          "# Pyhton script to plot data from MOOSE csv output files. #\n"
          "# ======================================================= #\n"
          "# ----------------------------------------------eigenturk #\n"+'\033[0m')
    print("This script is a tool for plotting csv files based on specified column numbers.\n\n"
          "Usage: plot [filename] [column_number1] [column_number2] ... [-h] [-s]\n\n"
          "Arguments:\n\n"
          "\tfilename\t\tName of the data file with extension\n"
          "\tcolumn(number or name)\t\tThe column number(name) of the data in csv file\n\n"
          "Optional arguments:\n\n"
          "  -h, Show this help message and exit.\n"
          "  -s, Save only mode, plot wont be shown.\n"
          "  -g, Gray scale mode, plot will be in black and white scale.\n\n"
          "  -f, Multiple file mode."+'\033[91m'+" << ! Depricated, will be deleted. !\n\n"+'\033[0m'
          '\033[4m'+'\033[1m'+"Manual for commands :\n\n"+'\033[0m'
          "Note  : To make it easy, create 'plot' command by adding following line to your shell profile.\n"
          '\033[92m'+"\talias plot=\"python projects/scripts/plot.py\"\n"+'\033[0m'
          "\n-Plotting data from a single file\n"
          '\033[93m'+"\tplot filename column_x column_y1.....column_yn\n"+'\033[0m'
          "\n-Plotting data from multiple files\n"
          '\033[91m'+"\tFirst, append name of all csv files to a seperate file (e.g. \"csvfiles\"),then use name of that file in command line.\n"
          '\033[93m'+"\tplot csvfiles column_x column_y\n"+'\033[0m'
          "\n-Save a plot without showing it by adding \"-s\" at end of the command\n"
          '\033[93m'+"\tplot filename column_x column_y1.....column_yn -s\n"+'\033[0m'
          "\n-Use gray color scale for plotting by adding \"-g\" at end of the command\n"
          '\033[93m'+"\tplot filename column_x column_y1.....column_yn -g\n"+'\033[0m')
    sys.exit()

if sys.argv[-1]=="-"+"h":
    getHelp()

# print 'Number of arguments:', len(sys.argv), 'arguments.'
# print 'Argument List:', str(sys.argv)
n=len(sys.argv)
filename = sys.argv[1]
file = open(filename)
figname=filename[:-4]+".png"

fmode = False
if sys.argv[-2]=="-"+"f" or sys.argv[-1]=="-"+"f":   # WILL BE DEPRICATED
    fmode = True
    n=n-1

gmode = False   #black and white mode
if sys.argv[-2]=="-"+"g" or sys.argv[-1]=="-"+"g":
    gmode = True
    n=n-1

if re.search(".csv",file.readlines()[0]):
    print('\033[92m'+"Multiple File Mode : Data from multiple files was plotted on the same figure.\n"+'\033[0m')
    fmode = True
    # Read file names from file
    csvfile=[]
    file = open(filename)
    filenames = file.readlines()
    for i in range(0,len(filenames)):
        csvfile.append(filenames[i][:-1])
else:
    fmode = False
    print('\033[92m'+"Single File Mode : Data from a single file was plotted.\n"+'\033[0m')
    csvfile = [filename]

smode = False
if sys.argv[-2]=="-"+"s" or sys.argv[-1]=="-"+"s":
    print("-s mode : save only mode, plot wont be shown")
    smode = True
    n=n-1

# tmode = False    # WORK ON THIS
# if sys.argv[-2]=="-"+"t" or sys.argv[-1]=="-"+"t":
#     print("-t mode : add secondary axis for column_y2")
#     tmode = True
#     n=n-1

#=============================================================================
#                               Figure Settings
#=============================================================================
mf=10000   #Marker frequency

#Create Figure
fig = plt.figure(figsize=(5, 5))
ax = fig.add_subplot(1, 1, 1)

# if tmode==True:  # ADD SECONDARY AXIS FEATURE, WORK ON THIS!!
#     ax2 = ax.twiny()

# Plotting Style,Color Palette,Markers and Line Styles
linestyles = ["solid","dotted","dashdot","dashed"]
markers = ["","","","",""]
plt.style.use('seaborn-whitegrid')

if gmode == True: # Use Gray Color Scale
    palette = plt.get_cmap('gray')  # Black and White Color Scale, {gnuplot}
    if fmode == True:  #For Single file, use only linestyles, dont use markers,
        markers = ["","o", "s", "v","X"]
else: # Colorful plotting
    palette = plt.get_cmap('Set1')  # Color Scale, {Set1,Set2,Set3,Dark2,tab10},tab20,Pastel1}


#=============================================================================

for fid in range(0,len(csvfile)):
    print('\033[92m'+"Reading file......"+'\033[0m'+csvfile[fid][-40:])
    with open(csvfile[fid], 'r') as f:
        reader = csv.reader(f, delimiter=',')
        headers = next(reader)
        data = np.array(list(reader)).astype(float)

    # print(headers)
    # print(data.shape)
    # print(data[:5])

    # Make a data frame
    df=pd.DataFrame(data,columns=headers)

    # Read Command Line Arguments
    log = [0]*n  #list to check if log-plot was requested for commandline argument
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

    #Labels
    xlbl = headers[int(sys.argv[2])]
    ylbl = headers[int(sys.argv[3])]
    # xlbl = "x [unit]"          # define x label manually
    # ylbl = "y(x) [unit]"       # define y label manually

    #Axis Limits
    xmin=np.floor(np.min(data[:, int(sys.argv[2])]))
    xmax=np.ceil(np.max(data[:, int(sys.argv[2])]))
    ymin=np.floor(np.min(data[:, int(sys.argv[3])]))
    ymax=np.ceil(np.max(data[:, int(sys.argv[3])]))#*1.05

    #=============================================================================
    #                           Plotting Data
    #=============================================================================
    num=0
    markevery=len(data)/(10*mf)
    for column in range(3,n):
        if fmode==1:
            lbl = csvfile[fid]#[-30:]     ## CHANGE THIS ACCORDING TO PARAMETER IN THE END OF FILENAME
            figname = ylbl
        else:
            lbl = headers[int(sys.argv[column])]
        if log[column]==1:
            ax.semilogy(data[:, int(sys.argv[2])], data[:, int(sys.argv[column])],ls=linestyles[num%4],marker=markers[fid%5],markersize=5,markevery=markevery,color=palette(fid), linewidth=1.5, alpha=1,label=lbl)
        else:
            ax.plot(data[:, int(sys.argv[2])], data[:, int(sys.argv[column])],ls=linestyles[num%4],marker=markers[fid%5],markersize=5,markevery=markevery, color=palette(fid), linewidth=1.5, alpha=1,label=lbl)
        if log[2]==1:
            ax.set_xscale('log',basex=10)
        if np.min(data[:, int(sys.argv[column])])<ymin:
            ymin=np.min(data[:, int(sys.argv[column])])
            ax.set_ylim(ymin,ymax)
        if np.ceil(np.max(data[:, int(sys.argv[column])]))>ymax:
            np.ceil(ymax=np.max(data[:, int(sys.argv[column])]))
            ax.set_ylim(ymin,ymax)
        num+=1

print('\033[92m'+"\nAvailable parameters for plotting: \n"+'\033[0m'+str(headers))
# WORK ON THIS TO CHECK EXISTENCE OF HEADERS

#=============================================================================
#                               Plot Settings
#=============================================================================
# if tmode==True:   # !WORK ON THIS,  NOT READY TO USE
#     # Tick Settings
#     ax2.xaxis.set_tick_params(which='major', size=7, width=1, direction='in', top=True)
#     ax2.xaxis.set_tick_params(which='minor', size=2, width=1, direction='in', top=True)
#     ax2.yaxis.set_tick_params(which='major', size=7, width=1, direction='in', right=True)
#     ax2.yaxis.set_tick_params(which='minor', size=2, width=1, direction='in', right=True)
#     # Hide or Show the top and right spines of the axis
#     ax2.spines['right'].set_visible(True)
#     ax2.spines['top'].set_visible(True)
#     # Set Labels
#     ax2.set_xlim(xmin,xmax)
#     ax2.set_xlabel(xlbl)
#     ax2.set_ylabel(ylbl)

# Font Settings
plt.rcParams['font.family']='Times New Roman'
plt.rcParams['font.size'] = 12
# Tick Settings
ax.xaxis.set_tick_params(which='major', size=7, width=1, direction='in', top=True)
ax.xaxis.set_tick_params(which='minor', size=2, width=1, direction='in', top=True)
ax.yaxis.set_tick_params(which='major', size=7, width=1, direction='in', right=True)
ax.yaxis.set_tick_params(which='minor', size=2, width=1, direction='in', right=True)
# Hide or Show the top and right spines of the axis
ax.spines['right'].set_visible(True)
ax.spines['top'].set_visible(True)
# Set Labels
ax.set_xlim(xmin,xmax)
ax.set_xlabel(xlbl)
ax.set_ylabel(ylbl)

# Add Legend and title
plt.legend(loc=0, ncol=1,fontsize='medium')
plt.title(filename)

# plt.axis('equal')               # fix x and y axis
# plt.autoscale(enable=True, axis='x', tight=True)   #autoscale x and y axis
if smode == True: #save only
    fig.savefig(figname, bbox_inches='tight',dpi=150, transparent=False)
else:
    plt.show()
    fig.savefig(figname, bbox_inches='tight',dpi=150, transparent=False)

#=============================================================================
