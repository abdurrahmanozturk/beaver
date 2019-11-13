#include <iostream>
#include <ctime>
#include "rndnum.h"

int main()
{
  std::srand(static_cast<unsigned int>(std::time(nullptr))); //sets the initial seed to 5233
  for (int count=1; count<10; count++) {
    std::cout <<" "<<rndnum(0,1);
    // std::cout << " " << std::rand();
    if (count%10==0)
      std::cout<<'\n';
  }
  while (true)
  {
  std::cout << "Enter an integer" << '\n';
  int x;
  std::cin >> x;
  if (std::cin.fail())
  {
    std::cin.clear();
    std::cin.ignore(32767,'\n');
  }
  else
    break;
  }
  return 0;
}
