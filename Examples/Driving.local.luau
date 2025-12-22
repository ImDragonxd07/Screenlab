local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore)
local Physics = require(game.ReplicatedStorage.ScreenLAB.Engine["Screenlab.Physics"])
local Camera = require(game.ReplicatedStorage.ScreenLAB.Engine["Screenlab.Camera"])

-- Game Settings
engine:CreateScene(script.Name,function()
	Physics.Gravity = 0

	local PlayerSize = UDim2.fromScale(0.03,0.1)
	local carAngle = 0
	local turnSpeed = 90
	local carSpeed = 0.5
	local MaxSpeed = 3
	local WallSize = 0.08
	local WorldSize = 9999
	local CarStartPos = UDim2.fromScale((PlayerSize.X.Scale/2) + 0.5,0.5)
	local RunService = game:GetService("RunService")

	-- Setup

	local Background = engine.Sprite.new()
	Background.Size = UDim2.fromScale(WorldSize,WorldSize)
	Background.Position = UDim2.fromScale(0.5 - (WorldSize / 2), 0.5 - (WorldSize / 2))
	Background.ZIndex = -1

	local BackgroundImage = Instance.new("ImageLabel")
	Background.AddComponent(BackgroundImage,{Image = "http://www.roblox.com/asset/?id=137102731003325", Size = UDim2.fromScale(1,1), ScaleType = Enum.ScaleType.Tile})
	BackgroundImage.TileSize = UDim2.new(0,1920,0,1080)

	local Help = engine.Sprite.new()
	Help.Size = UDim2.fromScale(1,0.1)
	Help.BackgroundTransparency = 1
	Help.SetSpace(engine.Space.Screen)

	local helptext = Help.AddComponent(Instance.new("TextLabel"),{Size = UDim2.fromScale(1,1),TextColor3 = Color3.new(1, 1, 1),TextXAlignment = Enum.TextXAlignment.Left,TextYAlignment = Enum.TextYAlignment.Top,TextScaled = true,BackgroundTransparency = 1})

	local Car = engine.Sprite.new()
	Car.Size = PlayerSize
	Car.Position = CarStartPos
	Car.BackgroundTransparency = 1



	local CarTexture = Car.AddComponent(Instance.new("ImageLabel"),{Image = "http://www.roblox.com/asset/?id=17121590236", Size = UDim2.fromScale(1,1), BackgroundTransparency = 1})

	local CarAudio = Car.AddComponent("Sound"):CreateSound("134924681849657",false,false)
	CarAudio.Looped = true
	CarAudio.Volume = 0
	CarAudio:Play()

	local CarPhysics = Car.AddComponent("Physics")
	CarPhysics.Settings.Simulate = true
	CarPhysics.Forces.Friction = 0.5

	--local CarParticles = Car.AddComponent("ParticleEmitter").Settings
	--CarParticles.Size = UDim2.fromOffset(30,30)

	---- Left Wall
	--local WallL = engine.Sprite.new()
	--WallL.Size = UDim2.fromScale(WallSize, 1)
	--WallL.Position = UDim2.fromScale(0-(WallSize/2), 0)
	--WallL.AddComponent("Physics")

	---- Right Wall
	--local WallR = engine.Sprite.new()
	--WallR.Size = UDim2.fromScale(WallSize, 1)
	--WallR.Position = UDim2.fromScale(1 - (WallSize/2), 0)
	--WallR.AddComponent("Physics")

	---- Top Wall
	--local WallT = engine.Sprite.new()
	--WallT.Size = UDim2.fromScale(1, WallSize)
	--WallT.Position = UDim2.fromScale(0, 0)
	--WallT.AddComponent("Physics")

	---- Bottom Wall
	--local WallB = engine.Sprite.new()
	--WallB.Size = UDim2.fromScale(1, WallSize)
	--WallB.Position = UDim2.fromScale(0, 1 - WallSize)
	--WallB.AddComponent("Physics")


	-- Driving Code
	local Input = require(game.ReplicatedStorage.ScreenLAB.Engine["Screenlab.Input"])
	local Boost = 0
	local cameraFollowPos = Vector2.new(Car.Position.X.Offset, Car.Position.Y.Offset)

	spawn(function()
		while true do
			local dt = RunService.RenderStepped:Wait()
			local Acceleration= CarPhysics:GetVelocity().Magnitude
			CarAudio.Volume = Acceleration / 50
			helptext.Text = "Forward: W \nReverse: S \nBoost: Stop and hold space \nSpeed: " .. math.round(Acceleration)
			local targetTurn = 0
			
			if Input.UnifiedInput.Left.IsDown then
				targetTurn = -1
			elseif Input.UnifiedInput.Right.IsDown then
				targetTurn = 1
			end
			carAngle += targetTurn * turnSpeed * dt
			local radians = math.rad(carAngle)
			local direction = Vector2.new(math.cos(radians), math.sin(radians))
			if Input.UnifiedInput.Up.IsDown then
				CarPhysics:ApplyVelocity(direction * carSpeed * dt * 60)
			elseif Input.UnifiedInput.Down.IsDown then
				CarPhysics:ApplyVelocity(-direction * carSpeed * 0.5 * dt * 60)
			elseif Input.UnifiedInput.Jump.IsDown and Acceleration < 0.1 then
				Boost += 0.5
				CarAudio.Volume = Boost / 50
			else
				CarPhysics:ApplyVelocity(direction * Boost)
				Boost = 0
			end
			local carPos = Vector2.new(Car.Position.X.Offset, Car.Position.Y.Offset)
			local lerpSpeed = 1 - math.exp(-Acceleration * 0.5)
			cameraFollowPos = cameraFollowPos:Lerp(carPos, lerpSpeed * dt * 5)
			Camera:SetPosition(-cameraFollowPos)
			Car.Rotation = carAngle
		end
	end)


end):Load()
