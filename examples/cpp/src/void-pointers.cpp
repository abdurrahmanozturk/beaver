#include <iostream>
#include <string>
#include <vector>

typedef std::vector<int> vec_t;
typedef std::string str_t;

int main ()
{
  int array[]{0,1,2,5,4,9,5,9,8,5,1,5};
  for (unsigned int elem : array)    //each time loop will copy the elements, so use reference
    std::cout <<elem<< '\n';

  for (const auto &elem : array)    //use references for performance reasons
    std::cout << elem << '\n';
  vec_t v={2,5,1,2,5};
  for (const auto &elem : v)
    std::cout << elem << '\n';
  str_t names[]{"Alex","Betty","Caroline","Dave","Emily","Greg","Holly"};
  str_t checkname;
  std::cout << "Enter a name " << '\n';
  std::cin >> checkname;
  bool found{false};
  for (auto &name : names)
  {
    if (name == checkname)
    {
      found=true;
      break;
    }
  }
  if (found == true)
  {
    std::cout << checkname << " was found in list" << '\n';
  }
  else
    std::cout << checkname << " was not found in list" << '\n';

  int intValue=9;
  void *voidPtr = &intValue;     // void pointer does not have a specific data type
  std::cout <<*(static_cast<int*>(voidPtr))<< '\n';    // so it cannot be dereferenced directly
  return 0;
}
