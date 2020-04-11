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
gf.AddButton("Latency","LEFT")
local btn = gb.Latency
btn.text              = "Latency"
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
gv.party.a["Latency"] = 0
gv.party.b["Latency"] = 0
gv.party.c["Latency"] = 0
gv.party.d["Latency"] = 0

---------------------------
-- update
---------------------------
function gf.Latency.update()
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
		gf.setButtonText(btn.button,"Lag: ",gf.Latency.formatLag(latencyHome).."/"..gf.Latency.formatLag(latencyWorld).." |rms",nil,nil)
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Latency.tooltip()
	Glance.Debug("function","tooltip","Latency")
	local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
	tooltip.Title("Latency", "GLD")
	tooltip.Double("Home", gf.Latency.formatLag(latencyHome).." ms","WHT","GRN")
	tooltip.Double("World", gf.Latency.formatLag(latencyWorld).." ms","WHT","GRN")
	tooltip.Double("Upload", gf.Latency.formatBandwidth(bandwidthOut),"WHT","GRN")
	tooltip.Double("Download", gf.Latency.formatBandwidth(bandwidthIn),"WHT","GRN")
	
	local GetNumPartyMembers, _ = GetNumSubgroupMembers()
	if ((GetNumPartyMembers ~= 0 and sender ~= UnitName("player")) or gv.Debug) and Glance_Local.Options.sendStats then
		gf.addonQuery("Latency")
		local pty = gv.party
		tooltip.Space()
		tooltip.Double("Party"..gf.crossRealm(), "Home/World", "GLD", "GLD")
		gf.partyTooltip("Latency")
	end
end

---------------------------
-- messaging
---------------------------
function gf.Latency.Message()
	local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
	return gf.Latency.formatLag(latencyHome).."/"..gf.Latency.formatLag(latencyWorld)
end

---------------------------
-- format lag
---------------------------
function gf.Latency.formatLag(input)
	local lag = input
	local sLag
	if lag >= 350 then
		sLag = HEX.red..lag
	elseif lag < 350 and lag > 200 then
		sLag = HEX.yellow..lag
	else
		sLag = HEX.green..lag
	end
	return sLag
end

---------------------------
-- format lag
---------------------------
function gf.Latency.formatBandwidth(input)
	local kb = format("%.2f KB/s", input)
	return kb
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Latency")
end