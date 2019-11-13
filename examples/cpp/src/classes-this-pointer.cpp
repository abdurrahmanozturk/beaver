#include <iostream>

// CH8: hidden constant pointet "this",

// useful for chainin member functions, remember it as std::cout
// std::cout<<"Hello"<< userName  -->  (std::cout<<"Hello")<< userName -->  std::cout<<username !!

class Simple   //compiler creates a hidden pointer to hold the address of object
{              // Simple* const this
private:
  int m_id;      //this can be reached via hidden *this pointer,  by this->m_id
public:
  Simple(int id)
  {
    setId(id);
  }
  void setId(int id) {m_id=id;}       //if m_id were named as id, it would make sense to disambiguate
  int getId() {return m_id;}          // to use this->id=id    (first is member variable, second is function parameter)
};

class Something
{
private:
    int data;

public:
    Something(int data)
    {
        this->data = data;
    }
};

class Calc
{
private:
    int m_value;

public:
    Calc() { m_value = 0; }

    Calc& add(int value) { m_value += value; return *this; }
    Calc& sub(int value) { m_value -= value; return *this; }
    Calc& mult(int value) { m_value *= value; return *this; }

    int getValue() { return m_value; }
};

int main(int argc, char const *argv[])
{
  Simple simple1(1);
  std::cout << simple1.getId()<< '\n';
  simple1.setId(5);
  std::cout << simple1.getId()<< '\n';

  Calc calc;
  calc.add(5).sub(3).mult(4);     // works like cout

  std::cout << calc.getValue() << '\n';
  return 0;

  return 0;
}
