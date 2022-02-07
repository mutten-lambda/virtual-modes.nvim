local M = {}

local normal_mode = "NORMAL"
local current_mode = normal_mode
local virtual_modes = {}
local global_settings = {}

local notify = require("virtual-modes.utils.notify").notify
local validate = require("virtual-modes.validate")

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

local function combine_executables(list)
	local executables = {}
	for _, value in ipairs(list) do
		if type(value) == "table" then
			for _, element in ipairs(value) do
				executables[#executables + 1] = element
			end
		else
			executables[#executables + 1] = value
		end
	end
	return executables
end

local function add_general_defaults(config)
	local c = config
	local gs = global_settings
	c.enable_keymap_prefix = c.enable_keymap_prefix or gs.enable_keymap_prefix
	c.keymaps = combine_executables({
		gs.keymaps,
		c.keymaps,
	})
	c.on_enter = combine_executables({
		gs.on_enter,
		c.on_enter,
		--[[ keymaps, ]]
	})
	c.on_exit = combine_executables({
		gs.on_exit,
		c.on_exit,
		--[[ keymaps, ]]
	})
	return c
end

-- Add missing fields the default value.
local function apply_settings(mode_config)
	local c = add_general_defaults(mode_config)
	local gs = global_settings

	-- Construct keymap_enter
	local prefix = ""
	if c.enable_keymap_prefix then
		prefix = gs.keymap_enter_prefix
	end
	c.keymap_enter = prefix .. c.keymap_enter

	return c
end

local function add_global_defaults(config)
	local c = add_general_defaults(config)
	local gd = require("virtual-modes.defaults").get_defaults()
	c.keymap_enter_prefix = c.keymap_enter_prefix or gd.keymap_enter_prefix
	c.enable_keymap_prefix = c.enable_keymap_prefix or gd.enable_keymap_prefix
	return c
end

-- Add a mode. Overwrite if mode already exists.
local function add_mode(mode_config)
	mode_config = apply_settings(mode_config)
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
	if not validate.is_config(config) then
		validate.print_config_warning(config)
	else
		-- Change global defaults
		global_settings = add_global_defaults(config)

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
