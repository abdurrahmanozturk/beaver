#include <iostream>
#include <vector>

void countDown(const int &count)
{
  std::cout <<count<< '\n';
  if (count > 1)
    countDown(count-1);
  std::cout <<"pop= "<<count<< '\n';
}

int fibonacci(const int &count)
{
  if (count==0)
    return 0;
  if (count==1)
    return 1;
  if (count>1)
    return fibonacci(count-1) + fibonacci(count-2);
}

void printFibonacci(const int &count)
{
  for (size_t i = 0; i < count; i++)
  {
    std::cout <<fibonacci(i)<<" ";
  }
  std::cout << '\n';
}

int factorial(const int &num)
{
  if (num==0 || num==1)
    return 1;
  else
    return num*factorial(num-1);
}

int sumDigits(const int &num)
{
  if (num<10)
    return num;
  else
    return num%10+sumDigits((num-num%10)/10);
}

int printBinary(const unsigned int &num)
{
  if (((num-num%2)/2)>0)
    printBinary(((num-num%2)/2));
  std::cout << num%2<<" ";
}

int main()
{
  std::cout << "How many fibonacci numbers do you want to see ?" << '\n';
  int count;
  std::cin >> count;
  // countDown(9);
  // printFibonacci(count);
  // std::cout <<factorial(count)<<'\n';
  // std::cout <<sumDigits(count)<<'\n';
  printBinary(count);
  return 0;
}
