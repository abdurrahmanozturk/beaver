#include <iostream>
#include <string>
#include <vector>

typedef std::string str_t;
typedef std::vector<double> vec_t;

struct Course      //use capital letter for struct names
{
  short id;
  str_t name;
  str_t grade;
};

struct Line   //creates a cube with unit length at origin point of (0,0,0)
{
  double length=1.0;
  vec_t origin{0.0,0.0,0.0};
};

struct University
{
  Course emch797{4,"Research","T"};   //nested structs are allowable, use two . operator
  Course speaking;
  str_t name;
};

Line getLine()   // function can return with struct, !! good way for returning multiple variable
{
  Line myLine{2,{0.0,1.0,1.0}};
  return myLine;
}

void printInfo(Course course)
{
  std::cout <<"Grade for "<<course.name<<" is "<<course.grade<< '\n';
}


int main()
{
  Course emch508;
  emch508.id=1;
  emch508.name="EMCH508: Finite Element Analysis";
  emch508.grade="A1";
  Course emch756;
  emch756.id=2;
  emch756.name="EMCH756: Reliability Analysis";
  emch756.grade="A1";
  int asd=emch756.id+1;  //just like normal variable
  Course emch753{++emch756.id,"EMCH753: Radiation Shielding","A1"};
  std::cout << "id " <<emch753.id<< '\n';
  int tot_id=emch508.id+emch756.id;  //operations can be made, treat them as variable
  std::cout << "total_id = " <<tot_id<< '\n';
  std::cout <<"Grade for "<<emch508.name<<" is "<<emch508.grade<< '\n';
  printInfo(emch756);
  printInfo(emch753);
  Line myCube;
  std::cout << "length of side is " <<myCube.length<< '\n';
  std::cout << "origin is (" <<myCube.origin[0]<<myCube.origin[1]<<myCube.origin[2]<<")"<<'\n';
  Line myLine=getLine();
  std::cout << "length of side is " <<myLine.length<< '\n';
  std::cout << "origin is (" <<myLine.origin[0]<<myLine.origin[1]<<myLine.origin[2]<<")"<<'\n';
  University usc;
  std::cout << "EMCH797 ID= " <<usc.emch797.id<<'\n';
  printInfo(usc.emch797);
  University ua{{},{1,"Speaking","A"},"University of Alabama"};  //uniform  initialization is allowd for nested structs
  printInfo(ua.speaking);
  return 0;
}
