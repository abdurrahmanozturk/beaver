#include <iostream>
#include <string>
#include <vector> //vector
#include <utility> //pair,make_pair
#include "io.h"

typedef std::string city_t; //dont need to create a new enum data type, create an alias name
typedef std::vector<std::pair<int,city_t>> citylist_t;
using plate_t = int;  // type alias in C++11 ,  same as typedef, favor this but be sure compiler is C++11
int main()
{
  plate_t plate{1},count(0);
  std::cout << "How many cities are there in Turkey?" << '\n';
  std::cin >>count;
  citylist_t city_list;
  city_t city;
  for (size_t i = 0; i < count; i++) {
    std::cin >> city;
    city_list.push_back(std::make_pair(plate++,city));
  }
  for (size_t i = 0; i < count; i++) {
  std::cout << "City No, Name = " <<city_list[i].first<<" "<<city_list[i].second<< '\n';
  }
  // std::cout <<city<< " is a city in Turkey" << '\n';
  return 0;
}
