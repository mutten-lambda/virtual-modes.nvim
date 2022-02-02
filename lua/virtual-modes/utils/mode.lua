local M = {}
local virtual_modes = require("virtual-modes")

-- stylua: ignore
local full_names = {
	["n"]    = "NORMAL",
	["no"]   = "O-PENDING",
	["nov"]  = "O-PENDING",
	["noV"]  = "O-PENDING",
	["no"] = "O-PENDING",
	["niI"]  = "NORMAL",
	["niR"]  = "NORMAL",
	["niV"]  = "NORMAL",
	["nt"]   = "NORMAL",
	["v"]    = "VISUAL",
	["vs"]   = "VISUAL",
	["V"]    = "V-LINE",
	["Vs"]   = "V-LINE",
	[""]   = "V-BLOCK",
	["s"]  = "V-BLOCK",
	["s"]    = "SELECT",
	["S"]    = "S-LINE",
	[""]   = "S-BLOCK",
	["i"]    = "INSERT",
	["ic"]   = "INSERT",
	["ix"]   = "INSERT",
	["R"]    = "REPLACE",
	["Rc"]   = "REPLACE",
	["Rx"]   = "REPLACE",
	["Rv"]   = "V-REPLACE",
	["Rvc"]  = "V-REPLACE",
	["Rvx"]  = "V-REPLACE",
	["c"]    = "COMMAND",
	["cv"]   = "EX",
	["ce"]   = "EX",
	["r"]    = "REPLACE",
	["rm"]   = "MORE",
	["r?"]   = "CONFIRM",
	["!"]    = "SHELL",
	["t"]    = "TERMINAL",
}

function M.get_mode()
	local mode = vim.api.nvim_get_mode().mode
	if mode == "n" then
		mode = require("virtual-modes").get_virtual_mode()
	elseif full_names[mode] ~= nil then
		mode = full_names[mode]
	end
	return mode
end

return M
