#include <iostream>

// auto add(int a,int b)->int; //tralling return syntax can help to define return data type

auto add(int a,int b)   // can be used for functions, but avoid for now
{
  return a+b;
}
int main()
{
  auto aint=1;   //auto can understant the data type by looking at initializing value
  auto bdouble=2.5;
  auto chr='a';
  std::cout << "bdouble= " <<bdouble<< '\n';
  std::cout << "aint= " <<aint<< '\n';
  std::cout << "char= " <<chr<< '\n';
  std::cout << "add= " <<add(aint,(2*aint))<< '\n';
  return 0;
}
