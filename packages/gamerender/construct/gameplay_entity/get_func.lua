local ecs = ...
local world = ecs.world
local w = world.w

local t = {}
t["logistics_center"] = ecs.require "construct.gameplay_entity.logistics_center"

return function(building_type)
    return t[building_type]
end
