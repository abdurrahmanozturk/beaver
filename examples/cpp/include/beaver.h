#ifndef BEAVER_H
#define BEAVER_H

class Beaver
{
private:
  double m_x;
  double m_y;
  double m_z;
  double m_ans;
public:
  Beaver(double x=0.0, double y=0.0, double z=0.0,double ans=0);
  Beaver& add(double x);
  Beaver& subtract(double x);
  Beaver& multiply(double x);
  Beaver& divide(double x);
  void setValue(double x, double y, double z, double ans);
  double getValue();
  void print();
};

#endif
