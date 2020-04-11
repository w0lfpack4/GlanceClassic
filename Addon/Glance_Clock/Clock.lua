---------------------------
-- lets simplify a bit..
---------------------------
local gf = Glance.Functions
local gv = Glance.Variables
local ga = Glance.Arrays
local gb = Glance.Buttons

---------------------------
-- create the button
---------------------------
gf.AddButton("Clock","RIGHT")
local btn = gb.Clock
btn.text              = "Clock"
--btn.font              = "Interface\\AddOns\\Glance\\fonts\\digital-7.ttf"
btn.events            = {}
btn.enabled           = true
btn.update            = true
btn.tooltip           = true
btn.click             = true
btn.timer1            = true
btn.menu              = true
btn.save.perAccount   = {["DisplayClock"] = "server", ["Imperial"] = true}

---------------------------
-- shortcuts
---------------------------
local spa = btn.save.perAccount
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip

---------------------------
-- update
---------------------------
function gf.Clock.update()
	local func = gf.Clock
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		local hour, min = GetGameTime()
		local lhour = tonumber(date("%H"))
		local title = ""
		if spa.DisplayClock == "local" then
			title = func.GetHour(lhour)..":"..func.GetMin(min).." "..func.GetAMPM(lhour).." (L)"
		elseif spa.DisplayClock == "date" then
			title = date("%m/%d/%Y")
		else
			title = func.GetHour(hour)..":"..func.GetMin(min).." "..func.GetAMPM(hour).." (S)"
		end
		gf.setButtonText(btn.button,title,"",nil,nil)
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Clock.tooltip()
	Glance.Debug("function","tooltip","Clock")
	local func = gf.Clock
	local hour, min = GetGameTime()
	local lhour = tonumber(date("%H"))
	tooltip.Title("Clock","GLD")
	tooltip.Double("Server Time: ", func.GetHour(hour)..":"..func.GetMin(min).." "..func.GetAMPM(hour), "WHT","GRN")
	tooltip.Double("Local Time: ", func.GetHour(lhour)..":"..func.GetMin(min).." "..func.GetAMPM(lhour), "WHT","GRN")
	tooltip.Double("Date: ", date("%m/%d/%Y"), "WHT","GRN")
	local tbl = {
		[1] = {["Display"]=spa.DisplayClock},
		[2] = {["24 Hour Clock"]=not spa.Imperial},
	}
	tooltip.Options(tbl)
	--(left,shift-left,right,shift-right,other)
	tooltip.Notes(nil,nil,"switch display",nil,nil)
end

---------------------------
-- click
---------------------------
function gf.Clock.click(self, button, down)
	Glance.Debug("function","click","Clock")
	if (button == "LeftButton") then 
		--ToggleCalendar()
	end
end

---------------------------
-- menu
---------------------------
function gf.Clock.menu(level,UIDROPDOWNMENU_MENU_VALUE)
	Glance.Debug("function","menu","Clock")
	level = level or 1
	if (level == 1) then
		gf.setMenuTitle("Clock Options")
		gf.setMenuHeader("Display","display",level)
		gf.setMenuHeader("24 Hour Clock","imperial",level)
	end
	if (level == 2) then
		if gf.isMenuValue("display") then
			gf.setMenuOption(spa.DisplayClock == "local","Local Time","Local Time",level,function() spa.DisplayClock = "local"; gf.Clock.update() end)
			gf.setMenuOption(spa.DisplayClock == "server","Server Time","Server Time",level,function() spa.DisplayClock = "server"; gf.Clock.update() end)
			gf.setMenuOption(spa.DisplayClock == "date","Date","Date",level,function() spa.DisplayClock = "date"; gf.Clock.update() end)
		end
		if gf.isMenuValue("imperial") then
			gf.setMenuOption(spa.Imperial==true,"Off","Off",level,function() spa.Imperial=true; gf.Clock.update() end)
			gf.setMenuOption(spa.Imperial==false,"On","On",level,function() spa.Imperial=false; gf.Clock.update() end)
		end
	end
end

---------------------------
-- Clock Hour function
---------------------------
function gf.Clock.GetHour(hour)
	if spa.Imperial then
		if hour > 12 then
			hour = hour - 12
		end
		if hour == 0 then
			hour = 12
		end
	end
	return hour
end

---------------------------
-- Clock Hour function
---------------------------
function gf.Clock.GetMin(min)
	if min < 10 then
		return "0"..min
	end
	return min
end

---------------------------
-- Clock DST function
---------------------------
function gf.Clock.GetAMPM(hour)
	if spa.Imperial then
		if hour < 12 then
			return "AM"
		else
			return "PM"
		end
	else
		return ""
	end	
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Clock")
end
