#include <iostream>

// forward declarations
void nasilsin();
void iyim();
//end of forward declarations

void mola()
{
  // returns nothing
  std::cout <<"mola verdim y=x+1 " << std::endl;
}

int iki()
{
  // returns integer value of 2
  return 2;
}

int sayigir()
{
  int a;
  std::cout << "z=" << '\n';
  std::cin >> a;
  return a;
}

void iyim()
{
  std::cout << "Iyim sen?" << '\n';
  // nasilsin();
}

void nasilsin()
{
  std::cout << "Nasilsin?" << '\n';
  iyim();
}

int carp(int x,int y)
{
  return x*y;
}

int topla(int x,int y)
{
  return x+y;
}

int main()
{
  int x = 1;
  int y=iki();
  std::cout << "basladim x=" << x << std::endl;
  mola();
  std::cout << "devam ettim x+y=" << x+y << std::endl;
  int z=sayigir();
  std::cout << x <<"+"<< y <<"+"<< z <<"="<< x+y+z<< '\n';
  nasilsin();
  std::cout << "(x+1)*(y-3)*(2z)=" <<carp(topla(x,1),y-3,carp(2,z,1))<< '\n';
  return 0;
}
