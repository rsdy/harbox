/*
 * Copyright (C) 2012 Peter Parkanyi <me@rhapsodhy.hu>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
#include <avr/eeprom.h>
#include <util/delay.h>
#include <string.h>
#include "interaction.h"
#include "utils.h"
#include "sha1.h"

InteractionClass Interaction;

void
InteractionClass::init(uint8_t* key,
		uint8_t key_len,
		command_handler *handlers,
		uint8_t handlers_len) {
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
	for(uint8_t available = stream->available();
			available < input_len && available < LEN(buffer);
			available = stream->available())
		;

	if(handler == 0)
		goto _end;

	i = 0;
	data_len = input_len - 20;
	Sha1.initHmac(key, key_len);
	Sha1.write(cmd);
	Sha1.write(input_len);

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
