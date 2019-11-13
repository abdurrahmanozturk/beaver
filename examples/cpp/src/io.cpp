#include <iostream>
#include <string>

typedef std::string str_t;

int getInt()
{
  while (true)
  {
    std::cout << "Enter an integer = ";
    int x;
    std::cin >> x;
    if (std::cin.fail())
    {
      std::cerr <<x<< " is not integer, please enter an integer. " << '\n';
      std::cin.clear();
      std::cin.ignore(32767,'\n');
    }
    else
    {
      std::cin.ignore(32767,'\n');
      return x;
    }
  }
}

char getOpt()
{
  while (true)
  {
    std::cout << "Enter an operator { + , - , * , / } = ";
    char opt;
    std::cin >> opt;
    if (std::cin.fail())
    {
      std::cerr <<opt<< " is not valid, please enter a valid operator. " << '\n';
      std::cin.clear();
      std::cin.ignore(32767,'\n');
    }
    else
    {
      std::cin.ignore(32767,'\n');
      if (opt=='+' || opt=='-' || opt=='*' || opt=='/')
      {
        return opt;
      }
    }
  }
}

double getDouble()
{
  std::cout << "Enter a double value = ";
  double a;
  std::cin >> a;
  return a;
}

int getInteger()
{
  std::cout << "Enter an integer value = ";
  int a;
  std::cin >> a;
  return a;
}

char getOperator()
{
  std::cout << "Enter an operator { + , - , * , / }  ";
  char a;
  std::cin >> a;
  if (a=='+' || a=='-' || a=='*' || a=='/')
    return a;
  else
    return 'f';
}

str_t getString()
{
  std::cout << "Enter a string = ";
  str_t str;
  std::cin >> str;
  return str;
}

void printResult(double x,double y, char opt)
{
  if (opt=='+')
      std::cout << x << opt << y << " = " << x+y << std::endl;
  else if (opt=='-')
      std::cout << x << opt << y << " = " << x-y << std::endl;
  else if (opt=='*')
      std::cout << x << opt << y << " = " << x*y << std::endl;
  else if (opt=='/')
      std::cout << x << opt << y << " = " << x/y << std::endl;
}
