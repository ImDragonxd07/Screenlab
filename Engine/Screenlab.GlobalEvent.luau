local Event = require(script.Parent["Screenlab.Event"])
local module = {}

module.Events = {
	NewObj = Event:New(),
	GameStarted = Event:New(),
	Update = Event:New(),
	PreRender = Event:New(),
}

return module

