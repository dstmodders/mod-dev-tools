require "busted.runner"()

describe("SaveDataDevTools", function()
    -- initialization
    local devtools, worlddevtools
    local SaveDataDevTools, savedatadevtools

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
        worlddevtools = MockWorldDevTools()

        SaveDataDevTools = require "devtools/devtools/world/savedatadevtools"
        savedatadevtools = SaveDataDevTools(worlddevtools, devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()

            -- initialization
            SaveDataDevTools = require "devtools/devtools/world/savedatadevtools"
        end)

        local function AssertDefaults(self)
            assert.is_equal("SaveDataDevTools", self.name)
            assert.is_equal(devtools, self.devtools)

            -- general
            assert.is_equal(savedatadevtools.inst, self.inst)
            assert.is_equal(worlddevtools, self.worlddevtools)

            -- walrus camps
            assert.is_equal(3, self.nr_of_walrus_camps)
        end

        describe("using the constructor", function()
            before_each(function()
                savedatadevtools = SaveDataDevTools(worlddevtools, devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(savedatadevtools)
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
            savedatadevtools = SaveDataDevTools(worlddevtools, devtools)
            AssertAddedMethodsAfter(methods, savedatadevtools, devtools)
        end)
    end)
end)
