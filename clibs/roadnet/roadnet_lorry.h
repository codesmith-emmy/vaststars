#pragma once

#include "roadnet_type.h"
#include "roadnet_coord.h"
#include <vector>

namespace roadnet {
    class world;
    struct road_coord;

    struct lorry {
        uint8_t tick;
        road_coord ending;
        uint8_t pathIdx;
        std::vector<direction> path;
        struct where {
            uint16_t endpoint;
            uint16_t index;
        };
        struct  {
            uint16_t item;
            where sell;
            where buy;
        } gameplay;
        direction getDirection(world& w);
        void nextDirection(world& w);
        void initTick(uint8_t v);
        void update(world& w, uint64_t ti);
        bool ready();
    };
}
