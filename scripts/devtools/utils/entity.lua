----
-- Different entity mod utilities.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Utils.Entity
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.3.0
----
local Entity = {}

local Table = require "devtools/utils/table"

--- Returns an entity animation state bank.
-- @see GetAnimStateBuild
-- @see GetAnimStateAnim
-- @tparam EntityScript entity
-- @treturn string
function Entity.GetAnimStateBank(entity)
    -- @todo: Find a better way of getting the entity AnimState bank instead of using RegEx...
    if entity.AnimState then
        local debug = entity:GetDebugString()
        local bank = string.match(debug, "AnimState:.*bank:%s+(%S+)")
        if bank and string.len(bank) > 0 then
            return bank
        end
    end
end

--- Returns an entity animation state build.
-- @see GetAnimStateBank
-- @see GetAnimStateAnim
-- @tparam EntityScript entity
-- @treturn string
function Entity.GetAnimStateBuild(entity)
    if entity.AnimState then
        return entity.AnimState:GetBuild()
    end
end

--- Returns an entity animation state animation.
-- @see GetAnimStateBank
-- @see GetAnimStateBuild
-- @tparam EntityScript entity
-- @treturn string
function Entity.GetAnimStateAnim(entity)
    -- TODO: Find a better way of getting the entity AnimState anim instead of using RegEx...
    if entity.AnimState then
        local debug = entity:GetDebugString()
        local anim = string.match(debug, "AnimState:.*anim:%s+(%S+)")
        if anim and string.len(anim) > 0 then
            return anim
        end
    end
end

--- Returns an entity state graph name.
-- @see GetStateGraphState
-- @tparam EntityScript entity
-- @treturn string
function Entity.GetStateGraphName(entity)
    -- TODO: Find a better way of getting the entity StateGraph name instead of using RegEx...
    if entity.sg then
        local debug = tostring(entity.sg)
        local name = string.match(debug, 'sg="(%S+)",')
        if name and string.len(name) > 0 then
            return name
        end
    end
end

--- Returns an entity state graph state.
-- @see GetStateGraphName
-- @tparam EntityScript entity
-- @treturn string
function Entity.GetStateGraphState(entity)
    -- TODO: Find a better way of getting the entity StateGraph state instead of using RegEx...
    if entity.sg then
        local debug = tostring(entity.sg)
        local state = string.match(debug, 'state="(%S+)",')
        if state and string.len(state) > 0 then
            return state
        end
    end
end

--- Returns an entity tags.
-- @tparam EntityScript entity
-- @tparam boolean is_all
-- @treturn table
function Entity.GetTags(entity, is_all)
    -- TODO: Find a better way of getting the entity tag instead of using RegEx...
    is_all = is_all == true

    local debug = entity:GetDebugString()
    local tags = string.match(debug, "Tags: (.-)\n")

    if tags and string.len(tags) > 0 then
        local result = {}

        if is_all then
            for tag in tags:gmatch("%S+") do
                table.insert(result, tag)
            end
        else
            for tag in tags:gmatch("%S+") do
                if not Table.HasValue(result, tag) then
                    table.insert(result, tag)
                end
            end
        end

        if #result > 0 then
            return Table.SortAlphabetically(result)
        end
    end
end

return Entity
