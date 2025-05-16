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
### `:TodoSidebarToggle`
* Open a side window with all keyword matches in the current git repo
### `:TodoSidebarRefresh`
* Refresh entries by searching again and updating current open sidebar
## Setup
### Dependencies
* Neovim (developed and tested on v0.10.4)
* plenary.nvim
### Installation
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
                -- uncomment lines to use custom options
                --
                -- define custom keyword list
                -- keywords = { "TODO", "FIXME", "NOTE", "REVIEW", }
                --
                -- case sensitivity
                -- case_sensitive = false,
                --
                -- max number of results in sidebar window
                -- max_results = 500,

                -- sidebar = {
                --     width = 40, -- character width
                --     position = "right", -- "left" or "right"
                --     auto_focus = false, -- whether focus immediately goes to sidebar
                --     auto_close_on_jump = false, -- close sidebar on jump
                --     keymaps = {
                --         jmp_to = "<CR>", -- jump to item in sidebar
                --         -- TODO add keybinds for various things
                --   },
                --},
            })
        end
    }
}
```
