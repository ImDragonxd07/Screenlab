local module = {}

local Engine = require(script.Parent.Parent.Parent.ScreenlabCore)
local Camera = require(script.Parent.Parent["Screenlab.Camera"])
local Delaunay = require(script.Parent.Parent.Dependencies["Screenlab.Extern.Delaunay"])

module.Settings = {
	DbgPolys = false,

}


module.Delaunay = Delaunay

module.RenderLayers = {}

module.TotalRenders = 0

module.RenderRect = function(RenderLayer, p1,p2,color)
	if RenderLayer.Removing then return end
	local key = tostring(p1) .. tostring(p2)
	if RenderLayer.Rects[key] then
		RenderLayer.RectBuffer[key] = RenderLayer.Rects[key]
		return RenderLayer.Rects[key][3]
	end
	print("new")
	module.TotalRenders += 1
	local rect = Instance.new("Frame")
	local width = math.abs(p2.x - p1.x)
	local height = math.abs(p2.y - p1.y)
	local midPoint = (p1 + p2) / 2
	rect.AnchorPoint = Vector2.new(0.5, 0.5)
	rect.Position = UDim2.new(0, midPoint.x, 0, midPoint.y) - Camera.CurrentCamera.Position.udim2
	rect.BorderSizePixel = 0
	rect.Size = UDim2.new(0, width, 0, height)
	rect.BackgroundColor3 = module.Settings.DbgPolys and Color3.new(0, 1, 0) or color
	rect.Parent = Engine.playerData.Tmp
	RenderLayer.Rects[key] = {p1,p2,rect}
	return rect
end

module.RenderLine = function(RenderLayer, p1,p2,thickness,color)
	if RenderLayer.Removing then return end
	local key = tostring(p1) .. tostring(p2)
	if RenderLayer.Lines[key] then
		RenderLayer.LineBuffer[key] = RenderLayer.Lines[key]
		return RenderLayer.Lines[key][3]
	end
	module.TotalRenders += 1
	local line = Instance.new("Frame")
	local length = (p2 - p1).magnitude
	local midPoint = (p1 + p2) / 2
	local angle = math.deg(math.atan2(p2.y - p1.y, p2.x - p1.x))

	line.Size = UDim2.new(0, length, 0, thickness)
	line.Position = UDim2.new(0, midPoint.x, 0, midPoint.y) - Camera.CurrentCamera.Position.udim2
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.BackgroundColor3 = module.Settings.DbgPolys and Color3.new(0, 1, 0) or color
	line.BorderSizePixel = 0
	line.Rotation = angle
	line.Parent = Engine.playerData.Tmp
	RenderLayer.Lines[key] = {p1,p2,line}
	return line

end


module.RenderPoly = function(RenderLayer,a, b, c, color)
	if RenderLayer.Removing then return end
	local key = tostring(a)..tostring(b)..tostring(c)
	
	
	-- If polygon already exists, reuse from PolyBuffer
	if RenderLayer.Polys[key] ~= nil then
		RenderLayer.PolyBuffer[key] = RenderLayer.Polys[key]
		return RenderLayer.Polys[key][1], RenderLayer.Polys[key][2]
	end
	module.TotalRenders += 1

	local HALF = Vector2.new(0.5, 0.5)
	local IMG = Instance.new("ImageLabel")
	IMG.BackgroundTransparency = 1
	IMG.AnchorPoint = HALF
	IMG.BorderSizePixel = 0

	local RIGHT = "rbxassetid://319692151"
	local LEFT = "rbxassetid://319692171"

	local ab, ac, bc = b - a, c - a, c - b
	local abd, acd, bcd = ab:Dot(ab), ac:Dot(ac), bc:Dot(bc)

	if abd > acd and abd > bcd then
		c, a = a, c
	elseif acd > bcd and acd > abd then
		a, b = b, a
	end

	ab, ac, bc = b - a, c - a, c - b

	local unit = bc.unit
	local height = unit:Cross(ab)
	local flip = height >= 0
	local theta = math.deg(math.atan2(unit.y, unit.x)) + (flip and 0 or 180)

	local m1 = (a + b) / 2
	local m2 = (a + c) / 2

	local w1 = IMG:Clone()
	w1.Image = flip and RIGHT or LEFT
	w1.AnchorPoint = HALF
	w1.Size = UDim2.new(0, math.abs(unit:Dot(ab)), 0, height)
	w1.Position = UDim2.new(0, m1.x, 0, m1.y) - Camera.CurrentCamera.Position.udim2
	w1.Rotation = theta
	w1.BorderSizePixel = 0
	w1.ImageColor3 = module.Settings.DbgPolys and Color3.new(1, 1, 1) or color
	w1.Parent = Engine.playerData.Tmp
	
		local borderThickness = 5

	local function edgeExists(p1, p2)
		for _, edge in pairs(RenderLayer.Lines) do
			if (edge[1] == p1 and edge[2] == p2) or (edge[1] == p2 and edge[2] == p1) then
				return true
			end
		end
		return false
	end

	local function createEdgeFrame(p1, p2)
		if edgeExists(p1, p2) then return end
		return module.RenderLine(RenderLayer,p1, p2, borderThickness, Color3.new(0, 0, 0))
	end
	createEdgeFrame(a, b)
	createEdgeFrame(b, c)
	createEdgeFrame(c, a)
	
	local w2 = IMG:Clone()
	w2.Image = flip and LEFT or RIGHT
	w2.AnchorPoint = HALF
	w2.Size = UDim2.new(0, math.abs(unit:Dot(ac)), 0, height)
	w2.Position = UDim2.new(0, m2.x, 0, m2.y) - Camera.CurrentCamera.Position.udim2
	w2.Rotation = theta
	w2.BorderSizePixel = 0
	w2.ImageColor3 = module.Settings.DbgPolys and Color3.new(0, 0, 0) or color
	w2.Parent = Engine.playerData.Tmp
	RenderLayer.Polys[key] = {w1, w2}

	return w1, w2
end



local dbgkeyenable = false
game:GetService("UserInputService").InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F2 and script.Parent.Parent.Parent.Settings.EnableDebugKeys.Value then
		dbgkeyenable = not dbgkeyenable
		module.Settings.DbgPolys = dbgkeyenable
	end
end)


local RenderLayer = {}
RenderLayer.__index = RenderLayer
module.NewRenderLayer = function()
	local self = setmetatable({}, RenderLayer) 
	
	self.LineBuffer = {}
	self.Lines = {}
	self.PolyBuffer = {}
	self.Polys = {}
	self.RectBuffer = {}
	self.Rects = {}
	
	self.NewFrame = function()
		for key, v in pairs(self.Polys) do
			if not self.PolyBuffer[key] then
				v[1]:Destroy()
				v[2]:Destroy()
				self.Polys[key] = nil
			end
		end
		for key, v in pairs(self.PolyBuffer) do
			self.Polys[key] = v
		end
		table.clear(self.PolyBuffer)
		for key, v in pairs(self.Lines) do
			if not self.LineBuffer[key] then
				v[3]:Destroy()
				self.Lines[key] = nil
			end
		end
		for key, v in pairs(self.LineBuffer) do
			self.Lines[key] = v
		end
		table.clear(self.LineBuffer)
		for key, v in pairs(self.Rects) do
			if not self.RectBuffer[key] then
				v[3]:Destroy()
				self.Rects[key] = nil
			end
		end
		for key, v in pairs(self.RectBuffer) do
			self.Rects[key] = v
		end
		table.clear(self.RectBuffer)
	end

	
	local tblpos = #module.RenderLayers + 1
	
	self.LayerPos = tblpos
	module.RenderLayers[tblpos] = self
	
	self.Removing = false
	self.Remove = function()
		self.Removing = true
		self.NewFrame()
		table.clear(self.PolyBuffer)
		for key, v in pairs(self.Polys) do
			v[1]:Destroy()
			v[2]:Destroy()
		end
		table.clear(self.LineBuffer)
		for key, v in pairs(self.Lines) do
			v[3]:Destroy()
		end
		table.clear(self.Lines)
		table.clear(self.RectBuffer)
		for key, v in pairs(self.Rects) do
			v[3]:Destroy()
		end
		table.clear(self.Rects)
		table.remove(module.RenderLayers, tblpos)
	end

	
	return self
end





return module
