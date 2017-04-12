/*
 * Timer.hpp
 *
 *  Created on: Apr 12, 2017
 *      Author: Jesús Martín Berlanga
 */
#include <ctime>

#ifndef TIMER_HPP_
#define TIMER_HPP_

class Timer {
private:
	std::clock_t begin;
public:
	void tic();
	double toc(); // CPU time in clocks
};

#endif /* TIMER_HPP_ */
