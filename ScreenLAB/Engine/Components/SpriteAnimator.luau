local component = {}
component.__index = component
function component.New()
	local self = setmetatable({}, component) 
	
	
	function self:CreateAnimatedImage(img,rows,columns,frames)
		local wrapper = Instance.new("Frame",img.Parent)
		wrapper.BackgroundTransparency = 1
		wrapper.ClipsDescendants = true
		wrapper.Size = UDim2.new(1,0,1,0)
		img.Parent = wrapper
		local tbl = {}
		img.Size =  UDim2.new(columns,0,rows,0)
		local lastFrame = 0
		repeat
			lastFrame = lastFrame + 1
			if lastFrame > frames then lastFrame = 1 end
			local CurrentColumn = lastFrame
			local CurrentRow = 1
			repeat
				if CurrentColumn>columns then
					CurrentColumn = CurrentColumn - columns
					CurrentRow = CurrentRow + 1
				end
			until not(CurrentColumn>columns)
			local pos = UDim2.new(-(CurrentColumn-1),0,-(CurrentRow-1),0)
			table.insert(tbl,pos)
		until lastFrame >= frames
		return {img,tbl}
	end
	function self:SetFrame(tbl,frame)
		local img = tbl[1]
		local selectedframe = tbl[2][frame]
		img.Position = selectedframe
	end
	self.Add = function(spritedata, playerData) -- ONLY USED BY ENGINE. Create new func for user use
	end

	self.Remove = function(spritedata) -- ONLY USED BY ENGINE. Create new func for user use
	end
	return self
end

return component
