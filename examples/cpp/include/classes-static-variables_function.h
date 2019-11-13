#ifndef MAIN_H
#define MAIN_H

#include <vector>

class Main
{
private:
  int m_a;
  int m_b;
  int m_id;
  static int s_counter;
  static std::vector<double> s_coords;
public:
  Main(int a=0,int b=0);
  int getId();
  static int getCount();
  static std::vector<double> getVector();
  static void pushVector(double a);
  class Initializer
  {
  public:
    Initializer();
  };
  static Initializer s_initialize;
};

#endif
