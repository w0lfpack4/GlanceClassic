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
-- create panels
---------------------------
function gf.createPanels()
	for i=1,#Glance.Panels do
		local title, desc, func  = unpack(Glance.Panels[i])
		gf.createPanel(title, desc, func)
	end
end
function gf.createPanel(title, desc, func)
	gv.Panels = gv.Panels + 1
	local i = gv.Panels
	local parent
	if not _G["Glance_Panel"..i] then
		if i==1 then parent = UIParent else parent = _G["Glance_Panel1"] end
		_G["Glance_Panel"..i] = CreateFrame( "Frame", "Glance_Panel"..i, parent )
		_G["Glance_Panel"..i].name = title
		if i > 1 then _G["Glance_Panel"..i].parent = parent.name end
		InterfaceOptions_AddCategory(_G["Glance_Panel"..i])
	end
	if title ~= nil then
		local t = gf.createText(i,0,0,title,"GameFontNormalLarge","")
	end
	if desc ~= nil then
		local d = gf.createText(i,0,-20,desc,"GameFontHighlight","")
	end
	-- if i==2 then
		-- _G["Glance_Panel"..i]:SetScript('OnShow', function(self) Glance.Frames.Slider:Show() end)
		-- _G["Glance_Panel"..i]:SetScript('OnHide', function(self) Glance.Frames.Slider:Hide() end)
	-- end
	if func ~= nil then
		_G["Glance_Panel"..i]:SetScript('OnShow', function(self) func() end)
	end
	return i
end

---------------------------
-- create texts
---------------------------
function gf.createTexts()
	for i=1,#Glance.Text do
		local anchor,x,y,text,font,color,name = unpack(Glance.Text[i])
		gf.createText(anchor,x,y,text,font,color,name)
	end
end
function gf.createText(anchor,x,y,text,font,color,name)
	local fs = _G["Glance_Panel"..anchor]:CreateFontString(name, "ARTWORK", font)
	fs:SetPoint("TOPLEFT", 16+x, -16+y)
	fs:SetHeight(60)
	fs:SetWidth(InterfaceOptionsFramePanelContainer:GetWidth()-30)
	fs:SetNonSpaceWrap(true)
	fs:SetWordWrap(true)
	fs:SetJustifyH("LEFT")
	fs:SetJustifyV("TOP")
	fs:SetText(color..tostring(text))
	fs:SetHeight(fs:GetStringHeight()+20)
	--return fs
end

---------------------------
-- create checkboxs
---------------------------
function gf.createCheckBoxes()
	for i=1,#Glance.CheckBoxes do
		local parent,x,y,opt,text,desc,func,disabled = unpack(Glance.CheckBoxes[i])
		gf.createCheckBox(i,parent,x,y,opt,text,desc,func,disabled)
	end
end
function gf.createCheckBox(i,parent,x,y,opt,text,desc,func,disabled)
	_G["chk"..i] = CreateFrame('CheckButton', "Glance_chk"..i, _G["Glance_Panel"..parent], 'InterfaceOptionsCheckButtonTemplate')
	_G["Glance_chk"..i.."Text"]:SetText(text)
	_G["chk"..i]:SetPoint("TOPLEFT", 16+x, -16+y)
	if desc ~= nil then
		local d = gf.createText(_G["chk"..i],12,-5,desc,"GameFontHighlightSmall","|cffffff00")
	end
	if func ~= nil then
		if opt == "autoHide" then
			_G["chk"..i]:SetScript('OnClick', function(...) func(); gf.switchOptionValues(_G["chk"..i],opt);  end )
		else
			_G["chk"..i]:SetScript('OnClick', function(...) gf.switchOptionValues(_G["chk"..i],opt); func();  end )
		end
	else
		_G["chk"..i]:SetScript('OnClick', function(...) gf.switchOptionValues(_G["chk"..i],opt) end )
	end
	if disabled then
		_G["chk"..i]:Disable()
	end
end

---------------------------
-- create menus
---------------------------
function gf.createDropDowns()
	for i=1,#Glance.DropDownList do
		local panel, name, x, y, items, itemID, selectedID, func = unpack(Glance.DropDownList[i])
		gf.createDropDown(panel, name, x, y, items, itemID, selectedID, func)
	end
end	
function gf.createDropDown(panel, name, x, y, items, itemID, selectedID, func)
	CreateFrame("Button", name, _G["Glance_Panel"..panel], "UIDropDownMenuTemplate")	 
	_G[name]:ClearAllPoints()
	_G[name]:SetPoint("TOPLEFT", x, y)
	_G[name]:Show()
	 	 
	local function OnClick(self)
	   UIDropDownMenu_SetSelectedID(_G[name], self:GetID())	   
	   func(self)
	end
	 
	local function initialize(self, level)
	   local info = UIDropDownMenu_CreateInfo()
	   for k,v in pairs(items) do
		  info = UIDropDownMenu_CreateInfo()
		  if itemID == 0 then
			info.text = v
			info.value = v
		  else
			info.text = v[itemID]
			info.value = v[itemID]
		  end
		  info.func = OnClick
		  UIDropDownMenu_AddButton(info, level)
	   end
	end 
	 
	UIDropDownMenu_Initialize(_G[name], initialize)
	UIDropDownMenu_SetWidth(_G[name], 100);
	UIDropDownMenu_SetButtonWidth(_G[name], 124)
	UIDropDownMenu_SetSelectedID(_G[name], selectedID)
	UIDropDownMenu_JustifyText(_G[name], "LEFT")
end

---------------------------
-- panel buttons
---------------------------
function gf.createOptionsButton(panel,name,text,x,y,func)
	local btn = CreateFrame("BUTTON", name, _G["Glance_Panel"..panel], "UIPanelButtonTemplate")
	btn:SetHeight(22)
	local fs = btn:CreateFontString()
	local gameFontName,_,_ = GameFontNormal:GetFont()
	fs:SetFont(gameFontName, 11)
	btn:SetFontString(fs)
	btn:SetText(text)
	btn:SetWidth(btn:GetTextWidth()+30)
	btn:SetPoint("TOPLEFT", x, y)
	btn:SetScript("OnClick", function() func() end)
	btn:Show()
end

---------------------------
-- create scrollbars
---------------------------
function gf.createScrollBars()
	for i=1,#Glance.Scrollbars do
		local parent,x,y,h,w,n,array,nameIDX,checkedIDX,func,toolIDX = unpack(Glance.Scrollbars[i])
		gf.createScrollBar(parent,x,y,h,w,n,array,nameIDX,checkedIDX,func,toolIDX)
	end
end
function gf.createScrollBar(parent,x,y,h,w,n,array,nameIDX,checkedIDX,func)
	gv.Scrollbars = gv.Scrollbars + 1
	local i = gv.Scrollbars
	_G["backframe"..i] = CreateFrame( "Frame", "Glance_BF"..i, parent)
	_G["backframe"..i]:SetPoint("TOPLEFT", x, y)
	_G["backframe"..i]:SetHeight(h)
	_G["backframe"..i]:SetWidth(w)
	_G["backframe"..i]:SetBackdrop(ga.backDrop)
	_G["Glance_SB"..i] = CreateFrame( "ScrollFrame", "Glance_SB"..i, _G["backframe"..i], "FauxScrollFrameTemplate")
	_G["Glance_SB"..i]:SetHeight(h)
	_G["Glance_SB"..i]:SetWidth(w-5)
	_G["Glance_SB"..i]:SetPoint("TOPLEFT",5,-8)
	_G["Glance_SB"..i]:SetPoint("BOTTOMRIGHT",-30,8)
	gf.createScrollLines(_G["Glance_SB"..i],"Glance_SBE"..i,n,16,16)
	_G["Glance_SB"..i]:SetScript("OnVerticalScroll",function(self,offset) FauxScrollFrame_OnVerticalScroll(self, offset, 16, function() gf.updateScrollbar(i,array,nameIDX,checkedIDX,func) end) end)
	_G["Glance_SB"..i]:SetScript("OnShow", function() gf.showScrollbar(i,array,nameIDX,checkedIDX,func) end)
	return i
end

---------------------------
-- create scrollbar lines
---------------------------
function gf.createScrollLines(parent,name,count,height,width)
	for i=1, count do
		_G[name..i] = CreateFrame('CheckButton', name..i, parent, 'InterfaceOptionsCheckButtonTemplate')
		if i==1 then
			_G[name..i]:SetPoint("TOPLEFT", parent, "TOPLEFT")
		else
			_G[name..i]:SetPoint("TOPLEFT", name..i-1, "BOTTOMLEFT")
		end
		_G[name..i]:SetHeight(20)
		_G[name..i]:SetWidth(width)
	end
end

---------------------------
-- scrollbar overflow fix
---------------------------
function gf.showScrollbar(sbIDX,array,nameIDX,checkedIDX,func)
	if gv.overflowFix then
		gf.updateScrollbar(sbIDX,array,nameIDX,checkedIDX,func)
	else
		return
	end
end

---------------------------
-- scrollbar update
---------------------------
function gf.updateScrollbar(sbIDX,array,nameIDX,checkedIDX,func) --Glance_Local.mounts,1,3,gf.setPreferredMount()
	FauxScrollFrame_Update(_G["Glance_SB"..sbIDX],#array,20,16);  -- (frame, numItems/lines, numToDisplay, pixelheight/line) -- this is the 195 count...
	local line, lineplusoffset, thisArray
	for line=1,20 do
		lineplusoffset = line + FauxScrollFrame_GetOffset(_G["Glance_SB"..sbIDX]);
		if lineplusoffset <= #array then
			thisArray =  array[lineplusoffset]	
			_G[getglobal("Glance_SBE"..sbIDX..line):GetName().."Text"]:SetText(thisArray[nameIDX])
			_G["Glance_SBE"..sbIDX..line]:SetChecked(thisArray[checkedIDX])
			_G["Glance_SBE"..sbIDX..line]:SetScript('OnClick', function(...) func(line) end )
			if array == ga.Modules then
				_G["Glance_SBE"..sbIDX..line]:SetScript('OnEnter', function(...) gf.Options.setModuleText(line)	end )				
				_G["Glance_SBE"..sbIDX..line]:SetScript('OnLeave', function(...) gf.Options.setModuleText(0) end )
			end
			_G["Glance_SBE"..sbIDX..line]:Show();
		else
			_G["Glance_SBE"..sbIDX..line]:Hide();
		end
	end
	gv.overflowFix = false
	_G["Glance_SB"..sbIDX]:Show()
end

---------------------------
-- create slider
---------------------------
function gf.createSlider(name,panel,value,smin,smax,step,x,y,func)
	local Slide = CreateFrame('Slider', "Glance_Slider"..name, _G["Glance_Panel"..panel], 'OptionsSliderTemplate')
	Slide:ClearAllPoints()
	Slide:SetPoint("TOPLEFT", _G["Glance_Panel"..panel], "TOPLEFT", x, y)
	Slide:SetMinMaxValues(smin, smax)
	Slide:SetValue(value)
	getglobal(Slide:GetName() .. "Low"):SetText("smaller")
	getglobal(Slide:GetName() .. "High"):SetText("larger")
	if value == 1 then
		getglobal(Slide:GetName() .. "Text"):SetText("default")
	else
		getglobal(Slide:GetName() .. "Text"):SetText(gf.roundDecimal(Slide:GetValue(),1))
	end
	Slide:SetValueStep(step)
	Slide:SetScript("OnValueChanged", function() func(gf.sliderValueChanged("Glance_Slider"..name)) end) 
end

---------------------------
-- slider change
---------------------------
function gf.sliderValueChanged(name)
	local scale = gf.roundDecimal(_G[name]:GetValue(),1)
	if scale == 1 then
		getglobal(_G[name]:GetName() .. "Text"):SetText("default")
	else
		getglobal(_G[name]:GetName() .. "Text"):SetText(scale)
	end
	return scale
end

---------------------------
-- create color swatch
---------------------------
function gf.createSwatch(name,panel,frameColorIdx,h,w,x,y)
	-- createSwatch("BarColor",Glance_Panel2,1,18,18,35,-410)
	local swatch = CreateFrame("BUTTON", "GlanceSwatch"..name, _G[panel])
	swatch:SetHeight(h)
	swatch:SetWidth(w)
	swatch:SetPoint("TOPLEFT", _G[panel], "TOPLEFT", x, y)
	local r,g,b,a = unpack(Glance_Global.Options.frameColor[frameColorIdx])
	local tb = swatch:CreateTexture("s1tb", "BORDER")
	tb:SetColorTexture(1,1,1,1)
	tb:SetHeight(h)
	tb:SetWidth(w)
	tb:SetAllPoints(swatch)
	
	local ta = swatch:CreateTexture(nil, "ARTWORK")
	ta:SetColorTexture(r,g,b,1)
	ta:SetHeight(h-2)
	ta:SetWidth(w-2)
	ta:SetPoint("TOPLEFT", tb, "TOPLEFT", 1, -1)
	swatch.texture = ta 
	
	swatch:SetScript("OnClick", function(self, button, down) 
		local r,g,b,a = unpack(Glance_Global.Options.frameColor[frameColorIdx])
		gv.swatch.ColorIndex = frameColorIdx;
		gv.swatch.Name = "GlanceSwatch"..name;
		gv.swatch.Frame = Glance.Frames.topFrame;
		gv.swatch.RGBA = {r,g,b,a}
		gf.ShowColorPicker(r,g,b,a); 
	end)
	swatch:SetScript("OnEnter", function(...) SetCursor("CAST_CURSOR") end)
	swatch:SetScript("OnLeave", function(...) SetCursor("POINT_CURSOR") end)
end

---------------------------
-- colorpicker function
---------------------------
function gf.ShowColorPicker(r, g, b, a)
	ColorPickerFrame.hasOpacity = true
	ColorPickerFrame.opacity = a;
	ColorPickerFrame.previousValues = {r,g,b,a};
	ColorPickerFrame:SetColorRGB(r,g,b);
	ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc = gf.ColorPickerUpdate, gf.ColorPickerOkay, gf.ColorPickerCancel;
	ColorPickerFrame:Show();
end

---------------------------
-- colorpicker cancel
---------------------------
function gf.ColorPickerCancel(restore)
	local r,g,b,a;
	if restore == nil then restore = gv.swatch.RGBA end
	if restore then -- cancel
		r,g,b,a = unpack(restore);
		_G[gv.swatch.Name].texture:SetColorTexture(r, g, b, 1)
		Glance_Global.Options.frameColor[gv.swatch.ColorIndex] = {r, g, b, a}
		--if gv.swatch.ColorIndex == 3 then
			gf.setBackground(1)
		--else
			--gf.setBackground(gv.swatch.ColorIndex)
		--end
	end
end

---------------------------
-- colorpicker okay
---------------------------
function gf.ColorPickerOkay()
	local r,g,b,a;
	a,r,g,b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	_G[gv.swatch.Name].texture:SetColorTexture(r, g, b, 1)
	Glance_Global.Options.frameColor[gv.swatch.ColorIndex] = {r, g, b, a}
	gf.setBackground(1)
end

---------------------------
-- colorpicker update
---------------------------
function gf.ColorPickerUpdate()
	local r,g,b,a;
	a,r,g,b = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB();
	_G[gv.swatch.Name].texture:SetColorTexture(r, g, b, 1)
	Glance_Global.Options.frameColor[gv.swatch.ColorIndex] = {r, g, b, a}
	gf.setBackground(gv.swatch.ColorIndex)
end