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
gf.AddButton("Bags","LEFT")
local btn = gb.Bags
btn.text              = "Bags"
btn.events            = {"BAG_UPDATE"}
btn.enabled           = true
btn.update            = true
btn.tooltip           = true
btn.click             = true
btn.menu              = true
btn.icon              = "INTERFACE\\ICONS\\INV_MISC_BAG_10"
btn.save.perCharacter = {["CountTradeBagSlots"] = false, ["Display"] = "Free", ["Title"] = "Icon"}

---------------------------
-- shortcuts
---------------------------
local spc = btn.save.perCharacter
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip

---------------------------
-- local data
---------------------------
ga.bags = {			
	["Free"] = 0,		
	["Used"] = 0,		
	["Total"] = 0,		
	["Used/Total"] = "0/0",
	["Free/Total"] = "0/0",
}

---------------------------
-- update
---------------------------
function gf.Bags.update()
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined	
		local totalSlots, usedSlots, freeSlots = 0,0,0
		for bag = 0, 4 do
			local total, used, free = unpack(gf.Bags.getBagInfo(bag))	
			totalSlots = totalSlots + total
			usedSlots = usedSlots + used
			freeSlots = freeSlots + free
		end
		gf.Bags.Data(freeSlots, usedSlots, totalSlots)
		local title = gf.getCondition(spc.Title =="Icon", gf.is(btn.icon,"display"), "Bags: ")
		local color = gf.getCondition(usedSlots == totalSlots,HEX.red,HEX.green)
		gf.setButtonText(btn.button,title,ga.bags[spc.Display],nil,color)
		wipe(ga.bags)
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Bags.tooltip()
	Glance.Debug("function","tooltip","Bags")
	tooltip.Double("Bags", spc.Display, "GLD","GLD")
	local totalSlots, usedSlots, freeSlots = 0,0,0
	for bag = 0, 4 do
		local total, used, free, isTradeBag, ac, tc, name, icon = unpack(gf.Bags.getBagInfo(bag))	
		if total > 0 or name ~= nil then
			local color = gf.getCondition(isTradeBag,HEX.red,HEX.gold)
			totalSlots = totalSlots + total
			usedSlots = usedSlots + used
			freeSlots = freeSlots + free
			if icon == nil then
				icon = gf.is(btn.icon,"tooltip")
			else
				icon = gf.is(icon,"tooltip")
			end
			if isTradeBag and not spc.CountTradeBagSlots then 
				tooltip.Double(color..bag..") "..name, " ", "WHT","GRN")
			else
				tooltip.Double(color..bag..") "..name, ga.bags[bag][spc.Display], "WHT","GRN")
			end
		end
	end
	gf.Bags.Data(freeSlots, usedSlots, totalSlots)
	if freeSlots == 0 then freeSlots = HEX.red..freeSlots end
	tooltip.Double(" ", ga.bags[spc.Display], "WHT","YEL")		
	local tbl = {
		[1] = {["Title"]=spc.Title},
		[2] = {["Display"]=spc.Display},
		[3] = {["Count Trade Bags"]=spc.CountTradeBagSlots},
	}
	tooltip.Options(tbl)
	--(left,shift-left,right,shift-right,other)
	tooltip.Notes("toggle all bags",nil,"change Options",nil,nil)
	wipe(ga.bags)
end

---------------------------
-- click
---------------------------
function gf.Bags.click(self, button, down)
	Glance.Debug("function","click","Bags")
	if (button == "LeftButton") then 
		ToggleAllBags();
	end
end

---------------------------
-- menu
---------------------------
function gf.Bags.menu(level,UIDROPDOWNMENU_MENU_VALUE)
	Glance.Debug("function","menu","Bags")
	level = level or 1
	if (level == 1) then
		gf.setMenuTitle("Bags Options")
		gf.setMenuHeader("Title","title",level)
		gf.setMenuHeader("Display","display",level)
		gf.setMenuHeader("Count Trade Bags","tradebags",level)
	end
	if (level == 2) then
		if gf.isMenuValue("title") then
			--checked,text,value,level,func,icon
			gf.setMenuOption(spc.Title == "Text","Text","Text",level,function() spc.Title = "Text"; gf.Bags.update() end)
			gf.setMenuOption(spc.Title == "Icon","Icon","Icon",level,function() spc.Title = "Icon"; gf.Bags.update() end)
		end
		if gf.isMenuValue("display") then		
			gf.setMenuOption(spc.Display == "Used/Total","Used/Total","Used/Total",level,function() spc.Display = "Used/Total"; gf.Bags.update() end)
			gf.setMenuOption(spc.Display == "Free/Total","Free/Total","Free/Total",level,function() spc.Display = "Free/Total"; gf.Bags.update() end)
			gf.setMenuOption(spc.Display == "Free","Free","Free",level,function() spc.Display = "Free"; gf.Bags.update() end)
			gf.setMenuOption(spc.Display == "Used","Used","Used",level,function() spc.Display = "Used"; gf.Bags.update() end)
			gf.setMenuOption(spc.Display == "Total","Total","Total",level,function() spc.Display = "Total"; gf.Bags.update() end)
		end
		if gf.isMenuValue("tradebags") then
			gf.setMenuOption(spc.CountTradeBagSlots==true,"Yes","Yes",level,function() spc.CountTradeBagSlots=true; gf.Bags.update() end)
			gf.setMenuOption(spc.CountTradeBagSlots==false,"No","No",level,function() spc.CountTradeBagSlots=false; gf.Bags.update() end)
		end
	end
end

---------------------------
-- get bag info
---------------------------
function gf.Bags.getBagInfo(bag)
	local total, free = 0,0
	local ac, tc = "", ""
	local bagType
	total = GetContainerNumSlots(bag);
	free, bagType = GetContainerNumFreeSlots(bag)
	if free == 0 then ac = HEX.red end
	if total == 0 then tc = HEX.red else tc = HEX.green end
	local name = GetBagName(bag)
	if name ~= nil then  -- need to prevent errors when update launched before bags exist
		local _,_,quality,_,_,_,_,_,_,icon = GetItemInfo(name)	
		if quality == nil then
			name = "|r"..name
		else
			quality = select(4, GetItemQualityColor(quality)) or "ffffffff"
			name = "|c"..quality..name
		end	
		if gf.Bags.isTradeBag(bagType) and not spc.CountTradeBagSlots then
			total, used, free = 0, 0, 0
			ac, tc = HEX.red, HEX.red
		end
		ga.bags[bag] = {			
			["Free"] = ac..free,		
			["Used"] = total-free,		
			["Total"] = tc..total,		
			["Used/Total"] = total-free.."|r/"..tc..total,
			["Free/Total"] = ac..free.."|r/"..tc..total,
		}
		return { total, total-free, free, gf.Bags.isTradeBag(bagType), ac, tc, name, icon }
	else
	return { 0,0,0,nil,HEX.red,HEX.red,nil,nil }
	end
end

---------------------------
-- set total data
---------------------------
function gf.Bags.Data(free, used, total)
	ga.bags = {			
		["Free"] = free,		
		["Used"] = used,		
		["Total"] = total,		
		["Used/Total"] = used.."/"..total,
		["Free/Total"] = free.."/"..total,
	}
end

---------------------------
-- is trade bag?
---------------------------
function gf.Bags.isTradeBag(bagType)
	if bagType == nil then return false end
	local BAGTYPE_PROFESSION = 0x0001 + 0x0002 + 0x0004 + 0x0008 + 0x0010 + 0x0020 + 0x0040 + 0x0080 + 0x0100 + 0x0200 + 0x0400 + 0x0800 + 0x1000 + 0x10000 + 0x100000
	if (bit.band(bagType, BAGTYPE_PROFESSION) > 0) then
		return true
	end
	return false
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Bags")
end