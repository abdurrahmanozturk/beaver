#include <iostream>
#include <iomanip>
bool isPrime(int x)
{
  if (x==2 || x==3 || x==5 || x==7)
    return true;
  else
    return false;
}
bool isEqual(int x, int y)
{
  return (x<y);
}
int main()
{
  //always initialize variables after defining them
  int x_int{2},y(6),z=4; // default is signed
  long x_int_long=5'154'145'120;
  constexpr int g(9.81); // can not be edited because it is defined as constant in compile time
  const int a(x_int);  // can not be edited, but it can be changed up to x_int value in run time
  int bin(0);
  bin=0b10111111;  //assign binary to variable
  signed int pos_neg;  //positive or negative 1byte range > -128to127
  unsigned short pos{65534}; // always positive 1 byte range> 0to255
  pos=pos+1; // overflow, will return to 0  1111 1111 1111 1111 (16bit)> 1 0000 0000 0000 0000 (17 bit, 1 is meaningless)
  pos=pos-1; // overflow, will return to 65535  0000 0000 0000 0000 > 1111 1111 1111 1111
  bool x_bool(true);
  char x_char('a');
  float x_float(2.15222222222211f);  //default precision is 6to9
  double x_double=3.14164845151354894461651561;  //default precision 15to18
  void function(); // void cannot be defined as variable type , it can be defined as function type or etc....
  std::cout <<"x y z :\t\t"<< x_int_long<<' '<<y<<' '<<z<<'\n';
  std::cout <<"size of x y z :\t"<< sizeof(x_int)<<' '<<sizeof(pos)<<' '<<sizeof(z)<<'\n';
  std::cout << x_bool<<'\n';
  std::cout << std::setprecision(16);  //from iomanip
  std::cout << x_float<<'\n';
  std::cout << x_double<<'\n';
  std::cout << x_char <<'\n';
  // Boolean variables
  bool b(false);
  bool c(!false);
  std::cout << b<<'\n';
  // std::cout<<std::boolalpha;   //turning on printing true or false
  // std::cout<<std::noboolalpha;   //turning off printing true or false
  if (true) c=0;
  else c=1;
  std::cout <<"c="<< c<< '\n';
  int d(7);
  if (c)
  {
    d=d+1;
    std::cout << "d+1= " <<d<< '\n';
  }
  else
  {
    d=d-1;
    std::cout << "d-1= " <<d<< '\n';
  }
  std::cout << "\aEnter an integer: ";   // with beep sound
  int x;
  std::cin >> x;
  std::cout << "\aEnter another integer: ";
  std::cin >> y;

  if (isEqual(x, y))
      std::cout << x << " bigger than " << y << std::endl;
  else
      std::cout << x << " smaller than(or equal) " << y << std::endl;
  std::cout << "\aEnter a number: ";
  std::cin >> x;
  if (isPrime(x))
    std::cout << "The digit is prime" << '\n';
  else
    std::cout << "The digit is not prime`" << '\n';
  // chars
  char ch1(97);
  char ch2('a');
  std::cout << "ch1= " <<ch1<< '\n';
  std::cout << "ch2= " <<ch2<< '\n';
  std::cout <<"ch1= "<<ch1<<"  , ch1(converted)= " << static_cast<int>(ch1) << '\n';
  std::cout << "\125 \" \? \\ \' \a \b  \v \x6F \f \r \t \\ \n";
  return 0;
}
