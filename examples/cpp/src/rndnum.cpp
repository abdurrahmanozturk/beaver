#include <iostream>
#include <cstdlib>
#include <random>

double rndnum(double min,double max)
{
  static const double fract=1.0/(RAND_MAX+1.0);
  return min + (max-min)*(std::rand()*fract);
}

double rndnum2(double min, double max)
{
  std::random_device rd;
	std::mt19937 mersenne(rd()); // Create a mersenne twister, seeded using the random device
	std::uniform_int_distribution<> die(min, max); // generate random numbers between min and max
  return die(mersenne);
}
