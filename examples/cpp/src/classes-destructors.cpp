#include <iostream>
#include <cassert>

// CH8 DESTRUCTORS helps clean up the class, CONSTRUCTORS helps initialize

// same name with class and beginning with tilde ( ~ )
// can not take arguments   (only one destructor may exist per class !)
// no return type
// is called when object is destroyed

class IntArray    //uses RAII paradigm, dynamically allocation in constructor, de-allocation in destructor
{
private:
	int *m_array;
	int m_length;

public:
	IntArray(int length) // constructor
	{
		assert(length > 0);

		m_array = new int[length];    //Dynamically allocated array
		m_length = length;
	}

	~IntArray() // destructor      // exit() function skips destructor and exit to OS!!
	{
		// Dynamically delete the array we allocated earlier
		delete[] m_array ;
	}

	void setValue(int index, int value) { m_array[index] = value; }
	int getValue(int index) { return m_array[index]; }

	int getLength() { return m_length; }
};

class Simple
{
private:
    int m_nID;

public:
    Simple(int nID)
    {
        std::cout << "Constructing Simple " << nID << '\n';
        m_nID = nID;
    }

    ~Simple()
    {
        std::cout << "Destructing Simple" << m_nID << '\n';
    }

    int getID() { return m_nID; }
};

int main()
{
	IntArray ar(10); // allocate 10 integers
	for (int count=0; count < 10; ++count)
		ar.setValue(count, count+1);

	std::cout << "The value of element 5 is: " << ar.getValue(5);

  // Allocate a Simple on the stack
  Simple simple(1);
  std::cout << simple.getID() << '\n';

  // Allocate a Simple dynamically
  Simple *pSimple = new Simple(2);
  std::cout << pSimple->getID() << '\n';
  delete pSimple;

	return 0;
} // simple and ar are destroyed here, so the ~IntArray() destructor function is called here
