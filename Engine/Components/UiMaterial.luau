local component = {}
component.Max = 1

component.__index = component
function component.New()
	local self = setmetatable({}, component) 
	
	local sprite = nil
	local renderer = require(script.Parent.Parent.Dependencies["Screenlab.Extern.UiMaterial"])

	self.SetMaterial = function(RobloxMaterial)
		if sprite then
			renderer:BindFrame(sprite,RobloxMaterial,{Transparency =sprite.BackgroundTransparency;
				BrickColor = BrickColor.new(sprite.BackgroundColor3);})
		else
			warn("No sprite to bind to")
		end

	end

	self.Add = function(spritedata, playerData) -- ONLY USED BY ENGINE. Create new func for user use
		sprite = spritedata.Object()
	end

	self.Remove = function(spritedata) -- ONLY USED BY ENGINE. Create new func for user use
		renderer:Cleantraces(sprite)
	end
	return self
end

return component
