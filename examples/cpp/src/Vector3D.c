#include <iostream>
#include "Vector3D.h"

Vector3D::Vector3D(double x,double y,double z) :
  m_x(x),
  m_y(y),
  m_z(z)
{
}
void Vector3D::print()
{
  std::cout<<"Vector("<<m_x<<","<<m_y<<","<<m_z<<")"<<'\n';
}
