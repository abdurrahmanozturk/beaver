#include <iostream>
#include <string>
#include <sstream>
#include <vector>
#include "beaver.h"
#include <sstream>

typedef std::vector<int> int_vec_t;
typedef std::string str_t;
typedef std::vector<str_t> str_vec_t;
typedef std::stringstream str_to_int_t;

//constructor
Beaver::Beaver(double x, double y, double z, double ans) :
  m_x(x),
  m_y(y),
  m_z(z),
  m_ans(ans)
{
}
//function
Beaver& Beaver::add(double x) {m_ans+=x; return *this;}
Beaver& Beaver::subtract(double x) {m_ans-=x; return *this;}
Beaver& Beaver::multiply(double x) {m_ans*=x; return *this;}
Beaver& Beaver::divide(double x) {m_ans/=x; return *this;}

str_t getInput()
{
  str_t userInput;
  std::cout << ":) ";
  std::cin >> userInput;
  if (userInput=="exit" || userInput=="quit" || userInput=="q" || userInput=="x")
    exit(1);
  return userInput;
}

int_vec_t getOptIndex(const str_t &userInput)
{
  int_vec_t optIndex{};
  for (size_t i = 0; i < userInput.length(); i++)
  {
    if (userInput[i]=='+' || userInput[i]=='-' || userInput[i]=='*' || userInput[i]=='/')
    {
      optIndex.push_back(i);
    }
  }
  return optIndex;
}

int_vec_t resolveInput(const str_t &userInput)
{
  int_vec_t optIndex{getOptIndex(userInput)};
  optIndex.push_back(userInput.length());
  str_vec_t numStr;
  int begin{0};
  if (optIndex[0]>0)
    numStr.push_back("");
  for (size_t i = 0; i < optIndex.size(); i++)
  {
    for (size_t j = begin; j <userInput.length(); j++)
    {
      if (j==optIndex[i])
      {
        numStr.push_back("");
        begin=optIndex[i]+1;
        break;
      }
      numStr[i]+=userInput[j];
    }
  }
  int_vec_t numInt;
  for (size_t i = 0; i < numStr.size(); i++)
  {
    int temp;
    str_to_int_t str{numStr[i]};    //create a variable for string input and initialize it with first program argument
    if (!(str>>temp))
    {
      std::cerr << "String-Integer Conversion failed" << '\n';
      temp=0.0;
    }
    numInt.push_back(temp);
  }

  return numInt;
}

int main(int argc, char const *argv[])
{
  Beaver calc;
  while (true)
  {
    str_t input{getInput()};
    std::cout <<"ans = "<<resolveInput(input)[0]+resolveInput(input)[1]<<'\n';
  }
  return 0;
}
