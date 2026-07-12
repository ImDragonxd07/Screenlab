local component = {}
component.__index = component
function component.New()
	local self = setmetatable({}, component) 
	self.Add = function(spritedata, playerData) -- ONLY USED BY ENGINE. Create new func for user use
		print("add")
	end

	self.Remove = function(spritedata) -- ONLY USED BY ENGINE. Create new func for user use
		print("remove")
	end
	return self
end

return component
