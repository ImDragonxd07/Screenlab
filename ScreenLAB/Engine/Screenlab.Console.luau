local module = {}

local screenlabconsole = script.Parent.Parent.Assets.ScreenlabConsole
module.SetVersion =function(ver)
	screenlabconsole.Versiontext.Text = tostring(ver)
end

module.MaxLogs = 300


module.Start = function(screengui,csettings)
	local internalfuncs = {}

	local StarterGui = game:GetService("StarterGui")
	local userInputService = game:GetService("UserInputService")
	local contextActionService = game:GetService("ContextActionService")
	local logservice = game:GetService("LogService")
	local function RblxTypeToColor(mtype)

		local switch = {
			[Enum.MessageType.MessageInfo] = Color3.new(0, 0.733333, 1),
			[Enum.MessageType.MessageError] = Color3.new(1, 0, 0.0156863),
			[Enum.MessageType.MessageWarning] = Color3.new(0.984314, 1, 0),
			[Enum.MessageType.MessageOutput] = Color3.new(1, 1, 1),
			["default"] = Color3.new(1, 1, 1)
		}

		if switch[mtype] then
			return switch[mtype]
		else
			return switch["default"]
		end
	end
	local msgbox = screenlabconsole.Frame.Frame.ScrollingFrame
	local function GetCurrTime()
		return string.format("%02d:%02d:%02d", os.date("*t").min, os.date("*t").sec, (os.clock() * 100) % 100)
	end
	local function makeprinttext(txt,mtime)
		return "["..tostring(mtime).."] ".. txt
	end
	local function max()
		local children = msgbox:GetChildren()
		if #children < module.MaxLogs then
			return
		end
		local extra = #children - module.MaxLogs
		for i=extra,1,-1 do
			if children[i]:IsA("TextLabel") then
				children[i]:Destroy()
			end
		end
	end
	local function log(txt,color,mtime)
		max()
		color = color or Color3.new(1,1,1)
		mtime = mtime or GetCurrTime()
		local newmsg = screenlabconsole.Frame.Frame.msg:Clone()
		newmsg.Text = makeprinttext(txt,mtime)
		newmsg.TextColor3 = color
		newmsg.Visible = true
		newmsg.Parent = msgbox
		newmsg.Traceback.Value = debug.traceback("CALLSTACK",3)
		newmsg.MouseEnter:Connect(function()
			newmsg.BackgroundTransparency = 0.8
		end)
		newmsg.MouseLeave:Connect(function()
			newmsg.BackgroundTransparency = 1
		end)
		return table.find(msgbox:GetChildren(),newmsg)
	end
	logservice.MessageOut:Connect(function(mmsg,mmtype)
		log(mmsg,RblxTypeToColor(mmtype))
	end)


	local function FrameUpdate()
		StarterGui:SetCore("DevConsoleVisible", false)
	end
	screenlabconsole.Parent = screengui
	screenlabconsole.Frame.Visible = false

	userInputService.InputBegan:Connect(function(inp)
		if inp.KeyCode == Enum.KeyCode.F9 then
			FrameUpdate()
			screenlabconsole.Frame.Visible = not screenlabconsole.Frame.Visible 
			screenlabconsole.Frame.Frame.ScrollingFrame.CanvasPosition  = Vector2.new(0,9999)
		end
	end)
	internalfuncs.Print = function(msg,color,mtime)
		return log(msg,color,mtime)
	end
	internalfuncs.UpdateLine = function(Linenumber,msg)
		msgbox:GetChildren()[Linenumber].Text = makeprinttext(msg,GetCurrTime())
	end
	local tooltip = screenlabconsole.Frame.tooltip
	tooltip.ZIndex = 2
	tooltip.Visible = false
	local mouse = game:GetService("Players").LocalPlayer:GetMouse()
	mouse.Move:Connect(function()
		local MousePos = game:GetService("UserInputService"):GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
		local getGUI = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetGuiObjectsAtPosition(MousePos.X,MousePos.Y)
		local hovermsg = false
		for i,v in pairs(getGUI) do
			if v.Name == "msg" and v.Traceback then
				hovermsg = csettings.ShowCallstackInGame or game:GetService("RunService"):IsStudio()
				tooltip.Text = v.Traceback.Value
			end
		end
		tooltip.Visible = hovermsg
		tooltip.Position = UDim2.new(0,MousePos.X,0,MousePos.Y + tooltip.Size.Y.Offset)
	end)
	return internalfuncs
end



return module

