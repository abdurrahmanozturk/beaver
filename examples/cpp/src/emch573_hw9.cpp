#include <iostream>
#include <string>
#include <cmath>
#include <sstream>

typedef std::string str_t;
typedef std::stringstream str_to_int_t;

constexpr double Na{6.0221409e23};
constexpr long double pi = 3.141592653589793238L;

struct Material
{
  str_t name;
  double amass;                               //amu
  double density;                             //g/cm3
  double threshouldEnergy;                    //eV
  double crossSection[2];                     //cm2
};

int main(int argc, char const *argv[])
{
  if (argc<=1)
  {
    std::cout << "Input is missing. <program name> <T> <x> <p> <bu>"<< '\n';
    exit(1);
  }
  std::cout << '\n';
  std::cout << "---------------------------------------------------------" << '\n';
  std::cout << "|   Problem 1:Displacement per atom (dpa) calculations  |" << '\n';
  std::cout << "---------------------------------------------------------" << '\n';
  double N,kappa;
  double phi{1.0e22};            // neutron flux     n/cm2-sec
  double dprv[2], dpas[2];
  double E[2]={5.0e5,1.0e7};   //Energy eV
  Material tungsten{"Tungsten",185.0,19.3,68.0,{40.0e-24,200.0e-24}};
  Material neutron{"Neutron",1.0,0.0,0.0,0.0};
  N=tungsten.density * Na / tungsten.amass;
  kappa=4 * tungsten.amass * neutron.amass/pow((tungsten.amass+neutron.amass),2);
  for (size_t i = 0; i < 2; i++)
  {
    std::cout <<"_________________________________________________________________________________"<<i<< '\n';
    std::cout <<"Cross section(cm2)="<<tungsten.crossSection[i]<<", E(eV)="<<E[i]<<", Kappa="<<kappa<<", Neutron Flux(n/cm2-sec)="<<phi<< '\n';
    std::cout << '\n';
    dpas[i]=(kappa * tungsten.crossSection[i] * E[i] * phi)/(4 * tungsten.threshouldEnergy);
    std::cout << "Number of displacements per atom per second (dpa/sec)= " << dpas[i]<< '\n';
    dprv[i]=N * dpas[i];
    std::cout << "Displacements rate per unit volume (dpa/cm3-sec)= " << dprv[i]<< '\n';
  }
  std::cout << '\n';
  std::cout << "----------------------------------------------------------------" << '\n';
  std::cout << "|   Problem 2:Temperature Drop for stochiometric fuel UO_2+x   |" << '\n';
  std::cout << "----------------------------------------------------------------" << '\n';
  double k,kp,p,t,x,T,dT,dTp,lhr,alpha;
  str_to_int_t argv1{argv[1]},argv2{argv[2]},argv3{argv[3]};    //create a variable for string input and initialize it with first program argument
  if (!(argv1>>T) || !(argv2>>x) || !(argv3>>p))
  {
    std::cerr << "String-Integer Conversion failed" << '\n';
    T=0.0;
    x=0.0;
    p=0.0;
  }
  t=T/1000;
  lhr=2e4;   // W/m
  k=(1/(0.0257 + 3.336 * x + (2.206 - 6.85 * x) * t * 0.1)) + 1.158 * 6400 * exp(-16.35/t) / pow(t,2.5);   //W/m-K
  kp=k * (1 - (2.6 - 0.5 * t) * p);
  dT=lhr/(4 * pi * k );
  dTp=lhr/(4 * pi * kp );
  std::cout <<"_________________________________________________________________________________"<< '\n';
  std::cout << "x="<<x<<" for T=" <<T<<'\n';
  std::cout << "Thermal Conductivity of UO_2+x for x="<<x<<" for T=" <<T<<" is :"<<k<< '\n';
  std::cout << "Thermal Conductivity of UO_2+x for x="<<x<<" for T=" <<T<<" for p=" <<p<<" is :"<<kp<< '\n';
  std::cout << "Themperature drop across fuel pellet is :"<<dT<< '\n';
  std::cout << "Themperature drop across porous fuel pellet is :"<<dTp<< '\n';
  std::cout << '\n';
  std::cout << "----------------------------------------------------------------" << '\n';
  std::cout << "|   Problem 3:Densification-Shrinkage of fuel during annealing |" << '\n';
  std::cout << "----------------------------------------------------------------" << '\n';
  double r{0.005},h{0.01},tg{0.0003},dg{10},p0{0.05},pf,dp,temp{1773},bu,a,a1,a2,ab,b;
  str_to_int_t argv4{argv[4]};    //create a variable for string input and initialize it with first program argument
  if (!(argv4>>bu))
  {
    std::cerr << "String-Integer Conversion failed" << '\n';
    bu=0.0;
  }
  a=exp((temp - 573) / 620) / dg;
  ab=5.12 * exp(-5100 / temp);
  b=ab/a;
  a2=1.5e-3;
  a1=100 * a2;
  dp=p0*(a * (1 - b*exp(-a1*bu) - (1-b)*exp(-a2*bu)));
  pf=p0-dp;
  std::cout << "Initial porosity fraction = " <<p0<< '\n';
  std::cout << "Final porosity fraction = " <<pf<< '\n';
  std::cout << "Change in porosity fraction = " <<dp<< '\n';
  std::cout << "dp/p0 = " <<(dp/p0)<< '\n';
  return 0;
}
