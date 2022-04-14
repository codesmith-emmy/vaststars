local ecs = ...
local world = ecs.world
local w = world.w

local math3d = require "math3d"
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local gameplay = import_package "vaststars.gameplay"
import_package "vaststars.prototype"
local igame_object = ecs.import.interface "vaststars.gamerender|igame_object"
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ientity = ecs.import.interface "ant.render|ientity"
local imaterial	= ecs.import.interface "ant.asset|imaterial"
local ientity_object = ecs.import.interface "vaststars.gamerender|ientity_object"
local imesh = ecs.import.interface "ant.asset|imesh"
local ifs = ecs.import.interface "ant.scene|ifilter_state"
local tile_size <const> = 10.0

local plane_vb <const> = {
	-0.5, 0, 0.5, 0, 1, 0,	--left top
	0.5,  0, 0.5, 0, 1, 0,	--right top
	-0.5, 0,-0.5, 0, 1, 0,	--left bottom
	-0.5, 0,-0.5, 0, 1, 0,
	0.5,  0, 0.5, 0, 1, 0,
	0.5,  0,-0.5, 0, 1, 0,	--right bottom
}

local rotators <const> = {
    N = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(0)}),
    E = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(90)}),
    S = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(180)}),
    W = math3d.ref(math3d.quaternion{axis=mc.YAXIS, r=math.rad(270)}),
}

local gen_id do
    local id = 0
    function gen_id()
        id = id + 1
        return id
    end
end

local block_events = {}
block_events.set_material_property = function(e, ...)
    imaterial.set_property(world:entity(e.id), ...)
end
block_events.set_position = function(e, ...)
    iom.set_position(e, ...)
end
block_events.set_rotation = function(e, ...)
    iom.set_rotation(e, ...)
end

local function create_block(color, block_edge_size, area, position, rotation)
    assert(color)
    local width, height = area >> 8, area & 0xFF
    local eid = ecs.create_entity{
		policy = {
			"ant.render|simplerender",
			"ant.general|name",
		},
		data = {
			scene 		= { srt = {r = rotation, s = {tile_size * width + block_edge_size, 1.0, tile_size * height + block_edge_size}, t = position}},
			material 	= "/pkg/vaststars.resources/materials/singlecolor.material",
			filter_state= "main_view",
			name 		= ("plane_%d"):format(gen_id()),
			simplemesh 	= imesh.init_mesh(ientity.create_mesh({"p3|n3", plane_vb}, nil, math3d.ref(math3d.aabb({-0.5, 0, -0.5}, {0.5, 0, 0.5}))), true),
			on_ready = function (e)
				w:sync("render_object:in", e)
				ifs.set_state(e, "main_view", true)
				imaterial.set_property(e, "u_color", color)
				w:sync("render_object_update:out", e)
			end
		},
	}

    return ientity_object.create(eid, block_events)
end

local function set_srt(e, srt)
    if not srt then
        return
    end
    iom.set_scale(e, srt.s)
    iom.set_rotation(e, srt.r)
    iom.set_position(e, srt.t)
end

local function get_rotation(self)
    return iom.get_rotation(world:entity(self.game_object.root))
end

local function set_position(self, position)
    iom.set_position(world:entity(self.game_object.root), position)
    if self.block_entity_object then
        self.block_entity_object:send("set_position", position)
    end
end

local function get_position(self)
    return iom.get_position(world:entity(self.game_object.root))
end

local function set_dir(self, dir)
    iom.set_rotation(world:entity(self.game_object.root), rotators[dir])

    if self.block_entity_object then
        self.block_entity_object:send("set_rotation", rotators[dir])
    end
end

local function remove(self)
    local game_object = self.game_object
    if game_object then
        game_object:remove()
    end

    if self.block_entity_object then
        self.block_entity_object:remove()
    end
end

local function update(self, t)
    if t.prototype_name or (t.state and t.state ~= self.state) then
        local srt
        local old_game_object = self.game_object
        if old_game_object then
            srt = world:entity(old_game_object.root).scene.srt
            old_game_object:remove()
        end

        local prototype_name = t.prototype_name or self.prototype_name
        local state = t.state or self.state
        local color = t.color or self.color

        local typeobject = gameplay.queryByName("entity", prototype_name)
        local game_object = igame_object.create(typeobject.model, state, color, self.id)
        set_srt(world:entity(game_object.root), srt)

        self.game_object, self.prototype_name, self.state, self.color = game_object, prototype_name, state, color
    else
        local game_object = self.game_object
        if t.state == "translucent" and t.color and not math3d.isequal(self.color, t.color) then
            self.color = t.color
            game_object:send("set_material_property", "u_basecolor_factor", t.color)
        end
    end

    if t.show_block == false and self.block_entity_object then
        self.block_entity_object:remove()
        self.block_entity_object = nil
    end

    if t.block_color and self.block_entity_object then
        if t.block_edge_size then
            self.block_entity_object:remove()
            local typeobject = gameplay.queryByName("entity", self.prototype_name)
            local position = self:get_position()
            local rotation = get_rotation(self)
            self.block_entity_object = create_block(t.block_color, t.block_edge_size, typeobject.area, position, rotation)
        else
            self.block_entity_object:send("set_material_property", "u_color", t.block_color)
        end
    end
end

local function attach(self, slot_name, prefab_file_name)
    if self.attach_slot_name == slot_name and self.attach_prefab_file_name == prefab_file_name then
        return
    end

    self.game_object:send("attach_slot", slot_name, prefab_file_name)
    self.attach_slot_name = slot_name
    self.attach_prefab_file_name = prefab_file_name
end

local function detach(self)
    if self.attach_slot_name == "" and self.attach_prefab_file_name == "" then
        return
    end
    self.game_object:send("detach_slot")
    self.attach_slot_name = ""
    self.attach_prefab_file_name = ""
end

local function animation_update(self, animation_name, process)
    local game_object = assert(self.game_object)
    if self.animation.name ~= animation_name then
        self.animation = {name = animation_name, process = process, loop = false, manual = true}
        game_object:send("animation_play", self.animation)
    end

    if self.animation.process ~= process then
        self.animation.process = process
        game_object:send("animation_set_time", animation_name, process)
    end
end

-- init = {
--     prototype_name = prototype_name,
--     state = "opaque"/"translucent",
--     color = color,
--     block_edge_size = block_edge_size,
--     position = position,
--     dir = 'N',
-- }
return function (init)
    local typeobject = gameplay.queryByName("entity", init.prototype_name)

    local vsobject_id = gen_id()
    local game_object = assert(igame_object.create(typeobject.model, init.state, init.color, vsobject_id))
    iom.set_position(world:entity(game_object.root), init.position)
    iom.set_rotation(world:entity(game_object.root), rotators[init.dir])

    local block_entity_object = create_block(init.block_color, init.block_edge_size, typeobject.area, init.position, rotators[init.dir])

    local vsobject = {
        id = vsobject_id,
        prototype_name = init.prototype_name,
        state = init.state,
        color = init.color,
        block_edge_size = init.block_edge_size,
        block_entity_object = block_entity_object,
        game_object = game_object,
        animation = {},
        attach_slot_name = "",
        attach_prefab_file_name = "",

        --
        update = update,
        set_position = set_position,
        get_position = get_position,
        set_dir = set_dir,
        remove = remove,
        attach = attach,
        detach = detach,
        animation_update = animation_update,
    }
    return vsobject
end
