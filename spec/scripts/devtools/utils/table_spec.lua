require("busted.runner")()
require("class")
require("devtools/utils")

describe("Utils.Table", function()
    -- before_each initialization
    local Table

    before_each(function()
        Table = require("devtools/utils/table")
    end)

    describe("TableCompare", function()
        it("should return true when both tables have the same reference", function()
            local test = {}
            assert.is_true(Table.Compare(test, test))
        end)

        it("should return true when both tables with nested ones are the same", function()
            local first = { first = {}, second = { third = {} } }
            local second = { first = {}, second = { third = {} } }
            assert.is_true(Table.Compare(first, second))
        end)

        it("should return false when one of the tables is nil", function()
            local test = {}
            assert.is_false(Table.Compare(nil, test))
            assert.is_false(Table.Compare(test, nil))
        end)

        it("should return false when one of the tables is not a table type", function()
            local test = {}
            assert.is_false(Table.Compare("table", test))
            assert.is_false(Table.Compare(test, "table"))
        end)

        it("should return false when both tables with nested ones are not the same", function()
            local first = { first = {}, second = { third = {} } }
            local second = { first = {}, second = { third = { "fourth" } } }
            assert.is_false(Table.Compare(first, second))
        end)
    end)

    describe("TableCount", function()
        it("should return false when the passed parameter is not a table", function()
            assert.is_false(Table.Count("test"))
        end)

        describe("in the table with default indexes", function()
            it("should count the number of elements", function()
                local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                assert.is_equal(5, Table.Count(test))
            end)
        end)

        describe("in the table with custom indexes", function()
            it("should count the number of elements", function()
                local test = { 1, 2, 3, 4, 5 }
                assert.is_equal(5, Table.Count(test))
            end)
        end)
    end)

    describe("TableHasValue", function()
        it("should return false when the passed parameter is not a table", function()
            assert.is_false(Table.HasValue("test"))
        end)

        describe("in the table with default indexes", function()
            it("should return true when the element is in the table", function()
                local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                assert.is_true(Table.HasValue(test, 3))
            end)

            it("should return false when the element is not in the table", function()
                local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                assert.is_false(Table.HasValue(test, 6))
            end)
        end)

        describe("in the table with custom indexes", function()
            it("should return true when the element is in the table", function()
                local test = { 1, 2, 3, 4, 5 }
                assert.is_true(Table.HasValue(test, 3))
            end)

            it("should return false when the element is not in the table", function()
                local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
                assert.is_false(Table.HasValue(test, 6))
            end)
        end)
    end)

    describe("TableKeyByValue", function()
        it("should return false when the passed parameter is not a table", function()
            assert.is_false(Table.KeyByValue("test"))
        end)

        it("should return the key when the valid table and value passed", function()
            local test = { one = 1, two = 2, three = 3, four = 4, five = 5 }
            assert.is_equal("two", Table.KeyByValue(test, 2))
        end)
    end)

    describe("TableMerge", function()
        it("should return two combined simple tables", function()
            local a = { a = "a", b = "b", c = "c" }
            local b = { d = "d", e = "e", a = "f" }
            assert.is_same({ a = "f", b = "b", c = "c", d = "d", e = "e" }, Table.Merge(a, b))
        end)

        it("should return two combined simple ipaired tables", function()
            local a = { "a", "b", "c" }
            local b = { "d", "e", "f" }
            assert.is_same({ "a", "b", "c", "d", "e", "f" }, Table.Merge(a, b))
        end)
    end)

    describe("TableNextValue", function()
        it("should return the next value", function()
            local t = { "a", "b", "c" }
            assert.is_equal("c", Table.NextValue(t, "b"))
        end)

        it("should return the first value when there is no next one", function()
            local t = { "a", "b", "c" }
            assert.is_equal("a", Table.NextValue(t, "c"))
        end)
    end)

    describe("TableSortAlphabetically", function()
        it("should return false when the passed parameter is not a table", function()
            assert.is_false(Table.SortAlphabetically("test"))
        end)

        it("should return true when both tables with nested ones are the same", function()
            local test = { "one", "two", "three", "four", "five" }
            local expected = { "five", "four", "one", "three", "two" }
            local result = Table.SortAlphabetically(test)

            assert.is_equal(#expected, #result)
            for k, v in pairs(result) do
                assert.is_equal(expected[k], v)
            end
        end)
    end)
end)
