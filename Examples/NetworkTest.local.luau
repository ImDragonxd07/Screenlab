local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore)
local input = require(game.ReplicatedStorage.ScreenLAB.Engine["Screenlab.Input"])
local MovementSpeed = 4


engine:CreateScene(script.Name,function()
	--LOCAL PLAYER
	local function CreatePlayer(plr)
		local player = engine.Sprite.new()
		player.Size = UDim2.fromScale(.1,.1)
		player.Position = UDim2.fromScale(.5,.5)
		player.AddComponent(Instance.new("TextLabel"),{
			Text = plr.Name,
			Size = UDim2.fromScale(1,1),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Center,
			TextYAlignment = Enum.TextYAlignment.Center
		})	
		plr.PlayerRemoving:Connect(function(plr)
			player:Destroy()
		end)
		return player
	end

	local localplayer = CreatePlayer(game.Players.LocalPlayer)

	--MOVEMENT
	spawn(function()
		while true do
			if input.UnifiedInput.Left.IsDown then
				localplayer.Position += UDim2.fromOffset(-MovementSpeed,0)
			end
			if input.UnifiedInput.Right.IsDown then
				localplayer.Position += UDim2.fromOffset(MovementSpeed,0)
			end
			if input.UnifiedInput.Up.IsDown then
				localplayer.Position += UDim2.fromOffset(0,-MovementSpeed)
			end
			if input.UnifiedInput.Down.IsDown then
				localplayer.Position += UDim2.fromOffset(0,MovementSpeed)
			end
			wait()
		end
	end)

	--NETWORKING
	local function NetworkPlayer(sprite,plr)
		local spritenetwork = sprite.AddComponent("Networking")
		spritenetwork.Settings = {
			ReplicatedProperties = {"Position"},
			ObjectNetworkId = plr.UserId,
			Target = "ALL"
		}
		spritenetwork.Start()
		return spritenetwork
	end

	for i,v in pairs(game.Players:GetPlayers()) do
		if v ~= game.Players.LocalPlayer then
			NetworkPlayer(CreatePlayer(v),v)
		end
	end

	game.Players.PlayerAdded:Connect(function(plr)
		NetworkPlayer(CreatePlayer(plr),plr)
	end)



	NetworkPlayer(localplayer,game.Players.LocalPlayer).ClaimObject()
end):Load()