ClassRegistry = {}

--
-- Helpers
--

local function __dummy()
end

local function __index(t, k)
    local p = rawget(t, "_")[k]
    if p ~= nil then
        return p[1]
    end
    return getmetatable(t)[k]
end

local function __newindex(t, k, v)
    local p = rawget(t, "_")[k]
    if p == nil then
        rawset(t, k, v)
    else
        local old = p[1]
        p[1] = v
        p[2](t, v, old)
    end
end

--
-- General
--

function Class(base, _ctor, props)
    local c = {}
    local c_inherited = {}

    if not _ctor and type(base) == "function" then
        _ctor = base
        base = nil -- luacheck: only
    elseif type(base) == "table" then
        for i, v in pairs(base) do
            c[i] = v
            c_inherited[i] = v
        end
        c._base = base
    end

    if props ~= nil then
        c.__index = __index
        c.__newindex = __newindex
    else
        c.__index = c
    end

    local mt = {}
    mt.__call = function(_, ...)
        local obj = {}
        if props ~= nil then
            obj._ = { _ = { nil, __dummy } }
            for k, v in pairs(props) do
                obj._[k] = { nil, v }
            end
        end
        setmetatable(obj, c)
        if c._ctor then
            c._ctor(obj, ...)
        end
        return obj
    end

    c._ctor = _ctor
    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do
            if m == klass then
                return true
            end
            m = m._base
        end
        return false
    end

    setmetatable(c, mt)
    ClassRegistry[c] = c_inherited

    return c
end
