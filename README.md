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
lua require("todo-sidebar.sidebar").close()()
```
calling open() when sidebar is already open will cause it to refresh the list items



### Refresh Sidebar Directly
you can refresh the sidebar directyly with
```lua
lua require("todo-sidebar.sidebar").toggle()
```
if the sidebar is not open it will just return out



### Sidebar Navigation
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
