#ifndef MAIN_H
#define MAIN_H

#include <string>

typedef std::string str_t;
class Family;
class Company
{
private:
  str_t name;
  int size;
public:
  Company(str_t name, int size);
  int findSize(auto &company);
  str_t findName(auto &company);
  friend void addMember(Family &family, Company &company, int a,int b);
};

void addMember(Family &family, Company &company, int a=0, int b=0);

class Family
{
private:
  str_t name;
  int size;
public:
  Family(str_t name="Ozturk", int size=8);
  int getSize();
  str_t getName();
  friend int Company::findSize(auto &company);
  friend str_t Company::findName(auto &company);
  friend void addMember(Family &family,Company &company, int a, int b);
};

#endif
