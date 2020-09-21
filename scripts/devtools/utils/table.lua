----
-- Different table mod utilities.
--
-- **Source Code:** [https://github.com/victorpopkov/dst-mod-dev-tools](https://github.com/victorpopkov/dst-mod-dev-tools)
--
-- @module Utils.Table
-- @see Utils
--
-- @author Victor Popkov
-- @copyright 2020
-- @license MIT
-- @release 0.5.0-alpha
----
local Table = {}

--- Compares two tables if they are the same.
-- @tparam table a Table A
-- @tparam table b Table B
-- @treturn boolean
function Table.Compare(a, b)
    -- basic validation
    if a == b then
        return true
    end

    -- null check
    if a == nil or b == nil then
        return false
    end

    -- validate type
    if type(a) ~= "table" then
        return false
    end

    -- compare meta tables
    local meta_table_a = getmetatable(a)
    local meta_table_b = getmetatable(b)
    if not Table.Compare(meta_table_a, meta_table_b) then
        return false
    end

    -- compare nested tables
    for index, va in pairs(a) do
        local vb = b[index]
        if not Table.Compare(va, vb) then
            return false
        end
    end

    for index, vb in pairs(b) do
        local va = a[index]
        if not Table.Compare(va, vb) then
            return false
        end
    end

    return true
end

--- Counts the number of elements inside the table.
-- @tparam table t Table
-- @treturn number
function Table.Count(t)
    if type(t) ~= "table" then
        return false
    end

    local result = 0
    for _ in pairs(t) do
        result = result + 1
    end

    return result
end

--- Checks if a table has the provided value.
-- @tparam table t Table
-- @tparam string value
-- @treturn boolean
function Table.HasValue(t, value)
    if type(t) ~= "table" then
        return false
    end

    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end

    return false
end

--- Gets the table key based on the value.
-- @tparam table t Table
-- @param value Value to look for
-- @treturn number
function Table.KeyByValue(t, value)
    if type(t) ~= "table" then
        return false
    end

    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
end

--- Merges two tables.
-- @todo Add nested tables merging support for ipaired tables
-- @tparam table a Table A
-- @tparam table b Table B
-- @tparam[opt] boolean is_merge_nested Should nested tables be merged
-- @treturn table
function Table.Merge(a, b, is_merge_nested)
    -- guessing if the table is an ipaired one
    local is_ipaired = true
    for k, _ in pairs(b) do
        if type(k) ~= "number" then
            is_ipaired = false
        end
    end

    if is_ipaired then
        for i = 1, #b do
            a[#a + 1] = b[i]
        end
    else
        for k, v in pairs(b) do
            if is_merge_nested then
                if type(v) == "table" then
                    if type(a[k] or false) == "table" then
                        Table.Merge(a[k] or {}, b[k] or {})
                    else
                        a[k] = v
                    end
                end
            else
                a[k] = v
            end
        end
    end
    return a
end

--- Gets the next table value.
--
-- When the next value doesn't exist it returns the first one.
--
-- **NB!** Currently supports only "ipaired" tables.
--
-- @tparam table t Table
-- @tparam string value Value
-- @treturn string
function Table.NextValue(t, value)
    if type(t) ~= "table" then
        return false
    end

    for k, v in pairs(t) do
        if v == value then
            return k < #t and t[k + 1] or t[1]
        end
    end
end

--- Sorts the table elements alphabetically.
-- @tparam table t Table
-- @treturn number
function Table.SortAlphabetically(t)
    if type(t) ~= "table" then
        return false
    end

    table.sort(t, function(a, b)
        return a:lower() < b:lower()
    end)

    return t
end

return Table
