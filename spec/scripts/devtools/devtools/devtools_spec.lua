require "busted.runner"()

describe("DevTools", function()
    -- initialization
    local _devtools
    local DevTools, devtools

    setup(function()
        DebugSpyInit()
    end)

    teardown(function()
        DebugSpyTerm()
    end)

    before_each(function()
        -- initialization
        _devtools = MockDevTools()

        DevTools = require "devtools/devtools/devtools"
        devtools = DevTools("Test", _devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            _devtools = MockDevTools()

            -- initialization
            DevTools = require "devtools/devtools/devtools"
        end)

        local function AssertDefaults(self)
            -- general
            assert.is_equal(_devtools, self.devtools)
            assert.is_equal("Test", self.name)
        end

        describe("using the constructor", function()
            before_each(function()
                devtools = DevTools("Test", _devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(devtools)
            end)
        end)
    end)

    describe("general", function()
        describe("should have the", function()
            describe("getter", function()
                it("GetName", function()
                    AssertClassGetter(devtools, "name", "GetName")
                end)
            end)
        end)
    end)
end)
