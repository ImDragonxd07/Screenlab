local PhysicsEngine = require(script.Parent.Engine["Screenlab.Physics"])
local Hooking = require(script.Parent.Engine["Screenlab.Hooking"])
local Types = require(script.Parent.Engine.Editor["Screenlab.Types"])
local GlobalEvents = require(script.Parent.Engine["Screenlab.GlobalEvent"])
local Time = require(script.Parent.Engine["Screenlab.Time"])
local module = {}


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
local VERSION = "1.0 BETA"
local LOADED = false
local function GetPlayerScreenGUI(Player)
	return Player:WaitForChild('PlayerGui')
end




local function err(code)
	local targetScript, originLevel
	pcall(function()
		local level = 2
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
		" • Error Name     : " .. tostring(code),
		" • Error Code #   : " .. errorIndex,
		" • Origin Script  : " .. (targetScript and targetScript:GetFullName() or "Unknown"),
		" • Stack Level    : " .. tostring(originLevel or "N/A"),
		"════════════════════ TRACEBACK ════════════════════",
		traceback,
		"═══════════════════════════════════════════════════",
		"\n"
	} 
	error(table.concat(lines, "\n"))
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
	
	
	-- PROPERTIES
	local ObjectHooks = {}
	local Object =  properties.Object or (properties.Object == nil and nil)
	self.Components = properties.Components or (properties.Components == nil and {}) 
	self.Space = module.Space.World
	self.ReadOnly = {
		UniqueId = GenerateID()
	}
	table.freeze(self.ReadOnly)

	
	-- FUNCTIONS
	
	local function CanScriptGetObj(env)
		return env.script:IsDescendantOf(script.Parent)
	end

	local CreateFunctionHook = function(name,scr,func)
		table.insert(ObjectHooks,{name,scr,func})
	end
	
	self.GetObject =function(ins)
		if CanScriptGetObj(getfenv(2)) then
			return Object
		end
		warn("Objects cannot be accesed through external functions")
		return  self.GetObject
	end	
	self.SetParent = function(sprite)
		Object.Parent = sprite.GetObject()
	end
	function self.AddComponent( componentinst, properties)
		if typeof(componentinst) == "Instance" then
			componentinst.Parent = Object
			if properties then
				for prop, value in pairs(properties) do
					componentinst[prop] = value
				end
			end
			--return err(ErrCodes.ERR_COMPONENT_NOT_FOUND) --ROBLOX COMPONENT
			--local rblxcomponent = Instance.new(componentname)
			--rblxcomponent.Parent = Object
			--return rblxcomponent
			return componentinst
		else			
			local inst = script.Parent.Engine.Components:FindFirstChild(componentinst);
				local req = require(inst)
				if req.Max then
				if #self.GetComponentsByType(componentinst) + 1 > req.Max then
						return err(ErrCodes.ERR_MAX_COMPONENT_TYPE_REACHED)
					end
				end

			local component = req.New()
			component["ScreenLabComponentInstance"] = inst.Name
			component.Add(self,module.playerData)
			Hooking.CreateHook(component,"Remove",self.RemoveComponent,component)
			table.insert(self.Components,component)
			return component

		end
	end
	
	self.SetSpace = function(Space : Types.Space)
		if Space == module.Space.Screen then
			Object.Parent = module.playerData.CameraSpace
		elseif Space == module.Space.World then
			Object.Parent = module.playerData.ScreenLabWindow.Sprites
		else
			return err(ErrCodes.ERR_INVALID_SPACE)
		end
		self.Space = Space
	end
	
	self.GetSpace = function()
		return self.Space
	end
	
	self.GetComponentsByType = function(name)
		local components = {}
		for i,v in pairs(self.Components) do
			if v["ScreenLabComponentInstance"] == name then
				table.insert(components,v)

			end
		end
		return components
	
	end
	
	self.RemoveComponent = function(componentinstance) -- pass require(script component here) ex. Requre(script)
		if table.find(self.Components,componentinstance) then
			Hooking.RemoveHook(componentinstance,"Remove")
			componentinstance.Remove(self)
			table.remove(self.Components,table.find(self.Components,componentinstance))
		else
			return err(ErrCodes.ERR_COMPONENT_NOT_FOUND)
		end

	end
	-- REGISTER
	local tblpos = #module.Sprites + 1
	module.Sprites[tblpos] = self

	
	self.REGISTER = function()
		if not module.playerData.ScreenLabWindow then
			return err(ErrCodes.ERR_GET_WINDOW)
		end
		if not self.Object then
			local obj = Instance.new("Frame")
			obj.Position = UDim2.new(0,0,0,0)
			obj.Size = UDim2.new(0.1,0,0.1,0)
			obj.BorderSizePixel = 0
			Object = obj
		end
		Object.Destroying:Connect(function()
			local components = table.clone(self.Components)
			for i,v in pairs(components) do
				self.RemoveComponent(v)
			end
			module.Sprites[tblpos] = nil
			setmetatable(self, nil)
			table.clear(self)
			table.freeze(self)
		end)
		self.SetSpace(module.Space.World)
		--if self.Simulate or not self.Static then
		--	PhysicsEngine.RegisterSprite(self)
		--end
		for i,v in pairs(self.Components) do
			self.AddComponent("",v)
		end
		

		
		
	end


	self.REGISTER()
	
	local InternalFuncs = {
		["Object"] = function() return Object end,
		["CreateFunctionHook"] = CreateFunctionHook,
	} 
	
	function self:Service(serviceName)
		local service = game:GetService(serviceName)
		local tbl = {}
		function tbl:Send(...)
			local args = table.pack(...)
			local name = args[1]
			for i, v in ipairs(args) do
				if type(v) == "table" and v["GetObject"] then
					args[i] = v["GetObject"]()
				end
			end
			table.remove(args,1)
			local ret= service[name](service,table.unpack(args))
			return ret
		end
		return tbl
	end
	
		
	-- Metamethods
	setmetatable(self, {
		__newindex = function(ttbl, key, value)
			local override = false
			if Object[key] then
				for i,v in pairs(ObjectHooks) do
					local hookvarname = v[1]
					local scr = v[2]
					local callbackfunc = v[3]
					if not require(scr)[callbackfunc](value) then
						override = true
					end
				end

			end
			if not override then
				Object[key] = value
				return Object[key]
			end
		end, 
		__index = function(t, key)
			if InternalFuncs[key] then
				if CanScriptGetObj(getfenv(2)) then
					return function(...)
						return InternalFuncs[key](...)
					end
				else
					warn("Cannot call engine funcs from game scripts (" .. key..")")
					return nil
				end
			end
			if typeof(Object[key]) == "function" then
				if Object[key] then
					return function(self, ...)
						return Object[key](Object, ...) 
					end				
				end
			else
				return Object[key]
			end
		end
	}) 
	
	
	GlobalEvents.Events.NewObj:Fire(self)
	
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
			require(intro.Frame.LoadManager).show(VERSION,script.Parent, game:GetService("RunService"):IsStudio() and not script.Parent.Settings.ShowIntroInStudio.Value)
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
		local success, err = pcall(scene.Code, scene)
		if not success then
			warn("Error loading scene:", err)
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
		local Base = Instance.new("Frame")
		Base.Name = "ScreenLabBase"
		Base.BorderSizePixel = 0
		Base.Size = UDim2.new(1,0,1,0)
		Base.Transparency  = 1
		Base.AnchorPoint = Vector2.new(0,0)
		Base.Parent = tmpwindow
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

