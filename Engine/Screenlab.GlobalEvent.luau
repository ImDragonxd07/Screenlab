local using = require(script.Parent.Using)
local module = {}

local Event = using("Screenlab.Event")

module.Events = {
	NewObj = Event:New(),
	GameStarted = Event:New(),
	Update = Event:New(),
	PreRender = Event:New(),
}

return module

