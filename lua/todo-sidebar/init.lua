local Config = require("todo-sidebar.config")
local Sidebar = require("todo-sidebar.sidebar")

local TodoSidebar = {}
TodoSidebar.__index = TodoSidebar

function TodoSidebar:new()
    return setmetatable({
        config = Config.options.defaults,
        sidebar = Sidebar:new()
    }, self)
end

local inst = TodoSidebar:new()

function TodoSidebar.setup(self, user_opts)
    if self ~= inst then
        self = inst
    end

    Config:setup(user_opts)
end

return inst
