local module = {}



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
	local VPSize = workspace.CurrentCamera.ViewportSize
	local Engine = require(script.Parent.Parent.ScreenlabCore)
	local newpos = UDim2.fromOffset(pos.X, pos.Y)
	module.CurrentCamera.Position.udim2 = newpos
	module.CurrentCamera.Position.vector2 = Vector2.new(newpos.X.Offset,newpos.Y.Offset)
	Engine.playerData.ScreenLabWindow.Position = newpos
end

function module:SetScale(scale)
	local Engine = require(script.Parent.Parent.ScreenlabCore)
	local newsize = UDim2.fromScale(scale.X,scale.Y)
	module.CurrentCamera.Size.udim2 = newsize
	module.CurrentCamera.Size.vector2 = scale
	Engine.playerData.ScreenLabWindow.Size = newsize
end

function module:TweenCamera(playerPos, speed)
	local currentPos = module.CurrentCamera.Position.vector2
	local followSpeed = speed or 0.1
	local newPos = currentPos:Lerp(playerPos, followSpeed)
	module:SetPosition(newPos)
end





return module
