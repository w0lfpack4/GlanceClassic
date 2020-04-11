--------------------------------------------------------------------
-- Interface Options Panel
--------------------------------------------------------------------

---------------------------
-- lets simplify a bit..
---------------------------
local gf = Glance.Functions
local gv = Glance.Variables
local ga = Glance.Arrays
local gb = Glance.Buttons
local gd = Glance.Data

---------------------------
-- reload UI dialog
---------------------------
StaticPopupDialogs["Glance_RELOADUI"] = {
	text = "Reload your User Interface?",
	button1 = "Accept",
	button2 = "Cancel",
	OnAccept = function()
		ReloadUI()
	end,
	OnCancel = function(data, reason)
		if (reason == "timeout") then
			ReloadUI()
		else
			StaticPopupDialogs["Glance_RELOADUI"].reloadAccepted = false
		end
	end,
	OnHide = function()
		if (StaticPopupDialogs["Glance_RELOADUI"].reloadAccepted) then
			ReloadUI();
		end
	end,
	OnShow = function()
		StaticPopupDialogs["Glance_RELOADUI"].reloadAccepted = true;
	end,
	timeout = 5,
	hideOnEscape = 1,
	exclusive = 1,
	whileDead = 1
}

---------------------------
-- update frame scale
---------------------------
function gf.updateFrameScale(scale)
	Glance_Local.Options.frameScale = scale
	Glance.Frames.topFrame:SetScale(scale)
	gf.moveUI()
	gf.updateAll()
end

---------------------------
-- preload checkboxes
---------------------------
function gf.setOptionValues()
	for i=1,#Glance.CheckBoxes do
		_G["chk"..i]:SetChecked(Glance_Local.Options[Glance.CheckBoxes[i][4]])
	end
end

---------------------------
-- checkbox onclick
---------------------------
function gf.switchOptionValues(btn,val)
	if btn:GetChecked() == false then
		Glance_Local.Options[val] = false
	else
		Glance_Local.Options[val] = true
	end
	--gf.updateAll()
end

---------------------------
-- save profile
---------------------------
function gf.saveProfile()
	local hour, min = GetGameTime()
	Glance_Profile.realm = GetRealmName()
	Glance_Profile.name  = UnitName("player")
	Glance_Profile.date  = date("%m/%d/%y")
	Glance_Profile.time  = gf.GetHour(hour)..":"..gf.GetMin(min).." "..gf.GetAMPM(hour).." (S)"
	Glance_Profile.Options = Glance_Local.Options
	Glance_Profile.button  = Glance_Local.button
	for k, v in pairs(gb) do
		if gb[k].save.allowProfile then
			if gb[k].save.perCharacter ~= nil then
				for key, val in pairs(gb[k].save.perCharacter) do
					if Glance_Profile[k] == nil then Glance_Profile[k] = {} end
					Glance_Profile[k][key] = gb[k].save.perCharacter[key]
				end
			end
		end
	end
	StaticPopupDialogs["Glance_Saved"] = {
		text = "Your settings have been saved to the profile.",
		button1 = "OK",
		timeout = 5,
		hideOnEscape = 1,
		exclusive = 1,
		whileDead = 1
	}
	StaticPopup_Show("Glance_Saved")
	_G["Glance_Profile_Text"]:SetText(Glance_Profile.realm.." \\ "..Glance_Profile.name.." on "..Glance_Profile.date.." at "..Glance_Profile.time)
end

---------------------------
-- load profile
---------------------------
function gf.loadProfile()
	Glance_Local.Options = Glance_Profile.Options
	Glance_Local.button = Glance_Profile.button
	gv.button = Glance_Profile.button
	for k, v in pairs(gb) do
		if gb[k].save.allowProfile then
			if gb[k].save.perCharacter ~= nil then
				for key, val in pairs(gb[k].save.perCharacter) do
					if Glance_Profile[k] ~= nil then 
					gb[k].save.perCharacter[key] = Glance_Profile[k][key]
					end
				end
			end
		end
	end
	gf.positionButtons()
	gf.updateAll()
	StaticPopupDialogs["Glance_Loaded"] = {
		text = "Your settings have been loaded from the profile.",
		button1 = "OK",
		timeout = 5,
		hideOnEscape = 1,
		exclusive = 1,
		whileDead = 1
	}
	StaticPopup_Show("Glance_Loaded")
end

---------------------------
-- Hour function
---------------------------
function gf.GetHour(hour)
	if hour > 12 then
		hour = hour - 12
	end
	if hour == 0 then
		hour = 12
	end
	return hour
end

---------------------------
-- Minute function
---------------------------
function gf.GetMin(min)
	if min < 10 then
		return "0"..min
	end
	return min
end

---------------------------
-- DST function
---------------------------
function gf.GetAMPM(hour)
	if hour < 12 then
		return "AM"
	else
		return "PM"
	end
end


