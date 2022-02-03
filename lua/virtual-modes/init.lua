local M = {}

local normal_mode = "NORMAL"
local current_mode = normal_mode
local virtual_modes = {}
local notify = require("virtual-modes.utils.notify").notify
local validate = require("virtual-modes.validate")
local global_defaults = {
	keymap_enter_prefix = "",
	enable_keymap_prefix = true,
	keymap_exit = "<esc>",
	on_enter = {
		function()
			notify("Entered mode " .. M.get_virtual_mode())
		end,
	},
	on_exit = {
		function()
			notify("Exiting mode " .. M.get_virtual_mode())
		end,
	},
}

-- Mode utility functions
-- TODO check if other modules can change the returned values. This would be unsafe!
-- Otherwise make local or move to other module.
function M.get_virtual_mode()
	return current_mode
end

function M.get_mode_configs()
	return virtual_modes
end

function M.mode_is_available(name)
	return virtual_modes[name] ~= nil
end

function M.get_mode_names()
	local names = {}
	for k, _ in pairs(virtual_modes) do
		table.insert(names, k)
	end
	return names
end

-- Execute vim command strings or lua functions.
-- Everything else gets ignored.
local function exec_string_or_function(value)
	if type(value) == "string" then
		vim.cmd(value)
	elseif type(value) == "function" then
		value()
	else
		notify("Type not allowed: " .. type(value), "debug")
	end
end

-- Execute vim command strings or lua functions, possible in a table.
-- Everything else gets ignored.
local function exec_string_or_function_table(value)
	if type(value) ~= "table" then
		exec_string_or_function(value)
	else
		for _, v in ipairs(value) do
			exec_string_or_function(v)
		end
	end
end

-- Add missing fields the default value.
local function add_defaults(mode_config)
	local c = mode_config
	local gd = global_defaults
	c.enable_keymap_prefix = c.enable_keymap_prefix or gd.enable_keymap_prefix
	c.keymap_enter = gd.keymap_enter_prefix .. c.keymap_enter -- TODO use enable_keymap_prefix
	c.on_enter = c.on_enter or gd.on_enter -- TODO both local and global
	c.on_exit = c.on_exit or gd.on_exit -- TODO both local and global
	return c
end

-- Add a mode. Overwrite if mode already exists.
local function add_mode(mode_config)
	mode_config = add_defaults(mode_config)
	local c = mode_config
	local name = c.name

	-- Actually declaring them makes sure no unrecognized fields get past
	virtual_modes[name] = {
		keymap_enter = c.keymap_enter,
		enable_keymap_prefix = c.enable_keymap_prefix,
		on_enter = c.on_enter,
		on_exit = c.on_exit,
	}

	-- Setting keymaps
	local opts = { noremap = true }
	vim.api.nvim_set_keymap("n", "<esc>", "<cmd>lua require('virtual-modes').exit_mode()<cr><esc>", opts)
	vim.api.nvim_set_keymap(
		"n",
		virtual_modes[name].keymap_enter,
		"<cmd>lua require('virtual-modes').enter_mode('" .. name .. "')<cr>",
		opts
	)
end

-- Remove a mode, if it exists.
function M.remove_mode(name)
	-- TODO check if name is key? What if name is table or nil..
	virtual_modes[name] = nil
end

function M.enter_mode(name)
	if not type(name) == "string" then
		notify("Mode should be a string.", "warn")
	elseif not M.mode_is_available(name) then
		notify("Mode '" .. name .. "' is not recognized.", "warn")
	elseif current_mode ~= name then
		if current_mode ~= normal_mode then
			M.exit_mode()
		end
		current_mode = name
		exec_string_or_function_table(virtual_modes[name].on_enter)
		-- set_keymaps(name)
	end
end

function M.exit_mode()
	if current_mode ~= normal_mode then
		exec_string_or_function_table(virtual_modes[current_mode].on_exit)
		current_mode = normal_mode
	end
end

function M.setup(config)
	-- TODO validate input: on_* should be table
	if not validate.is_config(config) then
		validate.print_config_warning(config)
	else
		-- Change global defaults
		local gd = global_defaults
		gd.keymap_enter_prefix = config.keymap_enter_prefix or gd.keymap_enter_prefix
		gd.enable_keymap_prefix = config.enable_keymap_prefix or gd.enable_keymap_prefix
		gd.on_enter = config.on_enter or gd.on_enter
		gd.on_exit = config.on_exit or gd.on_exit

		-- Add all modes
		local modes = config.modes or {}
		for name, mode in pairs(modes) do
			mode.name = mode.name or name -- Use key if name is not set.
			add_mode(mode)
		end
	end
end

require("virtual-modes.debug").init_test(M)

return M
