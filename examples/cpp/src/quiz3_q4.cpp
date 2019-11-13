#include <iostream>
#include "constants.h"

double getTowerHeight()
{
  std::cout << "Enter the height of the tower in meters= ";
  double h; // height in meters
  std::cin >> h;
}

double calculateHeight(double h,double g,int t)
{
  double x=h-g*t*t*0.5;
  return x;
}
int main()
{
  double h=getTowerHeight();
  double g=myConstants::gravity;
  double x; //distance fallen
  for (size_t i = 0; i < 6; i++)
  {
    x=calculateHeight(h,g,i);
    if (x>0)
      std::cout << "At "<<i<<" seconds, the ball is at height: "<<x<<" meters" << '\n';
    else
      std::cout << "At "<<i<<" seconds, the ball is at ground"<<std::endl;
  }
  return 0;
}
