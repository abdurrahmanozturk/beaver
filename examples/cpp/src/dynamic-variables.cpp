#include <iostream>

void doSomething()
{
    int *ptr = new int;    // ptr will go out of scope but memory will stay allocated, which is memory leak
}                          // the address of allocated memory will be lost

int main ()
{
  new int;   // has no scope untill  the program ends or deallocated, but pointers have scope be carefull!!
  int *ptr=new int {2};  // dynamically allocated and initialized
  *ptr=4;
  int *ptr1=new int;
  std::cout <<ptr<<'\n';
  std::cout <<*ptr<<'\n';
  delete ptr; // program itself is responsible for disposing the dynamically allocated memory
  ptr = nullptr;  //set deleted pointer to null immediately after deleting them
  std::cout << ptr << '\n';    // dangling pointer
  std::cout << *ptr << '\n';
  int *ptr2 = new (std::nothrow) int;  // pointer will be set to null if memory allocation fails
  if (!ptr2)   //if ptr2 will be returned null
    std::cout << "Could not allocate memory" << '\n';
  if (!ptr2)
    ptr2=new int; // if ptr2 is null then dynamically allocate memory to it
  int x=5;
  int *ptr3 = new int;    //allocates memory
  delete ptr3;      //delete pointer before assigning new value to it, otherwise memory leak will happen
  ptr3=&x;          // deleting will prevent loss of allocated memory address
  int *ptr4 = new int;
  ptr4 = new int;    // double allocation will also cause memory leak; the first one will be lost
  return 0;
}
