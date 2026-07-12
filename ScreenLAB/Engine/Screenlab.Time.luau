local using = require(script.Parent.Using)
local module = {}
local GlobalEvent = using("Screenlab.GlobalEvent")

local deltatime = 0 

module.TimeScale = 1

function module:GetDeltaTime()
	return deltatime
end

game:GetService("RunService").RenderStepped:Connect(function(dt)
	dt *= module.TimeScale
	deltatime = dt
	GlobalEvent.Events.Update:Fire(dt)
end)

return module
