local component = {}
component.__index = component

function component.New()
	local self = setmetatable({}, component) 
	local objspritedata = nil

	self.Create = function(imageid,mode)

		local label = Instance.new("ImageLabel", objspritedata.Object())
		if not imageid then
			imageid = "15589765056"
		end
		if mode then
			label.ScaleType = Enum.ScaleType[mode]
		end
		if mode == "Tile" then
			label.TileSize = UDim2.new(0,100,0,100)
		end
		label.Size = UDim2.new(1,0,1,0)
		label.Image = require(script.Parent.Parent["Screenlab.Util"]).StringToAssetId(imageid)
		return label
	end

	self.Add = function(spritedata, playerData)
		objspritedata = spritedata
	end

	self.Remove = function(spritedata)

	end
	return self
end

return component
