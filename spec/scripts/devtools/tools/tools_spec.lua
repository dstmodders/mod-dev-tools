require("busted.runner")()

describe("Tools", function()
    -- initialization
    local devtools
    local Tools, tools

    setup(function()
        DebugSpyInit()
    end)

    teardown(function()
        DebugSpyTerm()
    end)

    before_each(function()
        -- initialization
        devtools = MockDevTools()

        Tools = require("devtools/tools/tools")
        tools = Tools("Test", devtools)

        DebugSpyClear()
    end)

    insulate("initialization", function()
        before_each(function()
            -- general
            devtools = MockDevTools()

            -- initialization
            Tools = require("devtools/tools/tools")
        end)

        local function AssertDefaults(self)
            -- general
            assert.is_equal(devtools, self.devtools)
            assert.is_equal("Test", self.name)
        end

        describe("using the constructor", function()
            before_each(function()
                tools = Tools("Test", devtools)
            end)

            it("should have the default fields", function()
                AssertDefaults(tools)
            end)
        end)
    end)

    describe("general", function()
        describe("should have the", function()
            describe("getter", function()
                it("GetName", function()
                    AssertClassGetter(tools, "name", "GetName")
                end)
            end)
        end)
    end)
end)
