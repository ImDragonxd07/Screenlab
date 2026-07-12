local module = {}

local ScreenLab = nil
local ServerEvents = script.Parent.ServerEvents
local RegisteredEvents = {
	{"SpriteReplicator", require(ServerEvents.Object)},
	{"ObjectOwnership",  require(ServerEvents.Object)}
}


local logo = [[
		
⠀⠀____⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀_⠀⠀⠀⠀⠀⠀⠀⠀_⠀⠀⠀⠀____⠀⠀
⠀/⠀___|⠀⠀___⠀_⠀__⠀___⠀⠀___⠀_⠀__⠀|⠀|⠀⠀⠀⠀⠀⠀/⠀\⠀⠀|⠀__⠀)⠀
⠀\___⠀\⠀/⠀__|⠀'__/⠀_⠀\/⠀_⠀\⠀'_⠀\|⠀|⠀⠀⠀⠀⠀/⠀_⠀\⠀|⠀⠀_⠀\⠀
⠀⠀___)⠀|⠀(__|⠀|⠀|⠀⠀__/⠀⠀__/⠀|⠀|⠀|⠀|___⠀/⠀___⠀\|⠀|_)⠀|
⠀|____/⠀\___|_|⠀⠀\___|\___|_|⠀|_|_____/_/⠀⠀⠀\_\____/⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]


local function Log(msg)
	warn("["..DateTime.now():FormatLocalTime("HH:mm:ss", "en-us").."][SCREENLAB SERVER] " .. msg )
end


module.Init = function(ScreenLabFolder)
	local starttime = tick()
	Log("Init")
	Log(logo)
	ScreenLab = ScreenLabFolder
	local p2p = ScreenLab.Events.P2P
	local eventnum = 0
	for _,v in pairs(p2p:GetChildren()) do
		if v:IsA("RemoteEvent") then
			v.OnServerEvent:Connect(function(plr,target,data)
				local eventhandler = nil
				for _,E in pairs(RegisteredEvents) do
					if E[1] == v.Name then
						eventhandler = E[2]
					end
				end
				if eventhandler then
					eventhandler.OnEvent(plr,target,data,v)
				else
					if target == "ALL" then
						Log(plr.Name .. ": fired " .. v.Name .. " with a target of " .. target)
						v:FireAllClients(plr,data)
					else
						Log(plr.Name .. ": fired " .. v.Name .. " with a target of " .. target.Name)
						v:FireClient(target,plr,data)
					end
				end
			end)
			eventnum+=1
		end
	end
	Log("Registered " .. eventnum .. " P2P event/s")
	Log("Finished server init in " .. tick() - starttime)
end

return module
