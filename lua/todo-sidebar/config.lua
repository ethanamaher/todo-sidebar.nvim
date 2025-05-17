local M = {}

function M.get_default_config()
	return {
		sidebar = {
			keywords = { "TODO", "FIXME", "NOTE", },
			case_sensitive = false,

			ignore_patterns = {
				".git/",
			},

			git_tracked_only = true,

			max_results = 500,
			search_strategy = "git_grep",

			git_cmd = "git",

			git_grep_args = {},
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
