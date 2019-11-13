#include <iostream>
#include <vector>
#include <algorithm>
#include <array>
#include <string>
#include <utility>
#include <cstring>

typedef std::string str_t;

enum ItemType
{
  HEALTH_POTION,   //0
  TORCHE,          //1
  ARROW,           //2
  MAX_ITEMTYPE     //3
};

int countTotalItems(const int (&array)[MAX_ITEMTYPE])
{
  int sum{0};
  for (const auto &elem : array)
  {
    sum += elem;
  }
  return sum;
}

struct Student
{
  str_t name;
  double grade;
};

void sortThis(Student *array,int length)
{
  for (unsigned int i=0; i<length; ++i)
  {
    int maxIndex=i;
    for (unsigned int j=i; j<length; ++j)
    {
      if (array[j].grade>array[maxIndex].grade)
        maxIndex = j;
    }
    std::swap(array[i],array[maxIndex]);
  }
}

void swapThis(int &x,int &y)
{
  int temp;
  temp = x;
  x=y;
  y=temp;
}

// void printChar1(char *string)
// {
//   for (char *ptr=string; ptr<string+strlen(string);++ptr)
//   {
//     std::cout << *ptr << '\n';
//   }
// }

void printChar(const char *string)
{
  while (*string != '\0')
  {
    std::cout << *string << " ";
    ++string;
  }
  std::cout << '\n';
}

int main ()
{
  int bag[MAX_ITEMTYPE];  //can be initialized by {2,5,10} or seperately as below
  bag[HEALTH_POTION] = 2;
  bag[TORCHE] = 5;
  bag[ARROW] = 10;
  std::cout <<"Total number of items = " <<countTotalItems(bag) << '\n';
  std::cout << "How many students do you want to enter? " << '\n';
  int maxStudents;
  std::cin >> maxStudents;
  Student *students = new Student[maxStudents];   //dont forget to delete
  for (unsigned int i=0; i<maxStudents; ++i)
  {
    std::cout << "Student Name = " << '\n';
    std::cin >> students[i].name;
    std::cout << "Grade = " << '\n';
    std::cin >> students[i].grade;
  }
  sortThis(students,maxStudents);
  for (size_t i=0; i<maxStudents; ++i)
  {
    std::cout << students[i].name <<" got a grade of "<< students[i].grade<<'\n';
  }
  delete[] students;
  int x=5,y=9;
  std::cout << "x=" <<x <<"  y="<< y << '\n';
  swapThis(x,y);
  std::cout << "x=" <<x<<"  y="<< y << '\n';
  printChar("Hello, world!");
  return 0;
}
