#include <iostream>
#include "io.h"
#include "operations.h"

typedef int (*arithmeticFcn)(int,int);

arithmeticFcn getArithmeticFunction(char opt)
{
  switch (opt)
  {
    default:    // is add
    case '+': return add;
    case '-': return subtract;
    case '*': return multiply;
    case '/': return divide;
  }
}

struct arithmeticStruct
{
  arithmeticFcn fcn;
  char opt;
};

static const arithmeticStruct arithmeticArray[]
{
  {add,'+'},
  {subtract,'-'},
  {multiply,'*'},
  {divide,'/'}
};

arithmeticFcn getArithmeticFnc(char opt)
{
  for (const auto &elem : arithmeticArray)
  {
    if (elem.opt==opt)
      return elem.fcn;
  }
  return add;  //default
}

arithmeticFcn getArithmeticFnc2(const auto &opt, const auto &arithmeticArray)
{
  for (const auto &elem : arithmeticArray)
  {
    if (elem.opt==opt)
      return elem.fcn;
  }
  return add;  //default
}

int calculate(int x,int y, arithmeticFcn fcn)
{
  return fcn(x,y);
}

int main ()
{
  int x = getInt();
  int y = getInt();
  char opt = getOpt();
  arithmeticStruct array[]
  {
    {add,'+'},
    {subtract,'-'},
    {multiply,'*'},
    {divide,'/'}
  };
  std::cout <<x<<opt<<y<<" = "<<calculate(x,y,getArithmeticFunction(opt)) <<'\n';
  std::cout <<x<<opt<<y<<" = "<<calculate(x,y,getArithmeticFnc(opt)) <<'\n';
  std::cout <<x<<opt<<y<<" = "<<calculate(x,y,getArithmeticFnc2(opt,array)) <<'\n';
  return 0;
}
