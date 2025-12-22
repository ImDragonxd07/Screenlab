local component = {}
component.__index = component
local physics = require(script.Parent.Parent["Screenlab.Physics"])

function component.New()
	local self = setmetatable({}, component) 
	local Event = require(script.Parent.Parent["Screenlab.Event"])
	
	self.Settings = {
		Simulate = false,
		OnTouch = Event:New(),
		Register = true,
		CollisionGroup = "Default",
		Data = nil,
		printdbg = false,
	}
	self.Forces = {
		Enable = true,
		VelocityEvent = Event:New(),
		PositionEvent = Event:New(),
		Grounded = false,
		Friction = 0.1,
		AirResistance = 0.01,
		Bounciness = 0.3,
		CurrentVelocity = Vector2.new()
	}
	
	function self:ApplyVelocity(vel)
		self.Forces.VelocityEvent:Fire(vel)
	end
	
	function self:SetPosition(pos)
		self.Forces.PositionEvent:Fire(pos)
	end
	
	function self:GetVelocity()
		return self.Forces.CurrentVelocity
	end
	
	self.Add = function(spritedata, playerData) -- ONLY USED BY ENGINE. Create new func for user use
		self.Settings.Data = spritedata
		physics.RegisterSprite(self)
	end

	self.Remove = function(spritedata) -- ONLY USED BY ENGINE. Create new func for user use
		print("Object is being destroyed and unregistered")
		self.Settings.Register = false
	end
	
	return self
end

return component
