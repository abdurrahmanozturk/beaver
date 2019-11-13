#include <iostream>

class Node   //use class instead of struct because it contains both variables and functions
{
private:
  double m_x,m_y,m_z;
  double m_nx,m_ny,m_nz;
public:
  void setCoord(double x, double y, double z)
  {
    m_x=x;
    m_y=y;
    m_z=z;
  }
  void setNormal(double nx, double ny, double nz)
  {
    m_nx=nx;
    m_ny=ny;
    m_nz=nz;
  }
  void print()
  {
    std::cout << "x: " <<m_x<<" y: "<<m_y<<" z: "<<m_z<< '\n';
    std::cout << "nx: " <<m_nx<<" ny: "<<m_ny<<" nz: "<<m_nz<< '\n';
  }
  void copy(const Node &node)  // has private access to Node class of parameter node,because access is class-based, not object based
  {                            // if parameter type were different than class type "Node", it wouldnt access
    m_x=node.m_x;
    m_y=node.m_y;
    m_z=node.m_z;
    m_nx=node.m_nx;
    m_ny=node.m_ny;
    m_nz=node.m_nz;
  }
  bool isEqual(const Node &node)
  {
    return (m_x==node.m_x && m_y==node.m_y && m_z==node.m_z);
  }
};

int main(int argc, char const *argv[])
{
  Node n1,n2;
  n1.setCoord(0.0,0.5,0.9);
  n1.setNormal(0.71,0.71,0.0);
  n1.print();
  n2.copy(n1);
  n2.print();

  Node point1;
  point1.setCoord(1.0, 2.0, 3.0);

  Node point2;
  point2.setCoord(1.0, 2.0, 3.0);

  if (point1.isEqual(point2))
      std::cout << "point1 and point2 are equal\n";
  else
      std::cout << "point1 and point2 are not equal\n";

  Node point3;
  point3.setCoord(3.0, 4.0, 5.0);

  if (point1.isEqual(point3))
      std::cout << "point1 and point3 are equal\n";
  else
      std::cout << "point1 and point3 are not equal\n";

  return 0;
}
