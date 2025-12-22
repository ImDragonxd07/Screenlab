local module = {}
module.__index = module

module.PanDistance = 1.5

local SimulatedSound = script.Parent.Parent.Parent.Runtime.SimulatedSound

local function NewSimulatedObj()
	local obj3d = Instance.new("Part",SimulatedSound)
	obj3d.Name = "SimulatedSoundObject"
	obj3d.Anchored = true
	obj3d.CanCollide = false
	obj3d.Transparency = 1
	obj3d.Size = Vector3.zero
	obj3d.Position = workspace.CurrentCamera.CFrame.Position
	return obj3d
end

module.NewSound3d = function(obj,soundref)
	local self = setmetatable({}, module) 
	
	if not obj then
		warn("NewSound3D must pass a 2d object")
		return
	end
	if not soundref then
		warn("NewSound3D must pass a sound instance")
		return
	end

	local obj3d = NewSimulatedObj()

	local function Update(obj)
		if obj3d then
			local offset = workspace.CurrentCamera:ScreenPointToRay(obj.AbsolutePosition.X,obj.AbsolutePosition.Y,0)
			obj3d.Position = offset.Origin
		end
	end

	local function Cleanup()
		obj3d:Destroy()
	end

	self.Destroy = function()
		Cleanup()
	end

	obj.Destroying:Connect(function()
		Cleanup()
	end)

	obj:GetPropertyChangedSignal("Position"):Connect(function(pos)
		Update(obj)
	end)
	workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
		Update(obj)
	end)
	Update(obj)
	soundref.Parent = obj3d
	
	setmetatable(self, {
		__newindex = function(ttbl, key, value)
			soundref[key] = value
			return soundref[key]
		end,
		__index = function(tbl, key)
			if soundref[key] then
				return function(_, ...)
					return soundref[key](soundref, ...)
				end
			else
				return module[key]
			end
		end
	})
	
	return self
end

module.NewSound2d = function(obj, soundref)
	local self = setmetatable({}, module) 
	
	local soundpan = 0
	
	local obj3d = NewSimulatedObj()

	local function Update()
		if obj3d then
			obj3d.CFrame = workspace.CurrentCamera.CFrame
				* CFrame.Angles(0, soundpan, 0)
				* CFrame.new(0, 0, module.PanDistance) --PanDistance is the blend ammount between L and R
			
		end
	end
	
	self.Destroy = function()
		soundref:Destroy()
	end
	
	self.Pan = function(val)
		val = math.clamp(val,-1,1)
		soundpan = val
		Update()
	end
	
	
	obj.Destroying:Connect(function()
		obj3d:Destroy()
	end)
	
	workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(function()
		Update()
	end)
	
	Update()
	
	soundref.Parent = obj3d
		
	setmetatable(self, {
		__newindex = function(ttbl, key, value)
			soundref[key] = value
			return soundref[key]
		end,
		__index = function(tbl, key)
			if soundref[key] then
				return function(_, ...)
					return soundref[key](soundref, ...)
				end
			else
				return module[key]
			end
		end
	})
	return self
end

return module
