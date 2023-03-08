#pragma once

#include "util/component.h"
#include "util/flatmap.h"
#include "util/bit_cast.h"
#include <vector>
#include <map>

struct hub_mgr {
    enum struct berth_type: uint8_t {
        hub,
        chest_red,
        chest_blue,
    };
    struct berth {
        uint32_t unused : 5;
        uint32_t type : 2;
        uint32_t chest_slot : 4;
        uint32_t berth_slot : 3;
        uint32_t y : 9;
        uint32_t x : 9;
        inline uint32_t hash() const {
            return std::bit_cast<uint32_t>(*this) & 0xFFFFC000;
        }
        inline bool operator==(const berth& rhs) const {
            return std::bit_cast<uint32_t>(*this) == std::bit_cast<uint32_t>(rhs);
        }
        inline bool operator<(const berth& rhs) const {
            return std::bit_cast<uint32_t>(*this) < std::bit_cast<uint32_t>(rhs);
        }
    };
    static_assert(sizeof(berth) == sizeof(uint32_t));
    struct hub_info {
        uint16_t item;
        std::vector<berth> hub;
        std::vector<berth> chest_red;
        std::vector<berth> chest_blue;
    };
    std::map<berth, hub_info> hubs;
    flatmap<uint32_t, uint16_t> chests;
};
