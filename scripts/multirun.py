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

# #Read Command Line Arguments
# _file = sys.argv[1]
# _param = sys.argv[2]
# _range = sys.argv[3]
# # print(name(3))
# index = []
# for i in range(0,len(_range)):
#     if _range[i]==":":
#         index.append(i)
# lower = float(_range[0:index[0]])
# upper = float(_range[index[0]+1:index[1]])
# incre = float(_range[index[1]+1:])
# newline = []
# newfile = []
# for _val in np.arange(lower,upper,incre):
#     val = "%.*f"%(len(str(incre)),_val)
#     newline.append(_param+" = "+val)
#     newfile.append(_file[:-2:]+"_"+val)
#
# #Create and Run Input Files
# fcsv = open("csvfiles",'w')
# f = open(_file,'r')
# lines= f.readlines()
# f.close()
# for runid in range(0,len(newfile)):
#     os.system("mkdir "+newfile[runid])
#     f = open(newfile[runid]+"/"+newfile[runid]+".i",'w')
#     fcsv.write(newfile[runid]+"/"+newfile[runid]+".csv\n")
#     for line in lines:
#         if re.search(_param,line) and re.search("parametric study",line):
#             #offset intendation
#             offset = 0
#             for s in range(0,len(line)):
#                 if line[s]!=" ":
#                     offset = " "*s
#                     break
#             f.write(offset+newline[runid]+"\n")
#         elif re.search("file_base",line):
#             #offset intendation
#             offset = 0
#             for s in range(0,len(line)):
#                 if line[s]!=" ":
#                     offset = " "*s
#                     break
#             f.write(offset+"file_base = "+newfile[runid]+"/"+newfile[runid]+"\n")
#         else:
#             f.write(line)
#     f.close()
#     # os.system("mpiexec -n 2 ~/projects/beaver/beaver-opt -i "+newfile[runid]+"/"+newfile[runid]+".i")

def get_index(values,runid,param,line):
    index = []
    _param = ""
    if re.search("file_base",line):
        _param = "file_base"
    if re.search("function",line):
        _param = param+':='   #improve this
        ending= ";"
    # elif re.search("prop_values",line):
    #     _param = param+':='   #improve this
    #     ending= ";"
        _patern = re.compile(_param).search(line)
        index.append(_patern.end()) #patern starting index
        for i in range(_patern.end(),len(line)):
            if line[i]==ending:
                index.append(i) #patern ending index
                break
    else:
        if re.search(param+'=',line):
            _param = param+'='   #improve this
        if re.search(param+' = ',line):
            _param = param+' = '   #improve this
        _patern = re.compile(_param).search(line)
        index.append(_patern.end()) #patern starting index
        # ending= ' '
    return index

def newline(values,runid,param,line,file):
    if param == "function" or param == "prop_values":
        sys.exit("Error! : Specify variable name instead of "+param)
    index = get_index(values,runid,param,line)
    if len(index) == 1:
        if re.search("file_base",line):
            _newfile = newfile(values,runid,param,file)
            return line[:index[0]]+" = "+_newfile+"/"+_newfile
        return line[:index[0]]+values[runid]
    else:
        return line[:index[0]]+values[runid]+line[index[1]:]

def newfile(values,runid,param,file):
    if param == "function" or param == "prop_values":
        sys.exit("Error! : Specify variable name instead of "+param)
    return file[:-2:]+"_"+param+"_"+values[runid]

    #     newline.append(_param+" = "+val)
    #     newfile.append(_file[:-2:]+"_"+val)
    #
    # #offset intendation
    # offset = 0
    # for s in range(0,len(line)):
    #     if line[s]!=" ":
    #         offset = " "*s
    #         break



#Read Command Line Arguments
_file = sys.argv[1]
_param = sys.argv[2]
_range = sys.argv[3]

#Calculate Values based on given range
index = []
for i in range(0,len(_range)):
    if _range[i]==":":
        index.append(i)
lower = float(_range[0:index[0]])
upper = float(_range[index[0]+1:index[1]])
incre = float(_range[index[1]+1:])
print(incre)
print(len(str((upper-lower)/incre)))
values = []
for _val in np.arange(lower,upper,incre):
    values.append("%.*e"%(len(str((upper-lower)/incre)),_val))

#Open Files
fcsv = open("csvfiles",'w')
f = open(_file,'r')

#Read Input File
lines= f.readlines()
f.close()

for runid in range(0,len(values)):
    _newfile = newfile(values,runid,_param,_file)
    os.system("mkdir "+_newfile)
    f = open(_newfile+"/"+_newfile+".i",'w')
    fcsv.write(_newfile+"/"+_newfile+".csv\n")
    #Loop over input file
    for line in lines:
        if (re.search("file_base",line)) or (re.search(_param,line) and re.search("parametric study",line)):
            _newline = newline(values,runid,_param,line,_file)
            f.write(_newline+"\n")
        else:
            f.write(line)
    f.close()
    # os.system("mpiexec -n 2 ~/projects/beaver/beaver-opt -i "+_newfile+"/"+_newfile+".i")
