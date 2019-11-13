#include <iostream>
#include <algorithm>
#include <functional>

typedef bool (*functionPtr)(int, int);   //use typedef for function pointer declearation

// Here is a comparison function that sorts in ascending order
// (Note: it's exactly the same as the previous ascending() function)
bool ascending(int x, int y)
{
    return x > y; // swap if the first element is greater than the second
}

functionPtr ascendPtr=ascending;

// Here is a comparison function that sorts in descending order
bool descending(int x, int y)
{
    return x < y; // swap if the second element is greater than the first
}

// Note our user-defined comparison is the third parameter
void selectionSort(int *array, int size, bool (*comparisonFcn)(int, int)=ascending)
{
    // Step through each element of the array
    for (int startIndex = 0; startIndex < size; ++startIndex)
    {
        // bestIndex is the index of the smallest/largest element we've encountered so far.
        int bestIndex = startIndex;

        // Look for smallest/largest element remaining in the array (starting at startIndex+1)
        for (int currentIndex = startIndex + 1; currentIndex < size; ++currentIndex)
        {
            // If the current element is smaller/larger than our previously found smallest
            if (comparisonFcn(array[bestIndex], array[currentIndex])) // COMPARISON DONE HERE
                // This is the new smallest/largest number for this iteration
                bestIndex = currentIndex;
        }

        // Swap our start element with our smallest/largest element
        std::swap(array[startIndex], array[bestIndex]);
    }
}

// This function prints out the values in the array
void printArray(int *array, int size)
{
    for (int index=0; index < size; ++index)
        std::cout << array[index] << " ";
    std::cout << '\n';
}

int five()
{
  return 5;
}

double four()
{
  return 4.0;
}

int plusone(int x)
{
  return x+1;
}

int main ()
{
  std::cout <<reinterpret_cast<void*>(five)<<'\n';   //function address
  int (*fPtr)();    //pointer to function
  int (*const fcnPtr)() = five;      //const pointer to function
  fPtr=five;    //fPtr points to function five  dont use operator ()
  double (*fPtr2)()=four;    //fPtr2 points to function four  type should match double-double
  int (*fPtr3)(int)=plusone;   //fPtr3 points to function plusone with 1 int parameter
  std::cout <<(*fPtr3)(4) << '\n';     //function call via pointer way 1
  std::cout << fPtr() << '\n';        // function call via pointer way 2

  int array[9] = { 3, 7, 9, 5, 6, 1, 8, 2, 4 };
   // Sort the array in descending order using the descending() function
  selectionSort(array, 9, descending);
  printArray(array, 9);

  // Sort the array in ascending order using the ascending() function
  selectionSort(array, 9, ascending);
  printArray(array, 9);

  std::function<int()> fcnPtr5;
  fcnPtr5 = four;
  std::cout << fcnPtr5() << '\n';

  return 0;
}
