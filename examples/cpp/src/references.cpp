#include <iostream>
#include <string>

typedef std::string str_t;

int zero(int &ref)   //passing reference variable to function will change the
{                    //original variable, not threating like function argument, as in pointers and arrays
  ref=0;
}

void printArray(int (&array)[3])   //array size needs to be specified in function declaration
{
  const int length = sizeof(array)/sizeof(array[0]);
  for (size_t i = 0; i < length; i++)
  {
    array[i]=i;
    std::cout << array[i]<<'\n';
  }
}

struct Person
{
  str_t name;
  int age;
  str_t job;
  str_t education;
  int salary;
};

struct Company
{
  Person ao;
  str_t name;
  str_t location;
};

int main ()
{
  int value = 5;
  int value2 = 6;
  int &ref = value;   // & means reference to , reference variables must be initialized only to l values when they are created
  int &ref2 = value2;  // ref cannot be reassigned, new ref has to be created for new value
  std::cout << "refrenece = " <<ref<< '\n';
  ref = value2; //   assign value2 to value1(ref)    not aliasing value2 to ref
  ref = 3;   //changes value
  ref += value;  //  same with value += value
  std::cout << "refrenece = " <<ref<< '\n';
  std::cout << "address of ref and value " <<&ref<<" - "<<&value<< '\n';
  zero(ref);  //will assign 0 to ref(value),  useful for intending to make arguments be modified by function
  std::cout << "ref= " <<ref<< " value= "<< value <<'\n';
  int numbers[]{1,5,7};
  printArray(numbers);   // will change the original array values
  Person ao{"apo",30,"engineer","PhD",2000};
  Company beaver{{"apo",30,"engineer","PhD",2000},"Beaver AS","Columbia"};
  int &salary = beaver.ao.salary;
  std::cout << "Salary = " <<salary<< '\n';
  // struct by reference`
  Person &refao = ao;
  std::cout << "apo age " <<refao.age<< '\n';
  // struct by pointer,    it should be dereferenced
  Person *ptrao = &ao;
  std::cout << "apo age " <<(*ptrao).age<< '\n';   // dereference in enclosed by paranthesis
  std::cout << "apo age " <<ptrao->age<<'\n';   // ALWAYS USE -> operator for accessing pointer data
  const int consvlue = 9;
  const int &reftocons=consvlue;   // called as constant refences, unlike references to non-const variable, they can be initialized to l values, r values
  //reference variables allow passing , l values and r values to function
  // favor passing non=pointer, non fundemental data types by reference
  return 0;
}
