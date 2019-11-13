#include <iostream>
#include "Fraction.h"

// ch9.2

Fraction::Fraction(int numer, int denom)
  : m_numer(numer),
    m_denom(denom)
{
  reduce();
  m_frac=static_cast<double>(m_numer)/static_cast<double>(m_denom);
}

Fraction operator*(const Fraction &frac1, const Fraction &frac2)
{
  int numer = frac1.m_numer * frac2.m_numer;
  int denom = frac1.m_denom * frac2.m_denom;
  return Fraction(numer,denom);
}

Fraction operator*(const Fraction &frac, int x)
{
  int numer = frac.m_numer * x;
  int denom = frac.m_denom;
  return Fraction(numer,denom);
}

Fraction operator*(int x, const Fraction &frac)
{
  return (frac * x);
}

int Fraction::gcd(int a, int b)
{
  return (b == 0) ? (a > 0 ? a : -a) : gcd(b, a % b);
}

void Fraction::print()
{
  std::cout<<m_numer<<" / "<<m_denom<<" = "<<m_frac<<'\n';
}

void Fraction::reduce()
{
  int g = gcd(m_numer,m_denom);
  m_numer/= g;
  m_denom/= g;
}
