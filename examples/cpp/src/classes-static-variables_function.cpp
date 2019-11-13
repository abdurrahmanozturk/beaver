#include <iostream>
#include "main.h"
#include <vector>

//class constructor
Main::Main(int a,int b) :
  m_a(a),
  m_b(b),
  m_id(++s_counter)
{
}

Main::Initializer::Initializer()
{
  s_coords.push_back(2.1);
  s_coords.push_back(6.2);
  s_coords.push_back(9.3);
}

//defining static class members
int Main::s_counter={0};  // static class members are exist even if there is no class objects, they belong to class itself
std::vector<double> Main::s_coords;//{1.8,7.3,9.8};
Main::Initializer Main::s_initialize;

//class functions
int Main::getId(){return m_id;}
int Main::getCount(){return s_counter;}
std::vector<double> Main::getVector(){return s_coords;}
void Main::pushVector(double a){s_coords.push_back(a);}

int main(int argc, char const *argv[])
{
  std::cout << Main::getCount() << '\n';
  Main first;
  Main second;
  Main third;
  std::vector<double> vec{Main::getVector()};
  std::cout << first.getId() << '\n';
  std::cout << third.getId() << '\n';
  std::cout << vec[0] <<vec[1]<<vec[2]<< '\n';
  Main::pushVector(4.4);
  vec=Main::getVector();
  std::cout << vec[0] <<vec[1]<<vec[2]<<vec[3]<< '\n';
  return 0;
}
