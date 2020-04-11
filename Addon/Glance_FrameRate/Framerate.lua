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
gf.AddButton("Framerate","LEFT")
local btn = gb.Framerate
btn.text              = "Framerate"
btn.events            = {}
btn.enabled           = true
btn.update            = true
btn.tooltip           = true
btn.timer1            = true
btn.timerTooltip      = true

---------------------------
-- shortcuts
---------------------------
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip

---------------------------
-- mod variables
---------------------------
gv.party.a["Framerate"] = 0
gv.party.b["Framerate"] = 0
gv.party.c["Framerate"] = 0
gv.party.d["Framerate"] = 0
gv["fps"] = {
	["avg"] = 0,
	["current"] = 0,
	["min"] = 0,
	["max"] = 0,
	["count"] = 0,
}

---------------------------
-- update
---------------------------
function gf.Framerate.update()
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		gf.stats(gv.fps,GetFramerate())
		gf.setButtonText(btn.button,"FPS: ",gf.Framerate.formatFPS(GetFramerate()),nil,nil)
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Framerate.tooltip()
	Glance.Debug("function","tooltip","Framerate")
	tooltip.Title("Frames Per Second", "GLD")
	tooltip.Double("Current", gf.Framerate.formatFPS(gv.fps.current),"WHT","GRN")
	tooltip.Double("Minimum", gf.Framerate.formatFPS(gv.fps.min),"WHT","GRN")
	tooltip.Double("Maximum", gf.Framerate.formatFPS(gv.fps.max),"WHT","GRN")
	tooltip.Double("Average", gf.Framerate.formatFPS(gv.fps.avg),"WHT","GRN")
	local GetNumPartyMembers, _ = GetNumSubgroupMembers()
	if ((GetNumPartyMembers ~= 0 and sender ~= UnitName("player")) or gv.Debug) and Glance_Local.Options.sendStats then
		gf.addonQuery("Framerate")
		local pty = gv.party
		tooltip.Space()
		tooltip.Double("Party"..gf.crossRealm(), "AVG", "GLD", "GLD")
		gf.partyTooltip("Framerate")
	end
end

---------------------------
-- messaging
---------------------------
function gf.Framerate.Message()
	return gf.Framerate.formatFPS(gv.fps.avg)
end

---------------------------
-- fps format function
---------------------------
function gf.Framerate.formatFPS(fps)
	fps = math.floor(fps)
	local sfps
	if fps <= 8 then
		sfps = HEX.red..fps
	elseif fps > 8 and fps < 15 then
		sfps = HEX.yellow..fps
	else
		sfps = HEX.green..fps
	end
	return sfps
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Framerate")
end