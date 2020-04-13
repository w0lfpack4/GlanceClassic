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
gf.AddButton("Quests","RIGHT")
local btn = gb.Quests
btn.text              = "      "
btn.texture.normal    = "Interface\\AddOns\\Glance_Quests\\icon.tga"
btn.events            = {"QUEST_COMPLETE"}
btn.enabled           = true
btn.update            = true
btn.tooltip           = false
btn.click             = false
btn.menu              = false
btn.save.perCharacter = {["CountTradeBagSlots"] = false, ["Display"] = "Free", ["Title"] = "Icon"}


---------------------------
-- update
---------------------------
function gf.Quests.update(self, event, arg1)
	if btn.enabled and gv.loaded then
		Glance.Debug("function","update","Quests")
		if event == "QUEST_COMPLETE" then
			PlaySoundFile("Interface\\AddOns\\Glance_Quests\\QuestComplete")
		end if
	end
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Quests")
end