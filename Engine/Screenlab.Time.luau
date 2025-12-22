local module = {}
local GlobalEvent = require(script.Parent["Screenlab.GlobalEvent"])

local deltatime = 0 

function module:GetDeltaTime()
	return deltatime
end

game:GetService("RunService").RenderStepped:Connect(function(dt)
	deltatime = dt
	GlobalEvent.Events.Update:Fire(dt)
end)

return module
