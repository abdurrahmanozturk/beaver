#include <iostream>
#include <string>
#include <utility>

typedef std::string str_t;

enum Country
{
  Turkey,  //0
  Spain,
  France,
  England,
  Italy   //5
};

struct Statistics
{
  int population;
  str_t continent;
  str_t currency;
  double growthRate;
};

struct Family
{
  str_t name;
  str_t sex;
  int age;
  int id;
};

namespace Animals
{
  enum Animals
  {
    CHICKEN,
    DOG,
    CAT,
    ELEPHANT,
    DUCK,
    SNAKE,
    MAX_ANIMALS
  };
}

int main()
{
  Family coords_array[3];
  for (unsigned int i = 0; i<3; i++)
  {
    coords_array[i].name="abcdefg";
    coords_array[i].sex="male";
    coords_array[i].age=30+i*10;
    std::cout << coords_array[i].age << '\n';
  }
  int normals_array[3]={1,2,3};  // use { } for zero initializiation
  Statistics Countries[5];
  Countries[Turkey].population=80e6; // enums has implicit conversion to integer, can be used with arrays, but enum classes can not directly, should be converted
  Countries[Italy].continent="Europe";
  Countries[England].currency="Pounds";
  std::cout << "Turkey Population " <<Countries[Turkey].population<< '\n';
  std::cout << "Italy is in " <<Countries[Italy].continent<< '\n';
  int legs[Animals::MAX_ANIMALS]={2,4,4,4,2,0};
  std::cout << "An elephant has " <<legs[Animals::ELEPHANT]<<" legs \n";
  int array[]={4,6,7,3,8,2,1,9,5};
  // str_t array[]={"a","v","e","b"};
  const int arrayLength = sizeof(array)/sizeof(array[0]);
  int x;
  int index;
  do
  {
    std::cout << "Enter an integer between 1 and 9 = ";
    std::cin >> x;
    if (std::cin.fail())
      std::cin.clear();
    std::cin.ignore(32767,'\n');
  } while (x<1 || x>9);
  for (int i=0; i<arrayLength;++i)
  {
    std::cout <<array[i]<< " ";
    if (x==array[i])
      index=i;
  }
  std::cout<<"\nThe number "<<x<<" has index of "<<index<<'\n';
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
  // multidimensional arrays    array[row][col]
  int arr[][3]=     //leftmost length can be omitted
  {
  {1,2,3}
  {9,8,7}
  };
  int arr2[1][2]={ 0 };
  return 0;
}
