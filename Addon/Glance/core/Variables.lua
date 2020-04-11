--------------------------------------------------------------------
-- This is Glance.  One large array.
--------------------------------------------------------------------
Glance = {
	["Variables"]   = {},
	["Arrays"]	  = {["info"] = {}},
	["Functions"]   = {["Tooltip"] = {}},
	["Events"]	  = {},
	["Panels"]	  = {},
	["CheckBoxes"]  = {},
	["DropDownList"]  = {},
	["Scrollbars"]  = {},
	["Text"]		= {},
	["Frames"]	  = {},
	["Buttons"]	 = {},
	["Menus"]	   = {},
	["Data"]		= {},
	["Timers"]	  = {},
	["Commands"]	= {}
}

---------------------------
-- bypass wow time played
---------------------------
Glance.Functions.ChatFrame_DisplayTimePlayed = ChatFrame_DisplayTimePlayed

---------------------------
-- saved variables
---------------------------
Glance_Local = {
	["Options"] = {
		["Modules"] = {},
	},
}
Glance_Global = {}
Glance_Profile = {}
function Glance.Functions.loadDefaultVariables()
	if Glance_Local.Options.scaleTooltip == nil then Glance_Local.Options.scaleTooltip = false end
	if Glance_Local.Options.showLow == nil then Glance_Local.Options.showLow = false end
	if Glance_Local.Options.autoHide == nil then Glance_Local.Options.autoHide = false end
	if Glance_Local.Options.autoHidePet == nil then Glance_Local.Options.autoHidePet = true end
	if Glance_Local.Options.autoHideVehicle == nil then Glance_Local.Options.autoHideVehicle = true end
	if Glance_Local.Options.movePlayer == nil then Glance_Local.Options.movePlayer = true end
	if Glance_Local.Options.moveTarget == nil then Glance_Local.Options.moveTarget = true end
	if Glance_Local.Options.moveBuffs == nil then Glance_Local.Options.moveBuffs = true end
	if Glance_Local.Options.moveMinimap == nil then Glance_Local.Options.moveMinimap = true end
	if Glance_Local.Options.reposition == nil then Glance_Local.Options.reposition = true end
	if Glance_Local.Options.sendStats == nil then Glance_Local.Options.sendStats = true end
	if Glance_Local.Options.timePlayed == nil then Glance_Local.Options.timePlayed = true end
	if Glance_Local.Options.gameFont == nil then Glance_Local.Options.gameFont = false end
	if Glance_Local.Options.showShadow == nil then Glance_Local.Options.showShadow = true end
	if Glance_Local.Options.frameScale == nil then Glance_Local.Options.frameScale = 1 end
	if Glance_Local.Options.font == nil then Glance_Local.Options.font = 1 end
	if Glance_Local.Options.fontSize == nil then Glance_Local.Options.fontSize = 5 end
	if Glance_Local.button == nil then 
		Glance_Local.button = {
			["order"] = {
				["LEFT"] = {},
				["RIGHT"] = {},
			},
		}
	else
		Glance.Variables.buttonLock = false
	end
	if Glance_Global.Options == nil then
		Glance_Global.Options = {}
	end
	if Glance_Global.Options.frameColor == nil then 
		Glance_Global.Options.frameColor = {}
		Glance_Global.Options.frameColor[1] = {0,0,0,.5}
		Glance_Global.Options.frameColor[2] = {.4,0,0,.5}
		Glance_Global.Options.frameColor[3] = {.4, .4, .4, 1}
		Glance_Global.Options.frameColor[4] = {0,.5,.6,.5}
	end
	if Glance_Global.Options.frameColor[4] == nil then
		Glance_Global.Options.frameColor[4] = {0,0,.4,.5}
	end
end

---------------------------
-- Timers
---------------------------
Glance.Timers = {
	["load"] = {0,1,false,nil,"onLoad",nil},
	--["fix"] = {0,100,false,nil,"positionButtons",nil},
	["flip"] = {0,1,true,nil,nil,"flip"},--min,max,reset,button,func,var
}

---------------------------
-- variables
---------------------------
Glance.Variables = {
	["displayIcon"] = 15,
	["tooltipIcon"] = 16,
	["barY"] = 0,
	["moveLock"] = false,
	["menuOpen"] = false,
	["maxLevel"] = GetMaxPlayerLevel(),
	["buttonLock"] = true,
	["flip"] = true,
	["vehicleCheck"] = false,
	["inVehicle"] = false,
	["inPetBattle"] = false,
	["inCombatNeedExit"] = false,
	["messageCheck"] = true,
	["button"] = {
		["order"] = {
			["LEFT"] = {},
			["RIGHT"] = {},
		},
	},
	["buttonX"] = 0,
	["Scrollbars"] = 0,
	["overflowFix"] = true,
	["Panels"] = 0,
	["loaded"] = false,
	["Debug"] = false,
	["DebugUpdates"] = false,
	["DebugEvents"] = false,
	["DebugAllEvents"] = false,
	["DebugPositioning"] = false,
	["timer1"] = 0,
	["timer5"] = 0,
	["Delay"] = true,
	["spacer"] = 12,
	--["ga.Font[Glance_Local.Options.font]"] = "Interface\\AddOns\\Glance\\fonts\\font.ttf",
	--["ga.Font[Glance_Local.Options.font]"] = "Fonts\\FRIZQT__.TTF",
	--["ga.Font[Glance_Local.Options.font]"] = "Fonts\\ARIALN.TTF",
	--["ga.Font[Glance_Local.Options.font]"] = "Fonts\\MORPHEUS.ttf",
	["screenWidth"] = GetScreenWidth() * UIParent:GetEffectiveScale(),
	["timePlayed"] = false,
	["hook"] = {
		["player"] = false,
		["target"] = false,
		["buffs"] = false,
		["minimap"] = false,
	},
	["gametime"] = {
		["total"] = 0,
		["level"] = 0,
		["session"] = 0,
		["initTotal"] = 0,
		["initLevel"] = 0,
		["initSession"] = 0,
	},
	["party"] = {
		["a"] = {
			["name"] = 0,
			["level"] = 0,
		},
		["b"] = {
			["name"] = 0,
			["level"] = 0,
		},
		["c"] = {
			["name"] = 0,
			["level"] = 0,
		},
		["d"] = {
			["name"] = 0,
			["level"] = 0,
		},
	},
	["defaultFrameColor"] = {
		[1] = {0,0,0,.5},
		[2] = {.4,0,0,.5},
		[3] = {.4, .4, .4, 1},
		[4] = {0,.5,.6,.5},
	},
	["swatch"] = {},
}



---------------------------
-- Arrays: scroll backDrop
---------------------------
Glance.Arrays.backDrop = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	tile = true,
	tileSize = 32,
	edgeSize = 8,
	insets = {
		left = 1,
		right = 1,
		top = 1,
		bottom = 1
	}
}

---------------------------
-- Arrays: fonts
---------------------------
Glance.Arrays.Font = {
	{"Glance","Interface\\AddOns\\Glance\\fonts\\font.ttf"},
	{"Morpheus","Fonts\\MORPHEUS.ttf"},
	{"FRIZQT","Fonts\\FRIZQT__.TTF"},
	{"Arial Narrow","Fonts\\ARIALN.TTF"},
	{"Skurri","Fonts\\skurri.ttf"},
	{"Digital-7","Interface\\AddOns\\Glance\\fonts\\digital-7.ttf"},
	{"LED","Interface\\AddOns\\Glance\\fonts\\LED.ttf"},
}

---------------------------
-- Arrays: colors
---------------------------
Glance.Arrays.colors = {
	["RGB"] = {
		["WHT"] = { 1, 1, 1 },
		["GRY"] = { .5, .5, .5 },
		["GRN"] = { .3, 1, .3 },
		["GLD"] = { .9, .7, .2 },
		["YEL"] = { 1, 1, 0 },
		["BLU"] = { 0, .4, 1 },
		["LBL"] = { .4, .8, .94 },
		["RED"] = { 1, 0, 0 },
		["PPL"] = { .6, 0, .8 },
		["ORA"] = { 1, .46, 0 },
	},
	["CLASS"] = {
		["HUNTER"] = "|cffABD473",
		["WARLOCK"] = "|cff9482C9",
		["PRIEST"] = "|cffFFFFFF",
		["PALADIN"] = "|cffF58CBA",
		["MAGE"] = "|cff69CCF0",
		["ROGUE"] = "|cffFFF569",
		["DRUID"] = "|cffFF7D0A",
		["SHAMAN"] = "|cff0070DE",
		["WARRIOR"] = "|cffC79C6E",
		["DEATH KNIGHT"] = "|cffC41F3B",
		["MONK"] = "|cff00FF96",
	},
	["HEX"] = {
		["white"] = "|cffffffff",
		["red"] = "|cffff0000",
		["blue"] = "|cff3636fc",
		["darkblue"] = "|cff6fb8f0",
		["lightblue"] = "|cff6ff0ee",
		["green"] = "|cff00ff00",
		["orange"] = "|cffff7700",
		["yellow"] = "|cfffff000",
		["gold"] = "|cffffd700",
		["purple"] = "|cff9B30FF",
		["lightpurple"] = "|cffba74fb",
		["gray"] = "|cffcfcfcf",
		["boa"] = "|cffe6cc80",
	},
	["FACTION"] = {
		["horde"] = "|cffC41F3B",
		["alliance"] = "|cff69CCF0",
	},
	["DEFAULT"] = {
		["text"] = "|cffffffff",
		["value"] = "|cff00ff00",
		["warning"] = "|cffff7700",
		["error"] = "|cffff0000",
		["disabled"] = "|cffcfcfcf",
	},
	["QUALITY"] = { -- battle pets for now, might come in handy later..
		[1] = "|cff8a8a8a", -- gray
		[2] = "|cffffffff", -- white
		[3] = "|cff00ff00", -- green
		[4] = "|cff3995fd", -- blue
		[5] = "|cff9B30FF", -- purple
		[6] = "|cffff7700", -- orange
	},
	["QUALITYRGB"] = { -- battle pets for now, might come in handy later..
		[1] = {.5, .5, .5,}, -- gray
		[2] = { 1, 1, 1 }, -- white
		[3] = { .3, 1, .3 }, -- green
		[4] = { 0, .4, 1 }, -- blue
		[5] = { .6, 0, .8 }, -- purple
		[6] = { 1, .46, 0 }, -- orange
	},
}