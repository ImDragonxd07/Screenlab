-- Old code, could be made more efficent with the newer engine features

local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore)
local physicsengine = require(game.ReplicatedStorage.ScreenLAB.Engine["Screenlab.Physics"])
local Input = require(game.ReplicatedStorage.ScreenLAB.Engine["Screenlab.Input"])

local scene = engine:CreateScene(script.Name,function()
	local ts = game:GetService("TweenService")
	local bg = engine.Sprite.new()
	bg.Size = UDim2.new(1,0,1,0)
	bg.BorderSizePixel = 0
	bg.AddComponent(Instance.new("ImageLabel"),{Image ="rbxassetid://18126135985", BorderSizePixel = 0 ,Size = UDim2.fromScale(1,1)})
	bg.ZIndex = -1


	local bgsound = bg.AddComponent("Sound"):CreateSound("1839361751",true,false)
	bgsound:Play()
	bgsound.Looped = true

	local respawnpos = UDim2.new(0,0,0.6,-100)
	local plr =  engine.Sprite.new()
	plr.Size = UDim2.new(0.08,0,0.08,0)
	plr.Transparency = 1
	plr.Position = respawnpos
	plr.ZIndex = -1

	local ground = engine.Sprite.new()
	ground.Size = UDim2.new(100,0,0.05,0)
	ground.Position = UDim2.new(-50,0,1-0.05,0)
	ground.Name = "ground"
	ground.AddComponent(Instance.new("ImageLabel"),{Image ="rbxassetid://14664545951" ,Size = UDim2.fromScale(1,1)})
	ground.AddComponent("Physics")

	local phys= plr.AddComponent("Physics")
	phys.Settings.Simulate = true
	phys.Forces.AirResistance = 0
	--plr.AddComponent("Light")

	local plrimg = plr.AddComponent(Instance.new("ImageLabel"), {Size = UDim2.fromScale(1,1),Image = "rbxassetid://18126846705"})  -- rbxassetid://18126092149
	plrimg.BackgroundTransparency = 1
	local animator = plr.AddComponent("SpriteAnimator")
	local framedata = animator:CreateAnimatedImage(plrimg,4,9,4*9)
	local dead = false

	local currentlevel = 1

	local Scenes = { -- TEMPORARY UNTILL I IMPLEMENT SCENES
		[1] = {},
		[2] = {}
	}
	local function makeplatform()
		local platform = engine.Sprite.new()
		platform.Size = UDim2.new(0.3,0,0.1,0)
		platform.AddComponent(Instance.new("ImageLabel"),{Image = "rbxassetid://12969210670",Size = UDim2.fromScale(1,1),ScaleType = Enum.ScaleType.Tile,TileSize = UDim2.new(0,100,0,100)})
		platform.AddComponent("Physics")
		return platform
	end

	local plat1 = makeplatform()
	plat1.Position = UDim2.new(0.7,0,0.3,0)
	local plat2 = makeplatform()
	plat2.Position = UDim2.new(-.1,0,0.6,0) 

	table.insert(Scenes[1],plat2)
	local function die()
		dead = true
		plrimg.ImageTransparency = 0
		wait(0.2)
		plrimg.ImageTransparency = 1
		wait(0.2)
		plrimg.ImageTransparency = 0
		wait(0.2)
		plrimg.ImageTransparency = 1
		wait(0.2)
		plrimg.ImageTransparency = 0
		wait(0.2)
		plrimg.ImageTransparency = 1
		wait(0.2)
		plrimg.ImageTransparency = 0
		wait(0.2)
		phys:SetPosition(respawnpos)
		dead = false
	end


	local leveltrigger = engine.Sprite.new()
	leveltrigger.Name = "LevelTrigger"
	leveltrigger.Size = UDim2.new(0,1,0.4,0)
	leveltrigger.Position = UDim2.new(1,-1,0,0)
	leveltrigger.AddComponent("Physics")
	table.insert(Scenes[1],leveltrigger)



	local function NextLevel()
		currentlevel +=1
		respawnpos = UDim2.new(0,0,0.3,-100)
		plat1.Position = UDim2.new(0,0,0.3,0)
		phys:SetPosition(respawnpos)
		for i,v in pairs(Scenes[currentlevel-1]) do
			v:Destroy()
		end
	end

	phys.Settings.OnTouch:Connect(function(obj)
		print(obj.Name)
		if obj.Name == "ground" then
			die()
		end
		if obj.Name == "LevelTrigger" then
			NextLevel()
		end
	end)


	local animationtable={
		Walkleft = {10,11,12,13,14,15,16,17,18},
		Walkright = {28,29,30,31,32,33,34,35,36}
	}
	local currentanimation = nil




	local movingplatform = engine.Sprite.new()
	movingplatform.Size = UDim2.new(0,250,0,50)
	movingplatform.Position = UDim2.new(0.45,0,0.3,0)
	movingplatform.AddComponent(Instance.new("ImageLabel"),{Image = "rbxassetid://12969210670", Size =  UDim2.new(1,0,1,0),ScaleType = Enum.ScaleType.Tile,TileSize = UDim2.new(0,100,0,100)})
	movingplatform.AddComponent("Physics")
	table.insert(Scenes[1],movingplatform)


	if not game:GetService("RunService"):IsStudio() then
		local logo = engine.Sprite.new()
		logo.Size = UDim2.new(1,0,1,0)
		logo.BorderSizePixel = 0
		logo.BackgroundColor3 = Color3.new(0,0,0)
		logo.SetSpace(engine.Space.Screen)
		local txt = logo.AddComponent(Instance.new("TextLabel"))
		txt.Size = UDim2.new(1,0,1,0)
		txt.Font = Enum.Font.Garamond
		txt.Text = "You awake"
		txt.TextXAlignment = Enum.TextXAlignment.Center
		txt.TextYAlignment = Enum.TextYAlignment.Center
		txt.TextScaled = true
		txt.TextColor3 = Color3.new(1,1,1)
		txt.BackgroundTransparency = 1
		txt.BorderSizePixel = 0
		txt.TextTransparency = 1
		logo:Service("TweenService"):Send("Create",txt, TweenInfo.new(2), {TextTransparency = 0}):Play()
		wait(6)
		logo:Service("TweenService"):Send("Create",logo, TweenInfo.new(2), {BackgroundTransparency = 1}):Play()
		logo:Service("TweenService"):Send("Create",txt, TweenInfo.new(2), {TextTransparency = 1}):Play()
		wait(2)
	end


	spawn(function()
		local currentframe = 1
		while wait() do
			if currentanimation ~= nil then
				animator:SetFrame(framedata,currentanimation[currentframe])
				currentframe += 1
				if currentframe > #currentanimation then
					currentframe = 1
				end
			else
				animator:SetFrame(framedata,19)
				currentframe = 1
			end
		end
	end)

	Input.UnifiedInput.Jump.Down:Connect(function()
		if phys.Forces.Grounded and not dead  then
			phys:ApplyVelocity(Vector2.new(0,-20))
		end
	end)

	local movementspeed = 3

	local Camera = require(game.ReplicatedStorage.ScreenLAB.Engine["Screenlab.Camera"])
	Camera:SetScale(Vector2.new(1.5,1.5))

	spawn(function()
		while wait() do
			if Input.UnifiedInput.Left.IsDown and not dead  and phys.Forces.Grounded then
				currentanimation = animationtable.Walkleft
				phys:ApplyVelocity(Vector2.new(-movementspeed,0))
			elseif Input.UnifiedInput.Right.IsDown and not dead and phys.Forces.Grounded then 
				currentanimation = animationtable.Walkright
				phys:ApplyVelocity(Vector2.new(movementspeed,0))
			else
				currentanimation = nil
			end
			local x = plr.Position.X.Offset
			local y = plr.Position.Y.Offset
			local vp = workspace.CurrentCamera.ViewportSize
			Camera:TweenCamera(-Vector2.new(math.clamp(x - (vp.X /2),0, (vp.X /2)),math.clamp(y - (vp.Y/2),0,(vp.Y/2))))
		end
	end)



	spawn(function()
		pcall(function()
			while currentlevel == 1 do
				movingplatform:TweenPosition(UDim2.new(0.45,0,0.3,0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 2)
				wait(4)
				movingplatform:TweenPosition(UDim2.new(0.45,0,0.6,0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, 2)
				wait(4)
			end
		end)
	end)
end)
scene:Load()