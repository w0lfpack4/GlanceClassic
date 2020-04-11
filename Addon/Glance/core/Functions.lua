---------------------------
-- lets simplify a bit..
---------------------------
local gf = Glance.Functions
local gv = Glance.Variables
local ga = Glance.Arrays
local gb = Glance.Buttons
local gm = Glance.Menus
local gd = Glance.Data
local HEX = ga.colors.HEX

---------------------------
-- send message
---------------------------
function gf.sendMSG(text)
	print("|cff0279ffGlance:|r "..tostring(text));
end


---------------------------
-- debug messages
---------------------------
function Glance.Debug(what, which, msg)
	if gv.Debug then
		if which=="update" and not DebugUpdates then return end
		if what=="position" and not DebugPositioning then return end
		message = "("..date("%H:%M:%S")..") Debug: "..what..": "..which
		if msg ~= nil then
			message = message.." ("..msg..")"
		end
		if what == "event" then
			if gv.DebugEvents then
				gf.sendMSG(message)
			end
		else
			gf.sendMSG(message)
		end
	end
end

---------------------------
-- check button order
---------------------------
function gf.CheckButtonOrder(name)
	gf.CheckDuplicates()
	for i=1, #gv.button.order[gb[name].anchor] do
		if gv.button.order[gb[name].anchor][i] == name then
			return true
		end
	end
	return false
end

---------------------------
-- check button order dups
---------------------------
function gf.CheckDuplicates()
	local buttoncheck = {}	
	for i=1, #gv.button.order.LEFT do
		if buttoncheck[gv.button.order.LEFT[i]] == nil then
			buttoncheck[gv.button.order.LEFT[i]] = 1
		else
			buttoncheck[gv.button.order.LEFT[i]] = buttoncheck[gv.button.order.LEFT[i]] + 1
			gf.sendMSG("Duplicate entry found in left side button order. The problem is now fixed.")
			table.remove(gv.button.order.LEFT, i)
		end
	end
	for i=1, #gv.button.order.RIGHT do
		if buttoncheck[gv.button.order.RIGHT[i]] == nil then
			buttoncheck[gv.button.order.RIGHT[i]] = 1
		else
			buttoncheck[gv.button.order.RIGHT[i]] = buttoncheck[gv.button.order.RIGHT[i]] + 1
			gf.sendMSG("Duplicate entry found in right side button order. The problem is now fixed.")
			table.remove(gv.button.order.RIGHT, i)
		end
	end
	gf.saveButtonOrder()
end

---------------------------
-- add button to array
---------------------------
function gf.AddButton(name,anchor)
	gv.button.order[anchor][#gv.button.order[anchor]+1] = name
	gb[name] = {
		["name"] = name,
		["text"] = nil,
		["anchor"] = anchor,
		["font"] = nil,
		["position"] = #gv.button.order[anchor],
		["enabled"] = nil,
		["events"] = nil,
		["update"] = false,
		["onload"] = false,
		["tooltip"] = false,
		["menu"] = false,
		["click"] = false,
		["timer1"] = false,
		["timer5"] = false,
		["timerTooltip"] = false,
		["button"] = nil,
		["icon"] = nil,
		["texture"] ={
			["normal"] = nil,
			["highlight"] = nil,
		},
		["save"] = {
			["perCharacter"] = nil,
			["perAccount"] = nil,
			["allowProfile"] = false,
		},
	}
	gf[name] = {}
	Glance.Debug("function","addButton",name)
end

---------------------------
-- add timer to array
---------------------------
function gf.AddTimer(name,low,high,reset,button,func,var)
	if gb[name].enabled then
		Glance.Timers[name] = {low,high,reset,button,func,var}
	end
end

---------------------------
-- add command to array
---------------------------
function gf.AddCommand(button,name,desc,func)
	if gb[button].enabled then
		Glance.Commands[name] = {
			["desc"] = desc,
			["func"] = func,
		}
	end
end

---------------------------
-- show tooltip
---------------------------
function gf.showTooltip(which)
	if gb[which].enabled then
		Glance.Debug("function","showtooltip",which)
		GameTooltip:ClearLines()
		GameTooltip:ClearAllPoints()
		if Glance_Local.Options.showLow then
			GameTooltip:SetOwner(gb[which].button,"ANCHOR_TOPLEFT")
		else
			GameTooltip:SetOwner(gb[which].button,"ANCHOR_NONE")
			GameTooltip:SetPoint("TOPLEFT", gb[which].button, "BOTTOMLEFT", 0, 0)
		end
		gf[which].tooltip()
		if Glance_Local.Options.scaleTooltip then
			GameTooltip:SetScale(Glance_Local.Options.frameScale)
		end
		GameTooltip:Show()
	end
end

---------------------------
-- tooltip text
---------------------------
function gf.Tooltip.Title(text,color)
	local RGB = ga.colors.RGB
	GameTooltip:SetText(text, RGB[color][1], RGB[color][2], RGB[color][3])
end
function gf.Tooltip.Line(text,color)
	local RGB = ga.colors.RGB
	GameTooltip:AddLine(text, RGB[color][1], RGB[color][2], RGB[color][3])
end
function gf.Tooltip.Wrap(text,color)
	local RGB = ga.colors.RGB
	GameTooltip:AddLine(text, RGB[color][1], RGB[color][2], RGB[color][3], 1)
end
function gf.Tooltip.Double(text1,text2,col1,col2)
	local RGB = ga.colors.RGB
	GameTooltip:AddDoubleLine(text1, text2, RGB[col1][1], RGB[col1][2], RGB[col1][3], RGB[col2][1], RGB[col2][2], RGB[col2][3])
end
function gf.Tooltip.Space()
	gf.Tooltip.Line(" ","GLD")
end
	
---------------------------
-- tooltip Options list
---------------------------
function gf.Tooltip.Options(tbl)
	gf.Tooltip.Space()
	gf.Tooltip.Line("Options", "GLD")
	for i=1,#tbl do
		for k, v in pairs(tbl[i]) do
			local value, color = "", "GRN"
			if v == true then 
				value = "On"
			elseif v == false then 
				value = "Off"
				color = "RED"		
			elseif v == "Off" then 
				color = "RED"	
			else
				value = v
			end
			if v ~= nil then gf.Tooltip.Double(k,value,"WHT",color) end
		end
	end
end

---------------------------
-- tooltip notes
---------------------------
function gf.Tooltip.Notes(left,shiftLeft,right,shiftRight,other)
	gf.Tooltip.Space()
	gf.Tooltip.Line("Notes", "GLD")
	if left then gf.Tooltip.Line("(Click to "..left..".)","WHT") end
	if shiftLeft then gf.Tooltip.Line("(Shift-Click to "..shiftLeft..".)","WHT") end
	if right then gf.Tooltip.Line("(Right-Click to "..right..".)","WHT") end
	if shiftRight then gf.Tooltip.Line("(Shift-Right-Click to "..shiftRight..".)","WHT") end
	if other then gf.Tooltip.Space(); gf.Tooltip.Wrap("* "..other..". *","YEL") end
end

---------------------------
-- set menu info
---------------------------
function gf.setInfo(d,i,h,n,c,t,v,l,f,ic,koc,r) --disabled,isTitle,hasArrow,notCheckable,checked,text,value,level,func,icon,keepShown,notRadio
	--UIDROPDOWNMENU_BUTTON_HEIGHT = 20
	--UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 20
	wipe(ga.info)
	ga.info = {
		["disabled"]	 = d,
		["isTitle"]	  = i,
		["hasArrow"]	 = h,
		["notCheckable"] = n,
		["checked"]	  = c,
		["text"]		 = t,
		["value"]		= v,
		["func"]		 = f,
		["icon"]		 = ic,
		["keepShownOnClick"] = koc,
		["isNotRadio"] = r,
	}
	UIDropDownMenu_AddButton(ga.info, l)
end

---------------------------
-- set menu title
---------------------------
function gf.setMenuTitle(name, level, gold)	
	gf.setInfo(nil,true,false,true,nil,gf.getCondition(gold, HEX.gold, HEX.white)..name,"spacer",level,nil)
end

---------------------------
-- set menu headers
---------------------------
function gf.setMenuHeader(name,value,level,disabled)
	gf.setInfo(disabled,nil,true,true,nil,HEX.gold..name,value,level,nil)
end

---------------------------
-- set menu divider
---------------------------
function gf.setMenuDivider(level)
	gf.setInfo(nil,true,false,true,nil,HEX.gold.."     ----------------------------------","spacer",level,nil)
end

---------------------------
-- set menu check options
---------------------------
function gf.setMenuCheckBox(checked,name,value,level,func,icon,ks,nr)
	--disabled,isTitle,hasArrow,notCheckable,checked,text,value,level,func,icon,keepShown,notRadio	
	gf.setInfo(nil,false,false,false,checked,name,value,level,func,nil,true,true)
end

---------------------------
-- set menu radio options
---------------------------
function gf.setMenuOption(checked,name,value,level,func,icon)
	--disabled,isTitle,hasArrow,notCheckable,checked,text,value,level,func,icon,keepShown,notRadio	
	gf.setInfo(nil,false,false,false,checked,name,value,level,func,icon,nil,false)
end

---------------------------
-- set disabled menu radio options
---------------------------
function gf.setDisabledMenuOption(checked,name,value,level,func,icon)
	--disabled,isTitle,hasArrow,notCheckable,checked,text,value,level,func,icon,keepShown,notRadio	
	gf.setInfo(true,false,false,false,checked,name,value,level,func,nil,nil,false)
end

---------------------------
-- select menu
---------------------------
function gf.isMenuValue(value)
	if UIDROPDOWNMENU_MENU_VALUE == value then
		return true
	end
	return false
end

---------------------------
-- ? = T : F
---------------------------
function gf.getCondition(condition, t, f)
	if condition then return t else return f end
end

---------------------------
-- set display button text
---------------------------
function gf.setButtonText(btn,title,value,color1,color2)
	if color1 == nil then color1 = ga.colors.DEFAULT.text end
	if color2 == nil then color2 = ga.colors.DEFAULT.value end
	if value == nil then value = "" end
	btn:SetText(color1..title..color2..value)
	btn:SetWidth(btn:GetTextWidth())
end

---------------------------
-- bypass wow time played
---------------------------
function ChatFrame_DisplayTimePlayed(theFrame, totalTime, levelTime)
	if gv.requestingTimePlayed then
		gv.requestingTimePlayed = false
		gv.gametime.initTotal = time() - totalTime
		gv.gametime.initLevel = time() - levelTime
	else
		gf.ChatFrame_DisplayTimePlayed(theFrame, totalTime, levelTime)
	end
end

---------------------------
-- set frame rgba
---------------------------
function gf.setBackground(n)
	if n==1 or n==2 or n==4 then
		local t = Glance.Frames.topFrame.texture
		local r,g,b,a = unpack(Glance_Global.Options.frameColor[n])
		t:SetColorTexture(r, g, b, a)
		--t:SetTexture("Interface\\AddOns\\Glance\\Skins\\eye.tga",true);
		--t:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock",true);
	end
	local t2 = _G["GlanceBorder"]
	r,g,b,a = unpack(Glance_Global.Options.frameColor[3])
	t2:SetColorTexture(r,g,b,a)
end

---------------------------
-- show/hide frame
---------------------------
function gf.autoHide(hide)
	if hide == nil then hide=true end
	if Glance_Local.Options.autoHide or (Glance_Local.Options.autoHidePet and gv.inPetBattle) or (Glance_Local.Options.autoHideVehicle and gv.inVehicle) then
		if not gv.menuOpen then
			if hide then
				if not gv.moveLock then
					if Glance_Local.Options.showLow then
						gf.moveDown()
						Glance.Timers["moveDown"] = {0,1,true,nil,"moveDown",nil}
					else
						gf.moveUp()
						Glance.Timers["moveUp"] = {0,1,true,nil,"moveUp",nil}
					end
					gv.moveLock = true
				end
			else
				if not gv.moveLock then
					if Glance_Local.Options.showLow then
						gf.moveUp()
						Glance.Timers["moveUp"] = {0,1,true,nil,"moveUp",nil}
					else
						gf.moveDown()
						Glance.Timers["moveDown"] = {0,1,true,nil,"moveDown",nil}
					end
					gv.moveLock = true
				end
			end
		else
			_G["DropDownList1"]:SetScript("OnHide", function(...) gv.menuOpen = false; gf.autoHide(true); CloseDropDownMenus() end)			
		end
	end
end

---------------------------
-- animate the bar up
---------------------------
function gf.moveUp()
	local cf = Glance.Frames.cloneFrame
	local tf = Glance.Frames.topFrame
	gv.barY = gv.barY+4
	if Glance_Local.Options.showLow then
		tf:Show(); cf:Hide();
		gf.positionBar(gv.barY,true)
		if gv.barY >= 0 then
			gv.barY = 0
			Glance.Timers["moveUp"] = nil
			gv.moveLock = false
		end
	else
		tf:ClearAllPoints();
		gf.positionBar(gv.barY,false)
		if gv.barY >= 16 then
			gv.barY = 16
			Glance.Timers["moveUp"] = nil
			tf:Hide(); cf:Show();
			gv.moveLock = false
		end
	end
end

---------------------------
-- animate the bar down
---------------------------
function gf.moveDown()
	local cf = Glance.Frames.cloneFrame
	local tf = Glance.Frames.topFrame
	gv.barY = gv.barY-4
	if Glance_Local.Options.showLow then
		gf.positionBar(gv.barY,true)
		if gv.barY <= -16 then
			gv.barY = -16
			Glance.Timers["moveDown"] = nil
			tf:Hide(); cf:Show();
			gv.moveLock = false
		end
	else
		tf:Show(); cf:Hide();
		gf.positionBar(gv.barY,false)
		if gv.barY <= 0 then
			gv.barY = 0
			Glance.Timers["moveDown"] = nil
			gv.moveLock = false
		end
	end
end

---------------------------
-- reposition the bar
---------------------------
function gf.positionBar(barY,low)
	local cf = Glance.Frames.cloneFrame
	local tf = Glance.Frames.topFrame
	if barY == nil then barY = 0 end
	if low then
		tf:ClearAllPoints();
		tf:SetPoint("BOTTOMLEFT", 0, barY)
		tf:SetPoint("BOTTOMRIGHT", 0, barY)
		cf:ClearAllPoints()
		cf:SetPoint("BOTTOMLEFT", 0, 0)
		cf:SetPoint("BOTTOMRIGHT", 0, 0)
	else
		tf:ClearAllPoints();
		tf:SetPoint("TOPLEFT", 0, barY)
		tf:SetPoint("TOPRIGHT", 0, barY)
		cf:ClearAllPoints();
		cf:SetPoint("TOPLEFT", 0, 0)
		cf:SetPoint("TOPRIGHT", 0, 0)
	end
end

---------------------------
-- format time played string
---------------------------
function gf.formatTime(s)
	--return formatted
	local ts = SecondsToTime(s, false, false, 4)
	ts, count = string.gsub(ts,"Days","d")
	ts, count = string.gsub(ts,"Day","d")
	ts, count = string.gsub(ts,"Hr","h")
	ts, count = string.gsub(ts,"Min","m")
	ts, count = string.gsub(ts,"Sec","s")
	local a,b,c,d,e,f,g,h = strsplit(" ", ts) --gsub won't remove the spaces for whatever reason
	local tsnew = ""
	if a ~= nil and b ~= nil then tsnew = tsnew.." "..a..b end
	if c ~= nil and d ~= nil then tsnew = tsnew.." "..c..d end
	if e ~= nil and f ~= nil then tsnew = tsnew.." "..e..f end
	if g ~= nil and g ~= nil then tsnew = tsnew.." "..g..h end
	return tsnew
end

---------------------------
-- remove by value
---------------------------
function gf.tableRemoveByVal(tab, val)
	for k,v in pairs(tab) do
		if(v==val) then
			table.remove(tab, k);
			return true;
		end
	end
	return false;
end

---------------------------
-- add by value
---------------------------
function gf.tableAddByVal(tab, val)
	for k,v in pairs(tab) do
		if(v==val) then
			return false;
		end
	end
	table.insert(tab,val)
	return true;
end

---------------------------
-- min, max, avg
---------------------------
function gf.stats(var,num)
	var.current = num
	var.count = var.count + 1
	if (var.count == 1) then
		var.min = var.current
		var.max = var.current
		var.avg = var.current
	else
		if (var.current < var.min) then
			var.min = var.current
		elseif (var.current > var.max) then
			var.max = var.current
		end
		var.avg = math.floor((var.avg * (var.count-1) + var.current) / var.count)
	end
end

---------------------------
-- return pct
---------------------------
function gf.getPCT(small,large)
	if (large <= 0 or large == nil) then return 0 end
	return math.floor(((small/large)*100))
end

---------------------------
-- return rounded decimals
---------------------------
function gf.roundDecimal(what, decimals)
	return math.floor(what*math.pow(10,decimals)+0.5) / math.pow(10,decimals)
end

---------------------------
-- multi line text matching
---------------------------
function gf.match(u,t,find)
	for i = 1, u do
		local text = string.lower(_G[t..i]:GetText())
		for word in string.gmatch(text, "%S+") do
			if strfind(string.lower(word), string.lower(find)) then return true end
		end
	end
	return false
end

---------------------------
-- text matching
---------------------------
function gf.matchSingle(text,find)
	for word in string.gmatch(text, "%S+") do
		if strfind(string.lower(word), string.lower(find)) then return true end
	end
	return false
end

---------------------------
-- to string
---------------------------
function gf.ts(obj)
	return tostring(obj)
end

---------------------------
-- return an icon string
---------------------------
function gf.is(icon,which)
	if icon == nil then
		return "?:"
	else
		return "|T"..icon..":"..gv[which.."Icon"].."|t "
	end
end

---------------------------
-- check for cross realm party member
---------------------------
function gf.crossRealm()
	local pcr = ""
	local realm = string.gsub(GetRealmName(), " ", "")
	for i=1, GetNumPartyMembers or 1 do
		local name = UnitName("party"..i) or UnitName("player")
		local prealm = select(2,UnitName("party"..i))
		if prealm then -- nil is same realm
			prealm = string.gsub(prealm, " ", "")
			if realm ~= prealm then -- not nil so compare
				pcr = ga.colors.HEX.red.." (cross-realm)|r"
			end
		end
	end
	return pcr
end

---------------------------
-- List party stats for a module
---------------------------
function gf.partyTooltip(module)	
	if gv.party.a[module] ~= nil then
		if gv.party.a[module] ~= 0 then
			gf.Tooltip.Double(gv.party.a.name, gv.party.a[module], "WHT", "GRN")
		end
	else
		gf.Tooltip.Double(gv.party.a.name, gv.party.a[module], "WHT", "RED")
	end
	if gv.party.b[module] ~= nil then
		if gv.party.b[module] ~= 0 then
			gf.Tooltip.Double(gv.party.b.name, gv.party.b[module], "WHT", "GRN")
		end
	else
		gf.Tooltip.Double(gv.party.b.name, gv.party.b[module], "WHT", "RED")
	end
	if gv.party.c[module] ~= nil then
		if gv.party.c[module] ~= 0 then
			gf.Tooltip.Double(gv.party.c.name, gv.party.c[module], "WHT", "GRN")
		end
	else
		gf.Tooltip.Double(gv.party.c.name, gv.party.c[module], "WHT", "RED")
	end
	if gv.party.d[module] ~= nil then
		if gv.party.d[module] ~= 0 then
			gf.Tooltip.Double(gv.party.d.name, gv.party.d[module], "WHT", "GRN")
		end
	else
		gf.Tooltip.Double(gv.party.d.name, gv.party.d[module], "WHT", "RED")
	end
end

---------------------------
-- try to send a query message (sends a query to party glance, requesting (module) stats
---------------------------
function gf.addonQuery(module)
	Glance.Debug("function","addonQuery",module)
	local GetNumPartyMembers, _ = GetNumSubgroupMembers()
	if (GetNumPartyMembers ~= 0 or gv.Debug) and Glance_Local.Options.sendStats and gv.messageCheck and SendAddonMessage then
		if gv.Debug then
			SendAddonMessage("Glance", module.."^query^0", "WHISPER", UnitName("player"))
		else
			SendAddonMessage("Glance", module.."^query^0", "PARTY") -- sending a request for module data with a query header
		end
		gv.messageCheck = false
	end
end

---------------------------
-- try to send a response message
---------------------------
function gf.addonResponse(prefix, message, channel, sender)
	if prefix == "Glance" then
		Glance.Debug("function","addonResponse",sender..", "..message)
		local GetNumPartyMembers, _ = GetNumSubgroupMembers()
		if ((GetNumPartyMembers ~= 0 and sender ~= UnitName("Player")) or gv.Debug) and Glance_Local.Options.sendStats then
			local module,which,data = strsplit("^", message)
			if which == "query" then -- query for information from party member
				local msg = gf[module].Message(data,sender) -- the data to send back based on the module
				if gv.Debug then
					SendAddonMessage("Glance",module.."^response^"..msg, "WHISPER", UnitName("Player"))
				else
					SendAddonMessage("Glance",module.."^response^"..msg, "PARTY") -- sending the data about the module with a response header
				end
			elseif which == "response" then -- response with data from party member
				for i=1, GetNumPartyMembers do					
					local name = GetUnitName("party"..i,true) -- should return name-realm
					local party = {"a", "b", "c", "d"}
					if not strfind(name,"-") then name = name.."-"..GetRealmName() end
					name = string.gsub(name, " ", "") -- "Area 52" to Area52
					sender = string.gsub(sender, " ", "")
					if name == sender then
						gv.party[party[i]].name = sender
						gv.party[party[i]][module] = data
					end
				end
				if gv.Debug then
					local name = GetUnitName("player",true)
					if not strfind(name,"-") then name = name.."-"..GetRealmName() end
					if name == sender then
						gv.party.a.name = sender
						gv.party.a[module] = data
					end
				end
				gf.showTooltip(module)
			end
		end
	end
end

