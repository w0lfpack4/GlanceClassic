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
gf.AddButton("Friends","LEFT")
local btn = gb.Friends
btn.text		= "Friends"
btn.enabled		= true
btn.events		= {"BN_FRIEND_ACCOUNT_OFFLINE","BN_FRIEND_ACCOUNT_ONLINE","FRIENDLIST_UPDATE"}
btn.update		= true
btn.tooltip		= true
btn.click		= true

---------------------------
-- shortcuts
---------------------------
local HEX = ga.colors.HEX
local CLS = ga.colors.CLASS
local tooltip = gf.Tooltip

---------------------------
-- arrays
---------------------------
ga.Clients = {
	["WoW"]  = "WoW",
	["D3"]   = "Diablo III",
	["S2"]   = "StarCraft II",
	["HS"]   = "Hearthstone",
	["WTCG"] = "Hearthstone",	
	["App"]  = "Launcher",
	["BSAp"] = "Mobile App",
	["Hero"] = "Heroes of the Storm",
	["Pro"]  = "Overwatch",
	["S1"]   = "StarCraft: Remastered",
	["DST2"] = "Destiny 2",
	["VIPR"] = "CoD: Black Ops 4",
	["ODIN"] = "CoD: Modern Warfare",
	["W3"]   = "Warcraft III",
}

---------------------------
-- update
---------------------------
function gf.Friends.update()
	if btn.enabled and gv.loaded then -- loaded keeps it from launching when defined
		Glance.Debug("function","update","Friends")
		local totalWoW = C_FriendList.GetNumFriends()
		local onlineWoW = C_FriendList.GetNumOnlineFriends()
		local totalBliz, onlineBliz = BNGetNumFriends()
		local total, online = (totalWoW+totalBliz), (onlineWoW+onlineBliz)
		gf.setButtonText(btn.button,"Friends: ",online,nil,nil)
	end
end

---------------------------
-- tooltip
---------------------------
function gf.Friends.tooltip()
	Glance.Debug("function","tooltip","Friends")

	local totalWoW, onlineWoW = C_FriendList.GetNumFriends(), C_FriendList.GetNumOnlineFriends()
	local totalBliz, onlineBliz = BNGetNumFriends()
	local total, online = (totalWoW+totalBliz), (onlineWoW+onlineBliz)
	local friends = {}
	
	-- WoW Friends
	for i = 0, totalWoW do
		local f = C_FriendList.GetFriendInfoByIndex(i)
		if f and f.connected then
			table.insert(friends, {f.name, f.level, f.className, f.area, f.dnd, f.afk})
		end
	end	
	
	-- Blizzard Friends (on WoW)
	for i = 1, onlineBliz do
		local bnetIDAccount, accountName, battleTag, isBattleTagPresence, _, _, _, _, _, isAFK, isDND, broadcastText, noteText = BNGetFriendInfo(i)
		for j=1, BNGetNumFriendGameAccounts(i) do
			local location
			local hasFocus, toonName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, _, _, _, bnetIDGameAccount = BNGetFriendGameAccountInfo(i, j)
			if( client == _G.BNET_CLIENT_WOW ) then
				if zoneName and zoneName ~= "" then
					if realmName and realmName ~= "" and realmName ~= playerRealmName then
						location = zoneName.." - "..realmName
					else
						location = zoneName
					end
				else
					location = realmName
				end
				table.insert(friends, {toonName, level, class, location, isDND, isAFK})
			end
		end
	end

	-- Display friends
	tooltip.Double("WoW Friends: ",onlineWoW.."/"..totalWoW, "GLD", "GLD")
	if #friends == 0 then
		if totalWoW == 0 then
			tooltip.Line("You have no friends.  Go be social!","WHT")
		else
			tooltip.Line("No one is online.","WHT")
		end
	end
	table.sort(friends, function(a, b) return a[1] < b[1] end)
	local count = 1
	for k, v in pairs(friends) do
		local name, realm = strsplit("-", v[1])
		local level, class, zone, busy, away = v[2], string.upper(v[3]), v[4], v[5], ""
		if away then status = "  |r"..HEX.red.."[Away]|r" end
		if busy then status = "  |r"..HEX.red.."[Busy]|r" end
		if zone == GetZoneText() then zone = HEX.green..zone else zone = HEX.gray..zone end
		tooltip.Double(gf.Friends.colorLevels(level).." |r"..CLS[string.upper(v[3])]..name..status, zone, "WHT", "LBL")
		count = count + 1
		if count > 20 then 
			local howManyMore = (#friends-20)
			if howManyMore > 0 then
				tooltip.Line("|rand "..howManyMore.." more..", "WHT")
			end
		end
	end
	wipe(friends)

	-- Blizzard Friends
	tooltip.Space()
	tooltip.Double("BattleNet Friends",onlineBliz.."/"..totalBliz,"GLD","GLD")
	for i = 1, onlineBliz do
		local bnetIDAccount, accountName, battleTag, isBattleTagPresence, _, _, _, _, _, isAFK, isDND, broadcastText, noteText = BNGetFriendInfo(i)
		for j=1, BNGetNumFriendGameAccounts(i) do
			local hasFocus, toonName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, _, _, _, bnetIDGameAccount = BNGetFriendGameAccountInfo(i, j)
			local status = ""
			if isAFK then status = "  |r"..HEX.red.."[Away]|r" end
			if isDND then status = "  |r"..HEX.red.."[Busy]|r" end
			if client ~= "App" and client ~= "BSAp" then
				clientName = gameText or ga.Clients[client]
				friends[accountName] = {clientName, status}
			else
				if not isAFK and not isDND then status = " |r"..HEX.red.."[Away]|r" end
				if not friends[accountName] then
					friends[accountName] = {"IRL", status}
				end
			end
		end
	end
	for k,v in pairs(friends) do
		local color = "GLD"
		if v[1] == "IRL" then color = "GRY" end
		if v[1] == "WoW" or v[1] == "WoW Classic" then color = "GRN" end
		tooltip.Double(k..v[2], v[1], "LBL", color)
	end
	wipe(friends)
	
	--(left,shift-left,right,shift-right,other)	
	tooltip.Notes("open the Friends tab",nil,nil,nil,nil)
end

---------------------------
-- click
---------------------------
function gf.Friends.click(self, button, down)
	Glance.Debug("function","click","Friends")
	if button == "LeftButton" then
		ToggleFriendsFrame(1) --removed the value "1" from being passed to fix bug.
	end
end

---------------------------
-- colorize levels
---------------------------
function gf.Friends.colorLevels(level)
	local quality = string.sub(tostring(level),1,1)
	return ga.colors.QUALITY[tonumber(quality)]..level
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Friends")
end