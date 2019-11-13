#include <iostream>
#include <string>
#include <utility>

typedef std::string str_t;


void doSomething()
{
    int *ptr = new int;    // ptr will go out of scope but memory will stay allocated, which is memory leak
}                          // the address of allocated memory will be lost

void sortNames(str_t *array, int length)
{
    // const int arrayLength = sizeof(names)/sizeof(names[0]);  array is decaying to pointer so this can not be used check reference variable
    // selection method
    for (int i=0; i<length; ++i)
    {
      int minIndex=i;
      for (int j=i; j<length; ++j)
      {
        if (array[j]<array[minIndex])   // use > for descending sort
        {
          minIndex=j;
        }
      }
      std::swap(array[minIndex],array[i]);
    }
    std::cout << "Sorted" << '\n';
}


int main ()
{
  new int;   // has no scope untill  the program ends or deallocated, but pointers have scope be carefull!!
  int *ptr=new int {2};  // dynamically allocated and initialized
  *ptr=4;
  int *ptr1=new int;
  std::cout <<ptr<<'\n';
  std::cout <<*ptr<<'\n';
  delete ptr; // program itself is responsible for disposing the dynamically allocated memory
  ptr = nullptr;  // set deleted pointer to null immediately after deleting them
  std::cout << ptr << '\n';    // dangling pointer
  // std::cout << *ptr << '\n';     // will give segmentation fault 11 if ptr is null, which means, there is nothing in that memory address
  int *ptr2 = new (std::nothrow) int;  // pointer will be set to null if memory allocation fails
  if (!ptr2)   // if ptr2 will be returned null
    std::cout << "Could not allocate memory" << '\n';
  if (!ptr2)
    ptr2=new int; // if ptr2 is null then dynamically allocate memory to it
  int x=5;
  int *ptr3 = new int;    //allocates memory
  delete ptr3;      //delete pointer before assigning new value to it, otherwise memory leak will happen
  ptr3=&x;          // deleting will prevent loss of allocated memory address
  int *ptr4 = new int;
  ptr4 = new int;    // double allocation will also cause memory leak; the first one will be lost
  std::cout << "enter array length" << '\n';
  int len;
  std::cin >> len;
  int *array = new int[len];     // new int[len]()    initialize dynamic array to zero
  array[2]=6;
  std::cout << array[0]<<" "<<array[1]<<" "<<array[2]<< '\n';
  delete[] array;    // array version of delete for dynamically allocated arrays
  int fixedArray[5] = { 9, 7, 5, 3, 1 }; // initialize a fixed array in C++03
  int *dynamicArray = new int[5] { 9, 7, 5, 3, 1 }; // initialize a dynamic array in C++11
  std::cout << "How many names do you want to sort? " << '\n';
  int n;
  std::cin >> n;
  str_t *names = new str_t[n];
  for (size_t i=0; i<n; ++i)
  {
    std::cout << "Enter name #" <<i+1<< '\n';
    std::cin >>names[i];
  }
  sortNames(names,n);
  for (size_t i = 0; i < n; i++)
  {
    std::cout << names[i] << '\n';
  }
  delete[] names;
  return 0;
}
