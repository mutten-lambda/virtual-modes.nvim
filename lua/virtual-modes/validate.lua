local M = {}

local normal_mode = "NORMAL" -- TODO fix code duplication (see init.lua)
local notify = require("virtual-modes.utils.notify").notify

-- Validating functions
local function is_bool(value)
	return type(value) == "boolean"
end

local function is_string(value)
	return type(value) == "string"
end

local function is_simple_executable(value)
	return type(value) == "string" or type(value) == "function"
end

local function is_table_of_executables(value)
	local result = true
	if type(value) ~= "table" then
		result = false
	else
		for _, v in ipairs(value) do
			result = result and is_simple_executable(v)
		end
	end
	return result
end

local function is_executable(value)
	return is_simple_executable(value) or is_table_of_executables(value)
end

local function is_keymap(value)
	local result = true
	-- TODO add check
	return result
end

local function is_table_of_keymaps(value)
	local result = true
	if type(value) ~= "table" then
		result = false
	else
		for _, v in ipairs(value) do
			result = result and is_keymap(v)
		end
	end
	return result
end
local is_valid = {
	name = is_string,
	keymap_enter = is_string,
	keymap_enter_prefix = is_string,
	enable_keymap_prefix = is_bool,
	on_enter = is_executable,
	on_exit = is_executable,
	modes = nil, -- cannot be set yet since the defining function uses the is_valid table
	keymaps = is_table_of_keymaps
}

-- TODO make local
function M.is_mode(mode_config)
	local result = false
	if type(mode_config) == "table" then
		result = true
		for key, value in pairs(mode_config) do
			if type(is_valid[key]) == "function" then
				result = result and is_valid[key](value)
			else
				notify("Expected a function to validate " .. key .. ", but got: " .. type(is_valid[key]), "debug")
			end
		end
	end
	return result
end

local function is_table_of_modes(value)
	local result = false
	if type(value) == "table" then
		result = true
		for _, mode_config in pairs(value) do
			result = result and M.is_mode(mode_config)
		end
	end
	return result
end

is_valid.modes = is_table_of_modes -- Complete table
-- M.is_mode_config = is_mode

-- Verify type constraints. Unknown keys are ignored.
function M.is_config(config)
	local result = false
	if type(config) == "table" then
		result = true
		for key, value in pairs(config) do
			if type(is_valid[key]) == "function" then
				result = result and is_valid[key](value)
			else
				notify("Expected a function to validate " .. key .. ", but got: " .. type(is_valid[key]), "debug")
			end
		end
	end
	return result
end

-- Print functions
local function should_be_type(t, key, value)
	notify("Field '" .. key .. "' must be a " .. t .. ".\nGot a: " .. type(value) .. ".", "warn")
end

local function should_be_string(key, value)
	should_be_type("string", key, value)
end

local function should_be_name(key, value)
	if not is_string(value) then
		should_be_string(key, value)
	elseif value == normal_mode then
		notify("Mode cannot be named '" .. normal_mode .. "'.", "warn")
	end
end

local function should_be_bool(key, value)
	should_be_type("boolean", key, value)
end

local function should_be_executable(key, value)
	notify(
		"Field '"
			.. key
			.. "' must be a string, a lua function or table containing strings and/or lua functions.\nGot a: "
			.. type(value)
			.. ".",
		"warn"
	)
	notify(key .. ":\n".. vim.inspect(value), "debug")
end

local print_warning = {
	name = should_be_name,
	keymap_enter = should_be_string,
	keymap_enter_prefix = should_be_string,
	enable_keymap_prefix = should_be_bool,
	on_enter = should_be_executable,
	on_exit = should_be_executable,
	modes = nil, -- cannot be set yet since the defining function uses the is_valid table
	keymaps = should_be_keymaps
}

function M.print_mode_config_warning(name, mode_config)
	if type(mode_config) ~= "table" then
		notify(name .. "mode config should be a table", "warn")
	else
		for key, value in pairs(mode_config) do
			if type(is_valid[key]) == "function" and not is_valid[key](value) then
				print_warning[key](key, value)
			else
				notify("Unknown field: " .. key .. ".", "warn")
			end
		end
	end
end

print_warning.modes = M.print_mode_config_warning

function M.print_config_warning(config)
	notify("Config:\n" .. vim.inspect(config), "debug")
	if type(config) ~= "table" then
		notify("Global config should be a table", "warn")
	else
		for key, value in pairs(config) do
			if type(is_valid[key]) == nil then
				notify("Unknown field: " .. key .. ".", "warn")
			elseif not is_valid[key](value) then
				print_warning[key](key, value)
			end
		end
	end
end

return M
