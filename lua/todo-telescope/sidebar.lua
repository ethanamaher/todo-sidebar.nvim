--- lua/todo-telescope/sidebar.lua

local scanner = require("todo-telescope.scanner")
local config = require("todo-telescope.config")
local utils = require("todo-telescope.utils")

local M = {}

local state = {
    bufnr = nil,
    winid = nil,
    line_data = {}
}

local sidebar_defaults = {
    width = 40,
    position = "left",
    auto_focus = false,
    auto_close_on_jump = false,
    keymaps = {
        jmp_to = "<CR>",
        next_item = "j",
        prev_item = "k",
    },
}

local sidebar_config = {}

function M.setup(opts)
    sidebar_config = vim.tbl_deep_extend("force", {}, sidebar_defaults, opts or {})
end

local function format_buf_line(item)
    return string.format("[%s] %s:%s: %s",
        item.keyword,
        item.file_relative,
        item.line_number,
        item.text
    )
end

local test_data = {
    {
        keyword = "TODO",
        file_relative = "/file",
        line_number = "123",
        text = "Do this"
    },
    {
        keyword = "TODO",
        file_relative = "/file2",
        line_number = "1",
        text = "Do this next"
    },
}

local function populate_sidebar_buffer(items)
    if not state.bufnr or not vim.api.nvim_buf_is_valid(state.bufnr) then
        return
    end

    local lines = {}
    state.line_data = {}

    if #items == 0 then
       table.insert(lines, "No items found.")
    else
        for i, item in ipairs(items) do
            table.insert(lines, format_buf_line(item))
            state.line_data[i] = item
        end
    end

    vim.api.nvim_buf_set_option(state.bufnr, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)
    vim.api.nvim_buf_set_option(state.bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(state.bufnr, "modified", false)
end

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

    populate_sidebar_buffer(test_data)

    vim.notify("Scanning for keywords...", vim.log.levels.INFO, { title = "TodoSidebar" })
    scanner.find_todos_git_grep(repo_root, function(results)
        populate_sidebar_buffer(results)
        vim.notify("TODOs updated", vim.log.levels.INFO, { title = "TodoSidebar" })
    end)

end

local function create_sidebar_window_and_buffer()
    state.bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(state.bufnr, "bufhidden", "hide")
    vim.api.nvim_buf_set_option(state.bufnr, "buftype", "nofile")
    vim.api.nvim_buf_set_option(state.bufnr, "swapfile", false)
    vim.api.nvim_buf_set_option(state.bufnr, "filetype", "TodoSidebar")

    -- window creationx
    local win_cmd_prefix = sidebar_config.position == "left" and "topleft " or "botright "
    vim.cmd(win_cmd_prefix .. "vertical " .. sidebar_config.width .. " new")
    state.winid = vim.api.nvim_get_current_win()

    vim.api.nvim_win_set_buf(state.winid, state.bufnr)
end

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
