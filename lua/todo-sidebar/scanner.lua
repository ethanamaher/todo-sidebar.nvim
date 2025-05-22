local Job = require("plenary.job")
local Path = require("plenary.path")

local config
local function get_config(sidebar_config)
	config = sidebar_config
	if not config then
		config = require("todo-sidebar.config").get_default_config()
	end
end

local M = {}

---find the index location of any keyword set in config in a line of text
---@param text string line of text to search
---@return number|nil location of any matched keyword, nil if no keyword found
---@return string matched the matched keyword
local function find_loc_of_keyword(text)
    local location
    local matched = ""
    local search_for_kw = config.case_sensitive and text or text:lower()

    for _, kw_pair in ipairs(config.keywords) do
        local kw

        if type(kw_pair) == "table" then
            kw = config.case_sensitive and kw_pair.keyword or kw_pair.keyword:lower()
            location = search_for_kw:find(kw, 1, true)
            if search_for_kw:find(kw, 1, true) then
                matched = kw_pair.keyword
                break
            end
        elseif type(kw_pair) == "string" then
            kw = config.case_sensitive and kw_pair or kw_pair:lower()
            location = search_for_kw:find(kw, 1, true)
            if search_for_kw:find(kw, 1, true) then
                matched = kw_pair
                break
            end
        end
    end
    return location, matched
end

function M.find_todos_git_grep(sidebar_config, repo_root, callback)
	get_config(sidebar_config)
	if not repo_root then
		callback({})
		return
	end
	local patterns = {}

	for _, kw_pair in ipairs(config.keywords) do
		if type(kw_pair) == "table" then
			table.insert(patterns, "\\b" .. kw_pair.keyword .. "\\b")
		elseif type(kw_pair) == "string" then
			table.insert(patterns, "\\b" .. kw_pair .. "\\b")
		end
	end

	local grep_pattern = table.concat(patterns, "|")

	local git_cmd = config.git_cmd

	local args = { "-C", repo_root, "grep", "-n", "-E" }
	if not config.case_sensitive then
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

				if file_rel and lnum and text then
                    local location, matched = find_loc_of_keyword(text)

					if location then
						-- remove up to and past keyword matched
						local trimmed_text = text:sub(location + #matched)
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
			end
			callback(results)
		end),
	}):start()
end

return M
