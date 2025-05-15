local M = {}

local scanner = require("todo-telescope.scanner")
local telescope_integration = require("todo-telescope.telescope")
local config = require("todo-telescope.config")
local sidebar = require("todo-telescope.sidebar")
local utils  = require("todo-telescope.utils")

--- used for telescope picker
--- deprecated
function M.scan_todos_telescope()
    local repo_root = utils.find_git_repo_root()
    if not repo_root then return end

    if config.options.search_strategy == "git_grep" then
        scanner.find_todos_git_grep(repo_root, function(todo_items)
            if #todo_items == 0 then
                return
            end

            telescope_integration.show_telescope_picker(todo_items)
        end)
    else
        vim.notify("unknown search strategy", vim.log.levels.ERROR, { title="TODOTelescope" })
    end

end

function M.setup(user_opts)
    config.setup(user_opts)

    vim.api.nvim_create_user_command("TelescopeTodo", M.scan_todos_telescope, {
        desc = "Scan project for TODOs, FIXMEs, etc."
    })

    vim.api.nvim_create_user_command("TodoSidebarToggle", function()
            sidebar.toggle()
        end, {
        desc = "Scan project for TODOs, FIXMEs, etc."
    })
end

return M
