import numpy as np
import math
import subprocess
import os
import sys
import re

# line generation for list input
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

#Find the line number for given parameter
def find_line(param,file,blockmode=False,filename=False):
    #Read input file
    f = open(file,'r')
    lines= f.readlines()
    f.close()
    #Loop over file
    linenum = []
    index = 0

    for line in lines:
        if blockmode == False:
            name = re.escape(param)
            #Find the line including output filename
            if filename==True:
                for i in range(len(lines)-1,0,-1):
                    if re.search(name,lines[i]):
                        linenum.append(i)
                        return linenum
                sys.exit("Error! : "+name+" value is not defined input file.")
            #Find the line including parameter
            if re.compile(name).search(line) and re.search("parametric study",line):
                if re.search("_names",line):
                    subindex = 0
                    for subline in lines[index:]:
                        if re.search("_values",subline):
                            linenum.append(index+subindex)
                            # return index+subindex
                        if re.compile(re.escape("[../]")).search(subline):
                            for back in range(index,0,-1):
                                if re.search("_values",lines[back]):
                                    linenum.append(back)
                                    # return back
                                if re.compile(re.escape("[./")).search(lines[back]):
                                    sys.exit("Error! : "+name+" value is not defined input file.")
                        subindex += 1
                linenum.append(index)
                index += 1
            else:
                index += 1

        else:
            block = "[./"+param.split('/')[0]+"]"
            name = param.split('/')[1]
            if re.compile(re.escape(block)).search(line):
                subindex = 0
                for subline in lines[index:]:
                    if re.compile(name).search(subline):
                        if re.search("_names",subline):
                            prop_names_index = index+subindex
                            for prop_values_index in range(index,len(lines)):
                                if re.search("prop_values",lines[prop_values_index]):
                                    linenum.append(prop_values_index)
                                    return linenum
                        linenum.append(index+subindex)
                        return linenum
                    if re.compile(re.escape("[../]")).search(subline):
                        sys.exit("Error! : "+name+" is not defined in block "+block)
                    subindex += 1
            else:
                index += 1
    return linenum


#Generate New Line
def newline(values,runid,param,line,linenum,file):
    if param == "function" or param == "prop_values":
        sys.exit("Error! : Specify variable name instead of "+param)
    index = get_index(param,line,linenum,file)
    if len(index) == 1:
        if re.search("file_base",line):
            _newfile = newfile(values,runid,param,file)
            return line[:index[0]]+" = "+_newfile+"/"+_newfile+"\n"
        return line[:index[0]]+values[runid]+"\n"
    else:
        return line[:index[0]]+values[runid]+line[index[1]:]

#Generate New Filename
def newfile(values,runid,param,file):
    if param == "function" or param == "prop_values":
        sys.exit("Error! : Specify variable name instead of "+param)
    return file[:-2:]+"_"+param+"_"+values[runid]


#Find Index
def get_index(param,line,linenum,file):
    index = []
    if re.search("_values",line):
        param_index = 0
        #Read file
        f = open(file,'r')
        lines= f.readlines()
        f.close()
        values_line = line
        subindex = 0
        for subline in lines[linenum:]:
            if re.search("_names",subline):
                names_line = subline
                break
            if re.compile(re.escape("[../]")).search(subline):
                for back in range(linenum,0,-1):
                    if re.search("_names",lines[back]):
                        names_line = lines[back]
                        break
                    if re.compile(re.escape("[./")).search(lines[back]):
                        sys.exit("Error! : "+name+" value is not defined input file.")
            subindex += 1
        names_list = re.split(' ',re.split('\'',names_line)[1])
        for list_index in range(0,len(names_list)):
            if names_list[list_index]==param:
                param_index = list_index
        values_list = re.split(' ',re.split('\'',values_line)[1])
        string = "'"
        for i in range(0,param_index):
            string += values_list[i]+" "
        _start = re.compile(string).search(values_line)
        string += values_list[param_index]
        _end = re.compile(string).search(values_line)
        index.append(_start.end()) #patern starting index
        index.append(_end.end()) #patern ending index
        return index
    else:
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

def main():

    #Read Command Line Arguments
    _file = sys.argv[1]
    _param = sys.argv[2]
    _range = sys.argv[3]

    #Check parameter argument
    if len(_param.split('/'))>1:
        blockmode = True
        _param_name = _param.split('/')[1]
    else:
        _param_name = _param
        blockmode = False

    #Check range Argument
    [l,u,ck] =_range.split(':')
    [lower,upper] = [float(l),float(u)]
    if re.search('x',ck):
        n = int(ck.split('x')[0])
    else:
        n = int((upper-lower)/float(ck))

    #Limit max number of simulations to avoid overloading memory
    n_max = 10
    if n > n_max:
        n = n_max

    #Calculate values based on given range
    values = []
    log_mode = False
    if math.log((upper-lower)/n) > 3:
        log_mode = True
        incre = (math.log(upper,10)-math.log(lower,10))/n
    else:
        incre = (upper-lower)/n
    for i in range(0,n+1):
        if log_mode == True:
            _val = 10**(math.log(lower,10)+i*incre)
            _dec = len(str((math.log(upper,10)-math.log(lower,10))/incre))
        else:
            _val = lower + i*incre
            _dec = len(str((upper-lower)/incre))
        values.append("%.*e"%(_dec,_val))

    #Open files
    csvfile = "csvfiles"
    fcsv = open(csvfile,'w')
    f = open(_file,'r')

    #Read input file
    lines= f.readlines()
    f.close()

    #Find Parameter in input file
    param_line_num = find_line(_param,_file,blockmode)
    param_line = []
    for i in range(0,len(param_line_num)):
        param_line.append(lines[param_line_num[i]])
    filename_line_num = find_line("file_base",_file,False,True)[0]
    filename_line = lines[filename_line_num]

    #Loop over values, generate input files and run them
    for runid in range(0,len(values)):
        _newfile = newfile(values,runid,_param_name,_file)
        os.system("mkdir "+_newfile)
        fcsv.write(_newfile+"/"+_newfile+".csv\n")
        f = open(_newfile+"/"+_newfile+".i",'w')
        for i in range(0,len(param_line_num)):
            lines[param_line_num[i]] = newline(values,runid,_param_name,param_line[i],param_line_num[i],_file)
        lines[filename_line_num] = newline(values,runid,_param_name,filename_line,filename_line_num,_file)
        for line in lines:
            f.write(line)
        f.close()
        # os.system("mpiexec -n 2 ~/projects/beaver/beaver-opt -i "+_newfile+"/"+_newfile+".i")
    fcsv.close()

#======================#
#RUN THIS PYTHON SCRIPT
main()
# os.system("python ~/projects/beaver/scripts/plot.py csvfiles log-0 log-1 log-3 -f -s")
#======================#
