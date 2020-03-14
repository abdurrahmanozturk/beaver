import numpy as np
import math
import subprocess
import os
import sys
import re

#Read Command Line Arguments
_file = sys.argv[1]
_param = sys.argv[2]
_range = sys.argv[3]
index = []
for i in range(0,len(_range)):
    if _range[i]==":":
        index.append(i)
lower = float(_range[0:index[0]])
upper = float(_range[index[0]+1:index[1]])
incre = float(_range[index[1]+1:])
newline = []
newfile = []
for _val in np.arange(lower,upper,incre):
    val = "%.6f"%_val
    newline.append("\t\t"+_param+" = "+val)
    newfile.append(_file[:-2:]+"_"+val)

#Create and Run Input Files
f = open(_file,'r')
lines= f.readlines()
f.close()
for runid in range(0,len(newfile)):
    os.system("mkdir "+newfile[runid])
    f = open(newfile[runid]+"/"+newfile[runid]+".i",'w')
    for line in lines:
        if re.search(_param,line):
            f.write(newline[runid]+"\n")
        elif re.search("file_base",line):
            f.write("\tfile_base = "+newfile[runid]+"/"+newfile[runid]+"\n")
        else:
            f.write(line)
    f.close()
    os.system("mpiexec -n 2 ~/projects/beaver/beaver-opt -i "+newfile[runid]+"/"+newfile[runid]+".i")
