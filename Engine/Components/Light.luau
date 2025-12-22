local component = {}
component.__index = component
local light = require(script.Parent.Parent["Screenlab.Lighting"])
function component.New()
	local self = setmetatable({}, component) 
	local obj
	
	self.Settings = {
		Intensity = math.huge,
		Data = nil
	}
		
	self.Add = function(spritedata, playerData) -- ONLY USED BY ENGINE. Create new func for user use
		obj = spritedata.Object
		self.Settings.Data = spritedata
		light.AddLight(obj,self)
	end

	self.Remove = function(spritedata) -- ONLY USED BY ENGINE. Create new func for user use
		light.RemoveLight(obj)
	end
	return self
end

return component
