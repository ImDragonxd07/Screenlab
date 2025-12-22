local module = {}

local Compiler = require(script.Parent.Dependencies["Screenlab.Extern.Compiler"])

local Engine = require(script.Parent.Parent.ScreenlabCore)

module.Execute = function(str)
	if not script.Parent.Parent.Settings.AllowRuntimeCodeExecution.Value then
		warn("Code execution attempted without setting AllowRuntimeCodeExecution to true")
	else
		local executable, compileFailReason = Compiler(str)()
		if(compileFailReason) then
			warn(compileFailReason)
		end
	end
end

return module
