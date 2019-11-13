#include <iostream>
#include <cmath>
#include "io.h"

int decimalToBinary(int x)
{
  std::cout << "The binary representation of " <<x<<" is ";
  int count=static_cast<int>(log2(x));
  int bin[count];
  for (int i = count; i>=0; i--)
  {
    if (x>=pow(2,i))
    {
      x-=pow(2,i);
      bin[i]=1;
      // std::cout << "1";
    } else
      bin[i]=0;
      // std::cout << "0";
  }
  for (int i = count; i >=0; i--)
  {
    std::cout << bin[i];
  }
  std::cout <<'\n';
}
