#include <iostream>
#include <typeinfo>
#include <cstring>

void getData(double *ptr)   //getData(std::nullptr_t ptr) can be used
{
  if (ptr)
    std::cout <<*ptr;
  else
    std::cout << "null pointer" << '\n';
}

void printSize(int *array)   //it can be passed as (int array[])
{
  std::cout << sizeof(array)<< '\n';
}

int main()
{
  int x=1;
  std::cout << "x=" <<x<< '\n';
  std::cout << "the address of x= "<<&x<< '\n';
  std::cout <<typeid(&x).name() << '\n';   //returns as pointer
  std::cout << "x value at the specified address= " <<*&x<< '\n';
  double d=2.5;
  int *iPtr=&x;  //keeps the address of variable
  double *dPtr=&d;
  int* function();  //use asterisk after data type for function definitions

  const int value = 5; // value is const, cannot be changed via pointer
  const int *ptr = &value; // threats the value is const(even if it is not),  int *ptr = &value; will give compile error: cannot convert const int* to int*
  int value1 = 7;
  int *const ptr = &value1;   //const pointer can be defined, it cannot be changed later

  int valuee = 5;
  const int *ptr11 = &valuee; // ptr1 points to a "const int", so this is a pointer to a const value.
  int *const ptr22 = &valuee; // ptr2 points to an "int", so this is a const pointer to a non-const value.
  const int *const ptr33 = &valuee; // ptr3 points to a "const int", so this is a const pointer to a const value.

  std::cout <<iPtr<<" "<<dPtr<< '\n';
  std::cout <<*iPtr<<" "<<*dPtr<< '\n';
  float *fPtr{nullptr};  //null pointer, pointing to nothing  use this instead of 0
  getData(nullptr);
  int array[3]={1,2,3};
  std::cout << "array " <<array<< '\n';    // same address with the first element
  std::cout << "the first element address " <<&array[0]<< '\n';
  std::cout << "the first element " <<array[0]<<'\n';
  std::cout << "the first element " <<*array<< '\n';
  char name[]="Abdurrahman";
  std::cout << "first letter " <<*name<< '\n';
  char *cPtr=name;
  std::cout << "first letter = " <<*cPtr<< '\n';
  *cPtr='E';  // pointer keeps the address of the first element, so changing it will change the first element
  std::cout <<name<< '\n';
  int *aPtr=array;
  std::cout << "the first element address " <<&array[0]<< '\n';
  std::cout << "the second element address " <<&array[1]<< '\n';
  std::cout << "the third element address " <<aPtr+2<< '\n';
  std::cout << "the first element " <<array[0]<<'\n';
  std::cout << "the second element " <<array[1]<<'\n';
  std::cout << "the third element " <<array[2]<<'\n';
  std::cout << "the first element " <<*aPtr<<'\n';
  std::cout << "the second element " <<*(aPtr+1)<<'\n';
  std::cout << "the third element " <<*(aPtr+2)<<'\n';     //array[n] means *(array+n)
  for (char *ptr=name; ptr<name+strlen(name); ++ptr)
  {
    std::cout <<*ptr<<'\n';
  }

  return 0;
}
