#include <iostream>
#include <tuple>

struct S
{
  int x;
  double y;
};

std::tuple<int, double> returnTuple() // return a tuple that contains an int and a double
{
	return std::make_tuple(5, 6.7); // use std::make_tuple() as shortcut to make a tuple
}

int main ()
{
  std::tuple<int, double> s = returnTuple(); // get our tuple
  std::cout << std::get<0>(s) << ' ' << std::get<1>(s) << '\n'; // use std::get<n> to get the nth element of the tuple
  int a;
  double b;
  std::tie(a, b) = returnTuple(); // put elements of tuple in variables a and b
  std::cout << a << ' ' << b << '\n';
  auto [c, d] = returnTuple(); // used structured binding declaration to put results of tuple in variables a and b
  std::cout << c << ' ' << d << '\n';
  return 0;
}
