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
gf.AddButton("XP","LEFT")
local btn = gb.XP
btn.text              = "XP"
btn.enabled           = true
btn.events            = {"PLAYER_LEVEL_UP","CHAT_MSG_COMBAT_XP_GAIN","QUEST_COMPLETE","PLAYER_XP_UPDATE"}
btn.update            = true
btn.tooltip           = true
btn.save.perCharacter = {["xp"] = {["kills2level"] = 0,["quests2level"] = 0,["gathers2level"] = 0,["discoveries2level"] = 0,}}

---------------------------
-- shortcuts
---------------------------
local spc = btn.save.perCharacter
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip

---------------------------
-- variables
---------------------------
gv.party.a["XP"] = 0
gv.party.b["XP"] = 0
gv.party.c["XP"] = 0
gv.party.d["XP"] = 0
gv["xp"] = {
	["level"] = 0,
	["cap"] = 0,
	["accumulated"] = 0,
	["previous"] = UnitXP("player"),
	["current"] = 0,
	["currentPCT"] = 0,
	["init"] = UnitXP("player"),
	["needed"] = 0,
	["neededPCT"] = 0,
	["rested"] = 0,
	["restedPCT "] = 0,
	["session"] = 0,
	["sessionPCT"] = 0,
	["xpersec"] = 0,
	["xperhour"] = 0,
	["leveltime"] = 0,
	["petlevel"] = 0,
	["petcap"] = 0,
	["petcurrent"] = 0,
	["petcurrentPCT"] = 0,
	["petneeded"] = 0,
	["petneededPCT"] = 0,
	["kills2level"] = 0,
	["quests2level"] = 0,
	["gathers2level"] = 0,
	["discoveries2level"] = 0,
	["questCompleteOpen"] = false,
	["slayedCreature"] = false,
	["slayedNode"] = false,
	["kills"] = {
		["avg"] = 0,
		["current"] = 0,
		["min"] = 0,
		["max"] = 0,
		["count"] = 0,
	},
	["quests"] = {
		["avg"] = 0,
		["current"] = 0,
		["min"] = 0,
		["max"] = 0,
		["count"] = 0,
	},
	["gathers"] = {
		["avg"] = 0,
		["current"] = 0,
		["min"] = 0,
		["max"] = 0,
		["count"] = 0,
	},
	["discoveries"] = {
		["avg"] = 0,
		["current"] = 0,
		["min"] = 0,
		["max"] = 0,
		["count"] = 0,
	},
}

---------------------------
-- update
---------------------------
function gf.XP.update(self, event, arg1)
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		Glance.Debug("function","update","XP")
		if UnitLevel("player") < gv.maxLevel then
			gf.XP.set()
			if gv.xp.rested > 0 then
				btn.button:SetText("XP: "..HEX.lightblue..gv.xp.currentPCT.."% of "..UnitLevel("player"))
			else
				btn.button:SetText("XP: "..HEX.lightpurple..gv.xp.currentPCT.."% of "..UnitLevel("player"))
			end
		else
			btn.button:SetText("XP: "..HEX.green.."max")
		end
		btn.button:SetWidth(btn.button:GetTextWidth())
	end
	if (event == "CHAT_MSG_COMBAT_XP_GAIN") then
		gf.XP.onChatXPGain(arg1)		
	elseif (event == "QUEST_COMPLETE") then
		gv.xp.questCompleteOpen = true
	elseif (event == "PLAYER_LEVEL_UP") then
		gv.xp.accumulated = gv.xp.accumulated + UnitXPMax("player") - gv.xp.init
		gv.xp.init = 0
		gv.gametime.initLevel = time()
	elseif (event == "PLAYER_XP_UPDATE") then
		gf.XP.onPlayerXPUpdate()
	end
end

---------------------------
-- tooltip
---------------------------
function gf.XP.tooltip()
	gf.XP.set()
	Glance.Debug("function","tooltip","XP")
	local gti = gv.gametime
	local var = gv.xp	
	
	-- still leveling
	if var.level < gv.maxLevel then
		tooltip.Title("Experience", "GLD")
		if IsShiftKeyDown() then 
			tooltip.Double("Total XP Required This Level ("..var.level.." to "..(var.level+1)..")", var.cap,"WHT", "GRN")
			tooltip.Double("XP Gained This Level ", "("..var.currentPCT.."%) "..var.current, "WHT", "GRN")
		end

		local needed ="("..var.neededPCT.."%) "..var.needed
		if not IsShiftKeyDown() then needed = var.neededPCT.."%" end
		tooltip.Double("XP Needed To Level ", needed,"WHT", "GRN")
		
		local rested ="("..var.restedPCT.."%) "..var.rested
		if not IsShiftKeyDown() then rested = var.restedPCT.."%" end
		if var.rested > 0 then
			tooltip.Double("Rested XP ", rested, "BLU", "GRN")
		else
			tooltip.Double("Rested XP ", rested, "PPL", "RED")
		end
	end

	if IsShiftKeyDown() then
	
		-- maxed
		if var.level == gv.maxLevel then
			tooltip.Title("Game Time", "GLD")
		else
			tooltip.Space()
			tooltip.Line("Game Time", "GLD")
		end
		
		-- all levels
		tooltip.Double("Total Time Played", gf.formatTime(gti.total), "WHT", "GRN")
		tooltip.Double("Time Played This Level ", gf.formatTime(gti.level), "WHT", "GRN")
		tooltip.Double("Time Played This Session ", gf.formatTime(gti.session), "WHT", "GRN")
	end
	
	-- still leveling
	if var.level < gv.maxLevel then
		--if var.xperhour ~= 0 then
			tooltip.Space()
			tooltip.Line("Leveling Speed", "GLD")
			if IsShiftKeyDown() then
				tooltip.Double("XP/Hour ", var.xperhour, "WHT", "GRN")
			else
				tooltip.Double("XP/Hour ", var.xperhourPCT.."%", "WHT", "GRN")
			end
			tooltip.Double("Time To Level",  gf.formatTime(var.leveltime), "WHT", "GRN")
		--end
		tooltip.Space()
		tooltip.Line("Leveling Stats", "GLD")
		tooltip.Double("Kills To Level (avg "..var.kills.avg.." xp)", var.kills2level, "WHT", "GRN")
		tooltip.Double("Quests To Level (avg "..var.quests.avg.." xp)", var.quests2level, "WHT", "GRN")
		if (GetExpansionLevel() > 0)  then tooltip.Double("Gathers To Level (avg "..var.gathers.avg.." xp)", var.gathers2level, "WHT", "GRN") end
		tooltip.Double("Discoveries To Level (avg "..var.discoveries.avg.." xp)", var.discoveries2level, "WHT", "GRN")
	end	

	-- debugging
	if gv.Debug then
		tooltip.Space()
		tooltip.Line("currentxp - initxp + accumulatedxp = sessionxp", "GLD")
		tooltip.Line(var.current.." - "..var.init.." + "..var.accumulated.." = "..var.session, "WHT")
		tooltip.Space()
		tooltip.Line("sessionxp/sessiontime = xpersec", "GLD")
		tooltip.Line(var.session.."/"..gti.session.." = "..var.xpersec, "WHT")
		tooltip.Space()
		tooltip.Line("xpersec*3600 = xperhour", "GLD")
		tooltip.Line(var.xpersec.."*3600 = "..var.xperhour, "WHT")
		tooltip.Space()
		tooltip.Line("neededxp/xpersec = leveltime", "GLD")
		tooltip.Line(var.needed.."/"..var.xpersec.." = "..var.leveltime, "WHT")
	end
	
	-- pet
	if var.petcap ~= 0 then
		tooltip.Space()
		tooltip.Double("Hunter Pet (Level)", "XP", "GLD", "GLD")
		tooltip.Double(UnitName("pet").." ("..HEX.green..var.petlevel..HEX.white..") ", var.petcurrent.."/"..var.petcap.." ("..var.petcurrentPCT.."%)","WHT", "GRN")
	end
		
	-- party
	local GetNumPartyMembers, _ = GetNumSubgroupMembers()
	if ((GetNumPartyMembers ~= 0 and sender ~= UnitName("player")) or gv.Debug) and Glance_Local.Options.sendStats then
		gf.addonQuery("XP")
		local pty = gv.party
		tooltip.Space()
		tooltip.Double("Party"..gf.crossRealm(), "LVL / % / XPH", "GLD", "GLD")
		gf.partyTooltip("XP")
	end
	tooltip.hasOptions = true
end

---------------------------
-- messaging
---------------------------
function gf.XP.Message()
	return UnitLevel("player").." / "..gv.xp.currentPCT.."% / "..gv.xp.xperhour
end

---------------------------
-- set xp vars
---------------------------
function gf.XP.set()
	local gti = gv.gametime
	gti.session = time() - gti.initSession
	gti.total   = time() - gti.initTotal
	gti.level   = time() - gti.initLevel
	
	local var = gv.xp
	var.level         = UnitLevel("player")
	var.cap           = UnitXPMax("player")
	var.current       = UnitXP("player")
	var.currentPCT    = gf.getPCT(var.current,var.cap)
	var.needed        = var.cap - var.current
	var.neededPCT     = 100-var.currentPCT
	var.rested        = GetXPExhaustion() or 0
	var.restedPCT     = gf.getPCT(var.rested,var.cap)
	var.session       = var.current - var.init + var.accumulated
	var.sessionPCT    = gf.getPCT(var.session,var.cap)
	var.xpersec       = (var.session/gti.session) or 0
	var.xperhour      = math.ceil(var.xpersec*3600) or 0
	var.xperhourPCT      = gf.getPCT(var.xperhour,var.cap)
	if var.xpersec == 0 then
		var.leveltime = 0
	else
		var.leveltime = math.ceil(var.needed/var.xpersec)
	end
	if var.kills.avg ~= 0 then
		var.kills2level = math.ceil(var.needed/var.kills.avg) 
		spc.xp.kills2level = var.kills2level
	else 
		var.kills2level = spc.xp.kills2level or 0
	end
	if var.quests.avg ~= 0 then
		var.quests2level  = math.ceil(var.needed/var.quests.avg)
		spc.xp.quests2level = var.quests2level
	else
		var.quests2level = spc.xp.quests2level or 0
	end
	if var.gathers.avg ~= 0 then
		var.gathers2level = math.ceil(var.needed/var.gathers.avg)
		spc.xp.gathers2level = var.gathers2level
	else
		var.gathers2level = spc.xp.gathers2level or 0
	end
	if var.discoveries.avg ~= 0 then
		var.discoveries2level = math.ceil(var.needed/var.discoveries.avg)
		spc.xp.discoveries2level = var.discoveries2level
	else
		var.discoveries2level = spc.xp.discoveries2level or 0
	end
	var.petlevel      = UnitLevel("pet")
	var.petcap        = select(2,GetPetExperience()) or 0
	var.petcurrent    = select(1,GetPetExperience()) or 0
	var.petcurrentPCT = gf.getPCT(var.petcurrent,var.petcap)
	var.petneeded     = var.petcap-var.petcurrent or 0
	var.petneededPCT  = gf.getPCT(var.petneeded,var.petcap)
	spc.xp.kills2level   = var.kills2level
	spc.xp.quests2level  = var.quests2level
	spc.xp.gathers2level = var.gathers2level
	spc.xp.discoveries2level = var.discoveries2level
end

---------------------------
-- on chat xp event
---------------------------
function gf.XP.onChatXPGain(message)
    local xp, mobName = gf.XP.parseChatMessage(message)
    xp = tonumber(xp)
	if not xp then return false	end	
    if mobName ~= nil then
		gf.stats(gv.xp.kills,xp)
		gv.xp.slayedCreature = true
    else
		if gv.xp.questCompleteOpen then
			gf.stats(gv.xp.quests,xp)
		else			
			gf.stats(gv.xp.gathers,xp)
			gv.xp.slayedNode = true
		end
	end
end

---------------------------
-- on player xp update event
---------------------------
function gf.XP.onPlayerXPUpdate()
	-- turn off quest tracking (chatxp)
	if gv.xp.questCompleteOpen then
		gv.xp.questCompleteOpen = false
	-- turn off kill tracking (chatxp)
	elseif gv.xp.slayedCreature then		
		gv.xp.slayedCreature = false
	-- turn off gather tracking (chatxp) (retail only)
	elseif gv.xp.slayedNode then		
		gv.xp.slayedNode = false
	else
		--print("previous xp: "..tostring(gv.xp.previous))
		local xp = UnitXP("player") - gv.xp.previous
		--print("xp gained: "..tostring(xp))
		gf.stats(gv.xp.discoveries,xp)
		gv.xp.previous = UnitXP("player")
	end
end

---------------------------
-- regex chat log
---------------------------
function gf.XP.parseChatLog(isQuest)
	local inInstance, itype = IsInInstance()
	local GetNumPartyMembers, _ = GetNumSubgroupMembers()
	local inGroup =  GetNumPartyMembers > 0
	local regex = nil
	local isRested = GetXPExhaustion()
	if not isQuest then
		if inInstance and isRested then
			if itype == "party" and inGroup then
				regex = COMBATLOG_XPGAIN_EXHAUSTION1_GROUP
			elseif itype == "raid" and inGroup then
				regex = COMBATLOG_XPGAIN_EXHAUSTION1_RAID
			else
				regex = COMBATLOG_XPGAIN_EXHAUSTION1
			end
		elseif inInstance and not isRested then
			if itype == "party" and inGroup then
				regex = COMBATLOG_XPGAIN_FIRSTPERSON_GROUP
			elseif itype == "raid" and inGroup then
				regex = COMBATLOG_XPGAIN_FIRSTPERSON_RAID
			else
				regex = COMBATLOG_XPGAIN_FIRSTPERSON
			end
		else
			if isRested then
				regex = COMBATLOG_XPGAIN_EXHAUSTION1
			else
				regex = COMBATLOG_XPGAIN_FIRSTPERSON
			end
		end
	else
		regex = COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED
	end
	regex = string.gsub(regex, "%(", "%%(")
	regex = string.gsub(regex, "%)", "%%)")
	regex = string.gsub(regex, "%+", "%%+")
	regex = string.gsub(regex, "%-", "%%-")
	regex = string.gsub(regex, "%%%d?%$?s", "(.+)")
	regex = string.gsub(regex, "%%%d?%$?d", "(%%d+)")
	return regex
end

---------------------------
-- parse chat log
---------------------------
function gf.XP.parseChatMessage(message)
	local isQuest = string.find(message, ",") == nil
	local pattern = gf.XP.parseChatLog(isQuest)
	local mob, xp = strmatch(message, pattern);
	if tonumber(mob) then
		xp = tonumber(mob)
		mob = nil
	end	
	return xp, mob;
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("XP")
end