---------------------------
-- lets simplify a bit..
---------------------------
local gf = Glance.Functions
local gv = Glance.Variables
local ga = Glance.Arrays
local gb = Glance.Buttons
local gd = Glance.Data

---------------------------
-- create the button
---------------------------
gf.AddButton("Armor","LEFT")
local btn = gb.Armor
btn.text			  	= "Armor"
btn.enabled		   		= true
btn.events				= {"MERCHANT_SHOW","UNIT_DAMAGE","UPDATE_INVENTORY_DURABILITY","PLAYER_EQUIPMENT_CHANGED","PLAYER_ENTERING_WORLD","UNIT_INVENTORY_CHANGED","INSPECT_READY","PLAYER_TARGET_CHANGED"}
btn.texture.scan1       = "Interface\\AddOns\\Glance_Armor\\scan1.tga"
btn.texture.scan2       = "Interface\\AddOns\\Glance_Armor\\scan2.tga"
btn.onload              = true
btn.update				= true
btn.tooltip		   		= true
btn.menu			  	= true
btn.click				= true
btn.save.perCharacter 	= {["autoRepair"] = true,["guildRepair"] = true}
btn.save.perAccount 	= {["showIL"] = true,["showCharacterOverlay"] = true,["showInspectOverlay"] = true,["showTooltipOverlay"] = true}
btn.save.allowProfile 	= true

---------------------------
-- shortcuts
---------------------------
local spc = btn.save.perCharacter
local spa = btn.save.perAccount
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip
local loaded = false

---------------------------
-- variables
---------------------------
gf.Armor.iLvl = {}
gf.Armor.repair = {}
gv.currentInspectUnit = nil
gv.currentPreloadUnit = nil
gv.data = {}
gv.data.target = {}
gv.data.player = {}

---------------------------
-- arrays
---------------------------
ga.slotItems = { -- order is important, both names and index are used
	"AmmoSlot",
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"ShirtSlot",
	"ChestSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"WristSlot",
	"HandsSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"BackSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
	"RangedSlot",	
	"TabardSlot",
}
gv.party.a["Armor"] = 0
gv.party.b["Armor"] = 0
gv.party.c["Armor"] = 0
gv.party.d["Armor"] = 0

---------------------------
-- tooltips for parsing
---------------------------
local ArmorTooltip = CreateFrame("GameTooltip","Glance_Tooltip_Armor",UIParent,"GameTooltipTemplate")
ArmorTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")

---------------------------
-- scan in progress icon
---------------------------
local AI = CreateFrame("Frame","Glance_ArmorIcon",GameTooltip);
AI:SetWidth(45);
AI:SetHeight(45);	
AI.texture = AI:CreateTexture(nil,"BACKGROUND");
AI.texture:SetTexture(btn.texture.scan1);
AI.texture:SetAllPoints(AI);		
AI:SetPoint("CENTER",GameTooltip,"BOTTOMLEFT",0,0);
AI:Hide()

---------------------------
-- onload
---------------------------
function gf.Armor.onload()
	Glance.Debug("function","onload","Armor")
	-- create character sheet font strings for item levels
	if spa.showIL then
		local function createSlot(slot)
			local fs = _G[slot]:CreateFontString("Glance"..slot.."Text","OVERLAY");
			fs:SetJustifyH("Left");
			fs:SetPoint("BOTTOM",_G[slot],"BOTTOM");
			fs:SetFont("Fonts\\FRIZQT__.TTF", 9, "THICKOUTLINE")
			fs:SetText("|cff00ccff0|r");
			fs:Show();		
		end
		-- can't add the labels if the Frame doesn't exist
		if spa.showInspectOverlay then InspectUnit("player") end
		if spa.showCharacterOverlay then ToggleCharacter("PaperDollFrame") end
		-- iterate slots
		for i = 1,#ga.slotItems do
			if (ga.slotItems[i] ~= "ShirtSlot" and ga.slotItems[i] ~= "TabardSlot") then
				-- create character sheet slot text
				if spa.showCharacterOverlay then
					local slot = "Character"..ga.slotItems[i];
					if (slot and _G[slot]) and not _G["Glance"..slot.."Text"] then
						createSlot(slot)
					end
				end
				-- create inspect sheet slot text
				if spa.showInspectOverlay then
					local slot = "Inspect"..ga.slotItems[i];
					if (slot and _G[slot]) and not _G["Glance"..slot.."Text"] then
						createSlot(slot)
					end
				end
			end
		end
		-- create inspect frame avg ilevel	
		if spa.showInspectOverlay then		
			local fs = InspectPaperDollFrame:CreateFontString("GlanceInspectFrameText","OVERLAY");
			fs:SetJustifyH("Center");
			fs:SetJustifyV("TOP")
			fs:SetPoint("TOP",InspectPaperDollFrame,"TOP",0,-60);
			fs:SetFont(ga.Font[3][2], Glance_Local.Options.fontSize+6)
			fs:SetText(HEX.gold.."Average Item Level: ");
			fs:Show();		
			-- hide the inspect frame
			ClearInspectPlayer()
		end
		-- create character frame avg ilevel	
		if spa.showCharacterOverlay then		
			local fs = PaperDollFrame:CreateFontString("GlanceCharacterFrameText","OVERLAY");
			fs:SetJustifyH("Center");
			fs:SetJustifyV("TOP")
			fs:SetPoint("TOP",PaperDollFrame,"TOP",0,-60);
			fs:SetFont(ga.Font[3][2], Glance_Local.Options.fontSize+6)
			fs:SetText(HEX.gold.."Average Item Level: ");
			fs:Show();		
			-- hide the character frame
			ToggleCharacter("PaperDollFrame")
		end
		-- hooks for iLvl on target
		GameTooltip:HookScript("OnTooltipSetUnit",function(self,...)
			if ( UnitExists("mouseover") ) then		
				if (UnitIsUnit("mouseover","target")) then	
					if gv.currentInspectUnit == UnitGUID("mouseover") then
						gf.Armor.iLvl.tooltipUpdate()
					end
				end
			elseif ( GameTooltip:IsUnit("target") ) then		
				if (UnitIsUnit("target","target")) then	
					if gv.currentInspectUnit == UnitGUID("target") then
						gf.Armor.iLvl.tooltipUpdate()
					end
				end
			end
		end);		
		gf.Armor.iLvl.resetScanData("player");
		gf.Armor.iLvl.preload("player")
		Glance.Timers["Inspect"] = {1,5,false,"Armor","scan",nil} --min,max,reset,button,func,var	
		loaded = true
	end
end
	
---------------------------
-- update (event)
---------------------------
function gf.Armor.update(self, event, arg1)
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		Glance.Debug("function","update","Armor")
		gf.setButtonText(btn.button,"Armor: ",gf.Armor.getDurability().."%","","")
		-- auto repair
		if event == "MERCHANT_SHOW" then
			gf.Armor.repair.repairAll()
		-- update character tab overlays
		elseif event == "PLAYER_EQUIPMENT_CHANGED" or  event == "PLAYER_ENTERING_WORLD" then
			if (loaded and spa.showIL) then 				
				gf.Armor.iLvl.resetScanData("player");
				gf.Armor.iLvl.preload("player")
				Glance.Timers["Inspect"] = {1,5,false,"Armor","scan",nil} --min,max,reset,button,func,var		
			end			
		-- target item level
		elseif event == "PLAYER_TARGET_CHANGED" then	
			if InspectFrame and InspectFrame:IsShown() and CanInspect("target") then InspectUnit("target"); end
			if ( UnitExists("target") and spa.showIL ) then
				--reset scan variables
				gf.Armor.iLvl.resetScanData("target");
				if (UnitIsUnit("target","target")) then	
					-- send the inspection request
					if UnitIsPlayer("target") then
						gv.currentInspectUnit = UnitGUID("target")
						NotifyInspect("target")
					end
				end
			end
		-- after notify inspect
		elseif event == "INSPECT_READY" then
			if gv.currentInspectUnit == arg1 and spa.showIL then
				-- preload
				gf.Armor.iLvl.preload("target")
				-- set the timer to get the stats
				Glance.Timers["Inspect"] = {1,5,false,"Armor","scan",nil} --min,max,reset,button,func,var				
			end
		end
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Armor.tooltip()
	Glance.Debug("function","tooltip","Armor")
	tooltip.Title("Armor", "GLD")
	
	-- repair line
	local TotalInvCost, TotalBagCost, TotalRepairCost = gf.Armor.repair.getRepairCost()
	if TotalRepairCost > 0 then
		tooltip.Line("The total cost to repair your armor is: "..GetCoinTextureString(TotalRepairCost,0), "WHT")
	else
		tooltip.Line("Your armor is fully repaired.", "WHT")
	end
	
	-- item levels
	local itemLevel = gf.Armor.iLvl.GetAverageItemLevel("player")
	if itemLevel > 0 then
		tooltip.Space()
		tooltip.Line("Item Level (iLvl)", "GLD")
		tooltip.Double("Average Item Level",gf.Armor.iLvl.color(itemLevel), "WHT", "WHT")
		tooltip.Double("MIA",gv.data.player.mia-gv.data.player.mitigated, "WHT", "RED")
	end
		
	-- party stats
	local GetNumPartyMembers, _ = GetNumSubgroupMembers()
	if ((GetNumPartyMembers ~= 0 and sender ~= UnitName("player")) or gv.Debug) and Glance_Local.Options.sendStats then
		gf.addonQuery("Armor")
		tooltip.Space()
		tooltip.Double("Party"..gf.crossRealm(), "iLVL/DUR", "GLD", "GLD")	
		gf.partyTooltip("Armor")
	end	
	
	-- options and notes
	local tbl = {
		[1] = {["Auto-Repair"] = spc.autoRepair},
		[2] = {["Check Item Level on Target"] = spa.showIL},
		[3] = {["Use Guild Funds"] = gf.Armor.repair.canRepair()},
		[4] = {["Guild funds available today"] = gf.Armor.getGuildFunds()},
	}
	tooltip.Options(tbl)
	tooltip.Notes("open the character tab",nil,"change Options",nil,"Guild funds can only be used if allowed by the guild")	
end

---------------------------
-- click
---------------------------
function gf.Armor.click(self, button, down)
	Glance.Debug("function","click","Armor")
	if button == "LeftButton" then
		ToggleCharacter("PaperDollFrame")
	end
end

---------------------------
-- menu
---------------------------
function gf.Armor.menu(level,UIDROPDOWNMENU_MENU_VALUE)
	Glance.Debug("function","menu","Armor")
	level = level or 1
	if (level == 1) then
		gf.setMenuTitle("Armor Options")
		gf.setMenuHeader("Auto Repair","autorepair",level)
		gf.setMenuHeader("Check Item Level","showil",level)
	end
	if (level == 2) then
		if gf.isMenuValue("autorepair") then
			gf.setMenuOption(spc.autoRepair==true,"On","On",level,function() spc.autoRepair=true; end)
			gf.setMenuOption(spc.autoRepair==false,"Off","Off",level,function() spc.autoRepair=false; end)
			gf.setMenuHeader("Use Guild Funds","guildrepair",level)
		end
		if gf.isMenuValue("showil") then
			gf.setMenuOption(spa.showIL==true,"On","On",level,function() spa.showIL=true; gf.Armor.iLvl.showOverlays("Character",spa.showCharacterOverlay); gf.Armor.iLvl.showOverlays("Inspect",spa.showInspectOverlay); end)
			gf.setMenuOption(spa.showIL==false,"Off","Off",level,function() spa.showIL=false; gf.Armor.iLvl.showOverlays("Character",false); gf.Armor.iLvl.showOverlays("Inspect",false); end)
			gf.setMenuHeader("Character Frame Overlays","showCO",level, not spa.showIL)
			gf.setMenuHeader("Inspect Frame Overlays","showIO",level, not spa.showIL)
			gf.setMenuHeader("Tooltip Overlays","showTT",level, not spa.showIL)
		end
	end	
	if (level == 3) then
		if gf.isMenuValue("guildrepair") then
			gf.setMenuOption(spc.guildRepair==true,"On","On",level,function() spc.guildRepair=true; end)
			gf.setMenuOption(spc.guildRepair==false,"Off","Off",level,function() spc.guildRepair=false; end)
		end
		if gf.isMenuValue("showCO") then
			gf.setMenuOption(spa.showCharacterOverlay==true,"On","On",level,function() spa.showCharacterOverlay=true; gf.Armor.iLvl.showOverlays("Character",true); end)
			gf.setMenuOption(spa.showCharacterOverlay==false,"Off","Off",level,function() spa.showCharacterOverlay=false; gf.Armor.iLvl.showOverlays("Character",false); end)
		end
		if gf.isMenuValue("showIO") then
			gf.setMenuOption(spa.showInspectOverlay==true,"On","On",level,function() spa.showInspectOverlay=true; gf.Armor.iLvl.showOverlays("Inspect",true); end)
			gf.setMenuOption(spa.showInspectOverlay==false,"Off","Off",level,function() spa.showInspectOverlay=false; gf.Armor.iLvl.showOverlays("Inspect",false); end)
		end
		if gf.isMenuValue("showTT") then
			gf.setMenuOption(spa.showTooltipOverlay==true,"On","On",level,function() spa.showTooltipOverlay=true; end)
			gf.setMenuOption(spa.showTooltipOverlay==false,"Off","Off",level,function() spa.showTooltipOverlay=false;  end)
		end
	end
end

---------------------------
-- messaging
---------------------------
function gf.Armor.Message()
	Glance.Debug("function","Message","Armor")
	local itemLevel = gf.Armor.iLvl.GetAverageItemLevel("player")
	return "|r("..gf.Armor.iLvl.color(itemLevel).."|r)/"..gf.Armor.getDurability().."%"
end



------------------------------------------------------------------------------------------------------------
-- DURABILITY METHODS
------------------------------------------------------------------------------------------------------------

	

---------------------------
-- durability (button text)
---------------------------
function gf.Armor.getDurability()
	Glance.Debug("function","getDurability","Armor")
	local have, most, pct = 0,0,0
	local sOut
	for i = 1, 19 do
		local current, max = GetInventoryItemDurability(i)
		if current ~= nil then
			have = have + current
			most = most + max
		end
	end
	if most > 0 then
		pct = math.floor((have/most) * 100)
		if pct >= 75 then
			sOut = HEX.green..pct
		elseif pct < 75 and pct > 50 then
			sOut = HEX.yellow..pct
		else
			sOut = HEX.red..pct
		end
	end
	return sOut or HEX.gray.."0"
end



------------------------------------------------------------------------------------------------------------
-- REPAIR METHODS
------------------------------------------------------------------------------------------------------------



---------------------------
-- repair costs (tooltip repair line)
---------------------------
function gf.Armor.repair.getRepairCost()
	Glance.Debug("function","repair.getRepairCost","Armor")
	local TotalInventoryCost = 0
	local TotalBagCost = 0
	-- equipped
	for i=1, #ga.slotItems do
		local slotId, textureName = GetInventorySlotInfo(ga.slotItems[i])
		local hasItem, hasCooldown, repairCost = Glance_Tooltip_Armor:SetInventoryItem("player", slotId);
		if hasItem then
			TotalInventoryCost = TotalInventoryCost + (repairCost or 0)
		end
	end
	-- bags
	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local _, repairCost = Glance_Tooltip_Armor:SetBagItem(bag, slot);
			TotalBagCost = TotalBagCost + (repairCost or 0)
		end
	end
	Glance_Tooltip_Armor:Hide()
	return TotalInventoryCost, TotalBagCost, TotalInventoryCost + TotalBagCost
end
 	
---------------------------
-- return guild repair available (tooltip options)
---------------------------
function gf.Armor.repair.canRepair()
	Glance.Debug("function","repair.canRepair","Armor")
	local val
	if spc.guildRepair then val = "On" else val = "Off" end
	if CanGuildBankRepair and CanGuildBankRepair() then else val=HEX.gray..val end
	return val
end

---------------------------
-- return guild funds available (tooltip options)
---------------------------
function gf.Armor.getGuildFunds()
	Glance.Debug("function","getGuildFunds","Armor")
	if CanGuildBankRepair and CanGuildBankRepair() then
		local GuildMoney = GetGuildBankWithdrawMoney()
		if GuildMoney == -1 then 
			return HEX.green.."Unlimited"
		elseif gf.matchSingle(tostring(GuildMoney),"+") then
			return HEX.red.."Err"
		else
			return GetCoinTextureString(math.ceil(GuildMoney),0)
		end
	end
	return nil
end

---------------------------
-- armor repair (merchant open)
---------------------------
function gf.Armor.repair.repairAll()
	Glance.Debug("function","repair.repairAll","Armor")			
	if CanMerchantRepair()==true and spc.autoRepair then
		local cost, needed = GetRepairAllCost();	
		if needed then
			if CanGuildBankRepair and CanGuildBankRepair() and spc.guildRepair then
				local funds = GetGuildBankWithdrawMoney()
				if cost > funds then
					local funds = GetMoney()
					if cost > funds then
						gf.sendMSG("You don't have enough money for repair!");
					else
						RepairAllItems();
						PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND)
						gf.sendMSG("There was not enough money in your daily guild bank allotment for repair.  Your items have been repaired from your own funds for "..GetCoinTextureString(cost,0))		
					end
				else
					RepairAllItems(1)
					PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND)
					gf.sendMSG("Your items have been repaired by the guild for "..GetCoinTextureString(cost,0))
					return
				end
			else
				local funds = GetMoney()
				if cost > funds then
					gf.sendMSG("You don't have enough money for repair!");
				else
					RepairAllItems();
					PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND)
					gf.sendMSG("Your items have been repaired for "..GetCoinTextureString(cost,0))	
				end
			end
		end
	end
end



------------------------------------------------------------------------------------------------------------
-- ITEM LEVEL METHODS
------------------------------------------------------------------------------------------------------------



---------------------------
-- reset scan data (update, on target change)
---------------------------
function gf.Armor.iLvl.resetScanData(unit)
	Glance.Debug("function","iLvl.resetScanData","Armor")
	if not unit then unit = "target" end
	gv.data[unit].name = nil
	gv.data[unit].spec = nil
	gv.data[unit].iLvl = 0;
	gv.data[unit].mia = 0;
	gv.data[unit].missing = 0;
	gv.data[unit].mitigated = 0;
	gv.data[unit].fury = false;
	gv.data[unit].slot = {}
	for i = 1,#ga.slotItems do
		gv.data[unit].slot[i] = 0
	end
end 

---------------------------
-- average item level
---------------------------
function gf.Armor.iLvl.GetAverageItemLevel(unit)
	local total, average, count, slots = 0,0,0,0
	for i = 1,#ga.slotItems do		
		if (ga.slotItems[i] ~= "ShirtSlot" and ga.slotItems[i] ~= "TabardSlot") then
			total = total + gv.data[unit].slot[i]
			slots = slots + 1
			--print(ga.slotItems[i]..": "..tostring(gv.data[unit].slot[i]))
		end
	end
	if (total > 0) then
		count = slots - gv.data[unit].mia
		average = total/count
		--[[print("Missing: "..tostring(gv.data[unit].missing))
		print("MIA: "..tostring(gv.data[unit].mia))
		print("Mitigated: "..tostring(gv.data[unit].mitigated))
		print("Slots: "..tostring(slots))
		print("Count: "..tostring(count))
		print("Total: "..tostring(total))
		print("Average: "..tostring(math.floor(average+0.5)))--]]
		return math.floor(average+0.5)
	else
		return 0
	end
end

---------------------------
-- colorize avg iLvl
---------------------------
function gf.Armor.iLvl.color(iLvl,unit,rgb)
	Glance.Debug("function","iLvl.color","Armor")
	if not unit then unit = "player" end
	local pl = tonumber(UnitLevel(unit))
	local epic = pl+8
	local legendary = pl+4
	local uncommon = pl
	local common = pl-4
	local poor = pl-8		
	local r, g, b, hex
	if iLvl <= poor then 
		r, g, b, hex = GetItemQualityColor(0); --poor
	end
	if iLvl > poor and iLvl <= common then 
		r, g, b, hex = GetItemQualityColor(1); -- common
	end
	if iLvl > common and iLvl <= uncommon then 
		r, g, b, hex = GetItemQualityColor(2); -- uncommon
	end
	if iLvl > uncommon and iLvl <= legendary then 
		r, g, b, hex = GetItemQualityColor(3); -- legendary
	end
	if iLvl > legendary and iLvl <= epic then 
		r, g, b, hex = GetItemQualityColor(4); -- epic
	end
	if iLvl > epic then 
		r, g, b, hex = GetItemQualityColor(5); -- rare
	end
	if not rgb then
		return "|c"..hex..iLvl
	else
		return r,g,b
	end
end

---------------------------
-- set slot text
---------------------------
function gf.Armor.iLvl.setSlotText(slot,il,unit)
	if (_G["Glance"..slot.."Text"]) then
		local r, g, b = gf.Armor.iLvl.color(il,unit,true)		
		_G["Glance"..slot.."Text"]:SetTextColor(r,g,b,1);
		_G["Glance"..slot.."Text"]:SetText(il)
	end
end

---------------------------
-- do the fontstrings exist?
---------------------------
function gf.Armor.iLvl.showOverlays(which,show)
	Glance.Debug("function","iLvl.showOverlays","Armor")
	DoesNotExist = true
	for i = 1,#ga.slotItems do
		if (ga.slotItems[i] ~= "ShirtSlot" and ga.slotItems[i] ~= "TabardSlot") then
			local slot = which..ga.slotItems[i];
			if (_G["Glance"..slot.."Text"]) then
				if show then
					_G["Glance"..slot.."Text"]:Show()
				else
					_G["Glance"..slot.."Text"]:Hide()
				end
				DoesNotExist = false
			end
		end
	end
	if show then
		if DoesNotExist then
			gf.Armor.onload()
		elseif which=="Character" then
			gf.Armor.iLvl.getEquipmentLevels()
		end
		if which == "Inspect" then
			_G["GlanceInspectFrameText"]:Show()
		end
	else
		if which == "Inspect" then
			_G["GlanceInspectFrameText"]:Hide()
		end
	end
end

---------------------------
-- insert/update target tooltip line
---------------------------
function gf.Armor.iLvl.tooltipAddLine(line,text)	
	-- updating existing line
	if (line > 0) then
		_G["GameTooltipTextLeft"..line]:SetText(text);
	-- adding a new line
	else
		GameTooltip:AddLine(text);
	end
	GameTooltip:Show();
end

---------------------------
-- update target tooltip
---------------------------
function gf.Armor.iLvl.tooltipUpdate()
	if gv.data.target.scanning or not spa.showTooltipOverlay then return end	
	Glance.Debug("function","iLvl.tooltipUpdate","Armor")
	local outputLine, matched, index = nil, false, 0;	

	-- adding or editing the spec line
	if gv.data.target.spec then

		-- add the spec
		outputLine = HEX.yellow.."Spec: "..gv.data.target.spec
		
		--finds the line index of Spec if it exists
		for i = 2, GameTooltip:NumLines() do
			if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..HEX.yellow.."Spec: ")) then
				index = i;
				break;
			end
		end
		gf.Armor.iLvl.tooltipAddLine(index,outputLine); index = 0;
	end
		
	-- adding or editing the iLvl lines
	if gv.data.target.iLvl > 0 then

		-- add the item level
		outputLine = HEX.lightblue.."iLvl: |r"..gf.Armor.iLvl.color(gv.data.target.iLvl,"target")

		--finds the line index of iLvl if it exists
		for i = 2, GameTooltip:NumLines() do
			if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..HEX.white.."iLvl: ")) then
				index = i;
				break;
			end
		end
		gf.Armor.iLvl.tooltipAddLine(index,outputLine); index = 0;
	end	
		
	-- adding or editing the mia lines
	if gv.data.target.iLvl > 0 then

		-- add missing items
		outputLine = HEX.red.."MIA: |r"..tostring(gv.data.target.mia-gv.data.target.mitigated)	

		--finds the line index of MIA if it exists
		for i = 2, GameTooltip:NumLines() do
			if ((_G["GameTooltipTextLeft"..i]:GetText() or ""):match("^"..HEX.white.."MIA: ")) then
				index = i;
				break;
			end
		end
		gf.Armor.iLvl.tooltipAddLine(index,outputLine); index = 0;
	end
end

---------------------------
-- request server data
---------------------------
function gf.Armor.iLvl.preload(unit)
	Glance.Debug("function","iLvl.preload","Armor")
	-- checking the items early will start the server requests for data
	-- timer is set after the call to preload that will run the scan
	gv.data[unit].missing = 0
	gv.currentPreloadUnit = unit
	gv.data.target.scanning = true;
	gv.data.target.scanCount = 1;
	if spa.showTooltipOverlay then
		AI.texture:SetTexture(btn.texture.scan1);
		AI:Show()
	end
	for i = 1,#ga.slotItems do
		local link = nil
		if (ga.slotItems[i] ~= "ShirtSlot" and ga.slotItems[i] ~= "TabardSlot") then
			-- player
			if (UnitIsUnit("target","player")) then
				link = GetInventoryItemLink(GetUnitName("target",true),GetInventorySlotInfo(ga.slotItems[i]));
			-- target
			else
				link = GetInventoryItemLink("target",GetInventorySlotInfo(ga.slotItems[i]));
			end
			if (link) then local iname,_,rarity,level,_,_,subtype,_,equiptype = GetItemInfo(link); end	
			-- the textures if the items are already available
			-- so we can get the true number of missing items
			if not GetInventoryItemTexture("target",i) then
				gv.data[unit].missing = gv.data[unit].missing + 1
			end
		end
	end
end

---------------------------
-- get target stats
---------------------------

function gf.Armor.iLvl.scan(unit)
	if not spa.showIL then return end
	Glance.Debug("function","iLvl.scan","Armor")

	if not unit then unit = gv.currentPreloadUnit end

	-- locals
	local specID, lvl, count = nil,0,0;
	local dualHand, miaMainHand, miaOffHand, hasWand, hasThrown, miaAmmo, miaRanged = false, false, false, false, false, false, false;
	local lClass, eClass = UnitClass(unit);
	local name = GetUnitName(unit, false)

	-- no rescan targetting self
	if (unit == "target" and name == gv.data.player.name) then gf.Armor.iLvl.endscan(unit); return end

	-- end if repeat (player rescan ok, only called from equip change event)
	if (unit == "target" and name == gv.data.target.name) then gf.Armor.iLvl.endscan(unit); return end
	
	-- end if mismatch
	if not gv.currentInspectUnit == UnitGUID(unit) then gf.Armor.iLvl.endscan(unit); return end

	-- name
	gv.data[unit].name = name
		
	-- player spec
	local specID = 0
	if (unit == "player" and UnitLevel(unit) > 9 and GetSpecialization) then
		if (UnitLevel(unit) > 9 and GetSpecialization) then
			local currentSpec = GetSpecialization();
			specID = currentSpec and select(1, GetSpecializationInfo(currentSpec))
			gv.data[unit].spec = select(2,GetSpecializationInfoByID(specID));
		end
	-- target spec
	else
		if (UnitLevel(unit) > 9 and GetInspectSpecialization) then
			specID = GetInspectSpecialization(unit);
			gv.data[unit].spec = select(2,GetSpecializationInfoByID(specID));
		end
	end
	
	-- fury spec
	if (specID == "268") then
		gv.data[unit].fury = true
	end	
	
	-- iterate equipment
	for i = 1,#ga.slotItems do
		local link = nil

		-- not the shirt
		if (ga.slotItems[i] ~= "ShirtSlot" and ga.slotItems[i] ~= "TabardSlot") then

			-- player
			if (unit == "player") then
				link = GetInventoryItemLink(GetUnitName(unit,true),GetInventorySlotInfo(ga.slotItems[i]));
			-- target
			else
				link = GetInventoryItemLink(unit,GetInventorySlotInfo(ga.slotItems[i]));
			end

			-- if we get a link
			if (link) then

				--get the item info
				local iname,_,rarity,iLevel,_,_,subtype,_,equiptype = GetItemInfo(link);
								
				--do two-handed check based on mainhand weapon
				if (ga.slotItems[i]=="MainHandSlot") then
					if (equiptype == "INVTYPE_2HWEAPON" or equiptype == "INVTYPE_RANGED" or equiptype == "INVTYPE_RANGEDRIGHT") then
						dualHand = true;
					else
						dualHand = false;
					end
				end

				-- check for wands
				if (ga.slotItems[i]=="RangedSlot") then
					if (subtype == "Wands") then
						hasWand = true
					end
					if (subtype == "Thrown") then
						hasThrown = true
					end
				end
				
				-- set item level, count 
				if (iLevel) then
					count = count + 1
					gv.data[unit].slot[i] = iLevel
				end

			else			

				-- ding for missing item
				gv.data[unit].mia = gv.data[unit].mia + 1;

				-- check these, calculations to follow
				if (ga.slotItems[i]=="MainHandSlot") then
					miaMainHand = true;
				elseif (ga.slotItems[i]=="SecondaryHandSlot") then
					miaOffHand = true;
				elseif (ga.slotItems[i]=="RangedSlot") then
					miaRanged = true
				elseif (ga.slotItems[i]=="AmmoSlot") then
					miaAmmo = true
				end
			end
		end
	end

	-- missing offhand, but has dualhand weapon
	if (miaOffHand and dualHand) then
		gv.data[unit].mitigated = gv.data[unit].mitigated + 1;
	end
	-- missing ranged
	if (miaRanged) then
		-- these classes don't use ranged
		if (eClass == "DRUID" or eClass == "PALADIN" or eClass == "SHAMAN") then
			gv.data[unit].mitigated = gv.data[unit].mitigated + 1;			
		end
	end
	-- missing ammo
	if (miaAmmo) then
		-- these classes don't use ammo
		if (eClass == "DRUID" or eClass == "PALADIN" or eClass == "SHAMAN") then
			gv.data[unit].mitigated = gv.data[unit].mitigated + 1;			
		end
		-- wand and thrown don't use ammo
		if (hasWand or hasThrown) then
			gv.data[unit].mitigated = gv.data[unit].mitigated + 1;			
		end
	end
	-- inspect does not show ammo
	if (unit=="target") then
		--gv.data[unit].mitigated = gv.data[unit].mitigated + 1;		
	end

	
	--set the item level average
	if (count > 0) then		
		gv.data[unit].iLvl = gf.Armor.iLvl.GetAverageItemLevel(unit);
	else
		gv.data[unit].iLvl = 0;
	end
	
	-- if mia is greater than the true number of missing items then rescan (max 5 times)
	if (gv.data[unit].mia > gv.data[unit].missing) and gv.data[unit].scanCount < 5 then
		gv.data[unit].scanCount = gv.data[unit].scanCount + 1
		if spa.showTooltipOverlay then AI.texture:SetTexture(btn.texture.scan2); end
		gf.Armor.update(self, "INSPECT_READY", UnitGUID(unit))
	else
		gf.Armor.iLvl.endscan(unit)
		for i = 1,#ga.slotItems do
			local slot = nil
			if unit == "target" and spa.showInspectOverlay then 
				slot = "Inspect"..ga.slotItems[i] 
				gf.Armor.iLvl.setSlotText(slot,gv.data[unit].slot[i],unit)
			end
			if unit == "player" and spa.showCharacterOverlay then 
				slot = "Character"..ga.slotItems[i] 
				gf.Armor.iLvl.setSlotText(slot,gv.data[unit].slot[i],unit)
			end
		end
		if unit == "player" and spa.showCharacterOverlay then 
			_G["GlanceCharacterFrameText"]:SetText(HEX.gold.."Average Item Level: "..gf.Armor.iLvl.color(gv.data[unit].iLvl,unit))
		end
		if unit == "target" and spa.showInspectOverlay then 
			_G["GlanceInspectFrameText"]:SetText(HEX.gold.."Average Item Level: "..gf.Armor.iLvl.color(gv.data[unit].iLvl,unit))
		end
	end
	--ClearInspectPlayer()
end

---------------------------
-- end scanning
---------------------------
function gf.Armor.iLvl.endscan(unit)
	gv.data[unit].scanning = false;
	gv.currentPreloadUnit = nil
	if spa.showTooltipOverlay then
		AI:Hide()		
		gf.Armor.iLvl.tooltipUpdate()
	end
end


---------------------------
-- copy method for timer to work
---------------------------
function gf.Armor.scan() gf.Armor.iLvl.scan(); end


---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Armor")
end