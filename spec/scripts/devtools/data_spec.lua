require "busted.runner"()

describe("Data", function()
    -- setup match
    local match

    -- setup other
    local modname

    -- before_each globals (TheSim)
    local GetPersistentString

    -- before_each globals (TheWorld)
    local GetMasterSessionId, MasterSessionId, shardstate

    -- before_each globals
    local ENCODE_SAVES, SavePersistentString, json

    -- before_each initialization
    local Data, data

    setup(function()
        -- match
        match = require "luassert.match"

        -- debug
        DebugSpyTerm()
        DebugSpyInit(spy)

        -- other
        modname = "test"
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.ENCODE_SAVES = nil
        _G.SavePersistentString = nil
        _G.TheSim = nil
        _G.TheWorld = nil
        _G.json = nil
    end)

    before_each(function()
        -- globals (TheSim)
        GetPersistentString = spy.new(Empty)

        _G.TheSim = {
            GetPersistentString = GetPersistentString,
        }

        -- globals (TheWorld)
        MasterSessionId = "D000000000000000"
        GetMasterSessionId = spy.new(ReturnValueFn(MasterSessionId))
        shardstate = { GetMasterSessionId = GetMasterSessionId }

        _G.TheWorld = {
            net = {
                components = {
                    shardstate = shardstate,
                },
            },
        }

        -- globals
        ENCODE_SAVES = false
        SavePersistentString = spy.new(Empty)

        json = {
            encode = spy.new(Empty),
            decode = spy.new(Empty),
        }

        _G.ENCODE_SAVES = ENCODE_SAVES
        _G.SavePersistentString = SavePersistentString
        _G.json = json

        -- initialization
        DebugSpyTerm()
        DebugSpyInit(spy)
        Data = require "devtools/data"
        data = Data(modname)

        DebugSpyClear()
        GetMasterSessionId:clear()
        GetPersistentString:clear()
    end)

    insulate("initialization", function()
        before_each(function()
            Data = require "devtools/data"
        end)

        local function AssertDefaults(self)
            -- general
            assert.is_true(self.dirty)
            assert.is_equal(modname, self.modname)
            assert.is_equal("Data", self.name)
            assert.is_nil(self.server_id)

            -- persist data
            assert.is_same({
                general = {},
                servers = {},
            }, self.persist_data)
        end

        describe("using the constructor", function()
            before_each(function()
                data = Data(modname)
            end)

            it("should have the default fields", function()
                AssertDefaults(data)
            end)

            it("should call the Load()", function()
                DebugSpyAssertWasCalled("DebugStringStart", 1, {
                    "[data]",
                    "[load]",
                    string.format("Loading %s...", data:GetSaveName()),
                })
            end)

            it("should call the DebugInit()", function()
                DebugSpyAssertWasCalled("DebugInit", 1, {
                    data.name,
                })
            end)
        end)
    end)

    describe("general", function()
        describe("should have the", function()
            describe("getter", function()
                local getters = {
                    modname = "GetModname",
                    name = "GetName",
                    persist_data = "GetPersistData",
                    dirty = "IsDirty",
                }

                for field, getter in pairs(getters) do
                    it(getter, function()
                        AssertGetter(data, field, getter)
                    end)
                end
            end)

            describe("setter", function()
                it("SetDirty", function()
                    AssertSetter(data, "dirty", "SetDirty")
                end)
            end)
        end)

        describe("GetSaveName()", function()
            teardown(function()
                _G.BRANCH = nil
            end)

            describe("when the BRANCH is not dev", function()
                setup(function()
                    _G.BRANCH = "release"
                end)

                it("should return modname", function()
                    assert.is_equal(data.modname, data:GetSaveName())
                end)
            end)

            describe("when the BRANCH is dev", function()
                setup(function()
                    _G.BRANCH = "dev"
                end)

                it("should return modname", function()
                    assert.is_equal(data.modname .. "_dev", data:GetSaveName())
                end)
            end)
        end)

        describe("Reset()", function()
            before_each(function()
                data.dirty = false

                data.original_persist_data = {
                    general = {},
                    servers = {},
                }

                data.persist_data = {
                    general = {},
                    servers = {
                        [MasterSessionId] = {
                            data = {
                                test = "test",
                            },
                        },
                    },
                }
            end)

            it("should call the Debug:DebugString()", function()
                data:Reset()
                DebugSpyAssertWasCalled("DebugString", 1, {
                    "[data]",
                    "[reset]",
                    "Success",
                })
            end)

            it("should reset persist_data field", function()
                assert.is_not_same(data.original_persist_data, data.persist_data)
                data:Reset()
                assert.is_same(data.original_persist_data, data.persist_data)
            end)

            it("should set the dirty field to true", function()
                data:Reset()
                assert.is_true(data.dirty)
            end)
        end)
    end)

    describe("saving", function()
        describe("Save()", function()
            local cb

            before_each(function()
                cb = spy.new(Empty)
            end)

            describe("when the dirty is true", function()
                before_each(function()
                    data.dirty = true
                end)

                describe("and the name is passed", function()
                    it("should call the Debug:DebugString()", function()
                        data:Save(nil, "Test")
                        DebugSpyAssertWasCalled("DebugString", 1, {
                            "[data]",
                            "[save]",
                            "Saved (Test)"
                        })
                    end)
                end)

                describe("and the name is not passed", function()
                    it("should call the Debug:DebugString()", function()
                        data:Save()
                        DebugSpyAssertWasCalled("DebugString", 1, {
                            "[data]",
                            "[save]",
                            "Saved"
                        })
                    end)
                end)

                it("should set the dirty field to false", function()
                    data:Save()
                    assert.is_false(data.dirty)
                end)

                it("should call the json.encode()", function()
                    data:Save()
                    assert.spy(json.encode).was_called(1)
                    assert.spy(json.encode).was_called_with(data.persist_data)
                end)

                it("should call the SavePersistentString()", function()
                    data:Save()
                    assert.spy(SavePersistentString).was_called(1)
                    assert.spy(SavePersistentString).was_called_with(
                        data:GetSaveName(),
                        nil,
                        ENCODE_SAVES,
                        nil
                    )
                end)

                it("should call the callback if passed with true", function()
                    data:Save(cb)
                    assert.spy(cb).was_called(1)
                    assert.spy(cb).was_called_with(true)
                end)
            end)

            describe("when the dirty is false", function()
                before_each(function()
                    data.dirty = false
                end)

                it("shouldn't call the Debug:DebugString()", function()
                    data:Save()
                    DebugSpyAssertWasCalled("DebugString", 0)
                end)

                it("shouldn't call the SavePersistentString()", function()
                    data:Save()
                    assert.spy(SavePersistentString).was_not_called()
                end)

                it("shouldn't call the callback if passed", function()
                    data:Save(cb)
                    assert.spy(cb).was_not_called(1)
                end)
            end)
        end)
    end)

    describe("loading", function()
        describe("Load()", function()
            it("should call the Debug:DebugStringStart()", function()
                data:Load()
                DebugSpyAssertWasCalled("DebugStringStart", 1, {
                    "[data]",
                    "[load]",
                    string.format("Loading %s...", data:GetSaveName()),
                })
            end)

            it("should call the TheSim:GetPersistentString()", function()
                data:Load()
                assert.spy(GetPersistentString).was_called(1)
                assert.spy(GetPersistentString).was_called_with(
                    match.is_ref(TheSim),
                    data:GetSaveName(),
                    match.is_function(),
                    false
                )
            end)
        end)

        describe("OnLoad()", function()
            local cb
            local TrackedAssert

            before_each(function()
                -- general
                cb = spy.new(Empty)

                -- globals
                TrackedAssert = spy.new(Empty)
                _G.TrackedAssert = TrackedAssert
            end)

            teardown(function()
                _G.TrackedAssert = nil
            end)

            local function TestEmptyOrNilString(str)
                it("should call the Debug:DebugStringStop()", function()
                    data:OnLoad(str)
                    DebugSpyAssertWasCalled("DebugStringStop", 1, {
                        "[data]",
                        "[error]",
                        "[load]",
                        "Failure",
                        "(empty string)",
                    })
                end)

                it("should call the callback if passed with false", function()
                    data:OnLoad("", cb)
                    assert.spy(cb).was_called(1)
                    assert.spy(cb).was_called_with(false)
                end)
            end

            describe("when passed string is empty", function()
                TestEmptyOrNilString("")
            end)

            describe("when passed string is nil", function()
                TestEmptyOrNilString(nil)
            end)

            describe("when passed string not empty", function()
                local str
                local CleanServers, Save

                setup(function()
                    str = "test"
                end)

                before_each(function()
                    CleanServers = spy.on(data, "CleanServers")
                    Save = spy.on(data, "Save")
                end)

                it("should call the Debug:DebugStringStop()", function()
                    data:OnLoad(str)
                    DebugSpyAssertWasCalled("DebugStringStop", 1, {
                        "[data]",
                        "[load]",
                        "Success",
                        string.format("(length: %d)", string.len(str)),
                    })
                end)

                it("should call the TrackedAssert()", function()
                    data:OnLoad(str)
                    assert.spy(TrackedAssert).was_called(1)
                    assert.spy(TrackedAssert).was_called_with(
                        "TheSim:GetPersistentString " .. data.name,
                        match.is_ref(json.decode),
                        str
                    )
                end)

                it("should set the dirty field to false", function()
                    data:OnLoad(str)
                    assert.is_false(data.dirty)
                end)

                it("should set the original_persist_data field", function()
                    data.original_persist_data = {}
                    local before = data.original_persist_data
                    assert.is_equal(before, data.original_persist_data)
                    data:OnLoad(str)
                    assert.is_not_equal(before, data.original_persist_data)
                end)

                it("should set the persist data field", function()
                    data.persist_data = {}
                    local before = data.persist_data
                    assert.is_equal(before, data.persist_data)
                    data:OnLoad(str)
                    assert.is_not_equal(before, data.persist_data)
                end)

                it("should call the CleanServers()", function()
                    data:OnLoad(str)
                    assert.spy(CleanServers).was_called(1)
                    assert.spy(CleanServers).was_called_with(match.is_ref(data))
                end)

                it("should call the Save()", function()
                    data:OnLoad(str)
                    assert.spy(Save).was_called(1)
                    assert.spy(Save).was_called_with(match.is_ref(data))
                end)

                it("should call the callback if passed with true", function()
                    data:OnLoad(str, cb)
                    assert.spy(cb).was_called(1)
                    assert.spy(cb).was_called_with(true)
                end)
            end)
        end)
    end)

    --describe("general data", function()
    --    local time_previous, time_current
    --    local _os, time
    --
    --    setup(function()
    --        -- general
    --        time_previous = 1586860000
    --        time_current = 1586860001
    --
    --        -- globals
    --        time = spy.new(ReturnValueFn(time_current))
    --
    --        _os = _G.os
    --        _G.os.time = time
    --    end)
    --
    --    teardown(function()
    --        _G.os.time = _os.time
    --    end)
    --end)

    describe("server data", function()
        local time_previous, time_current
        local _os, time

        setup(function()
            -- general
            time_previous = 1586860000
            time_current = 1586860001

            -- globals
            time = spy.new(ReturnValueFn(time_current))

            _os = _G.os
            _G.os.time = time
        end)

        teardown(function()
            _G.os.time = _os.time
        end)

        describe("not in game", function()
            before_each(function()
                -- test data
                data.dirty = false
                data.persist_data = {
                    general = {},
                    servers = {
                        [MasterSessionId] = {
                            lastseen = time_previous,
                            data = {
                                test = "test",
                            },
                        },
                    },
                }

                -- globals
                _G.TheSim = nil
                _G.TheWorld = nil
            end)

            local function TestNoServerDataDebugString(fn, ...)
                local args = { ... }
                it("should call the Debug:DebugString()", function()
                    data[fn](data, unpack(args))
                    DebugSpyAssertWasCalled("DebugString", 1, {
                        "[data]",
                        "[error]",
                        "No server data",
                    })
                end)
            end

            local function TestNilChainFields(fn, field)
                describe("when some chain fields are missing", function()
                    it("should return nil", function()
                        if field then
                            data.persist_data.servers[MasterSessionId][field] = nil
                            assert.is_nil(data[fn](data), fn)
                        end

                        data.persist_data.servers[MasterSessionId] = nil
                        assert.is_nil(data[fn](data), fn)
                        data.persist_data.servers = nil
                        assert.is_nil(data[fn](data), fn)
                        data.persist_data = nil
                        assert.is_nil(data[fn](data), fn)
                    end)
                end)
            end

            describe("GetServerID()", function()
                it("should return nil", function()
                    assert.is_nil(data:GetServerID())
                end)
            end)

            describe("GetServer()", function()
                it("should set the server_id field to nil", function()
                    data:GetServer()
                    assert.is_nil(data.server_id)
                end)

                it("should return nil", function()
                    assert.is_nil(data:GetServer())
                end)

                TestNoServerDataDebugString("GetServer")
                TestNilChainFields("GetServer")
            end)

            describe("GetServerLastSeen()", function()
                it("should return nil", function()
                    assert.is_nil(data:GetServerLastSeen())
                end)

                TestNoServerDataDebugString("GetServerLastSeen")
                TestNilChainFields("GetServerLastSeen", "lastseen")
            end)

            describe("GetServerData()", function()
                it("should return nil", function()
                    assert.is_nil(data:GetServerData())
                end)

                TestNoServerDataDebugString("GetServerData")
                TestNilChainFields("GetServerData", "data")
            end)

            describe("ServerRefreshLastSeen()", function()
                it("should return false", function()
                    assert.is_false(data:ServerRefreshLastSeen())
                end)

                TestNoServerDataDebugString("ServerRefreshLastSeen")

                describe("when some chain fields are missing", function()
                    it("should return false", function()
                        data.persist_data.servers[MasterSessionId].lastseen = nil
                        assert.is_false(data:ServerRefreshLastSeen())
                        data.persist_data.servers[MasterSessionId] = nil
                        assert.is_false(data:ServerRefreshLastSeen())
                        data.persist_data.servers = nil
                        assert.is_false(data:ServerRefreshLastSeen())
                        data.persist_data = nil
                        assert.is_false(data:ServerRefreshLastSeen())
                    end)
                end)
            end)

            describe("ServerSet()", function()
                it("should return false", function()
                    assert.is_false(data:ServerSet("key", "value"))
                end)

                TestNoServerDataDebugString("ServerSet", "key", "value")

                describe("when some chain fields are missing", function()
                    it("should return false", function()
                        data.persist_data.servers[MasterSessionId].data = nil
                        assert.is_false(data:ServerSet("key", "value"))
                        data.persist_data.servers[MasterSessionId] = nil
                        assert.is_false(data:ServerSet("key", "value"))
                        data.persist_data.servers = nil
                        assert.is_false(data:ServerSet("key", "value"))
                        data.persist_data = nil
                        assert.is_false(data:ServerSet("key", "value"))
                    end)
                end)
            end)

            describe("ServerGet()", function()
                it("should return nil", function()
                    assert.is_nil(data:ServerGet("test"))
                end)

                TestNoServerDataDebugString("ServerGet", "test")

                describe("when some chain fields are missing", function()
                    it("should return nil", function()
                        data.persist_data.servers[MasterSessionId].data = nil
                        assert.is_nil(data:ServerGet("test"))
                        data.persist_data.servers[MasterSessionId] = nil
                        assert.is_nil(data:ServerGet("test"))
                        data.persist_data.servers = nil
                        assert.is_nil(data:ServerGet("test"))
                        data.persist_data = nil
                        assert.is_nil(data:ServerGet("test"))
                    end)
                end)
            end)
        end)

        describe("in game", function()
            local function TestNilChainFields(fn)
                describe("when some chain fields are missing", function()
                    it("should return nil", function()
                        data.persist_data.servers = nil
                        assert.is_nil(data[fn](data), fn)
                        data.persist_data = nil
                        assert.is_nil(data[fn](data), fn)
                    end)
                end)
            end

            describe("when server exists", function()
                before_each(function()
                    data.dirty = false
                    data.persist_data = {
                        general = {},
                        servers = {
                            [MasterSessionId] = {
                                lastseen = time_previous,
                                data = {
                                    test = "test",
                                },
                            },
                        },
                    }
                end)

                describe("GetServerID()", function()
                    it("should return master session id", function()
                        assert.is_equal(MasterSessionId, data:GetServerID())
                    end)

                    it(
                        "should call the TheWorld.net.components.shardstate:GetMasterSessionId()",
                        function()
                            data:GetServerID()
                            assert.spy(GetMasterSessionId).was_called(1)
                            assert.spy(GetMasterSessionId).was_called_with(match.is_ref(shardstate))
                        end
                    )

                    describe("when some chain fields are missing", function()
                        it("should return nil", function()
                            _G.TheWorld.net.components.shardstate.GetMasterSessionId = nil
                            assert.is_nil(data:GetServerID())
                            _G.TheWorld.net.components.shardstate = nil
                            assert.is_nil(data:GetServerID())
                            _G.TheWorld.net.components = nil
                            assert.is_nil(data:GetServerID())
                            _G.TheWorld.net = nil
                            assert.is_nil(data:GetServerID())
                            _G.TheWorld = nil
                            assert.is_nil(data:GetServerID())
                        end)
                    end)
                end)

                describe("GetServer()", function()
                    it("should set the server_id field", function()
                        data:GetServer()
                        assert.is_equal(MasterSessionId, data.server_id)
                    end)

                    it("should refresh the lastseen field", function()
                        assert.is_equal(
                            time_previous,
                            data.persist_data.servers[MasterSessionId].lastseen
                        )

                        data:GetServer()

                        assert.is_equal(
                            time_current,
                            data.persist_data.servers[MasterSessionId].lastseen
                        )
                    end)

                    it("should set dirty true", function()
                        data:GetServer()
                        assert.is_true(data.dirty)
                    end)

                    it("should return server", function()
                        assert.is_same({
                            lastseen = time_current,
                            data = {
                                test = "test",
                            },
                        }, data:GetServer())
                    end)

                    TestNilChainFields("GetServer")
                end)

                describe("GetServerLastSeen()", function()
                    it("should return the current time", function()
                        assert.is_equal(time_current, data:GetServerLastSeen())
                    end)

                    TestNilChainFields("GetServerLastSeen")
                end)

                describe("GetServerData()", function()
                    it("should return the server data", function()
                        assert.is_same({ test = "test" }, data:GetServerData())
                    end)

                    TestNilChainFields("GetServerData")
                end)

                describe("ServerRefreshLastSeen()", function()
                    it("should return true", function()
                        assert.is_true(data:ServerRefreshLastSeen())
                    end)

                    it("should refresh the lastseen field", function()
                        assert.is_equal(
                            time_previous,
                            data.persist_data.servers[MasterSessionId].lastseen
                        )

                        data:ServerRefreshLastSeen()

                        assert.is_equal(
                            time_current,
                            data.persist_data.servers[MasterSessionId].lastseen
                        )
                    end)

                    it("should set the dirty field to true", function()
                        data:ServerRefreshLastSeen()
                        assert.is_true(data.dirty)
                    end)

                    describe("when some chain fields are missing", function()
                        it("should return false", function()
                            data.persist_data.servers = nil
                            assert.is_false(data:ServerRefreshLastSeen())
                            data.persist_data = nil
                            assert.is_false(data:ServerRefreshLastSeen())
                        end)
                    end)
                end)

                describe("ServerSet()", function()
                    it("should call the Debug:DebugString()", function()
                        data:ServerSet("key", "value")
                        DebugSpyAssertWasCalled("DebugString", 1, {
                            "[data]",
                            "[set]",
                            "[" .. data.server_id .. "]",
                            "key:",
                            "value",
                        })
                    end)

                    it("should set dirty to true", function()
                        data:ServerSet("key", "value")
                        assert.is_true(data.dirty)
                    end)

                    it("should return true", function()
                        assert.is_true(data:ServerSet("key", "value"))
                    end)

                    describe("when some chain fields are missing", function()
                        it("should return false", function()
                            data.persist_data.servers[MasterSessionId].data = nil
                            assert.is_false(data:ServerSet("key", "value"))
                            data.persist_data.servers = nil
                            assert.is_false(data:ServerSet("key", "value"))
                            data.persist_data = nil
                            assert.is_false(data:ServerSet("key", "value"))
                        end)
                    end)
                end)

                describe("ServerGet()", function()
                    it("should call the Debug:DebugString()", function()
                        data:ServerGet("test")
                        DebugSpyAssertWasCalled("DebugString", 1, {
                            "[data]",
                            "[get]",
                            "[" .. data.server_id .. "]",
                            "test",
                        })
                    end)

                    it("should return value", function()
                        assert.is_equal("test", data:ServerGet("test"))
                    end)

                    describe("when no value", function()
                        before_each(function()
                            data.dirty = false
                            data.persist_data = {
                                general = {},
                                servers = {
                                    [MasterSessionId] = {
                                        lastseen = time_previous,
                                        data = {},
                                    },
                                },
                            }
                        end)

                        it("should call the Debug:DebugString()", function()
                            data:ServerGet("test")
                            DebugSpyAssertWasCalled("DebugString", 1, {
                                "[data]",
                                "[get]",
                                "[error]",
                                "[" .. data.server_id .. "]",
                                "test",
                            })
                        end)

                        it("should return nil", function()
                            assert.is_nil(data:ServerGet("test"))
                        end)
                    end)

                    describe("when some chain fields are missing", function()
                        it("should return nil", function()
                            data.persist_data.servers[MasterSessionId] = nil
                            assert.is_nil(data:ServerGet("test"))
                            data.persist_data.servers = nil
                            assert.is_nil(data:ServerGet("test"))
                            data.persist_data = nil
                            assert.is_nil(data:ServerGet("test"))
                        end)
                    end)
                end)
            end)

            describe("when server doesn't exist", function()
                before_each(function()
                    data.dirty = false
                    data.persist_data = {
                        general = {},
                        servers = {},
                    }
                end)

                describe("GetServer()", function()
                    it("should set the server_id field", function()
                        data:GetServer()
                        assert.is_equal(MasterSessionId, data.server_id)
                    end)

                    it("should set dirty to true", function()
                        data:GetServer()
                        assert.is_true(data.dirty)
                    end)

                    it("should return empty server with default fields", function()
                        assert.is_same({
                            lastseen = time_current,
                            data = {},
                        }, data:GetServer())
                    end)

                    TestNilChainFields("GetServer")
                end)

                describe("GetServerLastSeen()", function()
                    it("should return the current time", function()
                        assert.is_equal(time_current, data:GetServerLastSeen())
                    end)

                    TestNilChainFields("GetServerLastSeen")
                end)

                describe("GetServerData()", function()
                    it("should return the server data", function()
                        assert.is_same({}, data:GetServerData())
                    end)

                    TestNilChainFields("GetServerData")
                end)

                describe("ServerRefreshLastSeen()", function()
                    it("should return true", function()
                        assert.is_true(data:ServerRefreshLastSeen())
                    end)

                    it("should add a server with default fields", function()
                        assert.is_nil(data.persist_data.servers[MasterSessionId])
                        data:ServerRefreshLastSeen()
                        assert.is_same({
                            lastseen = time_current,
                            data = {},
                        }, data.persist_data.servers[MasterSessionId])
                    end)

                    it("should set the dirty field to true", function()
                        data:ServerRefreshLastSeen()
                        assert.is_true(data.dirty)
                    end)

                    describe("when some chain fields are missing", function()
                        it("should return false", function()
                            data.persist_data.servers = nil
                            assert.is_false(data:ServerRefreshLastSeen())
                            data.persist_data = nil
                            assert.is_false(data:ServerRefreshLastSeen())
                        end)
                    end)
                end)

                describe("ServerSet()", function()
                    it("should call the Debug:DebugString()", function()
                        data:ServerSet("key", "value")
                        DebugSpyAssertWasCalled("DebugString", 1, {
                            "[data]",
                            "[set]",
                            "[" .. data.server_id .. "]",
                            "key:",
                            "value",
                        })
                    end)

                    it("should set dirty to true", function()
                        data:ServerSet("key", "value")
                        assert.is_true(data.dirty)
                    end)

                    it("should return true", function()
                        assert.is_true(data:ServerSet("key", "value"))
                    end)

                    describe("when some chain fields are missing", function()
                        it("should return false", function()
                            data.persist_data.servers = nil
                            assert.is_false(data:ServerSet("key", "value"))
                            data.persist_data = nil
                            assert.is_false(data:ServerSet("key", "value"))
                        end)
                    end)
                end)

                describe("ServerGet()", function()
                    it("should call the Debug:DebugString()", function()
                        data:ServerGet("test")
                        DebugSpyAssertWasCalled("DebugString", 1, {
                            "[data]",
                            "[get]",
                            "[error]",
                            "[" .. data.server_id .. "]",
                            "test",
                        })
                    end)

                    it("should return nil", function()
                        assert.is_nil(data:ServerGet("test"))
                    end)

                    describe("when some chain fields are missing", function()
                        it("should return nil", function()
                            data.persist_data.servers[MasterSessionId] = nil
                            assert.is_nil(data:ServerGet("test"))
                            data.persist_data.servers = nil
                            assert.is_nil(data:ServerGet("test"))
                            data.persist_data = nil
                            assert.is_nil(data:ServerGet("test"))
                        end)
                    end)
                end)
            end)
        end)
    end)
end)
