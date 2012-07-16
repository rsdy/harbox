#include <avr/eeprom.h>
#include <util/delay.h>
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
InteractionClass::write(const uint8_t *msg, size_t len)
{
	if(len > 108)
		return;

	uint8_t buffer[128];
	Sha1.initHmac(key, key_len);
	Sha1.write(msg, len);

	// we send the data in one packet
	memcpy(buffer, msg, len);
	memcpy(buffer+len, Sha1.resultHmac(), 20);
	stream->write(buffer, len + 20);
}

command_handler*
InteractionClass::find_command(char cmd) {
	for(uint8_t i = 0; i < handlers_len; i++) {
		if(handlers[i].command == cmd)
			return handlers + i;
	}
	return 0;
}

void
InteractionClass::empty_buffer(void) {
	while(stream->available()) {
		_delay_us(50);
		stream->read();
	}
}

void
InteractionClass::process_input(void) {
	char cmd;
	uint8_t i;
	uint8_t data_len;
	uint8_t *result;

	if(stream->available() < 2)
		return;

	cmd = stream->read();
	input_len = stream->read();

	command_handler *handler = find_command(cmd);
	while(stream->available() < input_len)
		;

	if(handler == 0)
		goto _end;

	i = 0;
	data_len = input_len - 20;
	Sha1.initHmac(key, key_len);
	for(; i < data_len && i < LEN(buffer); i++) {
		buffer[i] = stream->read();
		Sha1.write(buffer[i]);
	}
	for(; i < input_len && i < LEN(buffer); i++)
		buffer[i] = stream->read();

	result = Sha1.resultHmac();
	if(memcmp(result, buffer + data_len, 20) == 0) {
		buffer[data_len] = 0;
		handler->fn(buffer, data_len);
	}

_end:
	empty_buffer();
}
