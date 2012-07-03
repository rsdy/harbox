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
	void init(Stream& stream,
			uint8_t* key,
			uint8_t key_len,
			command_handler *handlers,
			uint8_t handlers_len);

	void process_input(void);
	inline void println(const char *line);

private:
	inline command_handler* find_command(char cmd);
	inline void empty_buffer(void);

	uint8_t *key;
	uint8_t key_len;
	Stream *stream;
	char buffer[128];
	int input_len;
	command_handler *handlers;
	uint8_t handlers_len;
};
extern InteractionClass Interaction;

#endif
