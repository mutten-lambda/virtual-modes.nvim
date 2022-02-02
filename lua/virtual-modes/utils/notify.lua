local M = {}

function M.notify(msg, log_level, opts)
	msg = "[virtual_modes] " .. msg
	vim.notify(msg, log_level, opts)
end

return M
