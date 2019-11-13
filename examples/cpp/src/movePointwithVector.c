#include <iostream>
#include "Point3D.h"
#include "Vector3D.h"

int main(int argc, char const *argv[])
{
  Point3D p1{0.0,1.5,2.6};
  Vector3D v1{1,0,3};
  p1.print();
  v1.print();
  p1.move(v1);
  return 0;
}
