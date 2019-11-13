#include <iostream>
#include "timer.h"
#include "main.h"
#include <cmath>

Point2d::Point2d(double x,double y)
  : m_x(x),
    m_y(y)
{
}

void Point2d::print()
{
  std::cout << "Point2d("<<m_x<<","<<m_y<<")"<< '\n';
}

double Point2d::distanceTo(const Point2d &p)
{
  return pow(((m_x-p.m_x)*(m_x-p.m_x)+(m_y-p.m_y)*(m_y-p.m_y)),0.5);
}

double distanceFrom(const Point2d &p1,const Point2d &p2)
{
  return pow(((p1.m_x-p2.m_x)*(p1.m_x-p2.m_x)+(p1.m_y-p2.m_y)*(p1.m_y-p2.m_y)),0.5);
}

int main(int argc, char const *argv[])
{
  Timer t;
  Point2d first;
  Point2d second(3.0,4.0);
  first.print();
  second.print();
  std::cout << "Distance between points : " <<first.distanceTo(second)<< '\n';
  std::cout << "Distance between points : " <<distanceFrom(first,second)<< '\n';
  std::cout << "Elapsed time (sec) : " <<t.elapsed()<< '\n';
  return 0;
}
