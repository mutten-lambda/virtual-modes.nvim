local M = {}

local normal_mode = ""
local current_mode = normal_mode

M._virtual_modes = {}

function M.get_current_mode()
	return current_mode
end

function M.is_mode(name)
	return M._virtual_modes[name] or false
end

function M.del_mode(name)
	if current_mode == name then
		M.exit_mode()
	end
	M._virtual_modes[name] = nil
	-- vim.api.nvim_del_augroup_by_name( "VirtualModesEnter" .. name)
	-- pcall(vim.api.nvim_del_augroup_by_name, "VirtualModesExit" .. name)
end

function M.add_mode(mode_config)
	-- TODO validate config
	-- show warnings
	-- normalize
	local name = mode_config.name
	if not M._virtual_modes[name] then
		M.del_mode(name)
	end
	M._virtual_modes[mode_config.name] = true

	-- TODO second argument needed??
	-- Register modal on_enter callback
	local enter_group = vim.api.nvim_create_augroup("VirtualModesEnter" .. name, { clear = true })
	vim.api.nvim_create_autocmd(
		"User",
		{ pattern = "VirtualModesEnter" .. name, callback = mode_config.on_enter, group = enter_group }
	)

	-- Register modal on_exit callback
	local exit_group = vim.api.nvim_create_augroup("VirtualModesExit" .. name, { clear = true })
	vim.api.nvim_create_autocmd(
		"User",
		{ pattern = "VirtualModesExit" .. name, callback = mode_config.on_exit, group = exit_group }
	)

	-- Set up modal enter map
	if mode_config.keymap_enter then
		vim.api.nvim_set_keymap(
			"n",
			mode_config.keymap_enter,
			"<cmd>lua require('virtual-modes').enter_mode('" .. name .. "')<cr>",
			{ noremap = true }
		)
	end

	-- Set up exit map
	if mode_config.keymap_exit then
		vim.api.nvim_set_keymap(
			"n",
			mode_config.keymap_exit,
			"<cmd>lua require('virtual-modes').exit_mode()<cr>",
			{ noremap = true }
		)
	end
end

function M.enter_mode(name)
	-- TODO validate config
	-- show warnings

	-- Exit another virtual mode if necessary
	if current_mode ~= normal_mode and current_mode ~= name then
		M.exit_mode()
	end

	-- Enter new virtual mode
	current_mode = name
	vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesEnter" })
	vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesEnter" .. current_mode })
end

function M.exit_mode()
	-- Only exit if a virtual mode is active
	if current_mode ~= normal_mode then
		vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesExit" })
		vim.api.nvim_do_autocmd("User", { pattern = "VirtualModesExit" .. current_mode })
		current_mode = normal_mode
	end
end

function M._clear()
	for name, _ in pairs(M._virtual_modes) do
		M.del_mode(name)
	end
end

return M
