local validate = require("virtual-modes.input.validate")

describe("validate", function()
	describe("_is_executable", function()
		local _is_executable = validate._is_executable
		local test_function1 = function() end
		local test_function2 = function() end

		it("should block nil", function()
			assert.equals(false, _is_executable(nil))
		end)

		it("should block booleans", function()
			assert.equals(false, _is_executable(false))
			assert.equals(false, _is_executable(true))
		end)

		it("should block numbers", function()
			assert.equals(false, _is_executable(0))
			assert.equals(false, _is_executable(-1))
			assert.equals(false, _is_executable(1))
		end)

		it("should let strings through", function()
			assert.equals(true, _is_executable(""))
			assert.equals(true, _is_executable("test"))
		end)

		it("should let functions through", function()
			assert.equals(true, _is_executable(test_function1))
		end)

		it("should let the empty tables through", function()
			assert.equals(true, _is_executable({}))
		end)

		it("should let tables with one strings through", function()
			assert.equals(true, _is_executable({ "test" }))
			assert.equals(true, _is_executable({ test = "test" }))
		end)

		it("should let tables with multiple strings through", function()
			assert.equals(true, _is_executable({ "test1", "test2" }))
			assert.equals(true, _is_executable({ "test1", test2 = "test2" }))
			assert.equals(true, _is_executable({ test1 = "test1", test2 = "test2" }))
		end)

		it("should let tables with one function through", function()
			assert.equals(true, _is_executable({ test_function1 }))
			assert.equals(true, _is_executable({ test = test_function1 }))
		end)

		it("should let tables with multiple functions through", function()
			assert.equals(true, _is_executable({ test_function1, test_function2 }))
			assert.equals(true, _is_executable({ test_function1, test2 = test_function2 }))
			assert.equals(true, _is_executable({ test1 = test_function1, test2 = test_function2 }))
		end)

		it("should let tables with strings and functions through", function()
			assert.equals(true, _is_executable({ "test", test_function1 }))
		end)

		it("should block tables with booleans", function()
			assert.equals(false, _is_executable({ "test", test_function1, true }))
		end)

		it("should block tables with numbers", function()
			assert.equals(false, _is_executable({ "test", test_function1, 1 }))
		end)

		it("should block tables with tables", function()
			assert.equals(false, _is_executable({ "test", test_function1, {} }))
		end)
	end)

	describe("_is_keymap", function()
		local _is_keymap = validate._is_keymap
		it("should block non-table values", function()
			assert.equals(false, _is_keymap(nil))
			assert.equals(false, _is_keymap(true))
			assert.equals(false, _is_keymap(1))
			assert.equals(false, _is_keymap("test"))
			assert.equals(false, _is_keymap(function() end))
		end)

		it("should let keymap arguments without options through", function()
			assert.equals(true, _is_keymap({ "n", "lhs", "rhs" }))
			assert.equals(true, _is_keymap({ "", "", "" }))
		end)

		it("should let keymap arguments with options through", function()
			assert.equals(true, _is_keymap({ "n", "lhs", "rhs", { noremap = true } }))
			assert.equals(true, _is_keymap({ "", "", "", {} }))
		end)

		it("should block non keymap argument tables", function()
			assert.equals(false, _is_keymap({ "n" }))
			assert.equals(false, _is_keymap({ 0, "", "", {} }))
			assert.equals(false, _is_keymap({ "", 0, "", {} }))
			assert.equals(false, _is_keymap({ "", "", 0, {} }))
			assert.equals(false, _is_keymap({ "", "", "", 0 }))
		end)
	end)
end)
