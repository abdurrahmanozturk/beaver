#include <iostream>
#include <cassert>

class Stack
{
private:
  static const int m_stackLength{10};
  int m_array[m_stackLength];
  int m_currentLength{m_stackLength};
public:
  void reset()
  {
    for (size_t i = 0; i < m_stackLength; i++)
    {
      m_array[i]=0;
    }
    m_currentLength=0;
  }
  bool push(int x)
  {
    if (m_currentLength>=10)
    {
      std::cout << "Stack is full." << '\n';
      return false;
    }
    else
    {
      m_array[++m_currentLength - 1]=x;
      return true;
    }
  }
  int pop()
  {
    assert(m_currentLength>0 && "Stack is empty.");
    return m_array[m_currentLength-- - 1];
  }
  void print()
  {
    std::cout << "(";
    for (size_t i = 0; i < m_currentLength; i++)
    {
      std::cout <<" "<<m_array[i];
    }
    std::cout << " )" << '\n';
  }
};

int main(int argc, char const *argv[])
{
  Stack stack;
  stack.reset();
  stack.print();
  stack.push(5);
  stack.print();
  stack.push(8);
  stack.print();
  stack.push(3);
  stack.print();
  stack.pop();
  stack.print();
  stack.pop();
  stack.print();
  stack.pop();
  stack.print();
  for (size_t i = 0; i < 11; i++)
  {
    stack.push(i);
  }
  stack.push(10);
  stack.print();
  return 0;
}
