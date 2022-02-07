local M = {}

function M.get_defaults()
	return {
		keymap_enter_prefix = "",
		enable_keymap_prefix = true,
		keymap_exit = "<esc>",
		on_enter = {},
		on_exit = {},
		keymaps = {},
	}
end

return M
