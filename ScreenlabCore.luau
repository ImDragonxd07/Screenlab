local using = require(script.Parent.Engine.Using)
local module = {}

local Hooking = using("Screenlab.Hooking")
local Types = using("Screenlab.Types")
local GlobalEvents = using("Screenlab.GlobalEvent")
local Time = using("Screenlab.Time")

local ErrCodes = {
	ERR_INVALID_PLAYER = "ERR_INVALID_PLAYER",
	ERR_CREATE_WINDOW = "ERR_CREATE_WINDOW",
	ERR_NON_REGISTERED_PLAYER = "ERR_NON_REGISTERED_PLAYER",
	ERR_GET_WINDOW = "ERR_GET_WINDOW",
	ERR_COMPONENT_NOT_FOUND = "ERR_COMPONENT_NOT_FOUND",
	ERR_MAX_COMPONENT_TYPE_REACHED = "ERR_MAX_COMPONENT_TYPE_REACHED",
	ERR_NO_SCENEBUNDLE_NAME = "ERR_NO_SCENEBUNDLE_NAME",
	ERR_BUNDLE_ALREADY_EXISTS = "ERR_BUNDLE_ALREADY_EXISTS",
	ERR_INVALID_SPACE = "ERR_INVALID_SPACE"
}

-- SCREENLAB INTERNAL
local VERSION = "1.1 BETA"
local LOADED = false
local function GetPlayerScreenGUI(Player)
	return Player:WaitForChild('PlayerGui')
end

local function err(code)
	local targetScript, originLevel
	local baselevel = 2
	pcall(function()
		local level = baselevel
		while level < 100 do
			local success, env = pcall(getfenv, level)
			if not success or not env then break end

			if typeof(env.script) == "Instance" and env.script ~= script then
				targetScript = env.script
				originLevel = level
				break
			end

			level += 1
		end
	end)
	local traceback = debug.traceback()
	local errorIndex = tostring(table.find(ErrCodes, code) or "Unknown")
	local lines = {
		"\n",
		"╔══════════════════════════════════════════════╗",
		"            🛠️  SCREENLAB ERROR REPORTER       ",
		"╚══════════════════════════════════════════════╝",
		" • Time           : " .. os.date("%Y-%m-%d %H:%M:%S"),
		" • Error Name     : " .. tostring(code),
		" • Error Code #   : " .. errorIndex,
		" • Origin Script  : " .. (targetScript and targetScript:GetFullName() or "Unknown"),
		" • Stack Level    : " .. tostring(originLevel or "N/A") .. " (+"..baselevel..")", --+2 because we ignore first 2 layers as they would just be this function but still show this for debugging reasons
		"════════════════════ TRACEBACK ════════════════════",
		traceback,
		"═══════════════════════════════════════════════════",
		"All errors are treated as non fatal",
		"\n"
	} 
	warn(table.concat(lines, "\n"))
	return code
end

			   
local lastid = 0
local GenerateID = function ()
	lastid+=1
	return lastid
end
local assets = script.Parent.Assets

local function deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local introshown = false
-- SCREENLAB API

module.DeviceType = {
	Console = "Console",
	PC = "PC",
	Mobile = "Mobile",
	Unknown = "Unknown"
} :: Types.DeviceType

module.Space = {
	World = "World",
	Screen = "Screen"
} :: Types.Space

module.GetCurrentDeviceType = function()
	local UserInputService = game:GetService("UserInputService")
	if(game:GetService("GuiService"):IsTenFootInterface()) then
		return module.DeviceType.Console
	elseif UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled then
		return module.DeviceType.Mobile
	elseif not UserInputService.TouchEnabled and UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then
		return module.DeviceType.PC
	else
		return module.DeviceType.Unknown
	end
end

module.GetVersion = function()
	return VERSION
end

module.playerData = {
	ScreenLabWindow = nil,
	PlayerInstance = nil,
	ScreenLabBaseUI = nil,
	ScreenlabCore = module,
	Sprites = nil,
	Tmp = nil,
	CameraSpace = nil
}

module.ConsoleSettings = {
	UseCustomConsole = true,
	ShowCallstackInGame = true
}

module.Sprites = {}

module.Sprite = {}

module.Sprite.__index = module.Sprite

local function CanScriptGetObj(level)
	return true
end



function module.Sprite.new(properties) : Types.Sprite
	properties = properties or {}
	local self = setmetatable({}, module.Sprite) 

	-- 1. INTERNAL DATA 
	local _Methods = {
		VirtualPosition = Vector2.new(0,0),
		VirtualSize = Vector2.new(0,0),
		Position = UDim2.new(0,0,0,0),
		Size = UDim2.new(0,0,0,0),
		Space = properties.Space or module.Space.World,
		Components = properties.Components or {}
	}
	local Object = properties.Object

	-- 2. SECURED/EXPOSED FUNCTIONS
	self["[SECURED]_Object"] = function() return Object end
	self["[SECURED]_GetObject"] = function() return Object end
	self["[SECURED]_Methods"] = _Methods

	self.ReadOnly = table.freeze({
		UniqueId = GenerateID()
	})

	self.GetComponentsByType = function(typeName)
		local found = {}
		for _, comp in ipairs(_Methods.Components) do
			if comp.ScreenLabComponentInstance == typeName then
				table.insert(found, comp)
			end
		end
		return found
	end

	self["[EXPOSED]_SetParent"] = function(sprite)
		local target = sprite.GetObject() 
		if target and Object then
			Object.Parent = target
		end
	end

	self["[EXPOSED]_AddComponent"] = function(componentinst, properties)
		if typeof(componentinst) == "Instance" then
			componentinst.Parent = Object
			if properties then
				for prop, value in pairs(properties) do
					componentinst[prop] = value
				end
			end
			return componentinst
		else			
			local inst = script.Parent.Engine.Components:FindFirstChild(componentinst)
			if not inst then return warn("Component not found: " .. tostring(componentinst)) end

			local req = require(inst)
			local component = req.New()
			component["ScreenLabComponentInstance"] = inst.Name
			component.Add(self, module.playerData)
			table.insert(_Methods.Components, component) -- Store in _Methods
			return component
		end
	end

	self["[EXPOSED]_SetSpace"] = function(Space)
		if Space == module.Space.Screen then
			Object.Parent = module.playerData.CameraSpace
		elseif Space == module.Space.World then
			Object.Parent = module.playerData.ScreenLabWindow.Sprites
		end
		_Methods.Space = Space
	end

	self["[SECURED]_REGISTER"] = function()
		if not Object then
			local obj = Instance.new("Frame")
			obj.Position = UDim2.new(0,0,0,0)
			obj.Size = UDim2.new(0.1,0,0.1,0)
			obj.BorderSizePixel = 0
			Object = obj
		end

		Object.Destroying:Connect(function()
			local idx = table.find(module.Sprites, self)
			if idx then table.remove(module.Sprites, idx) end
			setmetatable(self, nil)
		end)

		---- Initial Sync
		--_Methods.VirtualPosition = Transform.ToVirtual(Object.Position)
		--_Methods.VirtualSize = Transform.ToVirtual(Object.Size)
		--_Methods.Position = Object.Position
		--_Methods.Size = Object.Size

		self["[EXPOSED]_SetSpace"](module.Space.World)
	end

	setmetatable(self, {
		__index = function(t, key)
			local tag = rawget(t, "[SECURED]_"..key) or rawget(t, "[EXPOSED]_"..key)
			if tag then return tag end
			local localVal = rawget(t, key)
			if localVal ~= nil then return localVal end
			if Object then
				return Object[key]
			end
			if _Methods[key] ~= nil then
				return _Methods[key]
			end
		end,
		__newindex = function(t, key, value)
			if key:sub(1,1) == "[" or key == "ReadOnly" then
				rawset(t, key, value)
				return
			end

			if Object then
				--if key == "VirtualPosition" then
				--	local s = Transform.ToScreen(value)
				--	_Methods.VirtualPosition, _Methods.Position = value, s
				--	Object.Position = s
				--	return
				--elseif key == "VirtualSize" then
				--	local s = Transform.ToScreenSize(value)
				--	_Methods.VirtualSize, _Methods.Size = value, s
				--	Object.Size = s
				--	return
				--elseif key == "Position" then
				--	_Methods.Position, Object.Position = value, value
				--	_Methods.VirtualPosition = Transform.ToVirtual(value)
				--	return
				--elseif key == "Size" then
				--	_Methods.Size, Object.Size = value, value
				--	_Methods.VirtualSize = Transform.ToVirtualSize(value)
				--	return
				--end
				pcall(function() Object[key] = value end)
			else
				_Methods[key] = value
			end
		end
	})

	self["[SECURED]_REGISTER"]()
	return self
end


module.CoreUI ={
	Topbar = nil
}

module.GetSpriteFromUniqueId = function(id)
	for i,v in pairs(module.Sprites) do
		if v.ReadOnly.UniqueId == id then
			return v
		end
	end
end

local function UpdateConsole(log,linenum)
	local count = 0
	
	GlobalEvents.Events.Update:Connect(function()
		count += 1
	end)
	
	while wait(1) do
		local str = [[

███████╗ ██████╗██████╗ ███████╗███████╗███╗   ██╗██╗      █████╗ ██████╗ 
██╔════╝██╔════╝██╔══██╗██╔════╝██╔════╝████╗  ██║██║     ██╔══██╗██╔══██╗
███████╗██║     ██████╔╝█████╗  █████╗  ██╔██╗ ██║██║     ███████║██████╔╝
╚════██║██║     ██╔══██╗██╔══╝  ██╔══╝  ██║╚██╗██║██║     ██╔══██║██╔══██╗
███████║╚██████╗██║  ██║███████╗███████╗██║ ╚████║███████╗██║  ██║██████╔╝
╚══════╝ ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═════╝ 
                                                                                  
]]
		log.UpdateLine(linenum,str .. "\n -> Screen Lab (ver " .. VERSION .. ")" .. "\n -> User: " .. module.playerData.PlayerInstance.Name .. "\n -> SpriteCount " .. #module.Sprites .. "\n -> Systime " .. os.time().. "\n -> FPS " .. count .. "\n -> DeltaTime " .. Time:GetDeltaTime() .. "\n -> Platform " .. module.GetCurrentDeviceType())
		count = 0
	end
end

module.Console = nil

module.RegisterPlayer = function (Player)
	if LOADED then return end
	
	if not table.find(game.Players:GetChildren(),Player) then
		return err(ErrCodes.ERR_INVALID_PLAYER)
	else
		module.playerData.PlayerInstance = Player
		local screengui = GetPlayerScreenGUI(module.playerData.PlayerInstance)
		if introshown == false then
			local intro = script.Parent.Assets.Intro:Clone()
			intro.Parent = screengui
			require(intro.Frame.LoadManager).show(module,VERSION,script.Parent, game:GetService("RunService"):IsStudio() and not script.Parent.Settings.ShowIntroInStudio.Value)
			introshown = true
		else
			local provider = game:GetService("ContentProvider")
			repeat wait() until provider.RequestQueueSize == 0 and game.Loaded
		end
		if module.ConsoleSettings.UseCustomConsole then
			local sole = require(script.Parent.Engine["Screenlab.Console"])
			local log = sole.Start(screengui,module.ConsoleSettings)
			sole.SetVersion(module.GetCurrentDeviceType() .. tostring(module.GetVersion()) .. "-" .. string.gsub(DateTime.now():FormatLocalTime("L","en-us"),"/","-") .. "(" .. game.GameId .. ")")
			module.Console = log
			
			local logolinenum = log.Print("",Color3.new(0.301961, 1, 0))
			task.spawn(UpdateConsole,log,logolinenum)
		else
			local str = [[
		
⠀⠀____⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀_⠀⠀⠀⠀⠀⠀⠀⠀_⠀⠀⠀⠀____⠀⠀
⠀/⠀___|⠀⠀___⠀_⠀__⠀___⠀⠀___⠀_⠀__⠀|⠀|⠀⠀⠀⠀⠀⠀/⠀\⠀⠀|⠀__⠀)⠀
⠀\___⠀\⠀/⠀__|⠀'__/⠀_⠀\/⠀_⠀\⠀'_⠀\|⠀|⠀⠀⠀⠀⠀/⠀_⠀\⠀|⠀⠀_⠀\⠀
⠀⠀___)⠀|⠀(__|⠀|⠀|⠀⠀__/⠀⠀__/⠀|⠀|⠀|⠀|___⠀/⠀___⠀\|⠀|_)⠀|
⠀|____/⠀\___|_|⠀⠀\___|\___|_|⠀|_|_____/_/⠀⠀⠀\_\____/⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]
			warn("####################",str,"\n-> Screen Lab (ver " .. VERSION .. ")","\n-> User " .. Player.Name,"\n-> Systime " .. os.time().. "\n -> Platform " .. module.GetCurrentDeviceType())
			warn("####################")
		end
		return module.playerData.PlayerInstance
	end
end
module.LockPlayer = function()
	if not module.playerData.PlayerInstance then
		return err(ErrCodes.ERR_NON_REGISTERED_PLAYER)
	else
		module.playerData.PlayerInstance.CharacterAdded:Connect(function()
			local Character = module.playerData.PlayerInstance.Character or module.playerData.PlayerInstance.CharacterAdded:Wait()
			Character:WaitForChild("HumanoidRootPart").Anchored = true
		end)
		local Character = module.playerData.PlayerInstance.Character or module.playerData.PlayerInstance.CharacterAdded:Wait()
		Character:WaitForChild("HumanoidRootPart").Anchored = true
		workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
	end
end

local Scenes = {}

function module:CreateScene(name, func)
	local scene = {}
	local SceneSprites = {}
	local SavedValues = {}
	scene.Name = name
	scene.Code = func

	function scene:Load()
		local originalSpriteNew = module.Sprite.new
		module.Sprite.new = function(...)
			local sprite = originalSpriteNew(...)
			table.insert(SceneSprites, sprite)
			return sprite
		end
		local success, sceneerror = pcall(scene.Code, scene)
		if not success then
			warn("Error loading scene:", sceneerror)
			err("Unknown")
		end
		module.Sprite.new = originalSpriteNew
	end

	function scene:Unload()
		for _, sprite in ipairs(SceneSprites) do
			sprite:Destroy()
		end
		table.clear(SceneSprites)
	end

	function scene:Destroy()
		scene:Unload()
		Scenes[name] = nil
		for k in pairs(scene) do
			scene[k] = nil
		end
	end

	function scene:Reload()
		scene:Unload()
		scene:Load()
	end

	Scenes[name] = scene
	return scene
end

function module:GetWorldSize()
	return Vector2.new(1920,1080)
end

function module:GetScene(name)
	return Scenes[name]
end

function module:GetScenes()
	return Scenes
end

module.CreatePlayerUI = function()
	if LOADED then return end
	if not module.playerData.PlayerInstance then
		return err(ErrCodes.ERR_NON_REGISTERED_PLAYER)
	else
		local tmpwindow = Instance.new("ScreenGui")
		tmpwindow.Name = "ScreenLabUI"
		tmpwindow.IgnoreGuiInset = false
		tmpwindow.ResetOnSpawn = false
		local Base = Instance.new("Frame",tmpwindow)
		Base.Name = "ScreenLabBase"
		Base.BorderSizePixel = 0
		local worldsize = module:GetWorldSize()
		Base.Size = UDim2.fromOffset(worldsize.X,worldsize.Y)
		Base.Transparency  = 1
		Base.AnchorPoint = Vector2.new(0,0)
		local core = Instance.new("Folder",Base)
		core.Name = "Core"
		local bg = Instance.new("Frame",tmpwindow)
		bg.BackgroundColor3 = Color3.new()
		bg.BorderSizePixel = 0
		bg.Size = UDim2.new(1,game:GetService("GuiService"):GetGuiInset().X,1,game:GetService("GuiService"):GetGuiInset().Y)
		bg.Position = UDim2.new(0,0,0,-game:GetService("GuiService"):GetGuiInset().Y)
		bg.ZIndex = -100
		local sprites = Instance.new("Folder",Base)
		sprites.Name = "Sprites"
		module.playerData.Sprites = sprites
		local Tmp = Instance.new("Folder",Base)
		Tmp.Name = "Tmp"
		module.playerData.Tmp = Tmp
		local CameraSpace = Instance.new("Frame",tmpwindow)
		CameraSpace.Name = "CameraSpace"
		CameraSpace.Size = UDim2.fromScale(1,1)
		CameraSpace.BackgroundTransparency = 1
		CameraSpace.ZIndex = 100
		module.playerData.CameraSpace = CameraSpace
		local tmpparent = GetPlayerScreenGUI(module.playerData.PlayerInstance)
		if not tmpparent then
			return err(ErrCodes.ERR_CREATE_WINDOW)
		else
			tmpwindow.Parent = tmpparent
			module.playerData.ScreenLabWindow = Base
			module.playerData.ScreenLabBaseUI = tmpwindow
			return Base
		end
	end
end

local function INIT()
	if not LOADED then
		module.RegisterPlayer(game.Players.LocalPlayer)
		module.LockPlayer()
		module.CreatePlayerUI()
		GlobalEvents.Events.GameStarted:Fire()
		LOADED = true
	end
end


-- ROBLOX FUNCS

INIT() -- EXECUTE WHEN REQUIRE IS CALLED

return module :: Types.Engine

