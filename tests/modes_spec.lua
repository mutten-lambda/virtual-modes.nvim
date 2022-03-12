describe("modes", function()
	local modes = require("virtual-modes.modes")

	local function get_keymap(mode, lhs)
		local keymaps = vim.api.nvim_get_keymap(mode)
		for _, k in ipairs(keymaps) do
			if k.lhs == lhs then
				return k
			end
		end
	end

	local target = false
	local modal_enter_target = false
	local modal_exit_target = false
	local test_group = vim.api.nvim_create_augroup("Test", { clear = true })

	local name = "TEST"
	local keymap_enter = ",et"
	local keymap_exit = "<Esc>"
	local modal_on_enter = function()
		modal_enter_target = true
	end
	local modal_on_exit = function()
		modal_exit_target = true
	end
	local test_mode = {
		name = name,
		keymap_enter = keymap_enter,
		keymap_exit = keymap_exit,
		on_enter = modal_on_enter,
		on_exit = modal_on_exit,
	}

	before_each(function()
		target = false
		modal_enter_target = false
		modal_exit_target = false
		test_group = vim.api.nvim_create_augroup("Test", { clear = true })
		modes.add_mode(test_mode)
	end)

	after_each(function()
		modes._clear()
	end)

	describe("is_mode", function()
		it("should recognize an existing mode", function()
			assert.is_true(modes.is_mode(name))
		end)

		it("should not recognize a non-existing mode", function()
			assert.is_false(modes.is_mode("non-existing"))
		end)
	end)

	describe("add_mode", function()
		it("should add a mode", function()
			assert.is_true(modes.is_mode(name))
		end)

		it("should register the modal on_enter handler", function()
			vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesEnter" .. name })
			assert.is_true(modal_enter_target)
		end)

		it("should register the modal on_exit handler", function()
			vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesExit" .. name })
			assert.is_true(modal_exit_target)
		end)

		it("should add a keymap to enter", function()
			assert.truthy(get_keymap("n", keymap_enter))
		end)

		it("should add a keymap to exit", function()
			assert.truthy(get_keymap("n", keymap_exit))
		end)
	end)

	-- describe("del_mode", function()
	-- 	it("should delete a mode", function()
	-- 		vm.del_mode(name)
	-- 		assert.is_false(vm.is_mode_setup(name))
	-- 	end)
	--
	-- 	it("should deregister the modal on_enter handler", function()
	-- 		vm.del_mode(name)
	-- 		vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesEnter" .. name })
	-- 		assert.is_false(modal_enter_target)
	-- 	end)
	--
	-- 	it("should deregister the modal on_exit handler", function()
	-- 		vm.del_mode(name)
	-- 		vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesExit" .. name })
	-- 		assert.is_false(modal_exit_target)
	-- 	end)
	--
	-- 	it("should delete a keymap to enter", function()
	-- 		assert.falsy(get_keymap("n", keymap_enter))
	-- 	end)
	--
	-- 	-- it("should add a keymap to exit", function()
	-- 	-- 	assert.truthy(get_keymap("n", keymap_exit))
	-- 	-- end)
	-- end)

	describe("enter_mode", function()
		it("should update the current mode", function()
			modes.enter_mode(name)
			assert.equals(name, modes.get_current_mode())
		end)

		it("should trigger the modal enter autocommand", function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VirtualModesEnter" .. name,
				callback = function()
					target = true
				end,
				group = test_group,
			})
			modes.enter_mode(name)
			assert.is_true(target)
		end)

		it("should trigger the global enter autocommand", function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VirtualModesEnter",
				callback = function()
					target = true
				end,
				group = test_group,
			})
			modes.enter_mode(name)
			assert.is_true(target)
		end)

		it("should do nothing when trying to enter the same virtual mode", function()
			modes.exit_mode()
			assert.is_false(modal_enter_target)
		end)
	end)

	describe("exit_mode", function()
		it("should update the current mode", function()
			modes.enter_mode(name)
			modes.exit_mode()
			assert.equals("", modes.get_current_mode())
		end)

		it("should trigger the modal exit autocommand", function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VirtualModesExit" .. name,
				callback = function()
					target = true
				end,
				group = test_group,
			})
			modes.enter_mode(name)
			modes.exit_mode()
			assert.is_true(target)
		end)

		it("should trigger the global exit autocommand", function()
			vim.api.nvim_create_autocmd("User", {
				pattern = "VirtualModesExit",
				callback = function()
					target = true
				end,
				group = test_group,
			})
			modes.enter_mode(name)
			modes.exit_mode()
			assert.is_true(target)
		end)

		it("should do nothing when no virtual mode is active", function()
			modes.exit_mode()
			assert.is_false(modal_exit_target)
		end)
	end)
end)
