--- lua/todo-sidebar/sidebar.lua

local scanner = require("todo-sidebar.scanner")
local config = require("todo-sidebar.config")
local utils = require("todo-sidebar.utils")

---@class TodoSideBarUI
---@field bufnr number
---@field winid number
---@field line_data table
local TodoSideBarUI = {}
TodoSideBarUI.__index = TodoSideBarUI

---@param sidebar_config table config to use for sidebar
---@return TodoSideBarUI
function TodoSideBarUI:new(sidebar_config)
	return setmetatable({
		bufnr = nil,
		winid = nil,
		line_data = {},
		sidebar_config = sidebar_config,
	}, self)
end

--- set up default sidebar_config with sidebar_defaults from config.lua
---@param opts? table|nil sidebar config options from config.lua
function TodoSideBarUI:setup(opts)
	local defaults = config.get_default_config()
	self.sidebar_config = vim.tbl_extend("force", defaults, opts or {})
end

-- TODO highlight mappings for keywords and items in entry string

---format a keyword entry for sidebar
---@param item table table of keyword entries { keyword, file_relative, line_number, text }
---@return string formatted string
local function format_buf_line(item)
	-- with relative file path it is too long i think, either need to increase
	-- width or shorter fmt str

	-- tentative formatting
	local short_filename = vim.fn.fnamemodify(item.file_relative, ":t")

	return string.format("[%s] %s (%s:%d)", item.keyword, item.text, short_filename, item.line_number)

	-- return string.format("[%s] %s:%s: %s",
	--    item.keyword,
	--    item.file_relative,
	--    item.line_number,
	--    item.text
	--)
end

---populate the sidebar buffer with a table of keyword entry items
---@param items table table of keyword entries
function TodoSideBarUI:populate_sidebar_buffer(items)
	if not self.bufnr or not vim.api.nvim_buf_is_valid(self.bufnr) then
		return
	end

	local lines = {}

	-- clear past line_data
	self.line_data = {}

	-- items can not be null
	-- find_todos_git_grep returns {} if no results
	if #items == 0 then
		table.insert(lines, "No items found.")
	else
		for i, item in ipairs(items) do
			table.insert(lines, format_buf_line(item))
			self.line_data[i] = item
		end
	end

	---set lines in buffer with lines table
	vim.api.nvim_buf_set_option(self.bufnr, "modifiable", true)
	vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, lines)
	vim.api.nvim_buf_set_option(self.bufnr, "modifiable", false)
	vim.api.nvim_buf_set_option(self.bufnr, "modified", false)

	-- FIXME holy this is scuffed
	-- initial highlight grouping
	for i, line in ipairs(lines) do
		local hl_group
		local match_len
		if line:find("TODO") then
			hl_group = "Todo"
			match_len = 4
		elseif line:find("FIXME") then
			hl_group = "WarningMsg"
			match_len = 5
		elseif line:find("NOTE") then
			hl_group = "Comment"
			match_len = 4
		end

		if hl_group then
			vim.api.nvim_buf_add_highlight(self.bufnr, -1, hl_group, i - 1, 0, match_len + 2)
		end
	end
end

---refresh the items in the sidebar
---runs scanner.find_todos_git_grep to get an up to date refresh of any entries
---that need to be added to buffer
function TodoSideBarUI:refresh_list()
	if not self.bufnr or not vim.api.nvim_buf_is_valid(self.bufnr) then
		-- sidebar not open notify
		return
	end

	local repo_root = utils.find_git_repo_root()
	if not repo_root then
		self:populate_sidebar_buffer({})
		return
	end

	vim.notify("Scanning for keywords...", vim.log.levels.INFO, { title = "TodoSideBarUI" })
	scanner.find_todos_git_grep(self.sidebar_config, repo_root, function(results)
		self:populate_sidebar_buffer(results)
		vim.notify("TODOs updated", vim.log.levels.INFO, { title = "TodoSideBarUI" })
	end)
end

---jump to a selected entry from sidebar
---@param jmp_command string jump command "edit" by default
function TodoSideBarUI:select_menu_item(jmp_command)
	--if not self.winid or not vim.api.nvim_win_is_valid(self.winid) then
	--    return
	--end

	local cursor_pos = vim.api.nvim_win_get_cursor(self.winid)
	-- line number of cursor in buffer
	local current_line_num = cursor_pos[1]
	local item = self.line_data[current_line_num]

	if item then
		local filepath = item.file_absolute
		local lnum = item.line_number

		-- switch focus to original window before opening
		local windows = vim.api.nvim_list_wins()
		for _, winid in ipairs(windows) do
			if winid ~= self.winid and vim.api.nvim_win_get_buf(winid) then
				local is_float = vim.api.nvim_win_get_config(winid).relative ~= ""
				if not is_float then
					vim.api.nvim_set_current_win(winid)
					break
				end
			end
		end

		-- exec jump
		vim.cmd(jmp_command .. " +" .. lnum .. " " .. vim.fn.fnameescape(filepath))
	else
		vim.notify("Error jumping to this item", vim.log.levels.WARN, { title = "TodoSideBarUI" })
	end

	-- auto close on jump
	if self.sidebar_config.auto_close_on_jump then
		self:close_menu()
	end
end

---set up default key mappings for sidebar
function TodoSideBarUI:setup_mappings()
	local map_opts = { noremap = true, silent = true, buffer = self.bufnr }
	local km = self.sidebar_config.keymaps

	vim.keymap.set("n", km.close, function()
		self:close_menu()
	end, map_opts)

	vim.keymap.set("n", km.refresh, function()
		self:refresh_list()
	end, map_opts)

	vim.keymap.set("n", km.jmp_to, function()
		self:select_menu_item("edit")
	end, map_opts)

	vim.keymap.set("n", km.jmp_to_vsplit, function()
		self:select_menu_item("vsplit")
	end, map_opts)

	vim.keymap.set("n", km.jmp_to_split, function()
		self:select_menu_item("split")
	end, map_opts)

	vim.keymap.set("n", km.next_item, "j", map_opts)
	vim.keymap.set("n", km.prev_item, "k", map_opts)

	vim.keymap.set("n", km.scroll_down, "<C-d>", map_opts)
	vim.keymap.set("n", km.scroll_up, "<C-u>", map_opts)
end

---create the window and buffer for sidebar
--- only called at beginning, buf and win should not exist
function TodoSideBarUI:_create_sidebar()
    local prev_win = vim.api.nvim_get_current_win()
	  local bufnr = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(bufnr, "bufhidden", "hide")
	  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
	  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
	  vim.api.nvim_buf_set_option(bufnr, "filetype", "TodoSideBarUI")

	  local win_cmd_prefix = self.sidebar_config.position == "left" and "topleft " or "botright "
	  vim.cmd(win_cmd_prefix .. "vertical " .. self.sidebar_config.width .. " new")
    local winid = vim.api.nvim_get_current_win()
      vim.api.nvim_win_set_buf(winid, bufnr)

      -- if not autofocus, set window to previous window
      if not self.sidebar_config.auto_focus then
          vim.api.nvim_set_current_win(prev_win)
      end

    return winid, bufnr
end

---open sidebar window and refresh_list
function TodoSideBarUI:open_menu()
	-- if sidebar window exists, set it to current window and refresh list
	if self.winid and vim.api.nvim_win_is_valid(self.winid) then
        vim.api.nvim_set_current_win(self.winid)
		    self:refresh_list()
    return
  end

	local winid = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(winid, bufnr)
	return winid, bufnr
end

---close sidebar window, preserves buffer and line data
function TodoSideBarUI:close_menu()
	if self.winid and vim.api.nvim_win_is_valid(self.winid) then
		vim.api.nvim_win_close(self.winid, true)
		self.winid = nil
	end
end

---toggle sidebar window open and closed
function TodoSideBarUI:toggle()
	-- get this working for custom opts
	if vim.tbl_isempty(self.sidebar_config) then
		self:setup(config.get_default_config() or {})
	end

	if self.winid and vim.api.nvim_win_is_valid(self.winid) then
		self:close_menu()
	else
		self:open_menu()
	end
end

return TodoSideBarUI
