describe("virtual-modes", function()
	local vm = require("virtual-modes")

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
	local global_enter_target = false
	local global_exit_target = false
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
	local global_on_enter = function()
		global_enter_target = true
	end
	local global_on_exit = function()
		global_exit_target = true
	end

	local test_mode
	local test_config

	before_each(function()
		test_mode = {
			name = name,
			keymap_enter = keymap_enter,
			keymap_exit = keymap_exit,
			on_enter = modal_on_enter,
			on_exit = modal_on_exit,
		}

		test_config = {
			global = {
				on_enter = global_on_enter,
				on_exit = global_on_exit,
			},
			modes = { test_mode },
		}

		target = false
		modal_enter_target = false
		modal_exit_target = false
		global_enter_target = false
		global_exit_target = false

		test_group = vim.api.nvim_create_augroup("Test", { clear = true })
	end)

	after_each(function ()
		vm._clear()
	end)

	describe("setup", function()
		it("should add the modes", function()
			vm.setup(test_config)
			assert.is_true(vm.is_mode_setup(name))
		end)

		it("should register the global on_enter handler", function()
			vm.setup(test_config)
			vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesEnter" })
			assert.is_true(global_enter_target)
		end)

		it("should register the global on_exit handler", function()
			vm.setup(test_config)
			vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesExit" })
			assert.is_true(global_exit_target)
		end)
	end)
end)
