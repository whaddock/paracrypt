#include "logging.hpp"

void hexdump(const char *title, const unsigned char *s, int length)
{
    for (int n = 0; n < length; ++n) {
	if ((n % 16) == 0)
		LOG_DEBUG(boost::format("\n%s  %04x") % title % n);
	LOG_DEBUG(boost::format(" %02x") % s[n]);
    }
    LOG_DEBUG("\n");
}
