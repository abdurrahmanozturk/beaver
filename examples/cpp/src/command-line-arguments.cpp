#include <iostream>
#include <cassert>
#include <sstream>  // for std::stringstream  to convert string to int
#include <cstdlib>  // for exit()

typedef std::stringstream str_to_int_t;

int main(int argc, char const *argv[])     //argc = argument count( default is 1, name of the program in command line)
{
  if (argc<=1)
  {
    std::cout << "Input is missing."<< '\n';
    if (argv[0])
    {
      std::cout << "Usage: " <<argv[0]<<" <input1> <input2> <input3> ..."<< '\n';
      std::cout << "Usage: " <<argv[0]<<" <input1> \"<second input>\" <input3> ..."<< '\n';
    }
    else
    {
      std::cout << "Usage: <program name> <input1> <input2> <input3> ..."<< '\n';
      std::cout << "Usage: <program name> <input1> \"<second input>\" <input3> ..."<< '\n';
    }
    exit(1);   //terminate program to ensure providing input and send error code 1 to OS
  }                                        //argv = argument values(vectors) ,array of c-style strings with length argc
  std::cout << "Number of arguments this program takes : " <<argc<< '\n';
  for (size_t i = 0; i < argc; i++)
  {
    std::cout << "Argument " <<i+1<<" = "<<argv[i]<< '\n';
  }
  str_to_int_t string_argument{argv[1]};    //create a variable for string input and initialize it with first program argument
  int int_argument;
  if (!(string_argument>>int_argument))
  {
    std::cerr << "String-Integer Conversion failed" << '\n';
    int_argument=0;
  }
  std::cout << "String Argument : " <<argv[1]<< '\n';
  std::cout << "String Argument +2 : " <<argv[1]+2<< '\n';
  std::cout << "Integer Argument : " <<int_argument<< '\n';
  std::cout << "Integer Argument +2 : " <<int_argument+2<< '\n';
  return 0;
}
