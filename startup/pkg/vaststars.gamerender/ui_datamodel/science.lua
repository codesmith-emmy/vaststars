local ecs, mailbox = ...
local world = ecs.world
local w = world.w
local gameplay_core = require "gameplay.core"
local global = require "global"
local iui = ecs.require "engine.system.ui_system"
local iprototype = require "gameplay.interface.prototype"
local irecipe = require "gameplay.interface.recipe"
local itypes = require "gameplay.interface.types"
local click_tech_event = mailbox:sub {"click_tech"}
local click_recipe_event = mailbox:sub {"click_recipe"}
local close_techui_event = mailbox:sub {"close_techui"}
local show_list_event = mailbox:sub {"show_list"}
local switch_mb = mailbox:sub {"switch"}
local iguide_tips = ecs.require "guide_tips"

local M = {}
local current_tech
local function get_techlist(tech_list)
    local check_new_recipe = (tech_list == global.science.finish_list)
    local function get_display_item(technode)
        local name = technode.name
        local value = technode.detail
        local simple_ingredients = {}
        local ingredients = irecipe.get_elements(value.ingredients)
        for _, ingredient in ipairs(ingredients) do
            simple_ingredients[#simple_ingredients + 1] = {icon = assert(ingredient.tech_icon), count = ingredient.count}
        end
        local detail = {}
        local sub_icon = ' '
        local sub_desc = ' '
        if value.sign_desc then
            for _, desc in ipairs(value.sign_desc) do
                if desc.name then
                    detail[#detail+1] = desc
                else
                    sub_icon = desc.icon
                    sub_desc = desc.desc
                end
            end
        end
        local item = {}
        if value.effects then
            if value.effects.unlock_recipe then
                local prototypes = iprototype.each_type("recipe")
                for _, recipe in ipairs(value.effects.unlock_recipe) do
                    local recipe_detail = prototypes[recipe]
                    if recipe_detail then
                        local input = {}
                        ingredients = irecipe.get_elements(recipe_detail.ingredients)
                        for _, ingredient in ipairs(ingredients) do
                            input[#input + 1] = {name = ingredient.name, icon = assert(ingredient.icon), count = ingredient.count}
                        end
                        local output = {}
                        local results = irecipe.get_elements(recipe_detail.results)
                        local new
                        if check_new_recipe then
                            for _, unpick in ipairs(global.science.tech_recipe_unpicked) do
                                if unpick.recipe_name == recipe then
                                    new = true
                                    break
                                end
                            end
                        end
                        for _, ingredient in ipairs(results) do
                            output[#output + 1] = {new = new, name = ingredient.name, icon = assert(ingredient.icon), count = ingredient.count}
                        end
                        detail[#detail + 1] = {
                            name = recipe,
                            icon = assert(recipe_detail.recipe_icon),
                            desc = recipe_detail.description,
                            input = input,
                            output = output,
                            time = itypes.time(recipe_detail.time)
                        }
                    end
                end
            end
            -- if value.effects.unlock_item then
            --     local prototypes = iprototype.each_type("item")
            --     for _, it in ipairs(value.effects.unlock_item) do
            --         local item_detail = prototypes[it]
            --         item[#item + 1] = {
            --             name = item_detail.name,
            --             icon = item_detail.item_icon,
            --             desc = item_detail.item_description,
            --         }
            --     end
            -- end
        end
        local game_world = gameplay_core.get_world()
        local progress = game_world:research_progress(name) or 0
        local queue = game_world:research_queue()

        return {
            name = name,
            desc = value.desc or " ",
            sub_icon = sub_icon,
            sub_desc = sub_desc,
            sign_icon = value.sign_icon,
            detail = detail,
            item = item,
            ingredients = simple_ingredients,
            count = value.count,
            time = value.time,
            task = value.task and true or false,
            progress = progress, --(progress > 0) and ((progress * 100) // value.count) or progress,
            running = #queue > 0 and queue[1] == name or false,
            new = global.science.tech_picked_flag[name] or false
        }
    end
    local items = {}
    for _, technode in ipairs(tech_list) do
        local di = get_display_item(technode)
        di.index = #items + 1
        items[#items + 1] = di
    end
    return items
end

local function get_button_str(tech)
    if not tech then
        return ""
    end
    return "开始" .. (tech.task and "任务" or "研究")
end

function M.create(unpicked_recipe)
    local items = get_techlist(global.science.tech_list)
    local tech_index
    local recipe_index
    local finish_items = {}
    if unpicked_recipe then
        finish_items = get_techlist(global.science.finish_list)
        for index, value in ipairs(finish_items) do
            if value.name == unpicked_recipe.tech_name then
                tech_index = index
                recipe_index = unpicked_recipe.index
                break
            end
        end
    end
    current_tech = tech_index and finish_items[tech_index] or items[1]
    return {
        techitems = tech_index and finish_items or items,
        show_finish = tech_index and true or false,
        tech_index = tech_index,
        recipe_index = recipe_index,
        current_tech = current_tech or {},
        current_running = current_tech and current_tech.running or false,
        current_button_str = get_button_str(current_tech)
    }
end

function M.update(datamodel)
    local function set_current_tech(tech)
        if current_tech == tech then
            return
        end
        current_tech = tech
        datamodel.current_tech = tech or {}
        datamodel.current_running = tech and tech.running or false
        datamodel.current_button_str = get_button_str(tech)
    end

    for _, _, _, index in click_tech_event:unpack() do
        global.science.tech_picked_flag[datamodel.techitems[index].name] = false
        set_current_tech(datamodel.techitems[index])
        iui.call_datamodel_method("/pkg/vaststars.resources/ui/construct.html", "update_tech")
    end
    for _, _, _, name in click_recipe_event:unpack() do
        world:pub {"tech_recipe_unpicked_dirty", name}
    end
    for _, _, _ in close_techui_event:unpack() do
        gameplay_core.world_update = true
        iui.close("/pkg/vaststars.resources/ui/science.html")
    end
    for _, _, _, list, tech_index in show_list_event:unpack() do
        local items = get_techlist((list == "todo") and global.science.tech_list or global.science.finish_list)
        datamodel.techitems = items
        tech_index = tech_index or 1
        if items[tech_index] then
            set_current_tech(items[tech_index])
        end
        
    end
    local game_world = gameplay_core.get_world()
    for _, _, _ in switch_mb:unpack() do
        if not current_tech then
            goto continue
        end
        current_tech.running = not current_tech.running
        if current_tech.running then
            for _, tech in ipairs(global.science.tech_list) do
                if current_tech ~= tech then
                    tech.running = false
                end
            end
            game_world:research_queue {current_tech.name}
            global.science.current_tech = global.science.tech_tree[current_tech.name]
            iguide_tips.show(global.science.current_tech)
        else
            game_world:research_queue {}
            iguide_tips.clear()
            global.science.current_tech = nil
        end
        datamodel.current_running = current_tech.running
        datamodel.current_progress = current_tech.progress
        datamodel.current_button_str = get_button_str(current_tech)
        ::continue::
    end
end

return M