local component = {}
component.__index = component

local audiodriver = require(script.Parent.Parent.Drivers["Screenlab.Drivers.Audio"])

function component.New()
	local self = setmetatable({}, component) 
	
	local object = nil
	local plrdata = nil
	local objspritedata = nil
	self.Object = nil

	--local Tmp3d = script.Parent.Parent.Parent.Runtime.Tmp3d
	local obj3d
	local sound
	local function simulate3daudio (sound,obj,sim3d)
		obj3d = Instance.new("Part",workspace)
		obj3d.Name = "SimulatedSoundObject"
		obj3d.Anchored = true
		obj3d.CanCollide = false
		obj3d.Transparency = 1
		obj3d.Size = Vector3.zero
		obj3d.Position = workspace.CurrentCamera.CFrame.Position
		sound.Parent = obj3d
		local camera = workspace.CurrentCamera

		local function Update(obj)
			if obj3d then
				local offset = camera:ScreenPointToRay(obj.AbsolutePosition.X,obj.AbsolutePosition.Y,0)
				obj3d.Position = offset.Origin
			end

		end
		obj:GetPropertyChangedSignal("Position"):Connect(function(pos)
			Update(obj)
		end)
		workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
			Update(obj)
		end)
		Update(obj)

	
	end
	local function cleanup()
		self.Object = nil
		if sound then
			sound:Destroy()
		end
		if obj3d then
			obj3d:Destroy()
		end
		sound = nil
		obj3d = nil
	end
	self.Remove = function(spritedata)
		cleanup()
	end
	function self:CreateSound(soundid, audio2d, destroyoncomplete)
		audio2d = audio2d or false -- default 3d
		destroyoncomplete = destroyoncomplete or false 
		if not sound then
			if object ~= nil and plrdata ~= nil then
				sound= Instance.new("Sound")
				local realid = require(script.Parent.Parent["Screenlab.Util"]).StringToAssetId(soundid)

				sound.SoundId = realid
				self.Object = sound
				local Driverobj = nil
				if audio2d then
					Driverobj = audiodriver.NewSound2d(object,sound)
					--sound.Parent = object
				else
					Driverobj = audiodriver.NewSound3d(object,sound)
					--simulate3daudio(sound,object,plrdata.Simulated3d)
				end
				sound.Destroying:Connect(function()
					cleanup()
				end)
				if destroyoncomplete then
					sound.Ended:Connect(function()
						cleanup()
					end)
				end
				return Driverobj
			end
		else
			warn("You can not create another sound on this sound component untill the other one has been removed")
		end
	end

	self.Add = function(spritedata, playerData)
		object = spritedata.Object()
		objspritedata = spritedata
		plrdata =  playerData
	end
	return self
end

return component
