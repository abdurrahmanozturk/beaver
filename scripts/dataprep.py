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

n=len(sys.argv)
csvfile=[]
file = open(sys.argv[1])
filenames = file.readlines()
for i in range(0,len(filenames)):
    csvfile.append(filenames[i][:-1])

# open the file including csv file names`
# store csv files into an array
# input desired column numbers
# loop over all csv files
# loop over given columns and copy data to the new file
# make sure data has headers and can be used for 3D plotting
