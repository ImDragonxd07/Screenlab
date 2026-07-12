local module = {}

local objects = {}

local function getownership(plr,objid)
	if objects[objid] == plr then
		return true
	else
		if objects[objid] == nil then
			objects[objid] = plr
			print("[ScreenLABServer] Set object " .. objid  .. " ownership to " .. plr.Name)
			return true
		else
			return false
		end
	end
end
module.OnEvent = function(plr,target,data,eventinstance)
	local obectnetworkid = data[1]
	local objectpropertytable  = data[2]
	if eventinstance.Name == "SpriteReplicator" then
		if getownership(plr,obectnetworkid) then
			if target == "ALL" then
				eventinstance:FireAllClients(plr,data)
			else
				eventinstance:FireClient(target,plr,data)
			end
		end
	else -- ObjectOwnership
		if data == true then
			eventinstance:FireClient(plr,getownership(plr,obectnetworkid))
		else
			if getownership(plr,obectnetworkid) then
				objects[obectnetworkid] = nil
				eventinstance:FireClient(plr,true)
			else
				eventinstance:FireClient(plr,false)
			end
		end
	end
end

return module
