#include <iostream>
#include "io.h"

enum Language
{
  Turkish,   //0
  English,   //1
  Spanish,   //2
  French,    //3
  Arabic     //4
};

int calculate(int a, int b,char opt)
{
  switch (opt)
  {
    case '+': //addition
      std::cout << a << opt << b << " = " << a+b << std::endl;
      return a+b;
    case '-': //substraction
      std::cout << a << opt << b << " = " << a-b << std::endl;
      return a-b;
    case '*': //multiplication
      std::cout << a << opt << b << " = " << a*b << std::endl;
      return a*b;
    case '/': //division
      std::cout << a << opt << b << " = " << static_cast<double>(a)/b << std::endl;
      return static_cast<double>(a)/b;
    default:
      std::cout << "Error : Invalid operation !" << '\n';
  }
}

int main()
{
  int a{getInteger()};
  int b{getInteger()};
  int c;
  char opt{'f'};
  while (opt=='f')
  {
    opt=getOperator();
    c=calculate(a,b,opt);
  }
  switch (c)       //Variables can be declared inside switch, but not be initialized,
  {                // if initialization is reqired use { } inside case statement
    case 0:
      std::cout << "Turkish" << '\n';
      break;  // if break is not used compiler will continue to execute other cases till a control flow keyword, such break, exit , return,.... etc
    case 1:
      std::cout << "English" << '\n';
      break;
    case 2:
      std::cout << "Spanish" << '\n';
      break;
    case 3:
      std::cout << "French" << '\n';
      break;
    case 4:
      std::cout << "Arabic" << '\n';
      break;
    default:
      std::cout << "Non-defined" << '\n';
      break;
  }
  switch (c)
  {
    case Turkish:
    case Arabic:
      std::cout << "Middle Eastern Language" << '\n';
      break;
    case English:
    case Spanish:
    case French:
      std::cout << "European Language" << '\n';
      break;
    default:
      std::cout << "Allien Language" << '\n';
      break;
  }
  switch (c)
  {
    case Turkish:
      std::cout << "Selam, Nasilsin?" << '\n';
      break;
    case English:
      std::cout << "Hi, How are you?" << '\n';
      break;
    case Spanish:
      std::cout << "Hola, Como estas?" << '\n';
      break;
    case French:
      std::cout << "Salut, Comment vas-tu?" << '\n';
      break;
    case Arabic:
      std::cout << "Marhabaan, kayf halikm?" << '\n';
      break;
    default:
      std::cout << ".*+ ..  &. -+ $2 h...!35 ,a?.!~ -- = . " << '\n';
      break;
  }
  return 0;
}
