local HookModule = {}
local originalFunctions = {}

function HookModule.CreateHook(targetTable, functionName, hookFunction, hookargs) -- STOLEN FROM ANOTHER ONE OF MY PROJECTS
	hookargs = hookargs or nil
	if type(targetTable) ~= "table" then
		error("Target table must be a table", 2)
	end
	if type(targetTable[functionName]) ~= "function" then
		error("Original function must be a function", 2)
	end
	if type(hookFunction) ~= "function" then
		error("Hook function must be a function", 2)
	end
	local originalFunction = targetTable[functionName]
	originalFunctions[targetTable] = originalFunctions[targetTable] or {}
	originalFunctions[targetTable][functionName] = originalFunction
	local function jmp(...)
		if hookargs then
			return hookFunction(hookargs)
		end
		return hookFunction(...)
	end
	local originalEnv = getfenv(originalFunction)
	local hookEnv = getfenv(hookFunction)
	local combinedEnv = setmetatable({}, {
		__index = function(t, k)
			return hookEnv[k] or originalEnv[k]
		end,
		__newindex = function(t, k, v)
			if hookEnv[k] ~= nil then
				hookEnv[k] = v
			else
				originalEnv[k] = v
			end
		end
	})
	setfenv(hookFunction, combinedEnv)
	targetTable[functionName] = jmp
	--print("[HOOKING] " .. tostring(originalFunction) .. " -> " .. tostring(hookFunction) .. " (as " .. functionName .. ")")
end

function HookModule.RemoveHook(targetTable, functionName)
	if type(targetTable) ~= "table" then
		error("Target table must be a table", 2)
	end
	if type(targetTable[functionName]) ~= "function" then
		error("Function to unhook must be a function", 2)
	end
	if not originalFunctions[targetTable] or not originalFunctions[targetTable][functionName] then
		error("No original function stored for this hook", 2)
	end
	targetTable[functionName] = originalFunctions[targetTable][functionName]
	originalFunctions[targetTable][functionName] = nil

	--print("[UNHOOKING] Restored " .. functionName .. " to original function")
end

return HookModule
