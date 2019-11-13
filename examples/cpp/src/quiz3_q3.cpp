#include <iostream>
#include "io.h"

int main()
{
  double a=getDouble();
  double b=getDouble();
  char opt=getOperator();
  printResult(a,b,opt);
  return 0;
}
