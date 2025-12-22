local component = {}
component.__index = component
local util = require(script.Parent.Parent["Screenlab.Util"])
local rs = game:GetService("RunService")

function component.New()
	local self = setmetatable({}, component) 
	local particles = {}
	
	self.Settings = {
		Size = UDim2.new(0,50,0,50),
		StartPosition = nil,
		ParticleTransparency = 1,
		Lifespan = 5,
		Image = "7145697379",
		MaxParticles = 10,
		SpawnRange = Vector2.new(80,0),
		SpawnTime = 0.3,
		Acceleration = Vector2.new(0,-2),
		Velocity = 2,
		StartTime = 0,
		LockToParent = false
	}
	local Active = false
	local function CreateParticle(spritedata,playerData)
		spawn(function()
			local frame = Instance.new("Frame")
			table.insert(particles,frame)
			frame.Destroying:Connect(function()
				table.remove(particles,table.find(particles,frame))
			end)
			local particlelifespan = self.Settings.StartTime
			frame.BorderSizePixel = 0
			frame.Size = self.Settings.Size
			frame.BackgroundTransparency = self.Settings.ParticleTransparency
			frame.Parent = spritedata.Object()
			frame.Position = self.Settings.StartPosition or spritedata.Object().Position
			frame.ZIndex = 2
			frame.AnchorPoint = Vector2.new(0.5,0)
			if self.Settings.Image then
				local img = Instance.new("ImageLabel",frame)
				img.BackgroundTransparency = self.Settings.ParticleTransparency
				img.Size = UDim2.new(1,0,1,0)
				img.Image = util.StringToAssetId(self.Settings.Image)
				img.BorderSizePixel = 0
			end
			local angleX =  math.random(-self.Settings.SpawnRange.X,self.Settings.SpawnRange.X)
			local angleY = math.random(-self.Settings.SpawnRange.Y,self.Settings.SpawnRange.Y)
			local angle = Vector2.new(math.sin(math.rad(angleX)),math.cos(math.rad(angleY)))
			frame.Rotation = -angleX
			if not self.Settings.LockToParent then
				frame.Position = UDim2.fromOffset(frame.AbsolutePosition.X,frame.AbsolutePosition.Y)
				frame.Parent = playerData.Tmp
			end
			while particlelifespan <= self.Settings.Lifespan and frame do
				particlelifespan += 1/40
				local accel = particlelifespan
				local dx = ( (self.Settings.Velocity * accel) + (self.Settings.Acceleration.X * (accel ^ 2) / 2) ) * angle.X
				local dy = ( (self.Settings.Velocity * accel) + (self.Settings.Acceleration.Y * (accel ^ 2) / 2) ) * angle.Y
				frame.Position += UDim2.fromOffset(dx,dy)
				rs.Heartbeat:Wait()
			end
			table.remove(particles,table.find(particles,frame))
			frame:Destroy()
		end)
	end
	
	self.Add = function(spritedata, playerData) -- ONLY USED BY ENGINE. Create new func for user use
		Active = true
		spawn(function()
			while Active do
				if #particles <= self.Settings.MaxParticles  then
					CreateParticle(spritedata,playerData)
				end
				wait(self.Settings.SpawnTime)
			end
		end)
	end

	self.Remove = function(spritedata) -- ONLY USED BY ENGINE. Create new func for user use
		Active = false
		self.Settings.MaxParticles = 0
		for i,v in pairs(particles) do
			v:Destroy()
		end
	end
	return self
end

return component
