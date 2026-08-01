local CrashManager = {}

local Reports = {}
local ErrorCache = {}

local Ui = script.Parent.Parent.Assets.Crashreport
local screengui

local UseCrashHandler = script.Parent.Parent.Settings.UseCrashHandler
local UseCrashHandlerForNonFatal = script.Parent.Parent.Settings.UseCrashHandlerForNonFatal


function CrashManager.SetScreenGui(gui)

	screengui = gui

end


function CrashManager.ShowError(report)
	if not screengui then return end
	local clone = Ui:Clone()
	
	clone.Parent = screengui


	clone.Frame.MainDetails.Text = string.format(
		"Error ID: %s\nSystem: %s\nSeverity: %s\nFatal: %s\nTime: %s",
		report.ID,
		report.System,
		report.Severity,
		tostring(report.Fatal),
		report.Time
	)


	if report.Fatal then

		clone.Frame.ErrorType.Text = "FATAL"

		clone.Frame.ErrorType.BackgroundColor3 =
			Color3.fromRGB(255, 0, 4)

	else

		clone.Frame.ErrorType.Text = "NON FATAL"

		clone.Frame.ErrorType.BackgroundColor3 =
			Color3.fromRGB(193, 193, 193)

	end


	clone.Frame.FullError.Text =
		report.Message


	for _, v in ipairs(report.Callstack or {}) do

		local item = clone.Frame.CallstackItem:Clone()

		item.Text = v

		item.Parent = clone.Frame.ScrollingFrame

		item.Visible = true

	end


	pcall(function()
		clone.Frame.Sound:Play()
	end)

end


local function createHash(report)

	return table.concat({
		report.System or "Unknown",
		report.Message or "Unknown"
	}, "|")

end


function CrashManager.Report(report)

	if not UseCrashHandler.Value then

		error(
			report.Message or "Unknown ScreenLab Error",
			0
		)

	end


	if not report.Fatal and not UseCrashHandlerForNonFatal.Value then

		warn(
			report.Message or "Unknown ScreenLab Error"
		)

		return report

	end


	local hash = createHash(report)

	local cached = ErrorCache[hash]


	if cached then

		cached.Count += 1

		cached.LastSeen =
			os.date("%Y-%m-%d %H:%M:%S")


		if screengui then

			CrashManager.ShowError(
				cached,
				screengui
			)

		end


		return cached

	end


	report.ID =
		#Reports + 1

	report.Time =
		os.date("%Y-%m-%d %H:%M:%S")

	report.LastSeen =
		report.Time

	report.Count =
		1


	table.insert(
		Reports,
		report
	)


	ErrorCache[hash] =
		report


	if screengui then

		CrashManager.ShowError(
			report,
			screengui
		)

	else

		warn(string.format(
[[
================================
        SCREENLAB ERROR
================================

ID:
%s

System:
%s

Category:
%s

Severity:
%s

Fatal:
%s

Message:
%s

Traceback:
%s

================================
]],
			report.ID or "Unknown",
			report.System or "Unknown",
			report.Category or "Unknown",
			report.Severity or "Unknown",
			tostring(report.Fatal),
			report.Message or "Unknown",
			report.Traceback or "No traceback"
			))

	end


	return report

end


function CrashManager.GetReports()

	return Reports

end


function CrashManager.GetReport(id)

	return Reports[id]

end


function CrashManager.GetLatest()

	return Reports[#Reports]

end


function CrashManager.Clear()

	table.clear(Reports)

	table.clear(ErrorCache)

end


return CrashManager