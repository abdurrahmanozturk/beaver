#ifndef VECTOR3D_H
#define VECTOR3D_H
#include "Point3D.h"

class Vector3D
{
private:
  double m_x,m_y,m_z;
public:
  Vector3D(double x=0,double y=0,double z=0);
  void print();
  // friend class Point3D;            //making point3D friend class
  friend void Point3D::move(const Vector3D &vector);    //making Point3D::move() friend function
};

#endif
