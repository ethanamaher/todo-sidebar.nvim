local M = {}

M.defaults = {
    keywords = { "TODO", "FIXME", "NOTE", "REVIEW" },
    case_sensitive = false,

    ignore_patterns = {
        ".git/",
    },

    git_tracked_only = true,

    max_results = 500,
    search_strategy = "git_grep",

    git_cmd = "git",

    git_grep_args = {},

    sidebar = {
        width = 40,
        position = "right",
        auto_focus = true,
        auto_close_on_jump = false,
        keymaps = {
            close           = "q",
            refresh         = "r",
            jmp_to          = "<CR>",
            jmp_to_vsplit   = "<C-v>",
            jmp_to_split    = "<C-s>",

            next_item       = "j",
            prev_item       = "k",

            scroll_down     = "<C-d>",
            scroll_up       = "<C-k>",
        },
    }
}

M.options = {}

function M.setup(user_opts)
    M.options = vim.tbl_deep_extend("force", {}, M.defaults, user_opts or {})
end

return M
