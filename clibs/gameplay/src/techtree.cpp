#include "techtree.h"
extern "C" {
#include "prototype.h"
}
#include "world.h"
#include <assert.h>

uint16_t techtree_mgr::get_progress(uint16_t techid) const {
    auto iter = progress.find(techid);
    if (iter == progress.end()) {
        return 0;
    }
    return iter->second;
}

bool techtree_mgr::is_researched(uint16_t techid) const {
    return researched.contains(techid);
}

bool techtree_mgr::research(uint16_t techid, uint16_t max, uint16_t inc) {
    assert(inc != 0);
    bool finish = false;
    auto iter = progress.find(techid);
    if (iter == progress.end()) {
        if (inc >= max) {
            inc = max;
            finish = true;
        }
        progress.emplace(techid, inc);
    }
    else {
        uint32_t value = (uint32_t)iter->second + inc;
        if (value >= max) {
            value = max;
            finish = true;
        }
        iter->second = value;
    }
    if (finish) {
        cache.erase(techid);
    }
    return finish;
}

struct lab_inputs {
    uint16_t n;
    uint16_t items[1];
};

static std::optional<uint16_t> recipeFind(lab_inputs& r, uint16_t item) {
    for (uint16_t i = 0; i < r.n; ++i) {
        if (r.items[i] == item) {
            return i;
        }
    }
    return std::nullopt;
}

techtree_mgr::ingredients_opt& techtree_mgr::get_ingredients(world& w, uint16_t labid, uint16_t techid) {
    auto& techcache = cache[techid];
    auto iter = techcache.find(labid);
    if (iter != techcache.end()) {
        return iter->second;
    }
    auto lab = w.prototype(labid);
    auto tech = w.prototype(techid);
    auto& inputs = *(lab_inputs*)pt_inputs(&lab);
    auto& ingredients = *(recipe_items*)pt_ingredients(&tech);

    ingredients_t r(inputs.n+1);
    r[0].item = inputs.n;
    r[0].amount = 0;
    for (uint16_t i = 0; i < inputs.n; ++i) {
        uint16_t item = inputs.items[i];
        r[i+1].item = inputs.items[i];
        r[i+1].amount = 0;
    }

    for (uint16_t i = 0; i < ingredients.n; ++i) {
        uint16_t item = ingredients.items[i].item;
        auto result = recipeFind(inputs, item);
        if (!result) {
            auto res = techcache.emplace(labid, std::nullopt);
            return res.first->second;
        }
        r[*result+1].amount = ingredients.items[i].amount;
    }

    auto res = techcache.emplace(labid, r);
    return res.first->second;
}

uint16_t techtree_mgr::queue_top() const {
    if (queue.empty()) {
        return 0;
    }
    return queue.back();
}

void techtree_mgr::queue_pop() {
    if (!queue.empty()) {
        queue.pop_back();
    }
}

void techtree_mgr::queue_set(const queue_t& q) {
    queue = q;
}

const techtree_mgr::queue_t& techtree_mgr::queue_get() const {
    return queue;
}
