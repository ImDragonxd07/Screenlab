local component = {}
component.Max = 1
component.__index = component
local Replicator = script.Parent.Parent.Parent.Events.P2P.SpriteReplicator
local Claim = script.Parent.Parent.Parent.Events.P2P.ObjectOwnership
function component.New()
	local self = setmetatable({}, component) 
	local data
	self.Settings = {
		ReplicatedProperties = {},
		ObjectNetworkId = nil,
		Target = "ALL"
	}
	local obj
	self.ClaimObject = function ()
		Claim.OnClientEvent:Connect(function(bool)
			return bool
		end)
		Claim:FireServer(self.Settings.Target,true)
	end
	self.UnclaimObject = function ()
		Claim.OnClientEvent:Connect(function(bool)
			return bool
		end)
		Claim:FireServer(self.Settings.Target,false)
	end
	self.Start = function()
		Replicator.OnClientEvent:Connect(function(plr,recieveddata)
			if plr ~= game.Players.LocalPlayer and recieveddata[1] == self.Settings.ObjectNetworkId then
				local data = recieveddata[2]
				for _,v in pairs(data) do
					if obj[v[1]] then
						obj[v[1]] = v[2]
					end
				end
			end
		end)
		local function Update()
			local datatbl = {}
			for _,v in pairs(self.Settings.ReplicatedProperties) do
				table.insert(datatbl,{v,obj[v]})
			end
			Replicator:FireServer(self.Settings.Target,{self.Settings.ObjectNetworkId,datatbl})
		end
		for _,v in pairs(self.Settings.ReplicatedProperties) do
			if obj[v] then
				obj:GetPropertyChangedSignal(v):Connect(Update)
			else
				warn(v .. " is not a valid property of " .. typeof(obj))
			end
		end
	end
	self.Add = function(spritedata, playerData) -- ONLY USED BY ENGINE. Create new func for user use
		data = spritedata
		obj = data.Object()
		if self.Settings.ObjectNetworkId == nil then
			self.Settings.ObjectNetworkId =  spritedata.ReadOnly.UniqueId
		end
	end
	self.Remove = function(spritedata) -- ONLY USED BY ENGINE. Create new func for user use
	end

	
	return self
end

return component
