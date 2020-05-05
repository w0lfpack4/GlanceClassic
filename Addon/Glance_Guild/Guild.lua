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
gf.AddButton("Guild","LEFT")
local btn = gb.Guild
btn.text              = "Guild"
btn.enabled           = true
btn.events            = {"GUILD_ROSTER_UPDATE","PLAYER_GUILD_UPDATE"}
btn.update            = true
btn.tooltip           = true
btn.click             = true
btn.timer5            = true

---------------------------
-- shortcuts
---------------------------
local HEX = ga.colors.HEX
local CLS = ga.colors.CLASS
local tooltip = gf.Tooltip

---------------------------
-- update
---------------------------
function gf.Guild.update()
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		Glance.Debug("function","update","Guild")
		local onlineTotal = 0
		if IsInGuild() then
			GuildRoster()
			for i = 1, GetNumGuildMembers(true) do
				 local online = select(9, GetGuildRosterInfo(i))
				 if online then
					onlineTotal = onlineTotal + 1
				 end
			end
		end
		local color = gf.getCondition(onlineTotal == 0,HEX.red,HEX.green)
		gf.setButtonText(btn.button,"Guild: ",onlineTotal,nil,color)
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Guild.tooltip()
	Glance.Debug("function","tooltip","Guild")
	if IsInGuild() then
		GuildRoster()
		local total = GetNumGuildMembers(true)
		local motd = GetGuildRosterMOTD()
		local guildName, guildRankName, guildRankIndex = GetGuildInfo("player");
		local onlineTotal = 0
		local guild = {}
		for i = 1, total do
			local name,_, _,level,class,zone,_,_,online,status,_ = GetGuildRosterInfo(i)
			if online then
				onlineTotal = onlineTotal + 1
				table.insert(guild, {name, level, class, zone, status})
			end
		end
		tooltip.Double("Guild: "..guildName,onlineTotal.."/"..total, "GLD", "GLD")
		tooltip.Space()
		tooltip.Wrap(motd,"LBL")
		tooltip.Space()
		table.sort(guild, function(a, b) return a[1] < b[1] end)
		local count = 1
		for k, v in pairs(guild) do
			local name, realm = strsplit("-", v[1])
			local level, class, zone, intStatus, status = v[2], string.upper(v[3]), v[4], v[5], ""
			if intStatus == 1 then status = " |r"..HEX.red.."[Away]|r" end
			if intStatus == 2 then status = " |r"..HEX.red.."[Busy]|r" end
			if zone == GetZoneText() then zone = HEX.green..zone else zone = HEX.gray..zone end
			tooltip.Double(gf.Guild.colorLevels(level).." |r"..CLS[string.upper(v[3])]..name..status, zone, "WHT", "LBL")
			count = count + 1
			if count > 20 then 
				local howManyMore = (#guild-20)
				if howManyMore > 0 then
					tooltip.Line("|rand "..howManyMore.." more..", "WHT")
				end
				break
			end
		end
		wipe(guild)
	else
		tooltip.Title("You are not in a guild.", "GLD")
	end
	tooltip.Notes("open the Guild tab",nil,nil,nil,nil)
end

---------------------------
-- click
---------------------------
function gf.Guild.click(self, button, down)
	Glance.Debug("function","click","Guild")
	if button == "LeftButton" then
		ToggleFriendsFrame(3)
	end
end

---------------------------
-- colorize levels
---------------------------
function gf.Guild.colorLevels(level)
	local quality = string.sub(tostring(level),1,1)
	return ga.colors.QUALITY[tonumber(quality)]..level
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Guild")
end