#include <iostream>
#include "io.h"

int main()
{
  int x = readNumber() + readNumber();
  writeAnswer(x);
  return 0;
}
