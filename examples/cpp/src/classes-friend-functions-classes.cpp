#include <iostream>
#include <string>
#include "main.h"

typedef std::string str_t;

Family::Family(str_t name, int size):
  name{name},
  size{size}
{
}
Company::Company(str_t name, int size):
  name{name},
  size{}
{
}

int Family::getSize(){return size;}
str_t Family::getName(){return name;}
int Company::findSize(auto &company){return company.size;}
str_t Company::findName(auto &company){return company.name;}
void addMember(Family &family, Company &company, int a, int b)
{
  family.size+=a;
  company.size+=b;
}

int main(int argc, char const *argv[])
{
  Family myFamily;
  Company myCompany{"AOEN",1412};
  Family herFamily{"Surname",4};
  addMember(myFamily,myCompany,herFamily.getSize());
  std::cout <<myFamily.getSize()<< '\n';
  std::cout <<myCompany.findSize(myFamily)<< '\n';
  std::cout <<myCompany.findName(myCompany)<< '\n';
  return 0;
}
