local M = {}

function M.get_default_config()
	return {
		sidebar = {
			keywords = {
                { keyword="TODO", hl_group="Todo" },
                { keyword="FIXME", hl_group="WarningMsg" },
                { keyword="NOTE", hl_group="Comment" },
            },
			case_sensitive = false,

			ignore_patterns = {
				".git/",
			},

			max_results = 500,
			git_cmd = "git",

			width = 40,

			position = "right",
			auto_focus = true,
			auto_close_on_jump = false,
			keymaps = {
				close = "q",
				refresh = "r",
				jmp_to = "<CR>",
				jmp_to_vsplit = "<C-v>",
				jmp_to_split = "<C-s>",

				next_item = "j",
				prev_item = "k",

				scroll_down = "<C-d>",
				scroll_up = "<C-k>",

                decrease_width = "<",
                increase_width = ">",
			},
		},
	}
end

function M.add_config(new_config, old_config)
	new_config = new_config or {}
	local config = old_config.sidebar or M.get_default_config().sidebar

	for k, v in pairs(new_config) do
		if k == "sidebar" then
			config = vim.tbl_deep_extend("force", config, v)
		end
	end

	return config
end

return M
