--- lua/todo-telescope/sidebar.lua

local Path = require("plenary.path")

local scanner = require("todo-telescope.scanner")
local config = require("todo-telescope.config")

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
        return
    end

    create_sidebar_window_and_buffer()
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
