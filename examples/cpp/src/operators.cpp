#include <iostream>
#include <cmath>
#include "io.h"
#include "converters.h"
bool isEven(int x)
{
  // return (x+1)%2;
  // return (x%2)==0;
  return x%2;    // return 1 if statement is true, 0 otherwise. == operates comparison
}

int main()
{
  int x{getInteger()};
  myConverters::decimalToBinary(x);
  (x!=5)?(std::cout << "is not 5" << '\n'):(std::cout << "is 5" << '\n');
  if (!isEven(x))
    std::cout << x <<" is an even number." << '\n';
  else
    std::cout << x<<" is an odd number." << '\n';
  (!isEven(x))?(std::cout <<"number is even" << '\n'):(std::cout <<"number is odd" << '\n');
  int y=++x;  //x is incremented first then put into y
  std::cout << "y=x++ = " <<y<< '\n';
  //x is put into y or cout first then incremented
  std::cout << "y=++x = " <<x++<< '\n';
  myConverters::hexToRGB();
  return 0;
}
