#include <iostream>

double max(const double &x, const double &y)
{
  if (x>y)
    return x;
  else
    return y;
}

void swap(int &x, int &y)
{
  int temp=x;
  x=y;
  y=temp;
  std::cout << "Swapped!" << '\n';
}

int& getLargestELement(int *array,int length)
{
  int largestIndex=0;
  for (unsigned int i = 0; i < length; ++i)
  {
    if (max(array[largestIndex],array[i])==array[i])
      largestIndex=i;
  }
  std::cout <<array[largestIndex]<< '\n';
  return array[largestIndex];
}

int main(int argc, char const *argv[])
{
  int x,y;
  std::cin >> x;
  std::cin >> y;
  std::cout << "x :"<<x<<" y :"<<y<< '\n';
  std::cout << "max : " <<max(x,y)<< '\n';
  swap(x,y);
  std::cout << "x :"<<x<<" y :"<<y<< '\n';
  int *array=new int[5]{1,5,6,9,8};
  std::cout << "array[4]= " <<array[3]<< '\n';
  getLargestELement(array,5)=15;
  std::cout << "array[4]= " <<array[3]<< '\n';
  delete[] array;
  return 0;
}
