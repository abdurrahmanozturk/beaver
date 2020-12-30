import numpy as np
import math
import subprocess
import os
import sys
import csv

# ------------------------------------------------------- #
# ======================================================= #
#     Pyhton script to create data file from CSV files    #
# ======================================================= #
# ----------------------------------------------eigenturk #

for i in range(1,len(sys.argv)):
    if re.search("=",sys.argv[i]):
        if sys.argv[i].split('=')[0]=='T':
            T=float(sys.argv[i].split('=')[1])
        elif sys.argv[i].split('=')[0]=='K0':
            K0=float(sys.argv[i].split('=')[1])
        elif sys.argv[i].split('=')[0]=='l':
            l=float(sys.argv[i].split('=')[1])
        elif sys.argv[i].split('=')[0]=='Cs':
            Cs=float(sys.argv[i].split('=')[1])

data_file = open('moose_data.csv', 'a')
data_file.close()

# open single/multiple file(s) including csv file names`
# store csv files into an array
# input desired column numbers or names
# loop over csv file(s)
# loop over given columns and copy data to the new file
# make sure data has headers and can be used for 3D plotting
