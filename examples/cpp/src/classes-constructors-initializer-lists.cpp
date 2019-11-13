#include <iostream>
#include <string>
#include <cstdint>

//Chapter 8:  CONSTRUCTORS, INITIALIZATION LIST, DELEAGATING, DESTRUCTORS

typedef std::string str_t;

class Human
{
private:
  str_t m_name;
  str_t m_gender;
  int m_age;
public:
  Human()       //default constructor,  1-exactly same name with class, 2-no return type
  {             // parameter initialization can be used instead a seperate default constructor
    std::cout << "!!!default constructor" << '\n';
    m_name = "Nihavend";
    m_gender = "Kadin";
    m_age = 30;
  }
  Human(str_t name, str_t gender = "Kadin", int age=30)  //constructor with three parameters(age's default value is 30)
  {                              //again 1-same name with class , 2-no return type
    std::cout << "!!!parameterized constructor" << '\n';
    m_name = name;
    m_gender = gender;
    m_age = age;
  }
  str_t getName() {return m_name;}
  void setName(str_t &name) {m_name=name;}
  str_t getGender() {return m_gender;}
  void setGender(str_t &gender) {m_gender=gender;}
  int getAge() {return m_age;}
  int setAge(int &age) {m_age=age;}
};

class Ball     // initializing parameters by assigning values to variables
{
private:
  str_t m_color;
  double m_radius;
public:
  Ball(const str_t &color="black", const double &radius=10)
  {
    m_color = color;
    m_radius = radius;
  }
  Ball(const double &radius)
  {
    m_color = "black";
    m_radius = radius;
  }
  void print()
  {
    std::cout <<m_color<<" ball has radius of "<<m_radius<< '\n';
  }
};

class Book     // initializing parameters by initializer list
{
private:
  const str_t m_name;
  int m_page;
public:
  Book(const str_t &name="Little Things", const int &page=150) :
    m_name {name},    // after creation, const int variable can not be assigned to a value, but initialized
    m_page {page}
  {/* no assignment */}
  void print()
  {
    std::cout <<m_name<< " has " <<m_page<<" pages."<<'\n';
  }
};

class Fruit
{
private:
  const str_t m_name[3];
  const str_t m_color[3];
public:
  Fruit() :
    m_name {"Orange", "Cherry", "Banana"},      //after C++11, array values can be assigned here
    m_color {"Orange" , "Red" , "Yellow"}
  {/* no assignment */}                        // prior to C++11 array values were to be assigned here
  void print()
  {
    for (size_t i=0; i<3; ++i)
    {
      std::cout <<m_name[i]<<' ';
      std::cout <<m_color[i] << '\n';
    }
  }
};

class RGBA
{
private:
  std::uint_fast8_t m_red;
  std::uint_fast8_t m_green;
  std::uint_fast8_t m_blue;
  std::uint_fast8_t m_alpha;
public:
  RGBA(const std::uint_fast8_t &red=0, const std::uint_fast8_t &green=0,
       const std::uint_fast8_t &blue=0,const std::uint_fast8_t &alpha=255) :
    m_red {red},
    m_green {green},
    m_blue {blue},
    m_alpha {alpha}
  {/* no assignments */}
  void print()
  {
    std::cout << " R:" <<static_cast<int>(m_red)<<
                 " G:" <<static_cast<int>(m_green)<<
                 " B:" <<static_cast<int>(m_blue)<<
                 " A:" <<static_cast<int>(m_alpha)<< '\n';
  }
};

class Ball2     // non-static member initialization, favor this
{
private:
  str_t m_color="black";
  double m_radius=10.0;
public:
  Ball2()
  {}
  Ball2(const str_t &color, const double &radius) :
    m_color{color},
    m_radius{radius}
  {}
  Ball2(const double &radius) :
    m_radius{radius}
  {}
  Ball2(const str_t &color) :
    m_color{color}
  {}
  void print()
  {
    std::cout <<m_color<<" ball has radius of "<<m_radius<< '\n';
  }
};

class Employee
{
private:
    int m_id;
    std::string m_name;

public:
    Employee(int id=0, const std::string &name=""):
        m_id(id), m_name(name)      //constructors can delegate or initialize. but not both
    {
        std::cout << "Employee " << m_name << " created.\n";
    }

    // Use a delegating constructors to minimize redundant code
    Employee(const std::string &name) : Employee(0, name) { }
};

int main(int argc, char const *argv[])
{
  Human insan1;
  std::cout <<insan1.getName()<<" "<<insan1.getGender()<<" "<<insan1.getAge()<< '\n';
  Human insan3 {"Basak"};
  std::cout <<insan3.getName()<<" "<<insan3.getGender()<<" "<<insan3.getAge()<< '\n';

  Ball def;
  def.print();

	Ball blue("blue");
	blue.print();

	Ball twenty(20.0);
	twenty.print();

	Ball blueTwenty("blue", 20.0);
	blueTwenty.print();

  Book book1;
  book1.print();

  Book book2("Guliver's Travels",198);
  book2.print();

  Fruit fruit;
  fruit.print();

  RGBA teal(0,127,127);
  teal.print();

  Ball2 def2;
  def2.print();


  return 0;
}
