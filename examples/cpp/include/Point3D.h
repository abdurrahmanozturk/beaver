#ifndef POINT3D_H
#define POINT3D_H

class Vector3D;

class Point3D
{
private:
  double m_x,m_y,m_z;
public:
  Point3D(double x=0,double y=0,double z=0);
  void print();
  void move(const Vector3D &vector);
};

#endif
