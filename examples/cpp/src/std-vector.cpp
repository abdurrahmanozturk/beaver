#include <iostream>
#include <vector>
#include <algorithm>

int main ()
{
  std::vector<int> int_vec;       //use vectors instead of dynamic arrays
  int_vec = {2,4,1,6,1,2};
  std::vector<double> double_vec{1.1,5.2,7.8,0.2};
  std::cout << int_vec.at(5) << '\n';      //bounds checking
  std::cout << double_vec[3]<< '\n';
  std::cout << int_vec.size() << '\n';
  int_vec.resize(10);       //vectors may be resized easily ,  resizing is computationally expensive dont use too much
  double_vec.resize(2);     //vectors may be resized smaller sizes
  for (const auto &elem : int_vec)
    std::cout << elem << '\n';
  for (const auto &elem : double_vec)
    std::cout << elem << '\n';
  std::vector<bool> bool_array{true,true,false,false,true};
  for (const auto &elem : bool_array)
    std::cout << elem << '\n';
  return 0;
}
