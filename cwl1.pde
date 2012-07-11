#include "cwl1.h"

#define COMPLEMENT(x) (((x) ^ 0xff) +1)

uint8_t *
CWL1::read(void) {
	static char hex[] = "0123456789ABCDEF";
	if(stream->read() != 'M')
		return 0;

	uint8_t checksum = COMPLEMENT((uint8_t)'M');
	buffer[10] = 0; // string terminator

	while(stream->available() < 6);

	for(uint8_t i = 0; i < 10; i+=2) {
		buffer[i] = stream->read();
		checksum += COMPLEMENT(buffer[i]);

		buffer[i + 1] = hex[buffer[i] & 0x0F];
		buffer[i] = hex[(buffer[i] >> 4) & 0x0F];
	}

	if(stream->read() != checksum)
		return 0;
	else
		return buffer;
}
