----
-- Different dump mod utilities.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Utils.Dump
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.7.0-alpha
----
local Dump = {}

local Table = require "devtools/utils/table"

local function PrintDumpValues(table, title, name, prepend)
    prepend = prepend ~= nil and prepend .. " " or ""

    print(prepend .. (name
        and string.format('Dumping "%s" %s...', name, title)
        or string.format('Dumping %s...', title)))

    if #table > 0 then
        table = Table.SortAlphabetically(table)
        for _, v in pairs(table) do
            print(prepend .. v)
        end
    else
        print(prepend .. "No " .. title)
    end
end

--- Returns a table on all entity components.
-- @usage dumptable(GetComponents(ThePlayer))
-- @see GetEventListeners
-- @see GetFields
-- @see GetFunctions
-- @see GetReplicas
-- @tparam EntityScript entity
-- @treturn table
function Dump.GetComponents(entity)
    local result = {}
    if type(entity) == "table" or type(entity) == "userdata" then
        if type(entity.components) == "table" then
            for k, _ in pairs(entity.components) do
                table.insert(result, k)
            end
        end
    end
    return result
end

--- Dumps all entity components.
-- @usage DumpComponents(ThePlayer, "ThePlayer")
-- @see EventListeners
-- @see Fields
-- @see Functions
-- @see Replicas
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Dump.Components(entity, name, prepend)
    PrintDumpValues(Dump.GetComponents(entity), "Components", name, prepend)
end

--- Returns a table on all entity event listeners.
-- @usage dumptable(GetEventListeners(ThePlayer))
-- @see GetComponents
-- @see GetFields
-- @see GetFunctions
-- @see GetReplicas
-- @tparam EntityScript entity
-- @treturn table
function Dump.GetEventListeners(entity)
    local result = {}
    if type(entity) == "table" or type(entity) == "userdata" then
        if type(entity.event_listeners) == "table" then
            for k, _ in pairs(entity.event_listeners) do
                table.insert(result, k)
            end
        end
    end
    return result
end

--- Dumps all entity event listeners.
-- @usage DumpEventListeners(ThePlayer, "ThePlayer")
-- @see Components
-- @see Fields
-- @see Functions
-- @see Replicas
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Dump.EventListeners(entity, name, prepend)
    PrintDumpValues(Dump.GetEventListeners(entity), "Event Listeners", name, prepend)
end

--- Returns a table on all entity fields.
-- @usage dumptable(GetFields(ThePlayer))
-- @see GetComponents
-- @see GetEventListeners
-- @see GetFunctions
-- @see GetReplicas
-- @tparam EntityScript entity
-- @treturn table
function Dump.GetFields(entity)
    local result = {}
    if type(entity) == "table" then
        for k, v in pairs(entity) do
            if type(v) ~= "function" then
                table.insert(result, k)
            end
        end
    end
    return result
end

--- Dumps all entity fields.
-- @usage DumpFields(ThePlayer, "ThePlayer")
-- @see Components
-- @see EventListeners
-- @see Functions
-- @see Replicas
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Dump.Fields(entity, name, prepend)
    PrintDumpValues(Dump.GetFields(entity), "Fields", name, prepend)
end

--- Returns a table on all entity functions.
-- @usage dumptable(GetFunctions(ThePlayer))
-- @see GetComponents
-- @see GetEventListeners
-- @see GetFields
-- @see GetReplicas
-- @tparam EntityScript entity
-- @treturn table
function Dump.GetFunctions(entity)
    local result = {}
    local metatable = getmetatable(entity)

    if metatable and metatable["__index"] then
        for k, _ in pairs(metatable["__index"]) do
            table.insert(result, k)
        end
    end

    if type(entity) == "table" and #result == 0 then
        for k, v in pairs(entity) do
            if type(v) == "function" then
                table.insert(result, k)
            end
        end
    end

    return result
end

--- Dumps all entity functions.
-- @usage DumpFunctions(ThePlayer, "ThePlayer")
-- @see Components
-- @see EventListeners
-- @see Fields
-- @see Replicas
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Dump.Functions(entity, name, prepend)
    PrintDumpValues(Dump.GetFunctions(entity), "Functions", name, prepend)
end

--- Returns a table on all entity replicas.
-- @usage dumptable(GetReplicas(ThePlayer))
-- @see GetComponents
-- @see GetEventListeners
-- @see GetFields
-- @see GetFunctions
-- @tparam EntityScript entity
-- @treturn table
function Dump.GetReplicas(entity)
    local result = {}
    if entity.replica and type(entity.replica._) == "table" then
        for k, _ in pairs(entity.replica._) do
            table.insert(result, k)
        end
    end
    return result
end

--- Dumps all entity replicas.
-- @usage DumpReplicas(ThePlayer, "ThePlayer")
-- @see Components
-- @see EventListeners
-- @see Fields
-- @see Functions
-- @tparam EntityScript entity
-- @tparam[opt] string name The name of the dumped entity
-- @tparam[opt] string prepend The prepend string on each line
-- @treturn table
function Dump.Replicas(entity, name, prepend)
    PrintDumpValues(Dump.GetReplicas(entity), "Replicas", name, prepend)
end

return Dump
