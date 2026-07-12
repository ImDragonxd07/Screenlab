local using = require(script.Parent.Using)

local module = {}

local Engine = using("ScreenlabCore")

module.ClampToScreen = false

module.CurrentCamera = {
	Position = {
		vector2 = Vector2.new(),
		udim2 = UDim2.new()
	},
	Size = {
		vector2 = Vector2.new(workspace.CurrentCamera.ViewportSize.X,workspace.CurrentCamera.ViewportSize.Y),
		udim2 = UDim2.fromScale(workspace.CurrentCamera.ViewportSize.X,workspace.CurrentCamera.ViewportSize.Y)
	},
}

function module:SetPosition(pos)
	local vp = workspace.CurrentCamera.ViewportSize
	local worldsize = Engine:GetWorldSize()
	local finalX, finalY
	if module.ClampToScreen then
		finalX = math.clamp(pos.X, -(worldsize.X - vp.X), 0)
		finalY = math.clamp(pos.Y, -(worldsize.Y - vp.Y), 0)
	else
		finalX = pos.X
		finalY = pos.Y
	end
	local newpos = UDim2.fromOffset(finalX, finalY)
	module.CurrentCamera.Position.udim2 = newpos
	module.CurrentCamera.Position.vector2 = Vector2.new(finalX, finalY)
	Engine.playerData.ScreenLabWindow.Position = newpos
end



function module:SetScale(cameraScale : Vector2)
	local window = Engine.playerData.ScreenLabWindow
	if not window then return end

	local world = Engine:GetWorldSize()
	local viewport = workspace.CurrentCamera.ViewportSize

	-- 1. Screen-fit scale (automatic, same on all devices)
	local fitX = viewport.X / world.X
	local fitY = viewport.Y / world.Y
	local screenScale = math.min(fitX, fitY)

	-- 2. Final scale (screen * camera)
	local finalScaleX = screenScale * cameraScale.X
	local finalScaleY = screenScale * cameraScale.Y

	window.Size = UDim2.fromOffset(
		world.X * finalScaleX,
		world.Y * finalScaleY
	)
	-- Store camera scale (for physics / transforms)
	module.CurrentCamera.Size.vector2 = cameraScale
end

function module:TweenCamera(playerPos, speed)
	local currentPos = module.CurrentCamera.Position.vector2
	local followSpeed = speed or 0.1
	local newPos = currentPos:Lerp(playerPos, followSpeed)
	module:SetPosition(newPos)
end

return module