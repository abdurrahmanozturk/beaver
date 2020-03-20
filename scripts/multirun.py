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

#Find Index
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

#Generate New Line
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

#Generate New Filename
def newfile(values,runid,param,file):
    if param == "function" or param == "prop_values":
        sys.exit("Error! : Specify variable name instead of "+param)
    return file[:-2:]+"_"+param+"_"+values[runid]

def main():

    #Read Command Line Arguments
    _file = sys.argv[1]
    _param = sys.argv[2]
    _range = sys.argv[3]
    [l,u,dlu] =_range.split(':')
    n_max = 10
    [lower,upper,incre] = [float(l),float(u),float(dlu)]
    print(upper,math.log(lower,10))
    print(upper,math.log(upper,10))
    print((upper-lower)/incre)
    print(n_max*n_max*n_max)
    #Calculate Values based on given range
    log_mode = False
    if (upper-lower)/incre > (n_max*n_max*n_max):
        incre = (math.log(upper,10)-math.log(lower,10))/n_max
        print("log mode")
        log_mode = True
    elif (upper-lower)/incre > n_max:
        incre = (upper-lower)/n_max
        print("linear mode")
    print(incre)
    # for i in range(0,len(_range)):
    #     if _range[i]==":":
    #         index.append(i)
    # lower = float(_range[0:index[0]])
    # upper = float(_range[index[0]+1:index[1]])
    # incre = float(_range[index[1]+1:])
    values = []
    for i in range(0,n_max+1):
        if log_mode == True:
            _val = 10**(math.log(lower,10)+i*incre)
            _dec = len(str((math.log(upper,10)-math.log(lower,10))/incre))
        else:
            _val = lower + i*incre
            _dec = len(str((upper-lower)/incre))
        values.append("%.*e"%(_dec,_val))
    # for _val in np.arange(lower,upper+incre,incre):
        # values.append("%.*e"%(len(str((upper-lower)/incre)),_val))

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

#Run
main()
# os.system("python ~/projects/beaver/scripts/plot.py csvfiles log-0 log-1 -f")
