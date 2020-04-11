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
gf.AddButton("Gold","LEFT")
local btn = gb.Gold
btn.text              = "Gold"
btn.events            = {"PLAYER_MONEY"}
btn.enabled           = true
btn.update            = true
btn.onload            = true
btn.tooltip           = true
btn.menu              = true
btn.save.perCharacter = {["DisplayGold"]="character"}
btn.save.perAccount   = {[GetRealmName()] = { ["HordeGold"] = {},["AllianceGold"] = {} }}
btn.save.allowProfile = true

---------------------------
-- shortcuts
---------------------------
local spc = btn.save.perCharacter
local spa = btn.save.perAccount
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip

---------------------------
-- update
---------------------------
function gf.Gold.update()
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		Glance.Debug("function","update","Gold")
		local coin = ""
		if spc.DisplayGold == "account" then
			local horde,alliance,total = spa[GetRealmName()]["HordeGold"],spa[GetRealmName()]["AllianceGold"],0
			for i=1,#horde do
				local name,count = unpack(horde[i])
				total = total + count
			end
			for i=1,#alliance do
				local name,count = unpack(alliance[i])
				total = total + count
			end
			coin = GetCoinTextureString(total,0)
		elseif spc.DisplayGold == "gold/hour" then
			local gti = gv.gametime
			gti.session = time() - gti.initSession
			local gsession, gpersec, gperhour = 0,0,0
			if gv.gold ~=0 and gv.gold ~= nil then
				gsession = GetMoney() - gv.gold
				gpersec = gsession/gv.gametime.session
				gperhour = math.ceil(gpersec*3600)
				if gperhour < 0 then
					coin = "-"..GetCoinTextureString(-gperhour,0).."/h"
				else
					coin = GetCoinTextureString(-gperhour,0).."/h"
				end
			else
				coin = GetCoinTextureString(0,0).."/h"
			end
		else
			coin = GetCoinTextureString(GetMoney(),0)
		end
		gf.setButtonText(btn.button,coin,"",nil,nil)
		gf.Gold.save() 
	end
end

---------------------------
-- onload
---------------------------
function gf.Gold.onload()
	gv.gold = GetMoney()
end

---------------------------
-- save
---------------------------
function gf.Gold.save()
	Glance.Debug("function","save","Gold")
	local faction = spa[GetRealmName()][select(1,UnitFactionGroup("player")).."Gold"]
	local foundPlayer = false
	if faction == nil then faction = {} end
	if faction[1] == nil then
		faction[1] = { UnitName("player"), GetMoney() }
	else
		for i=1,#faction do
			if faction[i][1] == UnitName("player") then
				faction[i] = { UnitName("player"), GetMoney() }
				foundPlayer = true
			end
		end
		if not foundPlayer then
			faction[#faction+1] = { UnitName("player"), GetMoney() }
		end
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Gold.tooltip()
	Glance.Debug("function","tooltip","Gold")
	local gti = gv.gametime
	gti.session = time() - gti.initSession
	local horde,alliance = spa[GetRealmName()]["HordeGold"],spa[GetRealmName()]["AllianceGold"]
	local htotal, atotal, total = 0, 0, 0
	local h,a,b = false, false, false
	tooltip.Title("Gold in Account ("..GetRealmName()..")","GLD")
	if #horde ~= 0 then h = true end
	if #alliance ~= 0 then a = true end
	if h and a then b = true end
	if b or h then
		if b then 
			tooltip.Space()
			tooltip.Line("Horde Gold","GLD") 
		end
		for i=1,#horde do
			local name,count = unpack(horde[i])
			tooltip.Double(name,GetCoinTextureString(count,0),"WHT","WHT")
			htotal = htotal + count
			total = total + count
		end
		if b then tooltip.Double("Horde Total",GetCoinTextureString(htotal,0),"GRN","WHT") end
	end
	if b or a then
		if b then 
			tooltip.Space()
			tooltip.Line("Alliance Gold","GLD")
		end
		for i=1,#alliance do
			local name,count = unpack(alliance[i])
			tooltip.Double(name,GetCoinTextureString(count,0),"WHT","WHT")
			atotal = atotal + count
			total = total + count
		end
		if b then tooltip.Double("Alliance Total",GetCoinTextureString(atotal,0),"GRN","WHT") end
	end
	tooltip.Space()
	tooltip.Double("Total Gold",GetCoinTextureString(total,0),"GRN","WHT")
	local gsession, gpersec, gperhour = 0,0,0
	if gv.gold ~=0 then
		tooltip.Space()
		tooltip.Line("Session","GLD")
		gsession = GetMoney() - gv.gold
		gpersec = gsession/gv.gametime.session
		gperhour = math.ceil(gpersec*3600)
		if gsession < 0 then
			tooltip.Double("Gold This Session","-"..GetCoinTextureString(-gsession,0),"WHT","WHT")
		else
			tooltip.Double("Gold This Session",GetCoinTextureString(gsession,0),"WHT","WHT")
		end
		if gperhour < 0 then
			tooltip.Double("Gold/Hour","-"..GetCoinTextureString(-gperhour,0),"WHT","WHT")
		else
			tooltip.Double("Gold/Hour",GetCoinTextureString(gperhour,0),"WHT","WHT")
		end
		local tbl = {
			[1] = {["Display"]=spc.DisplayGold},
		}
		tooltip.Options(tbl)
		--(left,shift-left,right,shift-right,other)
		tooltip.Notes(nil,nil,"switch display",nil,nil)
	end
end

---------------------------
-- menu
---------------------------
function gf.Gold.menu(level,UIDROPDOWNMENU_MENU_VALUE)
	Glance.Debug("function","menu","Gold")
	level = level or 1
	if (level == 1) then
		gf.setMenuTitle("Gold Options")
		gf.setMenuHeader("Display","display",level)
		gf.setMenuHeader("Delete Faction","faction",level)
		gf.setMenuHeader("Delete Character","character",level)
	end
	if (level == 2) then
		if gf.isMenuValue("display") then
			gf.setMenuOption(spc.DisplayGold == "character","This Character","This Character",level,function() spc.DisplayGold = "character"; gf.Gold.update() end)
			gf.setMenuOption(spc.DisplayGold == "account","This Account","This Account",level,function() spc.DisplayGold = "account"; gf.Gold.update() end)
			gf.setMenuOption(spc.DisplayGold == "gold/hour","Gold per Hour","Gold per Hour",level,function() spc.DisplayGold = "gold/hour"; gf.Gold.update() end)
		end
		if gf.isMenuValue("faction") then
			gf.setMenuOption(false,"Horde","Horde",level,function() spa[GetRealmName()].HordeGold={}; gf.Gold.update() end)
			gf.setMenuOption(false,"Alliance","Alliance",level,function() spa[GetRealmName()].AllianceGold={}; gf.Gold.update() end)
		end
		if gf.isMenuValue("character") then		
			local horde,alliance = spa[GetRealmName()]["HordeGold"],spa[GetRealmName()]["AllianceGold"]
			for i=1,#horde do
				local name,count = unpack(horde[i])
				gf.setMenuOption(false,name,name,level,function() table.remove(spa[GetRealmName()]["HordeGold"], i) end)
			end
			for i=1,#alliance do
				local name,count = unpack(alliance[i])
				gf.setMenuOption(false,name,name,level,function() table.remove(spa[GetRealmName()]["AllianceGold"], i) end)
			end
		end
	end
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Gold")
end