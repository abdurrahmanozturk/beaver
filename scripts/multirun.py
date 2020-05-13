import numpy as np
import math
import subprocess
import os
import sys
import csv

# ------------------------------------------------------- #
# ======================================================= #
#     Pyhton script to run multiple MOOSE input files.    #
# ======================================================= #
# ----------------------------------------------eigenturk #

# print 'Number of arguments:', len(sys.argv), 'arguments.'
# print 'Argument List:', str(sys.argv)

filename = sys.argv[1]
cores = "8"
if len(sys.argv)>2:
    cores = sys.argv[-1]

# Read file names from file
file = open(filename)
csvfile = file.readlines()
file.close()
for i in range(0,len(csvfile)):
    #directory = csvfile[i].split('.')[-2]
    os.system("mkdir "+str(i))
    os.system("mpiexec -n "+cores+" ~/projects/beaver/beaver-opt -i "+str(i)+"/"+csvfile[i])
