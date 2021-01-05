import pandas as pd
import numpy as np
import subprocess
import math
import sys
import csv
import os
import re

# ------------------------------------------------------- #
# ======================================================= #
#     Pyhton script to create data file from CSV files    #
# ======================================================= #
# ----------------------------------------------eigenturk #


#Read Command Line Arguments
n=len(sys.argv)

for i in range(2,len(sys.argv)):
    arg = sys.argv[i]
    if re.search("=",arg):
        arg_name = arg.split('=')[0]
        if re.search(',',arg.split('=')[1]):
            str_arg_value = arg.split('=')[1].split(',')
            arg_value = [float(str_arg_value[a]) for a in range(0,len(str_arg_value))]
        # elif re.search(":",arg.split('=')[1]):
        #     range = arg.split('=')[1]
        #     #Check range Argument
        #     [l,u,ck] = range.split(':')
        #     [lower,upper] = [float(l),float(u)]
        #     if re.search('x',ck):
        #         n = int(ck.split('x')[0])
        #         arg_value = np.arange(lower, upper+1, float((upper-lower)/(n-1)))
        #     else:
        #         arg_value = np.arange(lower, upper+1, float(ck))
        else:
            arg_value=[float(arg.split('=')[1])]

print(arg_name,arg_value)

filename = sys.argv[1]
file = open(filename)
lines = file.readlines()
fmode = False
if re.search(".csv",lines[0]):
    fmode = True
    filenames = lines
    # Read file names from file
    csvfile=[]
    for fid in range(0,len(filenames)):
        csvfile.append(filenames[fid][:-1])
else:
    csvfile = [filename]

data = []
df = pd.DataFrame(data)
for fid in range(0,len(csvfile)):
    print('\033[92m'+"Reading file......"+'\033[0m'+csvfile[fid][-40:])
    with open(csvfile[fid], 'r') as f:
        _reader = csv.reader(f, delimiter=',')
        _headers = next(_reader)
        _data = np.array(list(_reader)).astype(float)
    # Create data frames
    _df = pd.DataFrame(_data,columns=_headers)
    arg_list = [arg_value[fid]]*_df.shape[0]
    _df.insert(loc=0, column=arg_name, value=arg_list)
    df = pd.concat([df,_df],ignore_index=True)

print(df)
df.to_csv(filename+'_data.csv',index=False)

# open single/multiple file(s) including csv file names`
# store csv files into an array
# input desired column numbers or names
# loop over csv file(s)
# loop over given columns and copy data to the new file
# make sure data has headers and can be used for 3D plotting
