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
gf.AddButton("Location","RIGHT")
local btn = gb.Location
btn.text              = "Location"
btn.events            = {}
btn.enabled           = true
btn.update            = true
btn.tooltip           = true
btn.click             = true
btn.timer1            = true
btn.menu              = true
btn.save.perAccount   = {["DisplayZone"] = true,["DisplaySubZone"] = true,["DisplayCoords"] = true,["DisplayCoordsPlus"] = true,["DisplaySpeed"] = true}

---------------------------
-- shortcuts
---------------------------
local spa = btn.save.perAccount
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip
local name, subName

---------------------------
-- update
---------------------------
function gf.Location.update()
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		--if WorldMapFrame:IsVisible() == nil then
		
			local map = C_Map.GetBestMapForUnit("player");
			local p = nil
			if (map) then p = C_Map.GetPlayerMapPosition(map,"player") end
			local sep, display
			local s = ((GetUnitSpeed("Player") / 7) * 100);
			local speed = string.format("%d",s)
			if IsInInstance() then
				name, subName = select(1, GetInstanceInfo()), select(4, GetInstanceInfo())
			else
				name, subName = GetZoneText(), GetSubZoneText()
			end
			name = HEX.darkblue..name
			subName = HEX.lightblue..subName
			sep = "|r- "
			display = ""
			if GetUnitSpeed("Player") ~= 0 and spa.DisplaySpeed then
				display = display.."Speed: "..ga.colors.HEX.green..speed.."% "
				if spa.DisplayZone or spa.DisplaySubZone or spa.DisplayCoords then
					display = display..sep
				end
			end
			if spa.DisplayZone then
				display = display..name.." "
			end
			if spa.DisplaySubZone and subName ~= "" then
				if spa.DisplayZone then
					display = display..sep
				end
				display = display..subName.." "
			end
			if spa.DisplayCoords and p then
				if spa.DisplayCoordsPlus then
					display = display..string.format(HEX.lightblue.."("..HEX.white.."%.2f, %.2f"..HEX.lightblue..")", (p.x * 100), (p.y * 100)) 
				else
					display = display..string.format(HEX.lightblue.."("..HEX.white.."%d, %d"..HEX.lightblue..")", (p.x * 100), (p.y * 100)) 
				end
			end
			btn.button:SetText(display)
			btn.button:SetWidth(btn.button:GetTextWidth())
		--end
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Location.tooltip()
	Glance.Debug("function","tooltip","Location")
	local p = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"),"player")
	local speed, groundSpeed, flightSpeed, swimSpeed = GetUnitSpeed("Player")
	tooltip.Title("Location","GLD")
	tooltip.Double("Zone: ", name, "WHT","GRN")
	tooltip.Double("SubZone: ", subName, "WHT","GRN")
	tooltip.Double("Coordinates: ", string.format("(%.2f, %.2f)",(p.x * 100),(p.y * 100)), "WHT","GRN")		
	tooltip.Space()
	tooltip.Line("Speed", "GLD")
	tooltip.Double("Ground Speed", gf.Location.formatSpeed(groundSpeed).."%","WHT","GRN")
	tooltip.Double("Flight Speed", gf.Location.formatSpeed(flightSpeed).."%","WHT","GRN")
	tooltip.Double("Swim Speed", gf.Location.formatSpeed(swimSpeed).."%","WHT","GRN")
	--(left,shift-left,right,shift-right,other)
	tooltip.Notes("open the world map",nil,"switch display",nil,nil)
end

---------------------------
-- click
---------------------------
function gf.Location.click(self, button, down)
	Glance.Debug("function","click","Location")
	if (button == "LeftButton") then 
		ToggleFrame(WorldMapFrame)
		if IsShiftKeyDown() then
			local s = ((GetUnitSpeed("Target") / 7) * 100);
			gf.sendMSG("Target Speed: "..string.format("%d",s).."%");
		end
	end
end

---------------------------
-- menu
---------------------------
function gf.Location.menu(level,UIDROPDOWNMENU_MENU_VALUE)
	Glance.Debug("function","menu","Location")
	level = level or 1
	if (level == 1) then
		gf.setMenuTitle("Location Options")
		gf.setMenuHeader("Display","display",level)
	end
	if (level == 2) then
		if gf.isMenuValue("display") then	
			gf.setMenuCheckBox(spa.DisplayZone,"Show Zone","Show Zone",level,function() if spa.DisplayZone then spa.DisplayZone=false; else spa.DisplayZone=true; end; gf.Location.update() end)
			gf.setMenuCheckBox(spa.DisplaySubZone,"Show SubZone","Show SubZone",level,function() if spa.DisplaySubZone then spa.DisplaySubZone=false; else spa.DisplaySubZone=true; end; gf.Location.update() end)
			gf.setMenuCheckBox(spa.DisplayCoords,"Show Coordinates","Show Coordinates",level,function() if spa.DisplayCoords then spa.DisplayCoords=false; else spa.DisplayCoords=true; end; gf.Location.update() end)
			gf.setMenuCheckBox(spa.DisplayCoordsPlus,"Show Extended Coordinates","Show Extended Coordinates",level,function() if spa.DisplayCoordsPlus then spa.DisplayCoordsPlus=false; else spa.DisplayCoordsPlus=true; end; gf.Location.update() end)
			gf.setMenuCheckBox(spa.DisplaySpeed,"Show Speed","Show Speed",level,function() if spa.DisplaySpeed then spa.DisplaySpeed=false; else spa.DisplaySpeed=true; end; gf.Location.update() end)	
		end
	end
end

---------------------------
-- formatting
---------------------------
function gf.Location.formatSpeed(s)
	local speed = ((s / 7) * 100); -- 7 = 100%
	return string.format("%d",speed)
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Location")
end