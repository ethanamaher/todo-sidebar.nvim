local Config = require("todo-sidebar.config")
local Sidebar = require("todo-sidebar.sidebar")

local TodoSidebar = {}
TodoSidebar.__index = TodoSidebar

function TodoSidebar:new()
    local config = Config.get_default_config()
    return setmetatable({
        config = config,
        sidebar = Sidebar:new()
    }, self)
end

local inst = TodoSidebar:new()

function TodoSidebar.setup(self, user_opts)
    if self ~= inst then
        user_opts = self
        self = inst
    end

    -- works for setting new keymap
    self.config = Config.add_config(user_opts, self.config)
end

return inst
