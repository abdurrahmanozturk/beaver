#include <iostream>
#include <vector>

typedef std::vector<int> vec_t;

void printArray(const vec_t &array)
{
  for (const auto &elem : array)
    std::cout << elem<<" ";
  std::cout << "\t\tlength is " <<array.size();
  std::cout << "\t\tcapacity is " <<array.capacity();
  std::cout << "\t\tthe top item is " << array.back() <<'\n';
}

int main ()
{
  int stack[1];  // stack[100000000000000] will crash the program because of insufficient memory to keep that capacity
  vec_t array={1,2,3,4,5};
  printArray(array);
  array.reserve(5);
  printArray(array);
  array.push_back(6);    // vector may allocate more capacity than is needed for 1 push
  printArray(array);
  array.pop_back();
  printArray(array);
  array.resize(3);
  printArray(array);
  array.resize(11);
  printArray(array);
  return 0;

}
