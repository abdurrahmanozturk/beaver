#include <iostream>
#include "Point3D.h"
#include "Vector3D.h"

Point3D::Point3D(double x,double y,double z) :
  m_x(x),
  m_y(y),
  m_z(z)
{
}
void Point3D::print()
{
  std::cout<<"Point("<<m_x<<","<<m_y<<","<<m_z<<")"<<'\n';
}
void Point3D::move(const Vector3D &vector)
{
  m_x+=vector.m_x;
  m_y+=vector.m_y;
  m_z+=vector.m_z;
  std::cout<<"Point is moved by vector to ("<<m_x<<","<<m_y<<","<<m_z<<")"<<'\n';
}
