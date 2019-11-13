#include <iostream>
#include <cassert>

static_assert(sizeof(long)==8,"long must be 8 bytes");   //diagnosing
static_assert(sizeof(int)==4,"int must be 4 bytes");     // diagnosing

int enterInt()
{
  int x;
  std::cout << "Enter an integer" << '\n';
  while (true)
  {
  std::cin >> x;
    if (std::cin.fail())
    {
      std::cerr << "User entered a non-integer value, please enter an integer." << '\n';
      std::cin.clear();
      std::cin.ignore(32767,'\n');
    }
    else
    {
      std::cin.ignore(32767,'\n');
      return x;
    }
  }
}

int getArrayValue(const int (&array)[3],int index)
{
  int arrayLength=sizeof(array)/sizeof(array[0]);
  assert(index>=0 && index < arrayLength && "Index is out of array");
  return array[index];
}

int main()
{
  int array[3]{enterInt(),enterInt(),enterInt()};
  std::cout << getArrayValue(array,enterInt())<<'\n';
  return 0;
}
