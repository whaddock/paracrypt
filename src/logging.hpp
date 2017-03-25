#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <boost/log/trivial.hpp>
#include <boost/format.hpp>

#ifdef DEBUG
	#define LOG_DEBUG(str) BOOST_LOG_TRIVIAL(debug) << #str
#else
	#define LOG_DEBUG(str)
#endif
#define LOG_ERR(str) BOOST_LOG_TRIVIAL(error) << #str

void hexdump(FILE * f, const char *title, const unsigned char *s, int length);
