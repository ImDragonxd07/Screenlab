local module = {}
local Types = require(script.Parent.Editor["Screenlab.Types"])
local Events = require(script.Parent["Screenlab.Event"])
local ContextActionService = game:GetService("ContextActionService")



module.UnifiedInput = {
	Left = "Left"  :: Types.InputBinding,
	Right = "Right"  :: Types.InputBinding,
	Down = "Down"  :: Types.InputBinding,
	Up = "Up"  :: Types.InputBinding,
	Jump = "Jump"  :: Types.InputBinding,
	Crouch = "Crouch"  :: Types.InputBinding,
	Sprint = "Sprint"  :: Types.InputBinding,
	Interact = "Interact"  :: Types.InputBinding,
	Click = "Click" :: Types.InputBinding
}



local BindDefinitions = {
	Left = { Enum.KeyCode.A, Enum.KeyCode.Left},
	Right = { Enum.KeyCode.D, Enum.KeyCode.Right},
	Down = { Enum.KeyCode.S, Enum.KeyCode.Down},
	Up = { Enum.KeyCode.W, Enum.KeyCode.Up },
	Jump = { Enum.KeyCode.Space, Enum.KeyCode.ButtonA},
	Crouch = { Enum.KeyCode.C, Enum.KeyCode.ButtonB },
	Sprint = { Enum.KeyCode.LeftShift, Enum.KeyCode.Thumbstick1 },
	Interact = { Enum.KeyCode.E, Enum.KeyCode.ButtonX },
	Click = {Enum.UserInputType.MouseButton1, Enum.KeyCode.ButtonR2, Enum.UserInputType.Touch }
}

local function AddBinding(actionName, keys)
	local DownEvent = Events:New()
	local UpEvent = Events:New()
	local ChangedEvent = Events:New()
	local IsDown = false
	ContextActionService:BindAction(
		tostring(script.Name .. "." .. actionName),
		function(_, inputState)
			ChangedEvent:Fire(inputState)
			if inputState == Enum.UserInputState.Begin then
				DownEvent:Fire()
				IsDown = true
			elseif inputState == Enum.UserInputState.End then
				UpEvent:Fire()
				IsDown = false
			end
		end,
		false,
		unpack(keys)
	)
	module.UnifiedInput[actionName] = setmetatable({}, {
		__index = function(_, key)
			if key == "Down" then
				return DownEvent
			elseif key == "Up" then
				return UpEvent
			elseif key == "IsDown" then
				return IsDown
			elseif key == "Changed" then
				return ChangedEvent
			elseif key == "Bindings" then
				return BindDefinitions[actionName]
			elseif key == "Destroy" then
				return function()
					ContextActionService:UnbindAction(tostring(script.Name .. "." .. actionName))
					DownEvent:Destroy()
					UpEvent:Destroy()
				end
			end			
			return tostring(actionName)
		end,
		__newindex = function(_, key, value)
			if key == "Bindings" then
				BindDefinitions[actionName] = value
				ContextActionService:UnbindAction(tostring(script.Name .. "." .. actionName))
				ContextActionService:BindAction(
					tostring(script.Name .. "." .. actionName),
					function(_, inputState)
						if inputState == Enum.UserInputState.Begin then
							DownEvent:Fire()
							IsDown = true
						elseif inputState == Enum.UserInputState.End then
							UpEvent:Fire()
							IsDown = false
						end
					end,
					false,
					unpack(value)
				)
			else
				error("Cannot modify property: " .. tostring(key))
			end
		end,
		__tostring = function()
			return tostring(actionName)
		end,
	})

end


for actionName, keys in pairs(BindDefinitions) do
	AddBinding(actionName,keys)
end

module.CreateBind = function(name, bindings)
	if module.UnifiedInput[name] then
		error("Binding with name '" .. tostring(name) .. "' already exists.")
	end
	BindDefinitions[name] = bindings
	AddBinding(name, bindings)
end

module.GetBinding = function(UnifiedInput)
	local action = module.UnifiedInput[tostring(UnifiedInput)]
	if action then
		return action.Bindings
	else
		error("Invalid input action: " .. tostring(UnifiedInput))
	end
end

module.SetBinding = function(UnifiedInput, BindTable)
	local action = module.UnifiedInput[tostring(UnifiedInput)]
	if action then
		action.Bindings = BindTable
	else
		error("Invalid input action: " .. tostring(UnifiedInput))
	end
end

return module
