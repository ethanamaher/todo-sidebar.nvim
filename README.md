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
you can refresh the sidebar directyly with
```lua
lua require("todo-sidebar.sidebar").refresh_buffer_items()
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
                -- define custom keyword list
                keywords = { "TODO", "FIXME", "NOTE", "REVIEW", }

                -- case sensitivity for search
                case_sensitive = false,

                -- max number of results in sidebar window
                 max_results = 500,

                sidebar = {
                    -- sidebar width
                    width = 40,

                    -- position of sidebar, "right" or "left"
                    position = "right",

                    -- does focus go to sidebar on open
                    auto_focus = true,

                    -- close sidebar after jumping to item
                    auto_close_on_jump = false,


                    keymaps = {
                        close           = "q",
                        refresh         = "r",

                        -- jump to item
                        jmp_to          = "<CR>",

                        -- jump to item, open new buffer in vsplit
                        jmp_to_vsplit   = "<C-v>",

                        -- jump to item, open new buffer in vsplit
                        jmp_to_split    = "<C-s>",

                        next_item       = "j",
                        prev_item       = "k",
                        scroll_down     = "<C-d>",
                        scroll_up       = "<C-k>",
                    },
                }
            })

            vim.keymap.set("n", "<leader>tst", "<cmd>TodoSidebarToggle<CR>",
                        { desc = "Toggle Todo Sidebar" })
        end
    }
}
```
