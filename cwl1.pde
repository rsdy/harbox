#include "cwl1.h"

#define COMPLEMENT(x) (((x) ^ 0xff) +1)

uint8_t *
CWL1::read(void) {
	uint8_t checksum = COMPLEMENT((uint8_t)'M');

	if(stream->read() != 'M')
		return 0;

	while(stream->available() < 6)
		;

	for(uint8_t i = 0; i < 5; i++) {
		buffer[i] = stream->read();
		checksum += COMPLEMENT(buffer[i]);
	}

	if(stream->read() != checksum)
		return 0;
	else
		return buffer;
}
