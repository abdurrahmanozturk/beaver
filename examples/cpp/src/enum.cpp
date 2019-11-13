#include <iostream>

enum Class   //enum data type
{
  CLASS_EMCH508,  //assigned automatically to 0 in enum class Course
  CLASS_EMCH561,  //previous + 1 = 0+1 =1
  CLASS_EMCH553,  //2
  CLASS_EMCH573,  //3
  CLASS_EMCH753,  //4
  CLASS_EMCH756,  //5
  CLASS_EMCH757,  //6
  CLASS_EMCH758,  //7
  CLASS_EMCH797=797,  //assigned to 797 explicitly
  CLASS_RESEARCH=797  // assigned to 797 explicitly, shares the same value, dont do this
};

enum class Course   //enum class
{
  EMCH508,  //assigned automatically to 0 in enum class Course
  EMCH561,  //previous + 1 = 0+1 =1
  EMCH553,  //2
  EMCH573,  //3
  EMCH753,  //4
  EMCH756,  //5
  EMCH757,  //6
  EMCH758,  //7
  EMCH797=797,  //assigned to 797 explicitly
  RESEARCH=797  // assigned to 797 explicitly, shares the same value, dont do this
};

enum class University
{
  USC,  //0 in enum class University
  TAM,  //1
  NCSU  //2
};

void printGrade(Course myCourse)
{
  if (myCourse==Course::EMCH508)
  std::cout << "Grade for EMCH508 = A1" << '\n';
  else if (myCourse==Course::EMCH553)
  std::cout << "Grade for EMCH553 = A1" << '\n';
  else if (myCourse==Course::EMCH573)
  std::cout << "Grade for EMCH573 = A1" << '\n';
  else if (myCourse==Course::RESEARCH)
  std::cout << "Grade for RESEARCH = T" << '\n';
}

int main()
{
  Class myClass;
  myClass=CLASS_EMCH797;  //assigns to 797
  std::cout << "The class= " <<myClass<< '\n';
  Course myCourse1{Course::EMCH508};
  printGrade(myCourse1);
  // std::cout << "myCourse1= " <<myCourse1<< '\n';  // doesnt work with enum class
  std::cout <<static_cast<int>(myCourse1)<< '\n'; //enum classes doesnt convert them to integer
  // std::cin >> myCourse;  compiler doesnt allow to input,instead read integer and use static cast
  University myUniversity=University::USC; //assigns to 1 , no conflict with enum class Course
  return 0;
}
