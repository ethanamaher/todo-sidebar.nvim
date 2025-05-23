<div align="center">

# todo-sidebar
##### previously todo-telescope
</div>

---

a lazy nvim plugin created to find TODO, FIXME, REVIEW, etc statements in a git repo

made to make it easier to find any, kept merging too many into main and got chastised

opens any keyword hits in a navigable sidebar window
```
# TODO make this function work

# NOTE not tested

# REVIEW edge cases
```

## Features
* Search through git repo using `git grep` to find any keywords, default are `keywords = { "TODO", "FIXME", "NOTE", "REVIEW" },`
* Show relevant files and the statement highlighted in a sidebar window
* <CR> on any entries in sidebar to jump to that entry in code window



## Use



### Toggle Sidebar
toggle sidebar open or closed depending on current state
```lua
lua require("todo-sidebar.sidebar").toggle()
```

you can also open or close the sidebar with
```lua
lua require("todo-sidebar.sidebar").open()
lua require("todo-sidebar.sidebar").close()
```
calling open() when sidebar is already open will cause it to refresh the list items



### Refresh Sidebar Directly
you can refresh the sidebar directly with
```lua
lua require("todo-sidebar.sidebar").refresh_list()
```
if the sidebar is not open it will just return out


## Setup


### Dependencies
* Neovim (developed and tested on v0.10.4)
* plenary.nvim


### Installation and configuration
Add the following to your `lazy.nvim` plugin configuration
```lua
return {
    {
        "ethanamaher/todo-sidebar.nvim",

        dependencies = {
            "nvim-lua/plenary.nvim",
        },

        config = function()
            require("todo-sidebar").setup({
                sidebar = {
                    -- git_cmd = "git",

                    -- custom keyword list
                    -- keywords = {
                    --     -- keyword to match and highlight group to use
                    --     -- hl_group is optional, will default to hl_group="Comment"
                    --     { keyword="TODO", hl_group="Todo" },
                    --     { keyword="FIXME", hl_group="WarningMsg" },
                    --     { keyword="NOTE", hl_group="Comment" },
                    --     -- { keyword="NO_HL_GROUP" },

                    --     -- can also just do string, same thing will do hl_group="Comment"
                    --     -- "NO_TABLE"
                    -- },

                    -- keyword case sensitivity
                    -- case_sensitive = false,

                    -- max number of results in sidebar
                    -- max_results = 500,

                    -- sidebar width percentage
                    -- width = 50

                    -- sidebar position "left" or "right"
                    -- position = "right",

                    -- focus in sidebar on open
                    -- auto_focus = true,

                    -- close sidebar on jump
                    -- auto_close_on_jump = false,

                    -- custom keymap for sidebar nav
                    -- keymaps = {
                    --     close sidebar
                    --     close           = "q",

                    --     refresh items in sidebar
                    --     refresh         = "r",

                    --     jump to item in sidebar menu
                    --     jmp_to          = "<CR>",

                    --     jump to item in sidebar menu, open new buffer in vsplit
                    --     jmp_to_vsplit   = "<C-v>",

                    --     jump to item in sidebar menu, open new buffer in split
                    --     jmp_to_split    = "<C-s>",

                    --     next_item       = "j",
                    --     prev_item       = "k",

                    --     scroll_down     = "<C-d>",
                    --     scroll_up       = "<C-k>",

                    --     decrease_width = "<",
                    --     increase_width = ">",
                    -- },
                }
            })

            vim.keymap.set("n", "<leader>tst", "<cmd>TodoSidebarToggle<CR>",
                        { desc = "Toggle Todo Sidebar" })
        end
    }
}
```
