local M = {}

local normal_mode = "NORMAL" -- TODO fix code duplication (see init.lua)
local notify = require("virtual-modes.utils.notify").notify

-- Validating functions
function M._is_bool(value)
	return type(value) == "boolean"
end

function M._is_string(value)
	return type(value) == "string"
end

function M._is_table(value)
	return type(value) == "table"
end

function M._is_simple_executable(value)
	return type(value) == "string" or type(value) == "function"
end

function M._is_table_of_executables(value)
	local result = true
	if not M._is_table(value) then
		result = false
	else
		for _, v in ipairs(value) do
			result = result and M._is_simple_executable(v)
		end
	end
	return result
end

function M._is_executable(value)
	return M._is_simple_executable(value) or M._is_table_of_executables(value)
end

-- value should be { mode, lhs, rhs, opts }
local function is_keymap_with_opts(value)
	return M._is_table(value)
		and M._is_string(value[1])
		and M._is_string(value[2])
		and M._is_string(value[3])
		and M._is_table(value[4])
end

-- TODO use copy of value instead!!
-- value should be { mode, lhs, rhs }
local function is_keymap_without_opts(value)
	local result = false
	if M._is_table(value) then
		value[4] = {} -- set no options explicitly
		result = is_keymap_with_opts(value)
	end
	return result
end

function M._is_keymap(value)
	return is_keymap_without_opts(value) or is_keymap_without_opts(value)
end

function M._is_table_of_keymaps(value)
	local result = false
	if M._is_table(value) then
		result = true
		for _, keymap in ipairs(value) do
			result = result and M._is_keymap(keymap)
		end
	end
	return result
end

local is_valid = {
	name = M._is_string,
	keymap_enter = M._is_string,
	keymap_enter_prefix = M._is_string,
	enable_keymap_prefix = M._is_bool,
	on_enter = M._is_executable,
	on_exit = M._is_executable,
	modes = nil, -- cannot be set yet since the defining function uses the is_valid table
	keymaps = M._is_table_of_keymaps,
}

-- TODO make local
function M.is_mode(mode_config)
	local result = false
	if M._is_table(mode_config) then
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

function M._is_table_of_modes(value)
	local result = false
	if M._is_table(value) then
		result = true
		for _, mode_config in pairs(value) do
			result = result and M.is_mode(mode_config)
		end
	end
	return result
end

is_valid.modes = M._is_table_of_modes -- Complete table
-- M.is_mode_config = is_mode

-- Verify type constraints. Unknown keys are ignored.
function M.is_config(config)
	local result = false
	if M._is_table(config) then
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

return M
