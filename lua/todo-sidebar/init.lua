local M = {}

local config = require("todo-sidebar.config")
local sidebar = require("todo-sidebar.sidebar")

function M.setup(user_opts)
    config.setup(user_opts)

    vim.api.nvim_create_user_command("TodoSidebarToggle", function()
            sidebar.toggle()
        end, {
        desc = "Scan project for TODOs, FIXMEs, etc."
    })

    vim.api.nvim_create_user_command("TodoSidebarRefresh", function()
            sidebar.refresh_buffer_items()
        end, {
        desc = "Refresh items in sidebar"
    })
end

return M
