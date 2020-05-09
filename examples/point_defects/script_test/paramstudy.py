import re
import numpy as np
import os
import subprocess

cmd = "beaver8 problem2.i"

for i in range(1,2):
    # returned_value = os.system(cmd)
    returned_value = subprocess.call(cmd,shell=True)
    print(returned_value)

# void plotScript(std::string filename)
# {
#   std::fstream plotfile;
#   plotfile.open("plot.py", std::fstream::out);
#   plotfile<<"import numpy as np\n"
#             "import matplotlib.pyplot as plt\n"
#             "f = open('"<<filename<<".txt', 'r')\n"
#             "lines = f.readlines()\n"
#             "x = [float(line.split()[0]) for line in lines]\n"
#             "u = [float(line.split()[1]) for line in lines]\n"
#             "fig = plt.figure()\n"
#             "ax1=fig.add_subplot(111)\n"
#             "ax1.plot(x,u)\n"
#             "ax1.set_title('"<<filename<<"')\n"
#             "ax1.set_xlabel('x')\n"
#             "ax1.set_ylabel('u(x)')\n"
#             "plt.show()\n"
#             "fig.savefig(\""<<filename<<".png\", box_inches='tight')\n"
#             "f.close()"<<'\n';
#   plotfile.close();
#   std::string scriptfile = "plot.py";
#   std::string command = "python ";
#   command += scriptfile;
#   system(command.c_str());
# }
