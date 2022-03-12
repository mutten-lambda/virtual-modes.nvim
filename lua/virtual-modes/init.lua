local M = {}

local modes = require("virtual-modes.modes")

M.is_mode_setup = modes.is_mode
M.get_current_mode = modes.get_current_mode
M.add_mode = modes.add_mode
M.del_mode = modes.del_mode
M.enter_mode = modes.enter_mode
M.exit_mode = modes.exit_mode

function M.setup(config)
	-- TODO validate config
	-- show warnings
	-- normalize

	-- Set up global options

	-- Register global on_enter callback
	local enter_group = vim.api.nvim_create_augroup("VirtualModesEnter", { clear = true })
	vim.api.nvim_create_autocmd(
		"User",
		{ pattern = "VirtualModesEnter", callback = config.global.on_enter, group = enter_group }
	)

	-- Register global on_exit callback
	local exit_group = vim.api.nvim_create_augroup("VirtualModesExit", { clear = true })
	vim.api.nvim_create_autocmd(
		"User",
		{ pattern = "VirtualModesExit", callback = config.global.on_exit, group = exit_group }
	)

	-- Set up modes
	local mode_configs = config.modes
	for _, mode in pairs(mode_configs) do
		modes.add_mode(mode)
	end
end

function M._clear()
	-- TODO pcall doesn't catch the error raised when these deleting a group which does not exist. Currently, we overwrite these groups which has the same effect.
	for _, group in ipairs({ "VirtualModesEnter", "VirtualModesExit" }) do
		vim.api.nvim_create_augroup(group, { clear = true })
	end
	-- pcall(vim.api.nvim_del_augroup_by_name, "VirtualModesEnter")
	-- pcall(vim.api.nvim_del_augroup_by_name, "VirtualModesExit")
end

return M
