require "busted.runner"()

describe("WorldSaveDataTools", function()
    -- initialization
    local devtools, worldtools
    local WorldSaveDataTools, worldsavedatatools

    setup(function()
        DebugSpyInit()
    end)

    teardown(function()
        -- debug
        DebugSpyTerm()

        -- globals
        _G.TheSim = nil
    end)

    before_each(function()
        -- globals
        _G.TheSim = MockTheSim()

        -- initialization
        devtools = MockDevTools()
        worldtools = MockWorldTools()

        WorldSaveDataTools = require "devtools/tools/worldsavedatatools"
        worldsavedatatools = WorldSaveDataTools(worldtools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()

            -- initialization
            WorldSaveDataTools = require "devtools/tools/worldsavedatatools"
        end)

        local function AssertDefaults(self)
            assert.is_equal("WorldSaveDataTools", self.name)
            assert.is_equal(devtools, self.devtools)

            -- general
            assert.is_equal(worldsavedatatools.inst, self.inst)
            assert.is_equal(worldtools, self.worldtools)

            -- walrus camps
            assert.is_equal(3, self.nr_of_walrus_camps)
        end

        describe("using the constructor", function()
            before_each(function()
                worldsavedatatools = WorldSaveDataTools(worldtools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(worldsavedatatools)
            end)
        end)

        it("should add DevTools methods", function()
            local methods = {
                -- general
                GetSaveDataPath = "GetPath",
                GetSaveData = "GetSaveData",
                GetSaveDataMapPersistData = "GetMapPersistData",
                GetSaveDataMeta = "GetMeta",
                GetSaveDataSeed = "GetSeed",
                GetSaveDataVersion = "GetVersion",
                LoadSaveData = "Load",

                -- walrus camps
                "GuessNrOfWalrusCamps",
                "GetNrOfWalrusCamps",
            }

            AssertAddedMethodsBefore(methods, devtools)
            worldsavedatatools = WorldSaveDataTools(worldtools, devtools)
            AssertAddedMethodsAfter(methods, worldsavedatatools, devtools)
        end)
    end)
end)
