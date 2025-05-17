local Path = require("plenary.path")

local M = {}

function M.find_git_repo_root()
	local file_path = vim.fn.expand("%:p")
	local cur_path = Path:new(file_path)
	local init_path = cur_path:is_file() and cur_path:parent():absolute() or cur_path:absolute()

	local repo_root_cmd = { "git", "-C", vim.fn.fnameescape(init_path), "rev-parse", "--show-toplevel" }
	local repo_root_list = vim.fn.systemlist(repo_root_cmd)
	local repo_root = repo_root_list and repo_root_list[1]

	if vim.vshell_error ~= nil then
		if repo_root == "" then
			repo_root = nil
		end -- handle empty output
		vim.notify("ERROR HERE", vim.log.levels.ERROR, { title = "BetterGitBlame" })
	end

	if not repo_root then
		vim.notify(
			"Could not determine Git repository root. " .. tostring(parent_dir) .. " from " .. tostring(current_path),
			vim.log.levels.ERROR,
			{ title = "BetterGitBlame" }
		)
	end
	return repo_root
end

return M
