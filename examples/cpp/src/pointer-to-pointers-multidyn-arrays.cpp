#include <iostream>

int getSingleIndex(int row, int col, int numberOfColumnsInArray)
{
  return (row*numberOfColumnsInArray+col);
}

int main ()
{
  int value = 5;
  int *ptr1 = &value;
  std::cout << "ptr to value = " <<ptr1<<" "<<*ptr1<< '\n';
  int **ptrptr1 = &ptr1;
  std::cout << "ptr to ptr " <<ptrptr1<<" "<<**ptrptr1<<'\n';
  int *array1 = new int[4] {2, 5, 1, 2};  //dynamic array
  int **array2 = new int*[4];             //array of pointers
  for (size_t i = 0; i < 4 ; i++)
  {
    std::cout << array1[i] <<" <1 - 2>"<<array2[i]<< '\n';
  }
  int array3[3][5];    //defining multidimensional array
  int **array4 = new int*[3];    //defining dynamic array of pointers
  int (*array5)[4] = new int[5][4];  //defining multidimensional dynamic array  way1, right most is compile time constant
  auto array6 = new int[5][2];       //defining multidimensional dynamic array  way2, right most is compile time constant
  delete[] array1,array2,array5,array6;
  for (size_t i = 0; i < 3; i++)
  {
    array4[i] = new int[5];    // defining dynamic array of pointers for each array element
  }
  array4[1][3]=5;
  // arrays need to be deleted by looping
  for (size_t i = 0; i < 3; i++)
  {
    delete[] array4[i];
  }
  delete[] array4;

  for (size_t i = 0; i < 3; i++)
  {
    for (size_t j = 0; j < 5; j++)
    {
      std::cout << array4[i][j] <<" ";
    }
    std::cout << '\n';
  }

  //instead multidimensional array, use one-dimensional array of single index
  int *array7 = new int[15];     // 3x5 array
  array[getSingleIndex(2,4,5)]=6;     //assigning value to array[2][4]=6
}
