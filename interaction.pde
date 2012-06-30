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

command_handler*
InteractionClass::find_command(char cmd) {
	for(uint8_t i = 0; i < handlers_len; i++) {
		if(handlers[i].command == cmd) {
			return handlers + i;
		}
	}
	return 0;
}

void
InteractionClass::process_input(void) {
	if (stream->available() < 2)
		return;

	char cmd = stream->read();
	input_len = stream->read();

	command_handler *handler = find_command(cmd);
	if(handler == 0 || input_len >= LEN(buffer))
		return;

	while(stream->available() < input_len)
		;

	Sha1.initHmac(key, key_len);
	uint8_t i = 0;
	uint8_t data_len = input_len - 20;
	for(; i < data_len && i < LEN(buffer); i++) {
		buffer[i] = stream->read();
		Sha1.write(buffer[i]);
	}
	for(; i < input_len && i < LEN(buffer); i++)
		buffer[i] = stream->read();

	uint8_t *result = Sha1.resultHmac();
	if(memcmp(result, buffer + data_len, 20) == 0) {
		buffer[data_len] = 0;
		handler->fn(buffer, data_len);
	}
}
