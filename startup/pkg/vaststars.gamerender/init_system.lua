local ecs = ...
local world = ecs.world
local w = world.w

local FRAMES_PER_SECOND <const> = 30
local bgfx = require 'bgfx'
local iRmlUi   = ecs.import.interface "ant.rmlui|irmlui"
local iui = ecs.import.interface "vaststars.gamerender|iui"
local terrain = ecs.require "terrain"
local gameplay_core = require "gameplay.core"
local world_update = ecs.require "world_update.init"
local gameplay_update = require "gameplay.update.init"
local saveload = ecs.require "saveload"
local iguide = require "gameplay.interface.guide"
local TERRAIN_ONLY <const> = require "debugger".terrain_only
local NOTHING <const> = require "debugger".nothing
local DISABLE_LOADING <const> = require "debugger".disable_loading
local dragdrop_camera_mb = world:sub {"dragdrop_camera"}
local pickup_gesture_mb = world:sub {"pickup_gesture"}
local icanvas = ecs.require "engine.canvas"
local icamera_controller = ecs.import.interface "vaststars.gamerender|icamera_controller"
local math3d = require "math3d"
local YAXIS_PLANE <const> = math3d.constant("v4", {0, 1, 0, 0})
local PLANES <const> = {YAXIS_PLANE}
local lorry_manager = ecs.require "lorry_manager"
local iefk = ecs.require "engine.efk"
local iroadnet = ecs.require "roadnet"
local irender_layer = ecs.require "engine.render_layer"
local idn = ecs.import.interface "mod.daynight|idaynight"
local DayTick <const> = require("gameplay.interface.constant").DayTick
local m = ecs.system 'init_system'

iRmlUi.set_prefix "/pkg/vaststars.resources/ui/"
iRmlUi.add_bundle "/pkg/vaststars.resources/ui/ui.bundle"
iRmlUi.font_dir "/pkg/vaststars.resources/ui/font/"

local prefab_parse = require("engine.prefab_parser").parse
local mathpkg = import_package "ant.math"
local mc = mathpkg.constant
local iom = ecs.import.interface "ant.objcontroller|iobj_motion"
local ic = ecs.import.interface "ant.camera|icamera"
local function init_camera_position(prefab_file_name)
    local data = prefab_parse("/pkg/vaststars.resources/" .. prefab_file_name)
    if not data then
        return
    end
    assert(data[1] and data[1].data and data[1].data.camera)
    local c = data[1].data

    local mq = w:first("main_queue camera_ref:in")
    local e <close> = w:entity(mq.camera_ref, "scene:update")
    e.scene.updir = mc.NULL -- TODO: use math3d.lookto() to reset updir

    iom.set_srt(e, c.scene.s or mc.ONE, c.scene.r, c.scene.t)
    -- Note: It will be inversed when the animation exceeds 90 degrees
    -- iom.set_view(e, iom.get_position(e), iom.get_direction(e), math3d.vector(data.scene.updir)) -- don't need to set updir, it will cause nan error
    ic.set_frustum(e, c.camera.frustum)
end

local function daynight_update(gameplayWorld)
    local dne = w:first "daynight:in"
    if not dne then
        return
    end

    local cycle = (gameplayWorld:now() % DayTick) / DayTick
    idn.update_cycle(dne, cycle)
end

function m:init_world()
    bgfx.maxfps(FRAMES_PER_SECOND)
    ecs.create_instance "/pkg/vaststars.resources/daynight.prefab"

    -- "foreground", "opacity", "background", "translucent", "decal_stage", "ui_stage"
    irender_layer.init({
        {
            "opacity",
            {layer_name = "1", logic_layer_names = {"TERRAIN"}},
            {layer_name = "2", logic_layer_names = {"BUILDING_BASE"}},
            {layer_name = "3", logic_layer_names = {"LORRY_SHADOW"}},
            {layer_name = "4", logic_layer_names = {"LORRY"}},
        },
        {
            "background",
            {layer_name = "5", logic_layer_names = {"ICON"}},
            {layer_name = "6", logic_layer_names = {"ICON_CONTENT"}},
            {layer_name = "7", logic_layer_names = {"WIRE"}},
        },
        {
            "translucent",
            {layer_name = "8", logic_layer_names = {"SELECTED_BOXES"}},
        },
    })

    iefk.preload "/pkg/vaststars.resources/effect/efk/"

    iroadnet:create(not NOTHING)
    if not DISABLE_LOADING then
        iui.open({"loading.rml"})
        return
    end

    init_camera_position("camera_default.prefab")
    ecs.create_instance "/pkg/vaststars.resources/light.prefab"
    if NOTHING then
        saveload:restore_camera_setting()
        return
    end

    terrain:create()
    if TERRAIN_ONLY then
        iroadnet:init({})
        saveload:restore_camera_setting()
        return
    end

    local show = true
    local storage = gameplay_core.get_storage()
    if storage.info ~= nil then
        show = storage.info
    end
    icanvas.create(icanvas.types().ICON, show)
    icanvas.create(icanvas.types().BUILDING_BASE, true, 0.01)
    icanvas.create(icanvas.types().ROAD_ENTRANCE_MARKER, false, 0.02)

    if not saveload:restore() then
        return
    end
    iguide.world = gameplay_core.get_world()
    iui.set_guide_progress(iguide.get_progress())
end

function m:update_world()
    if NOTHING then
        return
    end

    local gameplay_world = gameplay_core.get_world()
    daynight_update(gameplay_world)
    iroadnet:update()

    if gameplay_core.world_update then
        gameplay_core.update()
        world_update(gameplay_world)
        gameplay_update(gameplay_world)

        local mc, x, y, z
        for lorry_id, rc, tick in gameplay_world:roadnet_each_lorry() do
            mc = gameplay_world:roadnet_map_coord(rc)
            x, y, z = mc & 0xFF, (mc >> 8) & 0xFF, (mc >> 16) & 0xFF
            lorry_manager.update(lorry_id, x, y, z, tick)
        end
    end
end

function m:camera_usage()
    for _ in dragdrop_camera_mb:unpack() do
        if not terrain.init then
            goto continue
        end
        local coord = terrain:align(icamera_controller.get_central_position(), 1, 1)
        if coord then
            terrain:enable_terrain(coord[1], coord[2])
        end
        ::continue::
    end

    -- for debug
    for _, _, x, y in pickup_gesture_mb:unpack() do
        if terrain.init then
            local pos = icamera_controller.screen_to_world(x, y, {PLANES[1]})
            local coord = terrain:get_coord_by_position(pos[1])
            if coord then
                log.info(("pickup coord: (%s, %s)"):format(coord[1], coord[2]))
            end
        end
    end
end