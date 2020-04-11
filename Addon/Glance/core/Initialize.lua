---------------------------
-- lets simplify a bit..
---------------------------
local gf = Glance.Functions
local gv = Glance.Variables
local ga = Glance.Arrays
local gb = Glance.Buttons
local gm = Glance.Menus


---------------------------
-- create button
---------------------------
function gf.createButton(anchor,i)
	local k = gv.button.order[anchor][i]
	local v = gb[k]
	if v.enabled then
		Glance.Debug("frame","create",k)
		-- create the button frame
		v.button = CreateFrame("BUTTON", "Glance_Buttons_"..v.name, Glance.Frames.topFrame)
		--v.button.texture = v.button:CreateTexture()
		--v.button.texture:SetAllPoints(v.button)
		--v.button.texture:SetTexture(1, 1, 1, .7)
		--v.button.texture:SetGradientAlpha("VERTICAL", 0, 0, 0, .7, .5, .5, .5, .7) 
		local btn = v.button
		-- set button height
		btn:SetHeight(16)
		-- set button font
		--local fs = btn:CreateFontString()
		--fs:SetFont(v.font, 12)
		local font = nil
		if v.font ~= nil then
			font = CreateFont("myfont")
			font:SetFont(v.font,12)
		else
			if Glance_Local.Options.font ~= nil then
				font = CreateFont(ga.Font[Glance_Local.Options.font][1])
				font:SetFont(ga.Font[Glance_Local.Options.font][2],Glance_Local.Options.fontSize+7) -- ID + 7 (starting fontsize = 8 but we go by id)
			else
				font = CreateFont(ga.Font[1][1])
				font:SetFont(ga.Font[1][2],12) -- ID + 7 (starting fontsize = 8 but we go by id)
			end
		end
		if Glance_Local.Options.showShadow then
			font:SetShadowColor(0, 0, 0, .7)
			font:SetShadowOffset(1, -1)
		end
		--btn:SetFontString(fs)
		btn:SetNormalFontObject(font)
		btn:SetText(v.text)
		-- set texture if any
		if v.texture.normal ~= nil then
			btn:SetNormalTexture(v.texture.normal)
		end
		if v.texture.highlight ~= nil then
			btn:SetHighlightTexture(v.texture.highlight)
		end	
		-- if button has onUpdate, register the events to the button frame
		if v.update then
			for i=1, #v.events do
				--Glance.Events[v.name] = v.events[i]
				Glance.Debug("event","registered",v.events[i])
				btn:RegisterEvent(v.events[i])
			end
			btn:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
				for i=1, #v.events do
					if event == v.events[i] then
						Glance.Debug("event","fired",event)
						gf[k].update(self, event, arg1)
					end
				end
			end)
		end
		-- create menu frame
		gm[k] = CreateFrame("Frame", "gm."..k)		
		
		-- set events for tooltip if any
		btn:SetScript("OnEnter", function(...) if v.enabled and v.tooltip then SetCursor("CAST_CURSOR") gf.showTooltip(v.name) end Glance.Timers["autoHide"] = nil end)
		btn:SetScript("OnLeave", function(...) GameTooltip:Hide(); SetCursor("POINT_CURSOR"); gv.messageCheck = true; Glance.Timers["autoHide"] = {0,50,true,nil,"autoHide",nil} end)
		
		-- button drag events and registration
		btn:SetMovable(true)
		btn:ClearAllPoints()
		btn:RegisterForDrag("LeftButton")
		btn:SetScript("OnDragStart", function() gf.onDrag(btn) end)
		btn:SetScript("OnMouseDown", function(self, button, down) gv.buttonX,_ = GetCursorPosition() end)
		-- set up click events if any
		btn:RegisterForClicks("AnyUp")
		if v.click then
			btn:SetScript("OnClick", function(self, button, down) if button == "RightButton" then gf[v.name].click(self, button, down); ToggleDropDownMenu(1, nil, gm[k], btn, 0, 0); gv.menuOpen = true; GameTooltip:Hide() else if not btn.isMoving then gf[v.name].click(self, button, down) gv.buttonX,_ = GetCursorPosition() end end end)
		else
			btn:SetScript("OnClick", function(self, button, down) if button == "RightButton" then ToggleDropDownMenu(1, nil, gm[k], btn, 0, 0); gv.menuOpen = true; GameTooltip:Hide() end end)
		end
		--set icon width if texture, or text width
		if v.texture.normal ~= nil then
			btn:SetWidth(16)
		else
			btn:SetWidth(btn:GetTextWidth())
		end
		-- hide by default
		btn:Hide()
	end
end

---------------------------
-- Disable Button
---------------------------
function gf.Disable(name)
	Glance.Debug("disable","button",name)
	-- WoW disable addon
	DisableAddOn("Glance_"..name)
	-- if button exists
	if gb[name] ~= nil then
		gb[name].enabled = false
		-- unregister any events
		for i=1, #gb[name].events do
			Glance.Debug("event","unregistered",gb[name].events[i])
			gb[name].button:UnregisterEvent(gb[name].events[i])
		end
		-- hide the button
		gb[name].button:Hide()
		-- remove the button from the button order
		if gf.CheckButtonOrder(name) then
			gf.tableRemoveByVal(gv.button.order[gb[name].anchor], name)
		end
		-- reposition buttons
		gf.positionButtons()
		-- save to local
		Glance_Local.button.order[gb[name].anchor] = gv.button.order[gb[name].anchor]
	end
end

---------------------------
-- Enable Button
---------------------------
function gf.Enable(name)
	Glance.Debug("enable","button",name)
	-- WoW enable addon (ONLY enables, does not load)
	EnableAddOn("Glance_"..name)
	-- addon is already in memory.  must have disabled/enabled from options or loaded from ACP
	if IsAddOnLoaded("Glance_"..name) then
		-- if part of button array
		if gb[name] ~= nil then
			gb[name].enabled = true
			-- if a frame exists
			if gb[name].button ~= nil then
				--register any events
				for i=1, #gb[name].events do
					Glance.Debug("event","registered",gb[name].events[i])
					gb[name].button:RegisterEvent(gb[name].events[i])
				end
				-- add to the button order
				if not gf.CheckButtonOrder(name) then
					table.insert(gv.button.order[gb[name].anchor],name)
				end
			-- if loaded from the UI/ACP
			else 
				-- add to the button order
				if not gf.CheckButtonOrder(name) then
					table.insert(gv.button.order[gb[name].anchor],name)
				end
				-- create the frame, run onUpdate, onLoad, setOptions
				gf.createButton(gb[name].anchor,#gv.button.order[gb[name].anchor])
				gf.load(name)
				if gb[name].update then
					gf[name].update()
				end
				if gb[name].onload then
					gf[name].onload()
				end
				if gb[name].options then
					gf[name].options()
				end
				-- set the width, add to per char module list
				gb[name].button:SetWidth(gb[name].button:GetTextWidth())
				gb.Options.save.perCharacter.Modules[name] = true
				-- reset options module list
				gf.Options.resetModuleList()
			end
			-- reposition buttons
			gf.positionButtons()
			gb[name].button:Show()
		end
	-- addon has NOT been loaded yet
	else
		-- if loaded from the Interface Options Panel.
		if IsAddOnLoadOnDemand("Glance_"..name) then 
			gv.loaded = false
			-- load the addon
			LoadAddOn("Glance_"..name)
			-- create the frame, run onUpdate, onLoad, setOptions
			gf.createButton(gb[name].anchor,#gv.button.order[gb[name].anchor])
			gf.load(name)
			gv.loaded = true
			if gb[name].update then
				gf[name].update()
			end
			if gb[name].onload then
				gf[name].onload()
			end
			if gb[name].options then
				gf[name].options()
			end
			-- set the width, add to per char module list
			gb[name].button:SetWidth(gb[name].button:GetTextWidth())
			gb.Options.save.perCharacter.Modules[name] = true
			-- reset options module list
			gf.Options.resetModuleList()
			-- reposition buttons
			gf.positionButtons()
			gb[name].button:Show()
		end
	end
end

---------------------------
-- create popup menus
---------------------------
function gf.createMenu(btn)
	if gb[btn].menu then
		--Glance.Debug("function","createMenu",btn)
		gm[btn].displayMode = "MENU"
		gm[btn].initialize = function(self, level)
			level = level or 1
			--if (level == 1) then 
				gf[btn].menu(level,UIDROPDOWNMENU_MENU_VALUE)
			--end
			--if (level == 2) then
			--	gf[btn].menu(level,UIDROPDOWNMENU_MENU_VALUE)
			--end
		end
	end
end

---------------------------
-- on drag
---------------------------
function gf.onDrag(btn)
	GameTooltip:Hide()
	if gv.flip then
		Glance.Debug("function","onDrag",btn:GetName())
		btn.isMoving = true
		local xpos,ypos = GetCursorPosition()
		for k, v in pairs(gb) do
			if btn:GetName() == gb[k].button:GetName() then
				if gv.buttonX-xpos > 0 then
					gf.flip(btn,"LEFT",gb[k].anchor)
				else
					gf.flip(btn,"RIGHT",gb[k].anchor)
				end
			end
		end
		btn:StopMovingOrSizing()
	end
end

---------------------------
-- swap buttons
---------------------------
function gf.flip(btn,dir,anchor)
	local i=0
	local bc = #gv.button.order[anchor]
	local bo = gv.button.order[anchor]
	for i=1, bc do
		local k = bo[i]
		local v = gb[k]
		if v ~= nil then
			if btn == v.button then
				Glance.Debug("function flip",dir,v.name)
				if anchor == "LEFT" then
					if dir == "LEFT" then
						if i == 1 then
							return
						else
							bo[i-1],bo[i] = bo[i],bo[i-1]
						end
					else
						if i == bc then
							table.remove(gv.button.order.LEFT) 
							table.insert(gv.button.order.RIGHT,v.name)
							v.anchor = "RIGHT"
							v.position = #gv.button.order.RIGHT
						else 
							bo[i+1],bo[i] = bo[i],bo[i+1]
						end
					end
				else
					if dir == "LEFT" then
						if i == bc then
							table.remove(gv.button.order.RIGHT) 
							table.insert(gv.button.order.LEFT,v.name)
							v.anchor = "LEFT"
							v.position = #gv.button.order.LEFT
						else
							bo[i+1],bo[i] = bo[i],bo[i+1]
						end
					else
						if i == 1 then
							return
						else
							bo[i-1],bo[i] = bo[i],bo[i-1]
						end
					end
				end
				gf.positionButtons()
				break
			end
		end
		btn:ClearAllPoints()
	end	
	btn.isMoving = false
	btn:StopMovingOrSizing()
	gv.flip = false
end

---------------------------
-- position buttons
---------------------------
function gf.positionButtons()
	Glance.Debug("function","positionButtons",nil)
	local i=0
	local prev = Glance.Frames.topFrame
	for i=1, #gv.button.order.LEFT do
		local k = gv.button.order.LEFT[i]
		local v = gb[k] or nil
		if v ~= nil then
			if v.enabled then
				if prev == Glance.Frames.topFrame then
					Glance.Debug("position",v.text.." anchored to frame",nil);
					v.button:SetPoint("LEFT", prev, "LEFT", 5, 0)
				else
					Glance.Debug("position",v.text.." anchored to "..prev:GetName(),nil);
					v.button:SetPoint("LEFT", prev, "RIGHT", gv.spacer, 0)
				end
				prev = v.button
				v.anchor = "LEFT"
				v.position = i
			end
		end
	end
	i=0
	prev = Glance.Frames.topFrame
	for i=1, #gv.button.order.RIGHT do
		local k = gv.button.order.RIGHT[i]
		local v = gb[k] or nil
		if v ~= nil then
			if v.enabled then
				if prev == Glance.Frames.topFrame then
					v.button:SetPoint("RIGHT", prev, "RIGHT", -gv.spacer, 0)
				else
					v.button:SetPoint("RIGHT", prev, "LEFT", -gv.spacer, 0)
				end
				prev = v.button
				v.anchor = "RIGHT"
				v.position = i
			end
		end
	end
	gf.saveButtonOrder()
end

---------------------------
-- preferred button order
---------------------------
function gf.setPreferredOrder()
	Glance_Local.button.order = {
		["RIGHT"] = {
			"Options", -- [1]
			"Titles", -- [2]
			"Dungeons", -- [3]
			"DualSpec", -- [4]
			"Pets", -- [5]
			"Mounts", -- [6]
			"Clock", -- [7]
			"Location", -- [8]
		},
		["LEFT"] = {
			"Gold", -- [1]
			"Emblems", -- [2]
			"Bags", -- [3]
			"Friends", -- [4]
			"Guild", -- [5]
			"Armor", -- [6]
			"XP", -- [7]
			"Reputation", -- [8]
			"Professions", -- [9]
			"Latency", -- [10]
			"Framerate", -- [11]
			"Memory", -- [12]
			"WinterGrasp", -- [13]
			"TolBarad", -- [14]
		},
	}
end

---------------------------
-- update mods
---------------------------
function gf.updateAll()
	Glance.Debug("function","update","all")
	local font = nil	
	if Glance_Local.Options.font ~= nil then
		font = CreateFont(ga.Font[Glance_Local.Options.font][1])
		font:SetFont(ga.Font[Glance_Local.Options.font][2],Glance_Local.Options.fontSize+7) -- ID + 7 (starting fontsize = 8 but we go by id)
	else
		font = CreateFont(ga.Font[1][1])
		font:SetFont(ga.Font[1][2],12) -- ID + 7 (starting fontsize = 8 but we go by id)
	end
	if Glance_Local.Options.showShadow then
		font:SetShadowColor(0, 0, 0, 1)
		font:SetShadowOffset(1, -1)
	else
		font:SetShadowColor(0, 0, 0, 0)
		font:SetShadowOffset(0, 0)
	end
	for k, v in pairs(gb) do
		if gb[k].enabled and gb[k].update then
			gf[k].update()
			gb[k].button:SetWidth(gb[k].button:GetTextWidth())
		end		
		if gb[k].enabled and gb[k].button ~= nil then
			gb[k].button:SetNormalFontObject(font)
		end
	end
end

---------------------------
-- load variables
---------------------------
function gf.load(name)
	--Glance.Debug("function","load variables",name)
	if gb[name].enabled then
		if gb[name].save.perAccount ~= nil then
			if Glance_Global[name] == nil then Glance_Global[name] = {} end
			for key, val in pairs(gb[name].save.perAccount) do
				if Glance_Global[name][key] == nil then 
					Glance_Global[name][key] = gb[name].save.perAccount[key]
				else
					gb[name].save.perAccount[key] = Glance_Global[name][key]
				end
			end
		end
		if gb[name].save.perCharacter ~= nil then
			if Glance_Local[name] == nil then Glance_Local[name] = {} end
			for key, val in pairs(gb[name].save.perCharacter) do
				if Glance_Local[name][key] == nil then 
					Glance_Local[name][key] = gb[name].save.perCharacter[key]
				else
					gb[name].save.perCharacter[key] = Glance_Local[name][key]
				end
			end
		end
		gf.createMenu(name)
	end
end

---------------------------
-- save variables
---------------------------
function gf.saveAll()
	Glance.Debug("function","save","all")
	for k, v in pairs(gb) do
		if gb[k].enabled then
			if gb[k].save.perAccount ~= nil then
				for key, val in pairs(gb[k].save.perAccount) do
					Glance_Global[k][key] = gb[k].save.perAccount[key]
				end
			end
			if gb[k].save.perCharacter ~= nil then
				for key, val in pairs(gb[k].save.perCharacter) do
					Glance_Local[k][key] = gb[k].save.perCharacter[key]
				end
			end
		end
	end
	gf.saveButtonOrder()
end

---------------------------
-- save buttons
---------------------------
function gf.saveButtonOrder()
	Glance_Local.button.order.LEFT = gv.button.order.LEFT
	Glance_Local.button.order.RIGHT = gv.button.order.RIGHT	
end

---------------------------
-- move player/target/buffs/map
---------------------------
function gf.moveUI()
	local point, relativeTo, relativePoint, xOfs, yOfs
	if (not Glance_Local.Options.showLow) and (not Glance_Local.Options.autoHide) then
		if Glance_Local.Options.movePlayer then
			point, relativeTo, relativePoint, xOfs, yOfs = PlayerFrame:GetPoint(1)
			PlayerFrame:ClearAllPoints()
			PlayerFrame:SetPoint("TOPLEFT", Glance.Frames.topFrame, "BOTTOMLEFT", xOfs, yOfs)
			gv.hook.player = true
		elseif gv.hook.player then
			x = PlayerFrame:GetLeft() - UIParent:GetLeft()
			PlayerFrame:ClearAllPoints()
			PlayerFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, -4)
		end
		
		if Glance_Local.Options.moveTarget then
			point, relativeTo, relativePoint, xOfs, yOfs = TargetFrame:GetPoint(1)
			TargetFrame:ClearAllPoints();
			TargetFrame:SetPoint("TOPLEFT", Glance.Frames.topFrame, "BOTTOMLEFT", xOfs, yOfs)
			gv.hook.target = true
		elseif gv.hook.target then
			x = TargetFrame:GetLeft() - UIParent:GetLeft()
			TargetFrame:ClearAllPoints();
			TargetFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, -4)
		end
		
		if Glance_Local.Options.moveBuffs then
			point, relativeTo, relativePoint, xOfs, yOfs = BuffFrame:GetPoint(1)
			BuffFrame:ClearAllPoints();
			BuffFrame:SetPoint("TOPRIGHT", Glance.Frames.topFrame, "BOTTOMRIGHT", xOfs, yOfs)
			gv.hook.buffs = true
		elseif gv.hook.buffs then
			x = BuffFrame:GetRight() - UIParent:GetRight()
			BuffFrame:ClearAllPoints();
			BuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", x, -13)
		end
		
		if Glance_Local.Options.moveMinimap then
			point, relativeTo, relativePoint, xOfs, yOfs = MinimapCluster:GetPoint(1)
			MinimapCluster:ClearAllPoints();
			MinimapCluster:SetPoint("TOPRIGHT", Glance.Frames.topFrame, "BOTTOMRIGHT", xOfs, -13)
			gv.hook.minimap = true
			--point, relativeTo, relativePoint, xOfs, yOfs = MainMenuBar:GetPoint(1)
		elseif gv.hook.minimap then
			x = MinimapCluster:GetRight() - UIParent:GetRight()
			MinimapCluster:ClearAllPoints();
			MinimapCluster:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", "RIGHT", 0)
		end
		--MainMenuBar:ClearAllPoints();
		--MainMenuBar:SetPoint("CENTER", Glance.Frames.bottomFrame, "CENTER", xOfs, 33)
	end
end

---------------------------
-- re-move player/target
---------------------------
function gf.checkUI()
	Glance.Debug("ui","reset",nil)
	if (not Glance_Local.Options.showLow) and (not Glance_Local.Options.autoHide) and (Glance_Local.Options.reposition) then
		if Glance_Local.Options.movePlayer then
			local point, relativeTo, relativePoint, xOfs, yOfs = PlayerFrame:GetPoint(1)
			PlayerFrame:ClearAllPoints()
			PlayerFrame:SetPoint("TOPLEFT", Glance.Frames.topFrame, "BOTTOMLEFT", xOfs, yOfs)
		end
		if Glance_Local.Options.moveTarget then
			local point, relativeTo, relativePoint, xOfs, yOfs = TargetFrame:GetPoint(1)
			TargetFrame:ClearAllPoints();
			TargetFrame:SetPoint("TOPLEFT", Glance.Frames.topFrame, "BOTTOMLEFT", xOfs, yOfs)
		end
	end
	gv.vehicleCheck = false;
end

---------------------------
-- first run onload delay called from timers
---------------------------
function gf.onLoad()
	if gv.loaded then return end
	Glance.Debug("function","onLoad",nil)
	Glance.Frames.topFrame:SetScale(Glance_Local.Options.frameScale)	
	-- button order does not exist, create a default
	if Glance_Local.button.order.RIGHT[1] == nil then
		gf.setPreferredOrder()
	end
	--load button variables, add to button order
	for k, v in pairs(gb) do
		gf.load(k,v)
		if Glance_Local.Options.Modules[k] == true then -- module is enabled
			local found = nil
			for i=1, #Glance_Local.button.order.RIGHT do
				if Glance_Local.button.order.RIGHT[i] == k then
					found = true -- module exists, skip
				end
			end
			for i=1, #Glance_Local.button.order.LEFT do
				if Glance_Local.button.order.LEFT[i] == k then
					found = true -- module exists, skip
				end
			end
			if not found then -- module not listed, should be new..
				gf.tableAddByVal(Glance_Local.button.order[gb[k].anchor], k) -- this by itself caused an error moving left side modules to right
			end
		end
	end
	
	-- set internal button order from saved local
	Glance.Debug("loading","button order",nil)
	gv.button.order.LEFT = Glance_Local.button.order.LEFT
	gv.button.order.RIGHT = Glance_Local.button.order.RIGHT
	
	gf.CheckDuplicates()
	gv.loaded = true
	-- run button onUpdate
	gf.updateAll()
	-- reposition the buttons
	gf.positionButtons()
	-- run button onLoad
	for k, v in pairs(gb) do
		if gb[k].button ~= nil then
			gb[k].button:Show()
			--set icon width if texture, or text width --Patch 5.4 workaround..
			gb[k].button:SetHeight(16)
			if gb[k].texture.normal ~= nil then
				gb[k].button:SetWidth(16)
			else
				gb[k].button:SetWidth(gb[k].button:GetTextWidth())
			end
			if gb[k].onload then
				gf[k].onload()
			end
			local point, relativeTo, relativePoint, xOfs, yOfs = gb[k].button:GetPoint(1)
			if relativeTo ~= nil then
				Glance.Debug("position",gb[k].text.." setpoint ("..point..", "..tostring(relativeTo:GetName())..", "..relativePoint..", "..xOfs..", "..yOfs..")",nil);
			end
		end
	end
	Glance.Frames.topFrame:SetText("")
	gv.gametime.initSession = time()
	gv.requestingTimePlayed = true
	RequestTimePlayed()

	-- nudge them all
	gf.moveUI()
	
	if Glance_Local.Options.showLow then
		local tf = Glance.Frames.topFrame
		local t = _G["GlanceBorder"]
		gf.positionBar(0,true)
		t:ClearAllPoints()
		t:SetPoint("BOTTOMLEFT", tf, "TOPLEFT", 0, 0)
		t:SetPoint("BOTTOMRIGHT", tf, "TOPRIGHT", 0, 0)
	end
	gf.sendMSG("v"..GetAddOnMetadata("Glance","Version").." loaded.  Type '/glance options' to set your preferences.")
	--if Glance_Local.Options.autoHide then
		local cf = Glance.Frames.cloneFrame
		local tf = Glance.Frames.topFrame
		gf.autoHide(true)
		cf:SetScript("OnEnter", function(...) gf.autoHide(false) end)
		tf:SetScript("OnEnter", function(...) Glance.Timers["autoHide"] = nil end)	
		tf:SetScript("OnLeave", function(...) Glance.Timers["autoHide"] = {0,50,true,nil,"autoHide",nil} end)	
	--end
end

---------------------------
-- addon loaded event
---------------------------
function gf.addonLoaded()
	Glance.Debug("function","addonLoaded",nil)
	Glance.Debug("loading","modules",nil)
	-- check for dependencies
	for i=1, GetNumAddOns() do
		local AddOnParent = GetAddOnDependencies(i)
		if AddOnParent == "Glance" then
			--found dependent
			local name, title, notes, enabled = GetAddOnInfo(i)
			local displayName = GetAddOnMetadata(name,"X-DisplayName")
			if name ~= "Glance_Options" and name ~= "Glance_Frames" then
				-- not in the options modules list, but not disabled.  new addon, add it.
				if Glance_Local.Options.Modules[displayName] == nil and enabled ~= nil then
					Glance_Local.Options.Modules[displayName] = true --per toon
				end
				-- disabled addon via ACP or WOW
				if enabled == nil then
					-- set to false so we don't load it
					Glance_Local.Options.Modules[displayName] = false -- per toon
					-- buttons already loaded, remove this addon from the button array
					if Glance_Local.button ~= nil then  -- double check this.. buttons shouldn't be loaded yet.
						gf.tableRemoveByVal(Glance_Local.button.order.LEFT, displayName)
						gf.tableRemoveByVal(Glance_Local.button.order.RIGHT, displayName)
					end
				end
				-- if we're allowed to, load it
				if Glance_Local.Options.Modules[displayName] then	
					Glance.Frames.topFrame:SetText("loading module: "..displayName.."...")
					local loaded, reason = LoadAddOn(i)
				end
			end
		end
	end
	for i=1, #gv.button.order.LEFT do
		gf.createButton("LEFT",i)
	end
	for i=1, #gv.button.order.RIGHT do
		gf.createButton("RIGHT",i)
	end
	-- creates local.options if they don't exist
	gf.loadDefaultVariables()
	gf.setBackground(1)
	-- needed for comm
	--RegisterAddonMessagePrefix("Glance")
	Glance.Frames.topFrame:SetText("modules loaded.  configuring...")
end

---------------------------
-- onEvent/onUpdate handler
---------------------------
function gf.handleEvents()
	Glance.Frames.topFrame:SetScript("OnEvent", function(self, event, arg1, arg2, arg3, arg4)
		-- addon first load, set variables
		if event=="SAVED_VARIABLES_TOO_LARGE" and arg1 == "Glance" then		
			Glance.Frames.topFrame:SetText("Error: Not Enough Memory")
		elseif event=="ADDON_LOADED" and arg1 == "Glance" then
			Glance.Debug("event","fired",event)
			gf.addonLoaded()
		-- player entering world, reset the UI
		elseif (event == "PLAYER_ENTERING_WORLD") then
			Glance.Debug("event","fired",event)
			gf.checkUI()
			if IsResting() then
				gf.setBackground(4)
			else
				gf.setBackground(1)
			end
		-- player resting
		elseif (event == "PLAYER_UPDATE_RESTING") then
			Glance.Debug("event","fired",event)
			if IsResting() then
				gf.setBackground(4)
			else
				gf.setBackground(1)
			end
		-- pet battle start
		elseif (event == "PET_BATTLE_OPENING_START") then
			Glance.Debug("event","fired",event)
			if (not Glance_Local.Options.autoHide) and (Glance_Local.Options.autoHidePet) then
				gv.inPetBattle = true -- order is important
				gf.autoHide()
			end
		-- pet battle end
		elseif (event == "PET_BATTLE_CLOSE") then		
			Glance.Debug("event","fired",event)
			if (not Glance_Local.Options.autoHide) and (Glance_Local.Options.autoHidePet) then
				gf.autoHide(false)	
				gv.inPetBattle = false -- order is important
			end
		-- player in combat
		elseif (event == "PLAYER_REGEN_DISABLED") then
			Glance.Debug("event","fired",event)
			gf.setBackground(2)
		--player out of combat
		elseif (event == "PLAYER_REGEN_ENABLED") then
			Glance.Debug("event","fired",event)
			gf.setBackground(1)
			if gv.inCombatNeedExit then
				gf.autoHide(false)
				gv.inVehicle = false -- order is important
				gv.inCombatNeedExit = false
			end
		-- player frame in vehicle
		elseif (event == "UNIT_ENTERING_VEHICLE" and arg1 == "player") then
			Glance.Debug("event","fired",event)
			gv.vehicleCheck = true
			if (not Glance_Local.Options.autoHide) and (Glance_Local.Options.autoHideVehicle) then
				gv.inVehicle = true -- order is important
				gf.autoHide()
			end
		-- player frame out of vehicle, timer5 will reset
		elseif (event == "UNIT_EXITING_VEHICLE" and arg1 == "player") then
			Glance.Debug("event","fired",event)
			gv.vehicleCheck = true
			if (not Glance_Local.Options.autoHide) and (Glance_Local.Options.autoHideVehicle) then
				if InCombatLockdown() then
					gv.inCombatNeedExit = true
				else
					gf.autoHide(false)
					gv.inVehicle = false -- order is important
				end
			end
		-- addon trying to communicate
		elseif (event == "CHAT_MSG_ADDON") then
			Glance.Debug("event","fired",event)
			gf.addonResponse(arg1,arg2,arg3,arg4)
		-- print time played
		elseif (event == "TIME_PLAYED_MSG") then
			Glance.Debug("event","fired",event)
			gv.gametime.initTotal = time() - arg1
			gv.gametime.initLevel = time() - arg2
			if Glance_Local.Options.timePlayed and not gv.timePlayed then
				gf.sendMSG("Total Time Played: "..gf.formatTime(time() - gv.gametime.initTotal))
				gf.sendMSG("Time Played This Level: "..gf.formatTime(time() - gv.gametime.initLevel))
				gv.timePlayed = true
			end
		--save data
		elseif (event == "PLAYER_LOGOUT") then
			Glance.Debug("event","fired",event)
			gf.saveAll()
		else
			if gv.DebugAllEvents then
				Glance.Debug("event","non-registered",event)
			end
		end
	end)
	
	-- on update event handling
	Glance.Frames.topFrame:SetScript("OnUpdate", function(self, elapsed)
		-- fire created timers
		for k, v in pairs(Glance.Timers) do 
			if Glance.Timers[k] ~= nil then --min,max,reset,button,func,var
				v[1] = v[1] + ceil(elapsed)
				if v[1] > v[2] then
					if v[6] ~= nil then
						if gv[v[6]] then
							gv[v[6]] = false
						else
							gv[v[6]] = true							
						end
					end
					if v[5] ~= nil then
						if v[4] ~= nil then
							gf[v[4]][v[5]]()
						else
							gf[v[5]]()
						end
					end
					if v[3] then
						v[1] = 0
					else
						Glance.Timers[k] = nil
					end
				end
			end
		end
		-- fire button update on timer 1
		gv.timer1 = gv.timer1 + elapsed
		if gv.timer1 >= 1 then
			gv.timer1 = 0
			gv.overflowFix = true
			for k, v in pairs(gb) do
				if gb[k].enabled and gb[k].timer1 then
					gf[k].update()
				end
				if gb[k].enabled and gb[k].timerTooltip then
					if GameTooltip:IsShown() and GameTooltip:GetOwner() == gb[k].button then
						gf.showTooltip(k)
					end
				end
			end
		end
		--fire button update on timer 5
		gv.timer5 = gv.timer5 + elapsed
		if gv.timer5 >= 5 then
			gv.timer5 = 0
			for k, v in pairs(gb) do
				if gb[k].enabled and gb[k].timer5 then
					gf[k].update()
				end
			end
			if gv.vehicleCheck and not InCombatLockdown() then
				gf.checkUI()				
			end
		end
	end)
end

---------------------------
-- create the main frame
---------------------------
function gf.loadFrame()
	Glance.Frames.topFrame = CreateFrame("BUTTON", "Glance", UIParent)
	local tf = Glance.Frames.topFrame
	tf:SetWidth(gv.screenWidth)
	tf:SetHeight(16)
	tf:SetPoint("TOPLEFT", 0, 0)
	tf:SetPoint("TOPRIGHT", 0, 0)
	tf:SetFrameStrata("HIGH")	
	
	Glance.Frames.cloneFrame = CreateFrame("BUTTON", "GlanceClone", UIParent)
	local cf = Glance.Frames.cloneFrame
	cf:SetWidth(gv.screenWidth)
	cf:SetHeight(16)
	cf:SetPoint("TOPLEFT", 0, 0)
	cf:SetPoint("TOPRIGHT", 0, 0)
	cf:SetFrameStrata("HIGH")
	
	--[[local c = cf:CreateTexture(nil, "BACKGROUND")
	c:SetTexture(1, 0, 0, .5)
	c:SetAllPoints(cf)
	cf.texture = c]]
	
	local t = tf:CreateTexture(nil, "BACKGROUND")
	t:SetTexture(0, 0, 0, .5)
	--t:SetTexture("Interface\\AddOns\\Glance\Skins\carbonfiber.tga",true); --gf.setBackground(n) overrides this.. go there	
	t:SetAllPoints(tf)
	tf.texture = t 	
	
	local t2 = tf:CreateTexture("GlanceBorder", "BORDER")
	t2:SetTexture(.4, .4, .4)
	t2:SetPoint("TOPLEFT", tf, "BOTTOMLEFT", 0, 0)
	t2:SetPoint("TOPRIGHT", tf, "BOTTOMRIGHT", 0, 0)
	t2:SetWidth(gv.screenWidth)
	t2:SetHeight(1)
	
	local fs = tf:CreateFontString()
	fs:SetFont(ga.Font[1][2], 12)
	tf:SetFontString(fs)
	tf:SetText("loading...")
	-- if I want to anchor the text left.
	-- fs:SetPoint("LEFT",tf,"LEFT",0,0);
	-- if I want to click on the frame to get options
	tf:EnableMouse(0)
	-- tf:RegisterForClicks("AnyUp")
	-- tf:SetScript("OnClick", function(self, button, down) if (button == "RightButton") then gf.Options.click(self, "LeftButton", down) end end)

end

---------------------------
-- initialize
---------------------------
function gf.Initialize()
	Glance.Debug("function","initialize",nil)
	gf.loadFrame()
	Glance.Frames.topFrame:Show()
	Glance.Frames.topFrame:RegisterEvent("ADDON_LOADED")
	Glance.Frames.topFrame:RegisterEvent("PLAYER_LOGIN")
	Glance.Frames.topFrame:RegisterEvent("PLAYER_LOGOUT")
	Glance.Frames.topFrame:RegisterEvent("TIME_PLAYED_MSG")
	Glance.Frames.topFrame:RegisterEvent("CHAT_MSG_ADDON")
	Glance.Frames.topFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	--Glance.Frames.topFrame:RegisterEvent("UNIT_ENTERING_VEHICLE")
	--Glance.Frames.topFrame:RegisterEvent("UNIT_EXITING_VEHICLE")
	Glance.Frames.topFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	Glance.Frames.topFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	Glance.Frames.topFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
	Glance.Frames.topFrame:RegisterEvent("SAVED_VARIABLES_TOO_LARGE")
	gf.handleEvents()
	--Glance.Frames.bottomFrame:Show()
end

---------------------------
-- slash commands
---------------------------
SLASH_GLANCE1 = "/Glance"
SlashCmdList["GLANCE"] = function (msg, editBox)
	if strfind(msg,"debug") ~= nil then
		if gv.Debug then
			gv.Debug = false
			gf.sendMSG("Debug Mode: off")
		else
			gv.Debug = true
			gf.sendMSG("Debug Mode: on")
		end
	else
		lmsg = string.lower(msg)
		if lmsg == "options" then
			 gf.Options.click("", "LeftButton", "")
		elseif lmsg == "hide" then
			Glance.Frames.topFrame:Hide()
			gf.moveUI()
			gf.sendMSG("Now hiding the Glance bar.")
		elseif lmsg == "show" then
			Glance.Frames.topFrame:Show()
			gf.moveUI()
			gf.sendMSG("Now showing the Glance bar.")
		elseif Glance.Commands[msg] ~= nil then
			Glance.Commands[msg].func()
		else
			local HEX = ga.colors.HEX
			gf.sendMSG(HEX.yellow.." ")
			gf.sendMSG(HEX.orange.."Glance Options")
			gf.sendMSG(HEX.yellow.."  /glance show: ")
			gf.sendMSG(HEX.white.."  Shows the bar")
			gf.sendMSG(HEX.yellow.."  /glance hide: ")
			gf.sendMSG(HEX.white.."  Hides the bar")
			gf.sendMSG(HEX.yellow.."  /glance options: ")
			gf.sendMSG(HEX.white.."  Shows the options panel")
			gf.sendMSG(HEX.white.." ")
			gf.sendMSG(HEX.orange.."Module Options (/glance)")
			for k, v in pairs(Glance.Commands) do
				gf.sendMSG(HEX.yellow.."  /glance "..k..": ")
				gf.sendMSG(HEX.white.."  "..v.desc)
			end
		end
	end
end
gf.Initialize()
