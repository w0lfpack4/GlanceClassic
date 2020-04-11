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
gf.AddButton("Memory","LEFT")
local btn = gb.Memory
btn.text              = "Memory"
btn.events            = {"PLAYER_LOGIN"}
btn.enabled           = true
btn.update            = true
btn.click             = true
btn.onload            = true
btn.tooltip           = true
btn.timer5            = true
btn.timerTooltip      = true
btn.menu              = true
btn.save.perAccount = { ["collectGarbage"] = false, ["oneGlance"] = true, ["showCPU"] = false, ["max"] = 25, ["MEMCPU"] = "MEM", ["showPercent"] = false, ["PCTAMT"] = "AMT"}

---------------------------
-- shortcuts
---------------------------
local spa = btn.save.perAccount
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip
local ACP

---------------------------
-- variables
---------------------------
gv.unitTotal = 0
gv.numAddons = 0
gv.addons = {}

---------------------------
-- update
---------------------------
function gf.Memory.update()
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined	
		local total, num = 0, 0
		if spa.showCPU then	UpdateAddOnCPUUsage() else UpdateAddOnMemoryUsage()	end -- CPU or MEM cache update
		for i=1, GetNumAddOns() do
			if IsAddOnLoaded(i) then -- for display, only loaded addons
				local unit = gf.getCondition(spa.showCPU, GetAddOnCPUUsage(i), GetAddOnMemoryUsage(i))
				total = total + unit
				num = num + 1
			end
		end
		gv.unitTotal = total; gv.numAddons = num;
		gf.setButtonText(btn.button,spa.MEMCPU..": ",gf.Memory.Format(spa.MEMCPU, total, true),nil,nil)
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Memory.tooltip()
	Glance.Debug("function","tooltip","Memory")
	local resort, count = false, 0
	-- update memory and compare
	for i=1, #gv.addons do
		local name, oldunit, color, image, modular = unpack(gv.addons[i]) -- current data
		local newunit, modular = gf.Memory.updateData(name) -- new data
		color, image = gf.Memory.compare(oldunit, newunit) -- compare 
		gv.addons[i] = {name, newunit, color, image, modular} -- update db
		if image ~= "steady" then resort = true end -- need to re-sort
	end
	
	-- resort db table
	if resort then
		table.sort(gv.addons, function(a, b) return a[2] > b[2] end)
		resort = false
	end
	
	-- tooltip title
	if spa.showCPU then
		tooltip.Title("Addon CPU Usage", "GLD")
	else
		tooltip.Title("Addon Memory Usage", "GLD")
	end
	
	-- parse db
	for k, v in pairs(gv.addons) do
		count = count + 1
		if count < spa.max then -- limit listings.  more listings, more mem usage from Glance
			local name, unit, color, image, modular = unpack(v) -- current data
			if modular and spa.oneGlance then name = name.." [+]" end -- addon has combined modules
			if unit > 0 then -- only loaded addons
				local threshold = "GRN"
				if unit > 1000 then threshold = "RED" elseif unit > 500 then threshold = "YEL" end
				tooltip.Double("|T".."Interface\\Addons\\Glance_Memory\\"..image..":0|t "..format("%s", name), gf.Memory.Format(spa.MEMCPU, unit,nil), color, threshold)
			end
		end
	end	
	
	-- show totals
	tooltip.Space()
	tooltip.Double("Total "..spa.MEMCPU.." Usage: ", gf.Memory.Format(spa.MEMCPU, gv.unitTotal, true), "WHT","WHT")		
	tooltip.Double("Total Loaded Addons: ", gv.numAddons, "WHT","WHT")	
	
	-- show options
	local tbl = {
		[1] = {["Display"]=spa.PCTAMT},
		[2] = {["Data"]=spa.MEMCPU},
		[3] = {["List"]=spa.max},
		[4] = {["Combine Modules"]=spa.oneGlance},
		[5] = {["Recycle Memory"]=spa.collectGarbage},
	}
	tooltip.Options(tbl)
	local showACP = nil
	if ACP then showACP = "launch ACP" end
	--(left,shift-left,right,shift-right,other)
	tooltip.Notes("recycle memory",showACP,"change Options",nil,nil)
end

---------------------------
-- click
---------------------------
function gf.Memory.click(self, button, down)
	Glance.Debug("function","click","Memory")
	if (button == "LeftButton") then 
		if IsShiftKeyDown() then
			ShowUIPanel(ACP_AddonList)
		else
			gf.Memory.collectGarbage()
		end
	end
end

---------------------------
-- onload
---------------------------
function gf.Memory.onload()
	wipe(gv.addons) -- kill existing list
	if spa.collectGarbage then -- recycle memory
		gf.Memory.collectGarbage() -- also calls UpdateAddonXXXUsage
	else
		if spa.showCPU then	UpdateAddOnCPUUsage() else UpdateAddOnMemoryUsage()	end -- CPU or MEM
	end
	for i=1, GetNumAddOns() do
		local unit, color, image = gf.getCondition(spa.showCPU, GetAddOnCPUUsage(i), GetAddOnMemoryUsage(i)), "LBL", "steady"
		local name, title = gf.Memory.GetAddOnInfo(i)
		if not gf.Memory.updateAddon(name, unit, color, image) then -- check if addon is in db
			table.insert(gv.addons, {name, unit, color, image, nil}) -- add new 
		end
	end
	table.sort(gv.addons, function(a, b) return a[2] > b[2] end)
	ACP = IsAddOnLoaded("ACP")
end

---------------------------
-- menu
---------------------------
function gf.Memory.menu(level,UIDROPDOWNMENU_MENU_VALUE)
	Glance.Debug("function","menu","Memory")
	level = level or 1
	if (level == 1) then
		gf.setMenuTitle("Options")		
		gf.setMenuHeader("Display","pct",level)	
		gf.setMenuHeader("Data","mem",level)	
		gf.setMenuHeader("List","max",level)
		gf.setMenuHeader("Combine Modules","one",level)
		gf.setMenuHeader("Recycle Memory on Login","garbage",level)
	end
	if (level == 2) then
		if gf.isMenuValue("mem") then
			if tonumber(GetCVar("scriptProfile")) > 0 then
				gf.setMenuOption(spa.showCPU==true,"CPU","CPU",level,function() spa.showCPU=true; spa.MEMCPU = "CPU"; gf.Memory.onload() end)
			else
				gf.setMenuOption(spa.showCPU==true,"CPU (requires reload)","CPU",level,function()  StaticPopup_Show("Glance_Memory_RELOADUI") end)
			end
			gf.setMenuOption(spa.showCPU==false,"Memory","Memory",level,function() spa.showCPU=false; spa.MEMCPU = "MEM"; gf.Memory.onload() end)
		end
		if gf.isMenuValue("pct") then
			gf.setMenuOption(spa.showPercent==true,"Percent","Percent",level,function() spa.showPercent=true; spa.PCTAMT = "PCT"; gf.Memory.onload() end)
			gf.setMenuOption(spa.showPercent==false,"Amount","Amount",level,function() spa.showPercent=false; spa.PCTAMT = "AMT"; gf.Memory.onload() end)
		end
		if gf.isMenuValue("max") then
			for i=10, 50, 5 do
				gf.setMenuOption(spa.max==i,i,i,level,function() spa.max=i; end)
			end
		end
		if gf.isMenuValue("one") then
			gf.setMenuOption(spa.oneGlance==true,"On","On",level,function() spa.oneGlance=true; gf.Memory.onload() end)
			gf.setMenuOption(spa.oneGlance==false,"Off","Off",level,function() spa.oneGlance=false; gf.Memory.onload() end)
		end
		if gf.isMenuValue("garbage") then
			gf.setMenuOption(spa.collectGarbage==true,"On","On",level,function() spa.collectGarbage=true; end)
			gf.setMenuOption(spa.collectGarbage==false,"Off","Off",level,function() spa.collectGarbage=false; end)
		end
	end
end

---------------------------
-- reformat addon info
---------------------------
function gf.Memory.GetAddOnInfo(input)
	local name, title = GetAddOnInfo(input) -- original input (name or id)
	if spa.oneGlance then -- combining
		if strfind(name,"_") then -- is Module?
			local pos, _ = strfind(name,"_")
			name = 	string.sub(name,1,pos-1)
		elseif strfind(name,"-") then -- is Module?
			local pos, _ = strfind(name,"-")
			name = 	string.sub(name,1,pos-1)
		end
	end
	return name, title
end

---------------------------
-- combine addons (called onload to see if formatted addon name exists in db)
---------------------------
function gf.Memory.updateAddon(name, unitIn, color, image)
	if not spa.oneGlance then return false end-- not combining
	for i=1, #gv.addons do
		if name and name==gv.addons[i][1] then -- match
			local unit = gv.addons[i][2]
			gv.addons[i][2] = unitIn + unit
			gv.addons[i][3] = color
			gv.addons[i][4] = image
			return true -- escape
		end
	end
	return false -- no match
end

---------------------------
-- collate module data (tooltip)
---------------------------
function gf.Memory.updateData(name)	
	local total, modular = 0, nil
	if spa.oneGlance then -- modules collated
		for i=1, GetNumAddOns() do
			local module, title = GetAddOnInfo(i)
			if strfind(module,name) then
				if strfind(module,"_") or strfind(module,"-") then modular = true end -- addon has modules
				local unit = gf.getCondition(spa.showCPU, GetAddOnCPUUsage(i), GetAddOnMemoryUsage(i)) -- CPU or MEM
				total = total + unit
			end		
		end
	else -- total for single addon
		total = gf.getCondition(spa.showCPU, GetAddOnCPUUsage(name), GetAddOnMemoryUsage(name))
	end
	return total, modular
end

---------------------------
-- format usage (calculations)
---------------------------
function gf.Memory.Format(Type,usage,display)
	local color, val, txt = HEX.green, usage, ""	
	if usage > 500 then	color = HEX.yellow;	end	
	if (not spa.showPercent) or display then
		if Type == "MEM" then	
			txt = "kb"
			if usage > 1000 then color = HEX.red; val = val/1024; txt = "mb"; end
		elseif Type == "CPU" then
			txt = "ms"
			if usage > 1000 then color = HEX.red; val = val/1000; txt = "s"; end
		end
	else
		if usage > 1000 then color = HEX.red; end
		txt = "%%"; val = (usage/gv.unitTotal)*100;
	end
	return format(color.."%.2f "..HEX.white..txt, val)
end

---------------------------
-- compare memory usage (color and image change on activity)
---------------------------
function gf.Memory.compare(a,b)
	local color, image = "LBL", "steady"
	if a ~= b then
		if a > b then image = "down" elseif a < b then image = "up"	end
		color = "GRN"
	end
	return color, image
end

---------------------------
-- garbage collection
---------------------------
function gf.Memory.collectGarbage()
	local current = collectgarbage("count")
	collectgarbage("collect")
	local garbage = current - collectgarbage("count")
	UpdateAddOnMemoryUsage()
	if spa.showCPU then UpdateAddOnCPUUsage() end
	gf.sendMSG("Memory Recycled. ("..gf.Memory.Format("MEM",garbage,true)..")");
end

---------------------------
-- reload UI to set CVar for CPU to work (only once)
---------------------------
StaticPopupDialogs["Glance_Memory_RELOADUI"] = {
	text = "Reload your User Interface?",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function()	
		spa.showCPU=true; 
		spa.MEMCPU = "CPU";
		SetCVar("scriptProfile",1) -- Needed to track CPU
		ReloadUI()
	end,
	timeout = 5,
	hideOnEscape = 1,
	exclusive = 1,
	whileDead = 1
}

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Memory")
end