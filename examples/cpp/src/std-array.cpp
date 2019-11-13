#include <iostream>
#include <array>
#include <algorithm>

int printSize(const std::array<double,3> &array)   //use reference to prevent copy all array, good for performance
{
  std::cout << "length of the array = " << array.size()<< '\n';
}

int main ()
{
  std::array<int,5> int_array;    //array with a length of 5, length should be defined at the compile time
  int_array={9,2,3,7,1};     //assigning is ok
  std::array<double,3> double_array {6.5, 0.2, 3.1};   // initialization is ok
  std::cout << double_array.at(1)<< '\n';     //.at() is slower but much safer than [] operator
  int_array.at(1)=5;
  std::cout << int_array[3] << '\n';
  int len = int_array.size();    //will give the length of the array
  std::cout << "length= " << len <<'\n';
  printSize(double_array);
  std::sort(int_array.begin(),int_array.end());        //sorting forwards
  // std::sort(int_array.rbegin(),int_array.rend());      //sorting backwards
  for (auto &elem : int_array)
    std::cout << "element " <<elem<< '\n';
  return 0;
}
