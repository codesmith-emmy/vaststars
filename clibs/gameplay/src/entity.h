#ifndef vaststars_entity_h
#define vaststars_entity_h

#include <stdint.h>

enum COMPONENT {
	COMPONENT_CAPACITANCE = 1,
	TAG_CONSUMER,
	TAG_GENERATOR,
	TAG_ACCUMULATOR,
	TAG_ROAD,
	COMPONENT_ENTITY,
	COMPONENT_BUNKER,
	COMPONENT_ASSEMBLING,
	COMPONENT_INSERTER,
	COMPONENT_STATION,
};

struct entity {
	uint16_t coord;
	uint16_t prototype;
	uint8_t  dir;
};

struct capacitance {
	float shortage;
};

struct bunker {
	int type;
	float number;
};

struct assembling {
	uint16_t recipe;
	uint16_t container;
	uint16_t process;
};

struct inserter {
	uint16_t input_container;
	uint16_t output_container;
	uint16_t hold_item;
	uint16_t hold_amount;
	uint16_t process : 15;
	uint16_t status  : 1;
};

struct station {
	uint16_t id;
	uint16_t coord;
};

#endif
