#include <iostream>
#include <string>
#include "io.h"

int main()
{
  int x{getInteger()};
  int y{getInteger()};
  if (y<x)
  {
    int temp=y;
    y=x;
    x=temp;
  } //temp dies here
  double xd(1.2);
  short yd(5);
  using std::cout;   // it can be defined as using namespace std;
  cout << "The smaller number is " <<x<< '\n';
  cout << "The larger number is " <<y<< '\n';
  std::string name;
  name="Abdurrahman";
  std::string surname("Ozturk");
  std::string ID("M37367226");
  std::cout << name << " " <<surname << " " << ID <<'\n';
  std::cout << "Where are you from ? " << '\n';
  std::string country;
  std::cin >> country;
  std::cout << "How old are you ?" << '\n';
  int age{0};
  std::cin >> age;
  std::cin.ignore(32767,'\n');  // std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
  std::cout << "What is your major ?" << '\n';
  using namespace std;
  string job;
  std::getline(std::cin,job);
  string fullName;
  fullName=name+" "+surname;
  cout <<fullName<< " is from " << country<< '\n';
  cout <<"He is " <<age<<" years old"<<'\n';
  cout <<"He is a " <<job<<'\n';
  int nameLength(fullName.length());
  std::cout << "His fullname has " <<nameLength<<" characters\n";
  double yearsPerLetter = static_cast<double>(age)/nameLength;
  std::cout << "he lived "<<yearsPerLetter<<" years per letter in his name" << '\n';
} // x and y dies here
