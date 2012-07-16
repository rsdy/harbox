#ifndef __CWL1_H__
#define __CWL1_H__

#include <Stream.h>

class CWL1 {
public:
	CWL1(Stream *stream) : stream(stream) {}
	uint8_t* read(void);

private:
	uint8_t buffer[5];
	Stream* stream;
};

#endif
