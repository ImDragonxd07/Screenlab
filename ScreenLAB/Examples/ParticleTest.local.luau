local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore)

engine:CreateScene(script.Name,function()
	local particlebox = engine.Sprite.new()
	particlebox.Size = UDim2.fromScale(0.1,0.1)
	particlebox.Position = UDim2.fromScale(0.45,0.7)

	local particles = particlebox.AddComponent("ParticleEmitter")
	particles.Settings.StartPosition = UDim2.fromScale(0.5,0)
	particles.Settings.StartTime = 2
	particles.Settings.Acceleration = Vector2.new(1,0)
	particles.Settings.Image = "137084906563680"
end):Load()