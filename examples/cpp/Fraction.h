#ifndef FRACTION_H
#define FRACTION_H

//ch9.2

#include <chrono> // for std::chrono functions

class Fraction
{
private:
  int m_numer;
  int m_denom;
  double m_frac;
public:
  Fraction(int numer=1, int denom=1);
  void print();
  void reduce();
  friend Fraction operator*(const Fraction &frac1, const Fraction &frac2);
  friend Fraction operator*(const Fraction &frac,int x);
  friend Fraction operator*(int x,const Fraction &frac);
  static int gcd(int a, int b);
};

#endif
