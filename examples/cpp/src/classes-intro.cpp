#include <iostream>

class Mesh   //use class instead of struct because it contains both variables and functions
{
public:
  double m_x,m_y,m_z;
  double m_nx,m_ny,m_nz;
  void printNode()
  {
    std::cout << "x: " <<m_x<<" y: "<<m_y<<" z: "<<m_z<< '\n';
    std::cout << "nx: " <<m_nx<<" ny: "<<m_ny<<" nz: "<<m_nz<< '\n';
  }
};

class IntPair
{
public:
  int m_x;
  int m_y;
  void set(int x, int y)
  {
    m_x=x;
    m_y=y;
  }
  void print()
  {
    std::cout << "Pair(" <<m_x<<","<<m_y<<")"<< '\n';
  }
};

int main(int argc, char const *argv[])
{
  Mesh plate{0.0,0.0,1.0,1.0,0.0,0.0};
  plate.printNode();
  IntPair p1;
	p1.set(1, 1); // set p1 values to (1, 1)

	IntPair p2{ 2, 2 }; // initialize p2 values to (2, 2)

	p1.print();
	p2.print();
  return 0;
}
