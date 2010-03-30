#ifndef __INTERACTION_H__
#define __INTERACTION_H__
#include <Stream.h>

namespace Interaction {
	typedef void (*handler)(size_t (*println)(const char*), const char* const buf, const uint8_t buf_len);
	typedef struct _handler_table_item {
		uint8_t command;
		handler fn;
	} handler_table_item;

	void process_input(void);

	extern handler_table_item handlers[];
	extern Stream& client;
};

#endif
