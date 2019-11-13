#include <iostream>
#include <string>
#include <utility>

int main()
{
  int array[]={4,6,7,3,8,2,1,9,5};
  const int arrayLength = sizeof(array)/sizeof(array[0]);
  // selection method
  for (int i=0; i<arrayLength; ++i)
  {
    int minIndex=i;
    for (int j=i; j<arrayLength; ++j)
    {
      if (array[j]<array[minIndex])   // use > for descending sort
      {
        minIndex=j;
      }
    }
    std::swap(array[minIndex],array[i]);
    std::cout <<array[i]<< " ";
  }
  std::cout <<'\n';

  //bubble method
  const int length(9);
  int arraybubble[length]={6,3,2,9,7,1,5,4,8};
  for (size_t i=length; i>0; --i)
  {
    bool isSwap(false);
    for (size_t j = 0; j < i-1; ++j)
    {
      if (arraybubble[j]>arraybubble[j+1])
      {
        std::swap(arraybubble[j+1],arraybubble[j]);
        isSwap=true;
      }
    }
    for (size_t i = 0; i < length; i++)
    {
        std::cout <<arraybubble[i]<<" ";
    }
    std::cout <<'\n';
    if (!isSwap)
    {
      std::cout << "Early termination on iteration " <<i<< '\n';
      break;
    }
  }
  return 0;
}
