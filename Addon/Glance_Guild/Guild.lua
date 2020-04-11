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
		local onlineTotal = 0
		local guild = {}
		for i = 1, total do
			local name,_, _,level,class,zone,_,_,online,_,_ = GetGuildRosterInfo(i)
			if online then
				onlineTotal = onlineTotal + 1
				table.insert(guild, {name, level, class, zone})
			end
		end
		tooltip.Title(onlineTotal.."/"..total.." Guild Member(s) Online", "GLD")
		table.sort(guild, function(a, b) return a[1] < b[1] end)
		for k, v in pairs(guild) do
			local name, realm = strsplit("-", v[1])
			tooltip.Double(CLS[string.upper(v[3])]..name.." |r("..HEX.green..v[2].." "..CLS[string.upper(v[3])]..v[3].."|r)", v[4], "WHT", "LBL")
		end
		wipe(guild)
	else
		tooltip.Title("Guild Member(s)", "GLD")
		tooltip.Line("|rYou are not in a guild.", "WHT")
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
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Guild")
end