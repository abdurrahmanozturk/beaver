#include <iostream>
#include <cstring>

int main()
{
  char myString[]="string";
  char name[255];
  std::cout << "What is your full name?" << '\n';
  std::cin.getline(name,255);
  int letterA=0;
  for (unsigned int i=0; i<strlen(name); ++i)
  {
    if (name[i]=='a')
      letterA++;
  }
  std::cout << "There are " <<letterA<<" a in "<<name<< '\n';

  //pointers
  const char *myName = "Alex"; // pointer to symbolic constant
  std::cout << myName;
  char myName[] = "Alex"; // fixed array
  std::cout << myName;
  int nArray[5] = { 9, 7, 5, 3, 1 };
  char cArray[] = "Hello!";
  const char *name = "Alex";
  std::cout << nArray << '\n'; // nArray will decay to type int*
  std::cout << cArray << '\n'; // cArray will decay to type char*
  std::cout << name << '\n'; // name is already type char*
  return 0;
}
