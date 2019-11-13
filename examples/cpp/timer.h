#ifndef TIMER_H
#define TIMER_H

#include <chrono> // for std::chrono functions

class Timer
{
private:
  typedef std::chrono::high_resolution_clock clock_t;
  typedef std::chrono::duration<double, std::ratio<1> > second_t;
  std::chrono::time_point<clock_t> m_beg;
public:
	Timer();
	void reset();
	const double elapsed();
};

#endif
