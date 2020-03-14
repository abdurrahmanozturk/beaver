import numpy as np
import math
import subprocess
import os
import sys
import re

# def name(n):
#     argc = sys.argv
#     _range = sys.argv[n]
#     if n==argc:
#         index = []
#         for i in range(0,len(_range)):
#             if _range[i]==":":
#                 index.append(i)
#         lower = float(_range[0:index[0]])
#         upper = float(_range[index[0]+1:index[1]])
#         incre = float(_range[index[1]+1:])
#         temp = []
#         for _val in np.arange(lower,upper,incre):
#             val = "%.*f"%(len(str(incre)),_val)
#             temp.append(val)
#         return name
#     else:
#         index = []
#         for i in range(0,len(_range)):
#             if _range[i]==":":
#                 index.append(i)
#         lower = float(_range[0:index[0]])
#         upper = float(_range[index[0]+1:index[1]])
#         incre = float(_range[index[1]+1:])
#         temp = []
#         for _val in np.arange(lower,upper,incre):
#             val = "%.*f"%(len(str(incre)),_val)
#             temp.append([val]+name(n+1))
#         return temp

#Read Command Line Arguments
_file = sys.argv[1]
_param = sys.argv[2]
_range = sys.argv[3]
print(name(3))
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
    val = "%.*f"%(len(str(incre)),_val)
    newline.append(_param+" = "+val)
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
            #offset intendation
            offset = 0
            for s in range(0,len(line)):
                if line[s]!=" ":
                    offset = " "*s
                    break
            f.write(offset+newline[runid]+"\n")
        elif re.search("file_base",line):
            #offset intendation
            offset = 0
            for s in range(0,len(line)):
                if line[s]!=" ":
                    offset = " "*s
                    break
            f.write(offset+"file_base = "+newfile[runid]+"/"+newfile[runid]+"\n")
        else:
            f.write(line)
    f.close()
    # os.system("mpiexec -n 2 ~/projects/beaver/beaver-opt -i "+newfile[runid]+"/"+newfile[runid]+".i")
