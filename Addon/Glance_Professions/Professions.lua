---------------------------
-- lets simplify a bit..
---------------------------
local gf = Glance.Functions
local gv = Glance.Variables
local ga = Glance.Arrays
local gb = Glance.Buttons
local gd = Glance.Data

---------------------------
-- create the button
---------------------------
gf.AddButton("Professions","LEFT")
local btn = gb.Professions
btn.text              = "Professions"
btn.enabled           = true
btn.events            = {"CHAT_MSG_SKILL","CHAT_MSG_TRADESKILLS","SKILL_LINES_CHANGED","TRADE_SKILL_UPDATE"}
btn.update            = true
btn.click             = true
btn.tooltip           = true
btn.menu              = true
btn.save.perCharacter = {["Profession"] = 0,["Title"] = "Icon",["Spell"]=""}

---------------------------
-- shortcuts
---------------------------
local spc = btn.save.perCharacter
local HEX = ga.colors.HEX
local tooltip = gf.Tooltip

---------------------------
-- variables
---------------------------
local maxCap = 700
--prof1, prof2, archaeology, fishing, cooking, firstAid
ga.Professions = { gf.GetProfessions() }
ga.ProfessionCaps = { -- add 75 to each level
	[75]  = "Apprentice",
	[150] = "Journeyman",
	[225] = "Expert",
	[300] = "Artisan",
	[375] = "Master",
	[450] = "Grand Master",
	[525] = "Illustrious",
	[600] = "Zen Master",
	[675] = "Draenor Master", -- warlords placeholder
	[700] = "Draenor Master", -- warlords placeholder
}
ga.ProfessionWarnings = {	
	["Apprentice"] = 50,
	["Journeyman"] = 125,
	["Expert"] = 200, -- all (first aid +25???)
	["Artisan"] = 275,
	["Master"] = 350,
	["Grand Master"] = 425,
	["Illustrious"] = 500,
	["Zen Master"] = 600, -- warlords placeholder
	--["Draenor Master"] = 675, -- warlords placeholder
}
-- racial buffs
ga.Racial = {
	["Alchemy"]       = {69045,15}, -- spellid, added skill points
	["Cooking"]       = {107073,15},
	["Enchanting"]    = {28877,10}, -- may be removed in warlords
	["Engineering"]   = {20593,15},
	["Jewelcrafting"] = {28875,10},
}

---------------------------
-- update
---------------------------
function gf.Professions.update(self, event, arg1)
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		Glance.Debug("function","update","Professions")
		ga.Professions = { gf.GetProfessions() }
		if spc.Profession ~= 0 then
			local name, icon, skillLevel, maxSkillLevel, pLevel, racial, HEXcolor, RGBcolor, warning, skillMod = unpack(gf.Professions.getProfessionInfo(spc.Profession))
			if maxSkillLevel ~= nil then 
				local title = name..": "
				if spc.Title =="Icon" then title = gf.is(icon,"display") end	
				local tracial = ""
				if racial > 0 then 
					--tracial = HEX.yellow.." [+"..racial.."]" 
					--maxSkillLevel = maxSkillLevel - racial
					skillMod = (skillMod or 0) + racial
				end				
				if skillMod > 0 then
					btn.button:SetText(title..HEXcolor..skillLevel.."|cffffff00(+"..skillMod..")"..HEXcolor.."/"..maxSkillLevel)
				else
					btn.button:SetText(title..HEXcolor..skillLevel.."/"..maxSkillLevel)
				end
			end
		else
			btn.button:SetText(HEX.red.."Professions")
		end
		btn.button:SetWidth(btn.button:GetTextWidth())
		local p = false
		for i=1,6 do
			if ga.Professions[i] ~= nil then
				p = true
			end
		end
		if not p then btn.enabled = false end
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Professions.tooltip()
	Glance.Debug("function","tooltip","Professions")
	tooltip.Title("Professions", "GLD")
	gf.Professions.update()
	local gather, bWarning
	local Hcolor, Rcolor = HEX.green, "GRN"
	for i=1,6 do
		if ga.Professions[i] ~= nil then
			local name, icon, skillLevel, maxSkillLevel, pLevel, racial, HEXcolor, RGBcolor, warning, skillMod = unpack(gf.Professions.getProfessionInfo(ga.Professions[i]))
			if warning == true then 
				Hcolor = HEXcolor; Rcolor = RGBcolor; bWarning = warning
			end
			local tracial = ""
			if racial > 0 then 
				--tracial = HEX.yellow.." [+"..racial.." racial]" 
				skillMod = (skillMod or 0) + racial
			end
			if skillMod > 0 then
				tooltip.Double(gf.is(icon,"tooltip").." "..name..": "..HEX.lightblue.."("..pLevel..")", skillLevel.."|cffffff00(+"..skillMod..")"..Hcolor.."/"..maxSkillLevel, "WHT",RGBcolor)
			else
				tooltip.Double(gf.is(icon,"tooltip").." "..name..": "..HEX.lightblue.."("..pLevel..")", skillLevel.."/"..maxSkillLevel, "WHT",RGBcolor)
			end
			if name=="Mining" or name=="Herbalism" then
				gather = gf.Professions.getGatherArea(name,skillLevel)
			end
		end
	end
	if bWarning then
		tooltip.Space()
		tooltip.Line("Warning","GLD")
		tooltip.Line("Go see your trainer.",Rcolor)
	end
	if gather then
		tooltip.Space()
		tooltip.Line("Gathering","GLD")
		tooltip.Wrap(gather,"WHT")
	end
	local tbl = {
		[1] = {["Title"]=spc.Title},
	}
	tooltip.Options(tbl)
	--(left,shift-left,right,shift-right,other)
	tooltip.Notes("open the Professions tab",nil,"change tracking",nil,nil)
end

---------------------------
-- click
---------------------------
function gf.Professions.click(self, button, down)
	Glance.Debug("function","click","Professions")
	if button == "LeftButton" then
		--ToggleSpellBook("professions") -- causes permission error now..
		--ToggleFrame(SpellBookFrame)
		if (spc.Spell~="") then
			CastSpellByName(spc.Spell)
		end
	end
end

---------------------------
-- menu
---------------------------
function gf.Professions.menu(level,UIDROPDOWNMENU_MENU_VALUE)
	Glance.Debug("function","menu","Professions")
	level = level or 1
	if (level == 1) then
		gf.setMenuTitle("Professions Options")
		gf.setMenuHeader("Title","title",level)
		gf.setMenuHeader("Tracking","tracking",level)
	end
	if (level == 2) then
		if gf.isMenuValue("tracking") then
			for i=1,6 do
				if ga.Professions[i] ~= nil then
					local name, icon, skillLevel, maxSkillLevel,_,_,_,skillMod = gf.GetProfessionInfo(ga.Professions[i])
					gf.setMenuOption(spc.Profession == ga.Professions[i],name,name,level,function() spc.Profession = ga.Professions[i]; spc.Spell = name; gf.Professions.update() end,icon)
				end
			end
		end
		if gf.isMenuValue("title") then
			gf.setMenuOption(spc.Title == "Text","Text","Text",level,function() spc.Title = "Text"; gf.Professions.update() end)
			gf.setMenuOption(spc.Title == "Icon","Icon","Icon",level,function() spc.Title = "Icon"; gf.Professions.update() end)		
		end
	end
end

---------------------------
-- profession info and colors
---------------------------
function gf.Professions.getProfessionInfo(id)
	local racial = 0
	local name, icon, skillLevel, maxSkillLevel,_,_,_,skillMod = gf.GetProfessionInfo(id)		
	if maxSkillLevel == nil then spc.Profession = 0; gf.Professions.update(); return end
	-- racial buffs
	if ga.Racial[name] ~= nil then
		if IsSpellKnown(ga.Racial[name][1]) == true then
			racial = ga.Racial[name][2]
		end
	end
	local pLevel = ga.ProfessionCaps[maxSkillLevel-racial] or "Unknown"
	local tLevel = ga.ProfessionWarnings[pLevel] or 10000
	local HEXcolor, RGBcolor = HEX.green, "GRN"
	local warning = false
	if skillLevel < maxCap then --not capped
		if skillLevel >= tLevel and skillLevel <= maxSkillLevel then -- between training level and maxskill learned
			HEXcolor = HEX.orange; RGBcolor = "ORA"; warning = true;
		elseif skillLevel == maxSkillLevel then -- at maxskill learned, can't go further
			HEXcolor = HEX.red; RGBcolor = "RED"; warning = true ;
		end		
	end
	return { name, icon, skillLevel, maxSkillLevel, pLevel, racial, HEXcolor, RGBcolor, warning, skillMod }
end

---------------------------
-- gather areas
---------------------------
function gf.Professions.getGatherArea(prof,skill)
	local name = "mining"
	if prof == "Herbalism" then name = "gathering" end
	if skill < maxCap then -- off when maxed
		for i=#gd[prof],1,-1 do
			local ore, lvl, loc = unpack(gd[prof][i])
			if skill >= lvl then return "You should be "..name.." "..HEX.orange..ore.."|r in: "..HEX.yellow..loc end
		end
	else
		return
	end
end

---------------------------
-- mining
---------------------------
Glance.Data.Mining = {
	{"Copper",1,"Alterac Mountains, Ashenvale, Darkshore, Desolace, Dun Morogh, Durotar, Duskwood, Elwynn Forest, Hillsbrad Foothills, Loch Modan, Mulgore, Redridge Mountains, Silverpine Forest, Stonetalon Mountains, The Barrens, Thousand Needles, Thunder Bluff, Tirisfal Glades, Westfall, Wetlands"},
	{"Tin",65,"The Barrens, Silverpine Forest, Darkshore, Ashenvale, Duskwood, Thousand Needles, Hillsbrad Foothills, Redridge Mountains, Loch Modan, Arathi Highlands, Wetlands, Stonetalon Mountains, Westfall, Alterac Mountains, Stranglethorn Vale, Desolace, Dustwallow Marsh, Feralas"},
	{"Silver",75,"Alterac Mountains, Arathi Highlands, Ashenvale, Badlands, Darkshore, Desolace, Duskwood, Dustwallow Marsh, Feralas, Hillsbad Foot hills, Loch Modan, Redridge Mountains, Searing Gorge, Silverpine Forest, Stonetalon Mountains, Stranglethorn Vale, Swamp of Sorrows, Tanaris, The Barrens, The Hinterlands, Thousand Needles, Westfall, Wetlands"},
	{"Iron",125,"Alterac Mountains, Arathi Highlands, Ashenvale, Badlands, Desolace, Duskwood, Dustwallow Marsh, Feralas, Hillsbrad Foothills, Searing Gorge, Stonetalon Mountains, Stranglethorn Vale, Swamp of Sorrows, Tanaris, The Hinterlands, Thousand Needles, Wetlands"},
	{"Gold",155,"Alterac Mountains, Alterac Valley, Arathi Highlands, Ashenvale, Azshara, Badlands, Blasted Lands, Burning Steppes, Desolace, Duskwood, Dustwallow Marsh, Eastern Plaguelands, Felwood, Feralas, Hillsbrad Foothills, Searing Gorge, Silithus, Stonetalon Mountains, Stranglethorn Vale, Swamp of Sorrows, Tanaris, The Hinterlands, Thousand Needles, Un'Goro Crater, Western Plaguelands, Wetlands, Winterspring"},
	{"Mithril",175,"Alterac Mountains, Arathi Highlands, Azshara, Badlands, Blasted Lands, Burning Steppes, Desolace, Dustwallow Marsh, Eastern Plaguelands, Felwood, Feralas, Hillsbrad Foothills, Searing Gorge, Silithus, Stonetalon Mountains, Stranglethorn Vale, Swamp of Sorrows, Tanaris, The Hinterlands, Un'Goro Crater, Western Plaguelands, Winterspring"},
	{"Truesilver",230,"Alterac Mountains, Arathi Highlands, Azshara, Badlands, Blasted Lands, Burning Steppes, Desolace, Dustwallow Marsh, Eastern Plaguelands, Felwood, Feralas, Hillsbrad Foothills, Searing Gorge, Silithus, Stonetalon Mountains, Stranglethorn Vale, Swamp of Sorrows, Tanaris, The Hinterlands, Thousand Needles, Un'Goro Crater, Western Plaguelands, Winterspring"},
	{"Dark Iron",230,"Burning Steppes, Searing Gorge, Blackrock Depths, The Molten Core"},
	{"Small Thorium",245,"Blasted Lands, Burning Steppes, Eastern Plaguelands, Felwood, Feralas, Searing Gorge, Silithus, Tanaris, The Hinterlands, Un'Goro Crater, Western Plaguelands, Winterspring"},
	{"Rich Thorium",275,"Azshara, Burning Steppes, Eastern Plaguelands, Un'Goro Crater, Western Plaguelands, Winterspring"},
	{"Fel Iron",300,"Hellfire Peninsula, Zangarmarsh, Terokkar Forest, Nagrand, Blade's Edge Mountains, Netherstorm, Shadowmoon Valley"},
	{"Adamantite",325,"Zangarmarsh, Terokkar Forest, Nagrand, Blade's Edge Mountains, Netherstorm, Shadowmoon Valley, and Dungeons"},
	{"Rich Adamantite",350,"Terokkar Forest, Nagrand, Blade's Edge Mountains, Netherstorm, Shadowmoon Valley, and Dungeons"},
	{"Cobalt",350,"Howling Fjord, Zul'Drak, Borean Tundra, Dragonblight, Grizzly Hills, and Crystalsong Forest"},
	{"Rich Cobalte",375,"Howling Fjord, Zul'Drak, Borean Tundra, Dragonblight, Grizzly Hills"},
	{"Saronite",400,"Sholazar Basin, Zul'Drak"},
	{"Obsidium",425,"Mount Hyjal,Vashj'ir"},
	{"Elementium",475,"Twilight Highlands"},
	{"Rich Elementium",500,"Twilight Highlands"},
	{"Pyrite",525,"Twilight Highlands"},
	{"Ghost Iron",525,"The Jade Forest, Valley of the Four Winds, Townlong Steppes, Kun-Lai Summit"},
	{"Rich Ghost Iron",550,"Valley of the Four Winds"},
	{"Trillium",575,"Kun-Lai Summit, Townlong Steppes, Dreaded Wastes, Vale of Eternal Blossoms"},
	{"Blackrock Ore or True Iron Ore",600,"Lunarfall, Frostwall"},
}

---------------------------
-- herbalism
---------------------------
Glance.Data.Herbalism = {
	{"Peacebloom",1,"Darkshore, Dun Morogh, Durotar, Elwynn Forest, Loch Modan, Mulgore, Silverpine Forest, Teldrassil, The Barrens, Tirisfal Glades, Westfall"},
	{"Silverleaf",1,"Darkshore, Dun Morogh, Durotar, Elwynn Forest, Loch Modan, Mulgore, Silverpine Forest, Teldrassil, The Barrens, Thunder Bluff, Tirisfal Glades, Westfall"},
	{"Earthroot",15,"Darkshore, Dun Morogh, Durotar, Elwynn Forest, Loch Modan, Mulgore, Redridge Mountains, Silverpine Forest, Teldrassil, The Barrens, Tirisfal Glades, Westfall"},
	{"Mageroyal",50,"Ashenvale, Darkshore, Durotar, Duskwood, Hillsbrad Foothills, Loch Modan, Redridge Mountains, Silverpine Forest, Stonetalon Mountains, Teldrassil, The Barrens, Westfall, Wetlands"},
	{"Briarthorn",70,"Ashenvale, Darkshore, Duskwood, Hillsbrad Foothills, Loch Modan, Redridge Mountains, Silverpine Forest, The Barrens, Westfall, Wetlands"},
	{"Stranglekelp",85,"Alterac Mountains, Arathi Highlands, Ashenvale, Azshara, Darkshore, Desolace, Dustwallow Marsh, Feralas, Hillsbrad Foothills, Silverpine Forest, Stranglethorn Vale, Swamp of Sorrows, Tanaris, The Barrens, The Hinterlands, Westfall, Wetlands"},
	{"Bruiseweed",100,"Alterac Mountains, Arathi Highlands, Ashenvale, Darkshore, Desolace, Hillsbrad Foothills, Loch Modan, Redridge Mountains, Silverpine Forest, Stonetalon Mountains, The Barrens, Thousand Needles, Westfall, Wetlands"},
	{"Wild Steelbloom",115,"Alterac Mountains, Arathi Highlands, Ashenvale, Badlands, Desolace, Duskwood, Hillsbrad Foothills, Stonetalon Mountains, Stranglethorn Vale, The Barrens, Thousand Needles, Wetlands"},
	{"Grave Moss",120,"Alterac Mountains, Arathi Highlands, Desolace, Duskwood, The Barrens, Wetlands"},
	{"Kingsblood",125,"Alterac Mountains, Arathi Highlands, Ashenvale, Badlands, Desolace, Duskwood, Dustwallow Marsh, Hillsbrad Foothills, Stonetalon Mountains, Stranglethorn Vale, Swamp of Sorrows, The Barrens, Thousand Needles, Wetlands"},
	{"Liferoot",150,"Alterac Mountains, Arathi Highlands, Ashenvale, Desolace, Dustwallow Marsh, Feralas, Hillsbrad Foothills, Silverpine Forest, Stranglethorn Vale, The Hinterlands, Wetlands"},
	{"Fadeleaf",160,"Alterac Mountains, Arathi Highlands, Badlands, Dustwallow Marsh, Stranglethorn Vale, Swamp of Sorrows, The Hinterlands"},
	{"Goldthorn",170,"Alterac Mountains, Arathi Highlands, Azshara, Badlands, Blasted Lands, Dustwallow Marsh, Feralas, Stranglethorn Vale, Swamp of Sorrows, The Hinterlands"},
	{"Khadgar's Whisker",185,"Alterac Mountains, Arathi Highlands, Azshara, Badlands, Dustwallow Marsh, Feralas, Hillsbrad Foothills, Stranglethorn Vale, Swamp of Sorrows, The Hinterlands"},
	{"Wintersbite",195,"Alterac Mountains"},
	{"Firebloom",205,"Badlands, Blasted Lands, Searing Gorge, Tanaris"},
	{"Purple Lotus",210,"Ashenvale, Azshara, Badlands, Feralas, Stranglethorn Vale, Tanaris, The Hinterlands"},
	{"Arthas' Tears",220,"Eastern Plaguelands, Felwood, Western Plaguelands"},
	{"Sungrass",230,"Azshara, Blasted Lands, Burning Steppes, Eastern Plaguelands, Felwood, Feralas, Silithus, The Hinterlands, Un'Goro Crater, Western Plaguelands"},
	{"Blindweed",235,"Swamp of Sorrows, Un'Goro Crater"},
	{"Ghost Mushroom",245,"The Hinterlands"},
	{"Gromsblood",250,"Ashenvale, Blasted Lands, Desolace, Felwood"},
	{"Golden Sansam",260,"Azshara, Burning Steppes, Eastern Plaguelands, Felwood, Feralas, Silithus, The Hinterlands, Un'Goro Crater"},
	{"Dreamfoil",270,"Azshara, Burning Steppes, Eastern Plaguelands, Felwood, Silithus, Un'Goro Crater, Western Plaguelands"},
	{"Mountain Silversage",280,"Azshara, Burning Steppes, Eastern Plaguelands, Felwood, Silithus, Un'Goro Crater, Western Plaguelands, Winterspring"},
	{"Plaguebloom",285,"Eastern Plaguelands, Felwood, Western Plaguelands"},
	{"Icecap",290,"Winterspring"},
	{"Black Lotus",300,"Burning Steppes, Eastern Plaguelands, Silithus, Winterspring"},
	{"Felweed",300,"Hellfire Peninsula, Zangarmarsh, Nagrand, Blade's Edge Mountains, Terokkar Forest, Shadowmoon Valley, Netherstorm"},
	{"Dreaming Glory",315,"Hellfire Peninsula, Zangarmarsh, Nagrand, Blade's Edge Mountains, Terokkar Forest, Shadowmoon Valley, Netherstorm"},
	{"Terocone",325,"Terokkar Forest, Shadowmoon Valley"},
	{"Ragveil",325,"Zangarmarsh"},
	{"Flame Cap",335,"Zangarmarsh"},
	{"Ancient Lichen",340,"Dungeons Only"},
	{"Netherbloom",350,"Netherstorm"},
	{"Nightmare Vine",365,"Shadowmoon Valley"},
	{"Mana Thistle",375,"Nagrand, Blade's Edge Mountains, Terokkar Forest, Shadowmoon Valley, Netherstorm"},
	{"Tiger Lily",400,"Borean Tundra, Grizzly Hills, Howling Fjord, Sholazar Basin, Zul'Drak"},
	{"Cinderbloom",425,"Mount Hyjal"},
	{"Adder's Tongue",430,"Sholazar Basin"},
	{"Azshara's Veil",450,"Mount Hyjal"},
	{"Heartblossom",475,"Deepholm"},
	{"Whiptail",500,"Uldum"},
	{"Green Tea Leaf",500,"Jade Forest, Valley of the Four Winds, Krasarang Wilds, Kun-Lai Summit"},
	{"Rain Poppy",525,"Jade Forest"},
	{"Silkweed",545,"Valley of the Four Winds"},
	{"Golden Lotus",550,"The Jade Forest, Valley of the Four Winds, Kun-Lai Summit"},
	{"Snow Lily",575,"Kun-Lai Summit"},
	{"Fool's Cap",585,"Dread Wastes, Townlong Steppes, The Jade Forest"},
	{"Frostweed",600,"Frostfire Ridge, Shadowmoon Valley, Spires of Arak"},
}

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Professions")
end