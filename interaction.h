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
#ifndef __INTERACTION_H__
#define __INTERACTION_H__
#include <Stream.h>

typedef void (*handler_fn)(const char* const buf, const uint8_t buf_len);
typedef struct _command_handler {
	char command;
	handler_fn fn;
} command_handler;

class InteractionClass {
public:
	void init(uint8_t* key,
			uint8_t key_len,
			command_handler *handlers,
			uint8_t handlers_len);

	void process_input(void);
	inline void write(const uint8_t *line, size_t len);

	Stream *stream;

private:
	inline command_handler* find_command(char cmd);
	inline void empty_buffer(void);

	uint8_t *key;
	uint8_t key_len;
	char buffer[128];
	int input_len;
	command_handler *handlers;
	uint8_t handlers_len;
};
extern InteractionClass Interaction;

#endif
