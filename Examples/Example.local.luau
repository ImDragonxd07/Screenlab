--[[
	Example program made for screenlab 1.0
	12/7/25
]]

local engine = require(game.ReplicatedStorage.ScreenLAB.ScreenlabCore) -- Call the engine and load it
local Input = require(game.ReplicatedStorage.ScreenLAB.Engine["Screenlab.Input"])

local Background = engine.Sprite.new() -- Create a new sprite for the background
Background.Size = UDim2.fromScale(1,1) -- Make the background fill the screen
Background.ZIndex = -1 -- Set the background to z layer -1
Background.BackgroundColor3 = Color3.new(0,0,0) -- Chnage the background color to black

local BackgroundText = Background.AddComponent(Instance.new("TextLabel")) -- Add a roblox textlabel as a component
BackgroundText.Size = UDim2.fromScale(1,1) -- Set text size to fill background sprite
BackgroundText.BackgroundTransparency = 1 -- Set the background to be transparent
BackgroundText.TextScaled = true -- Scale the text to fit the screen
BackgroundText.TextColor3 = Color3.new(1,1,1) -- Make the text color white
BackgroundText.Text = "Cube Game" -- Make the text say "Cube Game"

local Ground = engine.Sprite.new() -- Create the floor for our cube to interact with
Ground.Position = UDim2.fromScale(0,.9) -- Set Ground position to bottom of the screen
Ground.Size = UDim2.fromScale(1,0.1) -- Change Ground size to fill bottom of screen
Ground.AddComponent("Physics") -- Register ground in physics engine so the cube will react with it

local Cube = engine.Sprite.new() -- Create a cube
Cube.Size = UDim2.fromScale(.05,.05) -- Set the cubes size
Cube.BackgroundColor3 = Color3.new(1,0,0) -- Make the cube red so it stands out

local CubePhysics = Cube.AddComponent("Physics") -- Register cube in physics engine
CubePhysics.Settings.Simulate = true -- Make cube react to physics

local Mouse = game:GetService("Players").LocalPlayer:GetMouse() -- Get the players mouse

Input.UnifiedInput.Click.Down:Connect(function() -- Fied when the player presses the left mouse button
	CubePhysics:SetPosition(UDim2.fromOffset(Mouse.X,Mouse.Y)) -- Move cube to mouse when button 1 is pressed (SetPosition is required as it is simulated in physics)
end)