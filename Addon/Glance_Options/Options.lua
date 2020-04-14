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
local _tb = 0
local _cb = 1 -- needs to be 1

---------------------------
-- auto increment texts
---------------------------
local function tb()
	_tb = _tb + 1
	return _tb
end 

---------------------------
-- auto increment checkboxes
---------------------------
local function cb()
	_cb = _cb + 1
	return _cb
end 

---------------------------
-- enable/disable when showlow is changed
---------------------------
local function checkPositioning()
	local sl = nil
	for i=1, #Glance.CheckBoxes do
		if Glance.CheckBoxes[i][4] == "showLow" then
			sl = _G["Glance_chk"..i]:GetChecked()
		end
	end
	for i=1, #Glance.CheckBoxes do
		if (Glance.CheckBoxes[i][4] == "movePlayer") or (Glance.CheckBoxes[i][4] == "moveTarget") or (Glance.CheckBoxes[i][4] == "moveBuffs") or (Glance.CheckBoxes[i][4] == "moveMinimap") or (Glance.CheckBoxes[i][4] == "reposition") then
			if sl then
				_G["Glance_chk"..i]:Disable()
			else
				_G["Glance_chk"..i]:Enable()
			end
		end
	end
end

---------------------------
-- enable/disable when autohide is changed
---------------------------
local function checkAutoHide()
	local ah = nil
	local sl = nil
	for i=1, #Glance.CheckBoxes do
		if Glance.CheckBoxes[i][4] == "autoHide" then
			ah = _G["Glance_chk"..i]:GetChecked()
		end
		if Glance.CheckBoxes[i][4] == "showLow" then
			sl = _G["Glance_chk"..i]:GetChecked()
		end
	end
	for i=1, #Glance.CheckBoxes do
		if (Glance.CheckBoxes[i][4] == "autoHidePet") or (Glance.CheckBoxes[i][4] == "autoHideVehicle") then
			if ah then
				_G["Glance_chk"..i]:Disable()
			else
				_G["Glance_chk"..i]:Enable()
			end
		end
		if (Glance.CheckBoxes[i][4] == "movePlayer") or (Glance.CheckBoxes[i][4] == "moveTarget") or (Glance.CheckBoxes[i][4] == "moveBuffs") or (Glance.CheckBoxes[i][4] == "moveMinimap") or (Glance.CheckBoxes[i][4] == "reposition") then
			if sl then
				_G["Glance_chk"..i]:Disable()
			else
				if ah then
					_G["Glance_chk"..i]:Disable()
				else
					_G["Glance_chk"..i]:Enable()
				end
			end
		end
	end
end

---------------------------
-- create options
---------------------------
function gf.createOptionsPanel()

	-- panel list
	---------------------------
	Glance.Panels[2] = {"General Settings","General configuration settings for Glance."}
	Glance.Panels[3] = {"Colors+","Color, size, and font options for Glance."}
	Glance.Panels[4] = {"Modules","Enable or disable the following modules in Glance. Individual options for modules can be accessed via Right-Click. Previously enabled modules will remain in memory until the UI is reloaded."}
	Glance.Panels[5] = {"Profiles","This is a very simple profile tool.  Click Save Profile to save this character's options to the profile.  Some modules do not allow settings to be saved.  The mount list, for instance, would not be the same for every character.  When you login to another character, come back to the Profiles option panel and click Load Profile to load the previously saved options.  Click Reload UI to register the changes."}
	
	-- create the panels
	---------------------------
	gf.createPanels()
	
--------------------------------------------------------------------

	-- PANEL 1: about text
	---------------------------
	Glance.Text[tb()] = {1,15,-85,"Version","GameFontNormal",""}
	Glance.Text[tb()] = {1,15,-100,GetAddOnMetadata("Glance","Version"),"GameFontHighlight",""}
	Glance.Text[tb()] = {1,15,-135,"Updated","GameFontNormal",""}
	Glance.Text[tb()] = {1,15,-150,GetAddOnMetadata("Glance","X-Updated"),"GameFontHighlight",""}
	Glance.Text[tb()] = {1,15,-185,"Author","GameFontNormal",""}
	Glance.Text[tb()] = {1,15,-200,GetAddOnMetadata("Glance","Author"),"GameFontHighlight",""}
	Glance.Text[tb()] = {1,15,-235,"Category","GameFontNormal",""}
	Glance.Text[tb()] = {1,15,-250,GetAddOnMetadata("Glance","X-Category"),"GameFontHighlight",""}
	Glance.Text[tb()] = {1,15,-285,"New In This Version","GameFontNormal",""}
	Glance.Text[tb()] = {1,15,-300,GetAddOnMetadata("Glance","X-New"),"GameFontHighlight",""}
	
--------------------------------------------------------------------

	-- PANEL 2: general options
	---------------------------
	Glance.Text[tb()] = {2,0,-60,"If you don't like Glance on top..","GameFontNormal",""}
	--Glance.Text[tb()] = {2,0,-75,"You must reload the UI for this option to take effect.","GameFontHighlight",""}
	-- this checkbox must remain static at #1
	Glance.CheckBoxes[_cb] = {2,15,-80,"showLow","Show Glance at the bottom of the UI",nil,function() checkPositioning(); if _G["chk1"]:GetChecked() then gf.positionBar(0,true) else gf.positionBar() end end}
	
	-- PANEL 2: UI Options
	---------------------------
	Glance.Text[tb()] = {2,0,-120,"Move the following to make room for Glance","GameFontNormal",""}
	Glance.Text[tb()] = {2,0,-135,"If you encounter any protected function errors, or Glance is interfering with your minimap or positioning addons, then uncheck the following.  Glance will not release any unchecked frames to other addons until the UI is reloaded.","GameFontHighlight",""}
	Glance.CheckBoxes[cb()] = {2,15,-180,"movePlayer","Player Frame",nil,function() gf.moveUI() end, Glance_Local.Options.showLow or Glance_Local.Options.autoHide}
	Glance.CheckBoxes[cb()] = {2,15,-200,"moveTarget","Target Frame",nil,function() gf.moveUI() end, Glance_Local.Options.showLow or Glance_Local.Options.autoHide}
	Glance.CheckBoxes[cb()] = {2,15,-220,"moveBuffs","Buffs",nil,function() gf.moveUI() end, Glance_Local.Options.showLow or Glance_Local.Options.autoHide}
	Glance.CheckBoxes[cb()] = {2,15,-240,"moveMinimap","Minimap",nil,function() gf.moveUI() end, Glance_Local.Options.showLow or Glance_Local.Options.autoHide}
	if (GetExpansionLevel() > 0)  then Glance.CheckBoxes[cb()] = {2,15,-260,"reposition","Reposition Player and Target frames when entering/exiting vehicles.",nil,nil, Glance_Local.Options.showLow or Glance_Local.Options.autoHide} end
	
	-- PANEL 2: hide options
	---------------------------
	Glance.Text[tb()] = {2,0,-300,"Auto-Hide Options","GameFontNormal",""}
	Glance.CheckBoxes[cb()] = {2,15,-320,"autoHide","Auto-Hide the bar until mouseover",nil,function() gf.autoHide(false); checkAutoHide(); end,false}
	if (GetExpansionLevel() > 0)  then Glance.CheckBoxes[cb()] = {2,15,-340,"autoHideVehicle","Auto-Hide the bar in Vehicles",nil,nil,Glance_Local.Options.autoHide} end
	if (GetExpansionLevel() > 4)  then Glance.CheckBoxes[cb()] = {2,15,-360,"autoHidePet","Auto-Hide the bar during Pet Battles",nil,nil,Glance_Local.Options.autoHide} end
	
	-- PANEL 2: other options
	---------------------------
	Glance.Text[tb()] = {2,0,-400,"Other Options","GameFontNormal",""}
	Glance.CheckBoxes[cb()] = {2,15,-420,"sendStats","Send stats to party members using Glance",nil}
	Glance.CheckBoxes[cb()] = {2,15,-440,"timePlayed","Show time played on login",nil}
	
--------------------------------------------------------------------

	-- PANEL 3: font options
	---------------------------	
	Glance.Text[tb()] = {3,0,-60,"Font Family","GameFontNormal",""}	
	Glance.DropDownList[1] = {3,"fontMenu",0,-90,ga.Font,1,Glance_Local.Options.font,function(self) Glance_Local.Options.font = self:GetID(); gf.updateAll(); end}
	
	Glance.Text[tb()] = {3,150,-60,"Font Size","GameFontNormal",""}
	local items = { 8,9,10,11,12,13,14,15,16,17,18,19,20 }
	Glance.DropDownList[2] = {3,"sizeMenu",150,-90,items,0,Glance_Local.Options.fontSize,function(self) Glance_Local.Options.fontSize = self:GetID(); gf.updateAll(); end}
	
	Glance.Text[tb()] = {3,0,-120,"Font Options","GameFontNormal",""}
	--Glance.CheckBoxes[cb()] = {3,15,-80,"gameFont","Use the standard game font (Requires Restart)",nil}
	Glance.CheckBoxes[cb()] = {3,15,-140,"showShadow","Add a shadow to the font for visibility",nil,function() gf.updateAll(); end}
	
	
	-- PANEL 3: scale
	---------------------------
	Glance.Text[tb()] = {3,250,-180,"Select the scale of the Glance bar","GameFontNormal",""}
	Glance.CheckBoxes[cb()] = {3,265,-200,"scaleTooltip","Scale the tooltips with the bar",nil}
	gf.createSlider("FrameScale",3,Glance_Local.Options.frameScale,0.5,1.5,0.1,291,-265,gf.updateFrameScale)
	
	-- PANEL 3: colors
	---------------------------
	Glance.Text[tb()] = {3,0,-180,"Select the colors of the Glance bar","GameFontNormal",""}
	gf.createSwatch("BarColor","Glance_Panel3",1,18,18,35,-215)
	Glance.Text[tb()] = {3,45,-201,"Bar Color","GameFontHighlight",""}
	gf.createSwatch("BarColorCombat","Glance_Panel3",2,18,18,35,-239)
	Glance.Text[tb()] = {3,45,-226,"Bar Color (Combat)","GameFontHighlight",""}
	gf.createSwatch("BarColorResting","Glance_Panel3",4,18,18,35,-263)
	Glance.Text[tb()] = {3,45,-251,"Bar Color (Resting)","GameFontHighlight",""}
	gf.createSwatch("BarBorder","Glance_Panel3",3,18,18,35,-287)
	Glance.Text[tb()] = {3,45,-276,"Bar Border Color","GameFontHighlight",""}
	
	-- PANEL 3: reset color
	---------------------------
	gf.createOptionsButton(3,"GLance_Panel3_Reset","RESET",32,-312,function() 
		local r,g,b,a = unpack(gv.defaultFrameColor[1]);
		_G["GlanceSwatchBarColor"].texture:SetColorTexture(r, g, b, 1)
		r,g,b,a = unpack(gv.defaultFrameColor[2]);
		_G["GlanceSwatchBarColorCombat"].texture:SetColorTexture(r, g, b, 1)
		r,g,b,a = unpack(gv.defaultFrameColor[3]);
		_G["GlanceSwatchBarBorder"].texture:SetColorTexture(r, g, b, 1)
		r,g,b,a = unpack(gv.defaultFrameColor[4]);
		_G["GlanceSwatchBarColorResting"].texture:SetColorTexture(r, g, b, 1)
		Glance_Global.Options.frameColor = gv.defaultFrameColor
		gf.setBackground(1)
	end)	
	
--------------------------------------------------------------------

	-- PANEL 4: module descriptions frame
	---------------------------
	Glance.Frames.descFrame = CreateFrame("BUTTON", "Glance", Glance_Panel4)
	local tf = Glance.Frames.descFrame
	tf:SetWidth(275)
	tf:SetHeight(415)
	tf:SetPoint("TOPLEFT", 330, -80)
	tf:SetBackdrop(ga.backDrop)
	
	local t = tf:CreateTexture(nil, "BACKGROUND")
	t:SetTexture(0, 0, 0, .5)
	t:SetAllPoints(tf)
	tf.texture = t 	
	tf:Show()
	
	local fs = tf:CreateFontString()
	local gameFontName,_,_ = GameFontNormal:GetFont()
	fs:SetFont(gameFontName, 12)
	fs:SetHeight(400)
	fs:SetWidth(265)
	fs:SetNonSpaceWrap(true)
	fs:SetWordWrap(true)
	fs:SetJustifyH("LEFT")
	fs:SetJustifyV("TOP")
	tf:SetFontString(fs)
	
--------------------------------------------------------------------

	-- PANEL 5: profile text
	---------------------------
	Glance.Text[tb()] = {5,0,-140,"Stored Profile set to: ","GameFontNormal",""}
	Glance.Text[tb()] = {5,135,-140," ","GameFontHighlight","profile is not set.","Glance_Profile_Text"}
	
	-- PANEL 5: profile buttons
	---------------------------
	gf.createOptionsButton(5,"GLance_Panel5_Save","Save Profile",30,-110,function() gf.saveProfile() end)
	gf.createOptionsButton(5,"GLance_Panel5_Load","Load Profile",150,-110,function() gf.loadProfile() end)
	gf.createOptionsButton(5,"GLance_Panel5_Reload","RELOAD UI",270,-110,function() StaticPopup_Show("Glance_RELOADUI") end)
		
--------------------------------------------------------------------

	-- reload UI buttons
	---------------------------
	gf.createOptionsButton(2,"GLance_Panel2_ReloadUI","RELOAD UI",340,-582,function() StaticPopup_Show("Glance_RELOADUI") end)
	gf.createOptionsButton(3,"GLance_Panel3_ReloadUI","RELOAD UI",340,-582,function() StaticPopup_Show("Glance_RELOADUI") end)
	gf.createOptionsButton(4,"GLance_Panel4_ReloadUI","RELOAD UI",340,-582,function() StaticPopup_Show("Glance_RELOADUI") end)
	gf.createOptionsButton(5,"GLance_Panel5_ReloadUI","RELOAD UI",340,-582,function() StaticPopup_Show("Glance_RELOADUI") end)
	
	-- create checkbox/scroll
	---------------------------
	gf.createTexts()
	gf.createCheckBoxes()
	gf.createDropDowns()
	gf.createScrollBars()
	
	-- load button options
	---------------------------
	for k, v in pairs(gb) do
		if gb[k].options then
			gf[k].options()
		end
	end
	
	-- profile stored text
	---------------------------
	if Glance_Profile.realm ~= nil and Glance_Profile.name ~= nil and Glance_Profile.date ~= nil and Glance_Profile.time ~= nil then
		_G["Glance_Profile_Text"]:SetText(Glance_Profile.realm.." \\ "..Glance_Profile.name.." on "..Glance_Profile.date.." at "..Glance_Profile.time)
	end
		
	
end

gf.createOptionsPanel()
gf.setOptionValues()