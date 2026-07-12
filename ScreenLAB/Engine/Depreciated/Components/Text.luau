local component = {}
component.__index = component

function component.New()
	local self = setmetatable({}, component) 
	local label
	local sdata
	
	self.Create = function()
		label = Instance.new("TextLabel",sdata.Object())
		label.ZIndex = 2
		label.BorderSizePixel = 0
		label.BackgroundTransparency = 1
		label.Size = UDim2.fromScale(1,1)
		return label
	end
	self.Add = function(spritedata, playerData) -- ONLY USED BY ENGINE. Create new func for user use
		sdata = spritedata
	end

	self.Remove = function(spritedata) -- ONLY USED BY ENGINE. Create new func for user use
		if label then
			label:Destroy()
		end
	end
	return self
end

return component
