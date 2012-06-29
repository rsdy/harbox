#include <avr/eeprom.h>
#include <string.h>
#include "interaction.h"
#include "utils.h"
#include "sha1.h"

InteractionClass Interaction;

void
InteractionClass::init(Stream& stream,
		uint8_t* key,
		uint8_t key_len,
		command_handler *handlers,
		uint8_t handlers_len) {
	this->stream = &stream;
	this->key = key;
	this->key_len = key_len;
	this->handlers = handlers;
	this->handlers_len = handlers_len;
}

void
InteractionClass::println(const char *msg)
{
	stream->println(msg);
}

void
InteractionClass::fill_buffer(void) {
	register char ch = 0;
	buffer_len = 0;

	for(;;) {
		if(buffer_len < LEN(buffer)) {
			if(!stream->available())
				continue;

			ch = stream->read();
			if(ch == '\n')
				break;
			else
				buffer[buffer_len++] = ch;
		} else {
			stream->read();
		}
	}
}

int
InteractionClass::verify_buffer(void) {
	Sha1.initHmac(key, key_len);
	for(uint8_t i = 0; i < buffer_len - 20; i++)
		Sha1.write(buffer[i]);

	uint8_t *result = Sha1.resultHmac();
	return memcmp(result, buffer + buffer_len - 20, 20);
}

void
InteractionClass::process_input(void) {
	fill_buffer();
	if(!(buffer_len > 20 && verify_buffer() == 0))
		return;

	buffer[buffer_len - 20] = 0;

	for(uint8_t i = 0; i < handlers_len; i++) {
		if(handlers[i].command == buffer[0]) {
			handlers[i].fn(buffer + 1, buffer_len - 21);
			break;
		}
	}
}
