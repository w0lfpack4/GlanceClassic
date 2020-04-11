
---------------------------
-- create the button
---------------------------
Glance.Functions.AddButton("Options","RIGHT")
local btn = Glance.Buttons.Options
btn.text              = "      "
btn.enabled           = true
btn.texture.normal    = "Interface\\AddOns\\Glance\\images\\gear.tga"
btn.events            = {"ADDON_LOADED"}
btn.update            = true
btn.tooltip           = true
btn.click             = true
btn.onload            = true
btn.options           = true
btn.menu              = false
btn.save.perCharacter = {["Modules"] = {}}
btn.save.perAccount   = {}

---------------------------
-- variables
---------------------------
Glance.Arrays.Modules = {}
Glance.Variables.ModuleScrollIDX = 0

---------------------------
-- update
---------------------------
function Glance.Functions.Options.update(self, event, arg1)
	if event=="ADDON_LOADED" then
		local AddOnParent = GetAddOnDependencies(arg1)
		if AddOnParent == "Glance" then
			Glance.Functions.Options.resetModuleList()
		end
	end
end

---------------------------
-- tooltip
---------------------------
function Glance.Functions.Options.tooltip()
	Glance.Debug("function","tooltip","Options")
	local tooltip = Glance.Functions.Tooltip
	tooltip.Title("Options", "GLD")
	tooltip.Line("(Left-Click to open Glance Options)", "WHT")
end

---------------------------
-- click
---------------------------
function Glance.Functions.Options.click(self, button, down)
	Glance.Debug("function","click","Options")
	--if button == "LeftButton" then
		if not IsAddOnLoaded("Glance_Options") then
			LoadAddOn("Glance_Options")
		end
		InterfaceOptionsFrame_OpenToCategory(Glance_Panel1)
		InterfaceOptionsFrame_OpenToCategory(Glance_Panel1)
	--end
end

---------------------------
-- onload
---------------------------
function Glance.Functions.Options.onload()
	Glance.Functions.Options.resetModuleList()
	Glance.Panels[1] = {"Glance",GetAddOnMetadata("Glance","Notes")}
	_G["Glance_Panel1"] = CreateFrame( "Frame", "Glance_Panel1", UIParent )
	_G["Glance_Panel1"]:Hide()
	_G["Glance_Panel1"].name = "Glance"
	_G["Glance_Panel1"]:SetScript('OnShow', function(self) if not IsAddOnLoaded("Glance_Options") then LoadAddOn("Glance_Options"); InterfaceAddOnsList_Update(); end end)
	InterfaceOptions_AddCategory(_G["Glance_Panel1"])
end

---------------------------
-- options
---------------------------
function Glance.Functions.Options.options()
	Glance.Variables.ModuleScrollIDX = Glance.Functions.createScrollBar(_G["Glance_Panel4"],18,-80,415,300,20,Glance.Arrays.Modules,1,3,Glance.Functions.Options.setPreferredModule,4)
end

---------------------------
-- module scrollbar click
---------------------------
function Glance.Functions.Options.setPreferredModule(line)
	local pref, name, title
	name = _G[getglobal("Glance_SBE"..Glance.Variables.ModuleScrollIDX..line):GetName().."Text"]:GetText()
	pref = _G["Glance_SBE"..Glance.Variables.ModuleScrollIDX..line]:GetChecked()
	for i=1, #Glance.Arrays.Modules do
		if Glance.Functions.matchSingle(name,Glance.Arrays.Modules[i][2]) then
			title = Glance.Arrays.Modules[i][2]
		end
	end
	if title ~= nil then
		if pref then
			Glance.Functions.Enable(title)
		else
			Glance.Functions.Disable(title)
		end
		Glance.Buttons.Options.save.perCharacter.Modules[title] = pref
	end
	Glance.Functions.Options.resetModuleList()
end

---------------------------
-- module scrollbar onenter
---------------------------
function Glance.Functions.Options.setModuleText(line)
	if line == 0 then Glance.Frames.descFrame:SetText(""); return end	
	local HEX = Glance.Arrays.colors.HEX
	local name, title, checked, updated, description, new, mem, enabledyn, text
	name = _G[getglobal("Glance_SBE"..Glance.Variables.ModuleScrollIDX..line):GetName().."Text"]:GetText()
	for i=1, #Glance.Arrays.Modules do
		if Glance.Functions.matchSingle(name,Glance.Arrays.Modules[i][2]) then
			title = Glance.Arrays.Modules[i][2]
			checked = Glance.Arrays.Modules[i][3]
			updated = Glance.Arrays.Modules[i][4]
			description = Glance.Arrays.Modules[i][5] or "There is no description for this module"
			new = Glance.Arrays.Modules[i][6]
			mem = Glance.Arrays.Modules[i][7]
			if checked then enabledyn = HEX.green.."enabled" else enabledyn = HEX.red.."disabled" end
			if new == nil or new == "" then new = "There are no updates for this module in this release." end
		end
	end
	text = HEX.gold..title.." Module: \r"
	text = text..HEX.white..description
	
	text = text..HEX.gold.."\r\rModule: \r"
	text = text..HEX.white..enabledyn
	
	text = text..HEX.gold.."\r\rMemory Usage: \r"
	text = text..HEX.white..mem
	
	text = text..HEX.gold.."\r\rLast Updated: \r"
	text = text..HEX.white..updated
	
	text = text..HEX.gold.."\r\rNew in this version: \r"
	text = text..HEX.white..new
	
	Glance.Frames.descFrame:SetText(text)
					
end

---------------------------
-- create modules array
---------------------------
function Glance.Functions.Options.resetModuleList()
	UpdateAddOnMemoryUsage()
	wipe(Glance.Arrays.Modules)
	for i=1, GetNumAddOns() do
		local AddOnParent = GetAddOnDependencies(i)
		if AddOnParent == "Glance" then
			local checked = false
			if IsAddOnLoaded(i) then
				checked = true
			end
			local name, title, notes, enabled = GetAddOnInfo(i)
			local displayName = GetAddOnMetadata(name,"X-DisplayName")
			if enabled == nil then 
				checked = false 
			end
			if displayName ~= "Options" then
				local mem = Glance.Functions.Options.FormatMemory(GetAddOnMemoryUsage(i)) or "0"
				if Glance.Buttons.Options.save.perCharacter.Modules[displayName] == nil then
					Glance.Buttons.Options.save.perCharacter.Modules[displayName] = checked
				else
					checked = Glance.Buttons.Options.save.perCharacter.Modules[displayName]
				end
				table.insert(Glance.Arrays.Modules, {displayName.." Module ("..mem..")", displayName, checked, GetAddOnMetadata(name,"X-Updated"), GetAddOnMetadata(name,"X-Description"), GetAddOnMetadata(name,"X-New"), mem})
				--table.sort(Glance.Arrays.Modules, function(a, b) return a[1] > b[1] end)
			end
		end
	end
end

---------------------------
-- format memory usage
---------------------------
function Glance.Functions.Options.FormatMemory(usage)
	local HEX = Glance.Arrays.colors.HEX
	if usage > 1000 then
		return format(HEX.red.."%.2f "..HEX.white.."mb", usage/1024)
	elseif usage > 500 then
		return format(HEX.yellow.."%.2f "..HEX.white.."kb", usage)
	elseif usage > 0 then
		return format(HEX.green.."%.2f "..HEX.white.."kb", usage)
	end
end