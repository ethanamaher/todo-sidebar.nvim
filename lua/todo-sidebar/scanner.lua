local Job = require("plenary.job")

local Path = require("plenary.path")
local config

local function get_config(sidebar_config)
	config = sidebar_config
	if not config then
		config = require("todo-sidebar.config").get_default_config()
	end
	return config
end

local M = {}

function M.find_todos_git_grep(sidebar, repo_root, callback)
	local current_config = get_config(sidebar)
	if not repo_root then
		callback({})
		return
	end
	local patterns = {}

	for _, kw_pair in ipairs(current_config.keywords) do
		if type(kw_pair) == "table" then
			table.insert(patterns, "\\b" .. kw_pair.keyword .. "\\b")
		elseif type(kw_pair) == "string" then
			table.insert(patterns, "\\b" .. kw_pair.. "\\b")
		end
	end

	local grep_pattern = table.concat(patterns, "|")

	local git_cmd = current_config.git_cmd
	-- -i case insensitive
	local args = { "-C", repo_root, "grep", "-n", "-E" }

	if not current_config.case_sensitive then
		table.insert(args, "-i")
	end

	table.insert(args, grep_pattern)

	local results = {}
	Job:new({
		command = git_cmd,
		args = args,
		cwd = repo_root,

		on_exit = vim.schedule_wrap(function(j, return_val)
			local output_lines = j:result() or {}
			for _, line in ipairs(output_lines) do
				-- parse git grep output <filepath>:<line_number>:<text>
				local file_rel, lnum, text = line:match("([^:]+):(%d+):(.*)")
				local loc = -1
				if file_rel and lnum and text then
					local matched = ""
					local search_for_kw = current_config.case_sensitive and text or text:lower()
					for _, kw_pair in ipairs(current_config.keywords) do
						local kw
						if type(kw_pair) == "table" then
							kw = current_config.case_sensitive and kw_pair.keyword or kw_pair.keyword:lower()
							loc = search_for_kw:find(kw, 1, true)
							if search_for_kw:find(kw, 1, true) then
								matched = kw_pair.keyword
								break
							end
						elseif type(kw_pair) == "string" then
							kw = current_config.case_sensitive and kw_pair or kw_pair:lower()
							loc = search_for_kw:find(kw, 1, true)
							if search_for_kw:find(kw, 1, true) then
								matched = kw_pair
								break
							end
						end
					end

					-- remove up to and past keyword matched
					local trimmed_text = text:sub(loc + #matched)
					-- remove leading white space
					trimmed_text = trimmed_text:gsub("^%s*", "")

					table.insert(results, {
						file_absolute = Path:new(repo_root, file_rel):absolute(),
						file_relative = file_rel,
						line_number = tonumber(lnum),
						text = trimmed_text,
						keyword = matched,
					})
				end
			end
			callback(results)
		end),
	}):start()
end

return M
