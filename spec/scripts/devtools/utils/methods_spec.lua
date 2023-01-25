require("busted.runner")()
require("class")
require("devtools/utils")

describe("Utils.Entity", function()
    -- before_each initialization
    local Methods

    before_each(function()
        Methods = require("devtools/utils/methods")
    end)

    describe("AddMethodsToAnotherClass", function()
        local TestClassDestination, TestClassSource
        local src, dest

        setup(function()
            TestClassDestination = Class(function() end)

            TestClassSource = Class(function(self)
                self.test = true
            end)

            function TestClassSource:TestOne(value)
                return value, self.test
            end

            function TestClassSource:TestTwo()
                return self
            end

            -- luacheck: no unused args
            function TestClassSource:TestThree(value)
                return value
            end
            -- luacheck: unused args
        end)

        local TestBeforeAfter = function()
            assert.is_not_nil(src.TestOne)
            assert.is_not_nil(src.TestTwo)
            assert.is_not_nil(src.TestThree)

            local value, test = src:TestOne("test")
            assert.is_equal("test", value)
            assert.is_true(test)

            assert.is_equal(src, src:TestTwo())

            assert.is_equal("test", src:TestThree("test"))
        end

        before_each(function()
            src = TestClassSource()
            dest = TestClassDestination()
            TestBeforeAfter()
        end)

        after_each(function()
            TestBeforeAfter()
        end)

        describe("should add class functions from one class to another", function()
            it("when no destination names provided", function()
                assert.is_nil(dest.TestOne)
                assert.is_nil(dest.TestTwo)
                assert.is_nil(dest.TestThree)

                Methods.AddToAnotherClass(src, dest, {
                    "TestOne",
                    "TestTwo",
                    "TestThree",
                })

                local value, test = dest:TestOne("test")
                assert.is_equal("test", value)
                assert.is_true(test)

                assert.is_equal(src, dest:TestTwo())
            end)

            it("when destination names provided", function()
                assert.is_nil(dest.NewTestOne)
                assert.is_nil(dest.TestTwo)
                assert.is_nil(dest.TestThree)

                Methods.AddToAnotherClass(src, dest, {
                    NewTestOne = "TestOne",
                    "TestTwo",
                    "TestThree",
                })

                local value, test = dest:NewTestOne("test")
                assert.is_equal("test", value)
                assert.is_true(test)

                assert.is_equal(src, dest:TestTwo())
                assert.is_equal("test", dest:TestThree("test"))
            end)
        end)
    end)
end)
