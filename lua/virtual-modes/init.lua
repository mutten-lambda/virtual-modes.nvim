local M = {}

local normal_mode = "NORMAL"
local current_mode = normal_mode
local virtual_modes = {}
local notify = require("virtual-modes.utils.notify").notify
local global_defaults = {
	keymap_enter_prefix = "",
	keymap_exit = "<esc>",
	on_enter = function()
		notify("Entered mode " .. M.get_virtual_mode())
	end,
	on_exit = function()
		notify("Exiting mode " .. M.get_virtual_mode())
	end,
}

local function init()
	notify("Setting up virtual-modes!", "debug")
	M.setup({
		keymap_enter_prefix = "<leader>e",
		modes = {
			GIT = {
				keymap_enter = "g",
			},
			TEST = {
				keymap_enter = "t",
			},
		},
	})
	M.print_modes()
end

-- DEBUG
function M.reload()
	package.loaded["virtual-modes"] = nil
	require("virtual-modes")
end

function M.print_names()
	vim.notify("The recognized modes are:\n" .. vim.inspect(M.get_mode_names()), "debug")
end

function M.print_modes()
	vim.notify("The mode settings are:\n" .. vim.inspect(virtual_modes), "debug")
end

-- Mode utility functions
function M.get_virtual_mode()
	return current_mode
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

local function is_table(value)
	return type(value) == "table"
end

local function is_bool(value)
	return type(value) == "boolean"
end

local function is_string(value)
	return type(value) == "string"
end

local function is_function(value)
	return type(value) == "function"
end

local function is_string_or_function(value)
	return type(value) == "string" or type(value) == "function"
end

-- Execute vim command strings or lua functions.
-- Everything else gets ignored.
local function exec_string_or_function(value)
	if is_string(value) then
		vim.cmd(value)
	elseif is_function(value) then
		value()
	else
		notify("Type not allowed: " .. type(value), "debug")
	end
end

local function is_valid_mode_config(mode_config)
	local c = mode_config
	return is_string(c.name)
		and c.name ~= normal_mode
		and is_string(c.keymap_enter)
		and is_string_or_function(c.on_enter)
		and is_string_or_function(c.on_exit)
end

local function add_defaults(mode_config)
	local c = mode_config
	c.keymap_enter = global_defaults.keymap_enter_prefix .. c.keymap_enter
	c.on_enter = c.on_enter or global_defaults.on_enter -- TODO both local and global
	c.on_exit = c.on_exit or global_defaults.on_exit -- TODO both local and global
	return c
end

local function print_mode_config_warning(mode_config)
	local c = mode_config
	if not is_string(c.name) then
		notify("Mode should have a name.", "warn")
	elseif c.name == normal_mode then
		notify("Mode cannot be named '" .. normal_mode .. "'.", "warn")
	elseif not is_string(c.keymap_enter) then
		notify("Field keymap_enter must be a string, not: " .. type(c.keymap_enter), "warn")
	elseif not is_string_or_function(c.on_enter) then
		notify("Field 'on_enter' must be a string or lua function, not: " .. type(c.on_enter), "warn")
	elseif not is_string_or_function(c.on_exit) then
		notify("Field 'on_exit' must be a string or lua function, not: " .. type(c.on_exit), "warn")
	end
end
-- Add a mode. Overwrite if mode already exists.
function M.add_mode(mode_config)
	mode_config = add_defaults(mode_config)
	if not is_valid_mode_config(mode_config) then
		print_mode_config_warning(mode_config)
	else
		local c = mode_config
		local name = c.name
		-- Actually declaring them makes sure no unrecognized fields get past
		virtual_modes[name] = {
			keymap_enter = c.keymap_enter,
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
end

-- Remove a mode, if it exists.
function M.remove_mode(name)
	-- TODO check if name is key? What if name is table or nil..
	virtual_modes[name] = nil
end

function M.enter_mode(name)
	if not is_string(name) then
		notify("Mode should be a string.", "warn")
	elseif not M.mode_is_available(name) then
		notify("Mode '" .. name .. "' is not recognized.", "warn")
	elseif current_mode ~= name then
		if current_mode ~= normal_mode then
			M.exit_mode()
		end
		current_mode = name
		exec_string_or_function(virtual_modes[name].on_enter)
		-- set_keymaps(name)
	end
end

function M.exit_mode()
	if current_mode ~= normal_mode then
		exec_string_or_function(virtual_modes[current_mode].on_exit)
		current_mode = normal_mode
	end
end

function M.setup(config)
	-- Change global defaults
	global_defaults.keymap_enter_prefix = config.keymap_enter_prefix or global_defaults.keymap_enter_prefix

	-- Add all modes
	local modes = config.modes or {}
	if not is_table(modes) then
		notify("Field 'modes' should be a table, not: " .. type(table), "warn")
	else
		for name, mode in pairs(modes) do
			mode.name = mode.name or name -- Use key if name is not set.
			M.add_mode(mode)
		end
	end
end

init()

return M
