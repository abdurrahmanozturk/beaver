#include <iostream>
#include <chrono> // for std::chrono functions
#include "timer.h"

Timer::Timer()
  : m_beg(clock_t::now())
{
}

void Timer::reset()
{
	m_beg = clock_t::now();
}

const double Timer::elapsed()
{
	return std::chrono::duration_cast<second_t>(clock_t::now() - m_beg).count();
}
