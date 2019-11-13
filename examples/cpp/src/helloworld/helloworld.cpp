#include <iostream>

int main()
{
  std::cout << " Enter x value " <<std::endl;
  int x;
  std::cin >> x;
  std::cout << x <<std::endl;
  int a=8;
  int const * y = &a;
  std::cout<<&a<<std::endl;
  std::cout<<y<<std::endl;
  std::cout<<*y++<<std::endl;
  std::cout<<y<<std::endl;
  std::cout<<*y<<std::endl;
  std::cout<<a<<std::endl;
  return 0;
}
