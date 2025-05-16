--- lua/todo-sidebar/sidebar.lua

local scanner = require("todo-sidebar.scanner")
local config = require("todo-sidebar.config")
local utils = require("todo-sidebar.utils")

local M = {}

local state = {
    bufnr = nil,
    winid = nil,
    line_data = {}
}

local sidebar_config = {}

---set up default sidebar_config with sidebar_defaults from config.lua
--- default config is in config.lua can be modified by user in
--- require("todo-sidebar").setup({})
---@param opts table sidebar from config.lua
function M.setup(opts)
    sidebar_config = vim.tbl_deep_extend("force", {}, opts or {})
end

-- TODO highlight mappings for keywords and items in entry string

---format a keyword entry for sidebar
---@param item table table of keyword entries { keyword, file_relative, line_number, text }
---@return string formatted string
local function format_buf_line(item)
    -- with relative file path it is too long i think, either need to increase
    -- width or shorter fmt str
    return string.format("[%s]: %s",
        item.keyword,
        item.text
    )

    -- return string.format("[%s] %s:%s: %s",
    --    item.keyword,
    --    item.file_relative,
    --    item.line_number,
    --    item.text
    --)
end

---populate the sidebar buffer with a table of keyword entry items
---@param items table table of keyword entries
local function populate_sidebar_buffer(items)
    if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        return
    end

    local lines = {}

    ---clear past line_data
    state.line_data = {}

    if #items == 0 then
       table.insert(lines, "No items found.")
    else
        for i, item in ipairs(items) do
            table.insert(lines, format_buf_line(item))
            state.line_data[i] = item
        end
    end

    ---set lines in buffer with lines table
    vim.api.nvim_buf_set_option(state.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(state.bufnr, "modified", false)
end

---refresh the items in the sidebar
---runs scanner.find_todos_git_grep to get an up to date refresh of any entries
---that need to be added to buffer
function M.refresh_buffer_items()
    if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        -- sidebar no topen notify
        return
    end

    local repo_root = utils.find_git_repo_root()
    if not repo_root then
        populate_sidebar_buffer({})
        return
    end

    vim.notify("Scanning for keywords...", vim.log.levels.INFO, { title = "TodoSidebar" })
    scanner.find_todos_git_grep(repo_root, function(results)
        populate_sidebar_buffer(results)
        vim.notify("TODOs updated", vim.log.levels.INFO, { title = "TodoSidebar" })
    end)
end

---jump to a selected entry from sidebar
---@param jmp_command string jump command "edit" by default
function M.jump_to_selected_item(jmp_command)
    if not state.winid or not vim.api.nvim_win_is_valid(state.winid) then
        return
    end

    local cursor_pos = vim.api.nvim_win_get_cursor(state.winid)
    -- line number of cursor in buffer
    local current_line_num = cursor_pos[1]
    local item = state.line_data[current_line_num]

    if item then
        local filepath = item.file_absolute
        local lnum = item.line_number

        local prev_winid = vim.api.nvim_get_current_win()

        -- switch focus to original window before opening
        local windows = vim.api.nvim_list_wins()
        for _, winid in ipairs(windows) do
            if winid ~= state.winid and vim.api.nvim_win_get_buf(winid) then
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
        vim.notify("Error jumping to this item", vim.log.levels.WARN, { title = "TodoSidebar" })
    end
end

---set up default key mappings for sidebar
local function setup_mappings()
    local map_opts = { noremap = true, silent = true, buffer = state.bufnr }
    local km = sidebar_config.keymaps

    vim.keymap.set("n", km.close, function() M.close() end, map_opts)
    vim.keymap.set("n", km.refresh, function() M.refresh_buffer_items() end, map_opts)

    vim.keymap.set("n", km.jmp_to, function() M.jump_to_selected_item("edit") end, map_opts)
    vim.keymap.set("n", km.jmp_to_vsplit, function() M.jump_to_selected_item("vsplit") end, map_opts)
    vim.keymap.set("n", km.jmp_to_split, function() M.jump_to_selected_item("split") end, map_opts)

    vim.keymap.set("n", km.next_item, "j", map_opts)
    vim.keymap.set("n", km.prev_item, "k", map_opts)

    vim.keymap.set("n", km.scroll_down, "<C-d>", map_opts)
    vim.keymap.set("n", km.scroll_up, "<C-u>", map_opts)
end

---instantiate the buffer for sidebar
---@return number bufnr of created buffer
local function instantiate_buffer()
    state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(state.bufnr, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(state.bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(state.bufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(state.bufnr, "filetype", "TodoSidebar")

    return state.bufnr
end

---instantiate the window for sidebar
---@return number winid of created window
local function instantiate_window()
    local win_cmd_prefix = sidebar_config.position == "left" and "topleft " or "botright "
    vim.cmd(win_cmd_prefix .. "vertical " .. sidebar_config.width .. " new")
    state.winid = vim.api.nvim_get_current_win()
    return state.winid
end


---create the window and buffer for sidebar
local function create_sidebar_window_and_buffer()
    instantiate_buffer()
    if not state.bufnr then
        return
    end

    instantiate_window()
    if not state.winid then
        return
    end
    vim.api.nvim_win_set_buf(state.winid, state.bufnr)

    setup_mappings()
end

---open sidebar window and refresh_buffer_items
function M.open()
    if state.winid and vim.api.nvim_win_is_valid(state.winid) then
        if sidebar_config.auto_focus then
            vim.api.nvim_set_current_win(state.winid)
        end
        M.refresh_buffer_items()
        return
    end

    create_sidebar_window_and_buffer()
    M.refresh_buffer_items()
end

---close sidebar window and clear line_data
function M.close()
    if state.winid and vim.api.nvim_win_is_valid(state.winid) then
        vim.api.nvim_win_close(state.winid, true)
        state.winid = nil
    end

    if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
        vim.api.nvim_buf_delete(state.bufnr, { force = true })
        state.bufnr = nil
    end
    state.line_data = {}
end

---toggle sidebar window open and closed
function M.toggle()
    if vim.tbl_isempty(sidebar_config) then
        M.setup(config.options.sidebar or {})
    end

    if state.winid and vim.api.nvim_win_is_valid(state.winid) then
        M.close()
    else
        M.open()
    end
end

return M
