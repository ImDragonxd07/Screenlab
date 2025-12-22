local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore)

engine:CreateScene(script.Name,function()

	local toggle = true

	engine.ShowIntroInStudio = false
	engine.RegisterPlayer(game:GetService("Players").LocalPlayer)
	engine.CreatePlayerUI()
	engine.LockPlayer()

	local bg = engine.Sprite.new()
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.new(0.498039, 0.498039, 0.498039)
	bg.ZIndex = -1

	local tob = engine.Sprite.new()
	tob.Size = UDim2.new(0, 50, 0, 100)
	tob.Position = UDim2.new(0.2, 0, 0.1, 0)
	tob.Name = "first"
	tob.BackgroundColor3 = Color3.new(0, 1, 0)

	local testobj = engine.Sprite.new()
	testobj.Size = UDim2.new(0, 50, 0, 200)
	testobj.Position = UDim2.new(0.6, 0, 0, 0)
	testobj.Name = "second"


	local lightref = engine.Sprite.new()
	lightref.Size = UDim2.new(0, 50, 0, 50)
	lightref.Position = UDim2.new(0.35, 0, 0.1, 0)
	lightref.BackgroundColor3 = Color3.new(0.403922, 0.403922, 0.403922)
	lightref.Name = "light"
	lightref.ZIndex = -1

	local lightref2 = engine.Sprite.new()
	lightref2.Size = UDim2.new(0, 50, 0, 50)
	lightref2.Position = UDim2.new(0.35, 0, 0.1, 0)
	lightref2.BackgroundColor3 = Color3.new(0.403922, 0.403922, 0.403922)
	lightref2.Name = "lightref2"
	lightref2.ZIndex = -1

	local img = Instance.new("ImageLabel");
	img.BackgroundTransparency = 1;
	img.BorderSizePixel = 0;


	lightref.AddComponent("Light")
	lightref2.AddComponent("Light")

	game:GetService("UserInputService").InputBegan:Connect(function(inp)
		if inp.KeyCode == Enum.KeyCode.Space then
			toggle = not toggle
		end
	end)

	game:GetService("Players").LocalPlayer:GetMouse().Move:Connect(function()
		local x = game:GetService("Players").LocalPlayer:GetMouse().X
		local y = game:GetService("Players").LocalPlayer:GetMouse().y
		lightref.Position = UDim2.fromOffset(x,y)
		if toggle then
			lightref2.Position = UDim2.fromOffset(x + 400,y)
		end
	end)
end):Load()