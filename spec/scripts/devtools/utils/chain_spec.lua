require("busted.runner")()
require("class")
require("devtools/utils")

describe("Utils.Entity", function()
    -- setup
    local match

    -- before_each initialization
    local Chain
    local value, netvar, GetTimeUntilPhase, clock, TheWorld

    setup(function()
        match = require("luassert.match")
    end)

    before_each(function()
        -- initialization
        Chain = require("devtools/utils/chain")

        value = 42
        netvar = { value = spy.new(ReturnValueFn(value)) }
        GetTimeUntilPhase = spy.new(ReturnValueFn(value))

        clock = {
            boolean = true,
            fn = ReturnValueFn(value),
            netvar = netvar,
            number = 1,
            string = "test",
            table = {},
            GetTimeUntilPhase = GetTimeUntilPhase,
        }

        TheWorld = {
            net = {
                components = {
                    clock = clock,
                },
            },
        }
    end)

    describe("ChainGet", function()
        describe("when an invalid src is passed", function()
            it("should return nil", function()
                assert.is_nil(Chain.Get(nil, "net"))
                assert.is_nil(Chain.Get("nil", "net"))
                assert.is_nil(Chain.Get(42, "net"))
                assert.is_nil(Chain.Get(true, "net"))
            end)
        end)

        describe("when some chain fields are missing", function()
            it("should return nil", function()
                AssertChainNil(function()
                    assert.is_nil(
                        Chain.Get(TheWorld, "net", "components", "clock", "GetTimeUntilPhase")
                    )
                end, TheWorld, "net", "components", "clock", "GetTimeUntilPhase")
            end)
        end)

        describe("when the last parameter is true", function()
            it("should return the last field call (function)", function()
                assert.is_equal(
                    value,
                    Chain.Get(TheWorld, "net", "components", "clock", "fn", true)
                )
            end)

            it("should return the last field call (table as a function)", function()
                assert.is_equal(
                    value,
                    Chain.Get(TheWorld, "net", "components", "clock", "GetTimeUntilPhase", true)
                )

                assert.spy(GetTimeUntilPhase).was_called(1)
                assert.spy(GetTimeUntilPhase).was_called_with(match.is_ref(clock))
            end)

            it("should return the last netvar value", function()
                assert.is_equal(
                    value,
                    Chain.Get(TheWorld, "net", "components", "clock", "netvar", true)
                )

                assert.spy(netvar.value).was_called(1)
                assert.spy(netvar.value).was_called_with(match.is_ref(netvar))
            end)

            local fields = {
                "boolean",
                "number",
                "string",
                "table",
            }

            for _, field in pairs(fields) do
                describe("and the previous parameter is a " .. field, function()
                    it("should return nil", function()
                        assert.is_nil(
                            Chain.Get(TheWorld, "net", "components", "clock", field, true),
                            field
                        )
                    end)
                end)
            end

            describe("and the previous parameter is a nil", function()
                it("should return nil", function()
                    assert.is_nil(Chain.Get(TheWorld, "net", "components", "test", true))
                end)
            end)
        end)

        it("should return the last field", function()
            assert.is_equal(
                GetTimeUntilPhase,
                Chain.Get(TheWorld, "net", "components", "clock", "GetTimeUntilPhase")
            )

            assert.spy(GetTimeUntilPhase).was_not_called()
        end)
    end)

    describe("ChainValidate", function()
        describe("when an invalid src is passed", function()
            it("should return false", function()
                assert.is_false(Chain.Validate(nil, "net"))
                assert.is_false(Chain.Validate("nil", "net"))
                assert.is_false(Chain.Validate(42, "net"))
                assert.is_false(Chain.Validate(true, "net"))
            end)
        end)

        describe("when some chain fields are missing", function()
            it("should return false", function()
                AssertChainNil(function()
                    assert.is_false(
                        Chain.Validate(TheWorld, "net", "components", "clock", "GetTimeUntilPhase")
                    )
                end, TheWorld, "net", "components", "clock", "GetTimeUntilPhase")
            end)
        end)

        describe("when all chain fields are available", function()
            it("should return true", function()
                assert.is_true(
                    Chain.Validate(TheWorld, "net", "components", "clock", "GetTimeUntilPhase")
                )
            end)
        end)
    end)
end)
