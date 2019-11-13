#include <iostream>
#include "io.h"

struct Advertising
{
  int numberAds;
  double clickPercentage;
  double earningPerClick;
};

double printInfo(Advertising ads)
{
  std::cout << "Number of Ads= " <<ads.numberAds<< '\n';
  std::cout << "Percentage of Clicks= " <<ads.clickPercentage<< '\n';
  std::cout << "Earning per Click= " <<ads.earningPerClick<< '\n';
  double money=ads.numberAds*ads.clickPercentage*ads.earningPerClick;
  std::cout << "Total Money Earned in a day is = $" <<money<< '\n';
  return money;
}

Advertising getAds()
{
  Advertising ads;
  std::cout << "Enter Number of Ads= "<< '\n';
  std::cin >> ads.numberAds;
  std::cout << "Enter Percentage of Clicks" << '\n';
  std::cin >> ads.clickPercentage;
  std::cout << "Enter money earned per click" << '\n';
  std::cin >> ads.earningPerClick;
  return ads;
}

struct Fraction
{
  int numerator;
  int denominator;
};

void multiply(Fraction x,Fraction y)
{
  std::cout << "fract1*fract2= " <<static_cast<double>(x.numerator*y.numerator)/(x.denominator*y.denominator)<< '\n';
}

Fraction getFraction()
{
  Fraction fract;
  fract.numerator=getInteger();
  fract.denominator=getInteger();
  return fract;
}

int main()
{
  Advertising ads=getAds();
  printInfo(ads);
  Fraction fract1=getFraction(), fract2=getFraction();
  // fract1.numerator=getInteger();
  // fract1.denominator=getInteger();
  // Fraction fract2{getInteger(),getInteger()};
  multiply(fract1,fract2);
}
