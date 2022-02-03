local M = {}

local notify = require("virtual-modes.utils.notify").notify
local virtual_modes

-- DEBUG
function M.reload()
	local list = {
		"virtual-modes",
		"virtual-modes.debug",
		"virtual-modes.validate",
		"virtual-modes.utils.notify",
	}
	for _, module in ipairs(list) do
		package.loaded[module] = nil
	end
	require("virtual-modes")
end

function M.print_names()
	notify("The recognized modes are:\n" .. vim.inspect(M.get_mode_names()), "debug")
end

function M.print_modes()
	notify("The mode settings are:\n" .. vim.inspect(virtual_modes.get_mode_configs()), "debug")
end

-- Set up test
function M.init_test(v_modes)
	virtual_modes = v_modes
	notify("Setting up virtual-modes!", "debug")
	virtual_modes.setup({
		on_enter = {
			function()
				notify("Entered mode " .. v_modes.get_virtual_mode())
			end,
		},
		on_exit = {
			function()
				notify("Exiting mode " .. v_modes.get_virtual_mode())
			end,
		},
		keymap_enter_prefix = "<leader>e",
		modes = {
			GIT = {
				keymap_enter = "g",
			},
			QUICKFIX = {
				keymap_enter = "q",
			},
			LOCATION = {
				keymap_enter = "l",
			},
			SPELL = {
				keymap_enter = "s",
			},
			TEST = {
				keymap_enter = "t",
			},
			NORD = {
				keymap_enter = "n",
				on_enter = {"colorscheme nord", "set nonumber", "set norelativenumber"},
				on_exit = {"colorscheme gruvbox", "set number", "set relativenumber"},
			},
		},
	})
	M.print_modes()
end

return M
