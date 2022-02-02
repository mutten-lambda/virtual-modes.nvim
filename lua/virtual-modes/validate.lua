local M = {}

local normal_mode = "NORMAL" -- TODO fix code duplication (see init.lua)
local notify = require("virtual-modes.utils.notify").notify

local function is_string_or_function(value)
	return type(value) == "string" or type(value) == "function"
end

function M.is_valid_mode_config(mode_config)
	local c = mode_config
	return type(c.name) == "string"
		and c.name ~= normal_mode
		and type(c.keymap_enter) == "string"
		and is_string_or_function(c.on_enter)
		and is_string_or_function(c.on_exit)
end

function M.print_mode_config_warning(mode_config)
	local c = mode_config
	if not type(c.name) ~= "string" then
		notify("Mode should have a name.", "warn")
	elseif c.name == normal_mode then
		notify("Mode cannot be named '" .. normal_mode .. "'.", "warn")
	elseif type(c.keymap_enter) ~="string" then
		notify("Field keymap_enter must be a string, not: " .. type(c.keymap_enter), "warn")
	elseif not is_string_or_function(c.on_enter) then
		notify("Field 'on_enter' must be a string or lua function, not: " .. type(c.on_enter), "warn")
	elseif not is_string_or_function(c.on_exit) then
		notify("Field 'on_exit' must be a string or lua function, not: " .. type(c.on_exit), "warn")
	end
end

return M
