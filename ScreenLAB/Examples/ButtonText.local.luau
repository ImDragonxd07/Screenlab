local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore)

engine:CreateScene(script.Name,function()
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromScale(1,1)
	engine.Sprite.new().AddComponent(button)
	local clicks = 0
	button.MouseButton1Click:Connect(function()
		clicks+=1
		button.Text = tostring(clicks)
	end)
end):Load()
