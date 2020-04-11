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
		local WoWFriends = C_FriendList.GetNumFriends()
		local _,RealFriends = BNGetNumFriends()
		gf.setButtonText(btn.button,"Friends: ",WoWFriends..","..RealFriends,nil,nil)
	end
end





local function getRealIDGroupIndicator(bnetIDAccount, playerRealmName)
	if TitanGetVar(TITAN_SOCIAL_ID, "ShowGroupMembers") then
		local index = BNGetFriendIndex(bnetIDAccount)
		for i = 1, BNGetNumFriendGameAccounts(index) do
			local _, characterName, client, realmName = BNGetFriendGameAccountInfo(index, i)
			if client == BNET_CLIENT_WOW then
				if realmName and realmName ~= "" and realmName ~= playerRealmName then
					realmName = realmName:gsub("[%s%-]", "")
					characterName = characterName.."-"..realmName
				end
				if UnitInParty(characterName) or UnitInRaid(characterName) then
					return CHECK_ICON
				end
			end
		end
		return spacer()
	end
	return ""
end

---------------------------
-- tooltip
---------------------------
function gf.Friends.tooltip()
	Glance.Debug("function","tooltip","Friends")
	
	-- Friends
	local WoWFriends = C_FriendList.GetNumFriends()
	tooltip.Double(WoWFriends.." Friend(s) Online","Location","GLD","GLD")
	for i = 0, C_FriendList.GetNumFriends() do
		local f = C_FriendList.GetFriendInfoByIndex(i)
		if f and f.connected then
			local msg1, msg2 = unpack(gf.Friends.formatFriend(f.name, f.level, f.race, f.className, f.area))
			tooltip.Double(msg1, msg2, "WHT", "LBL")
		end
	end	
	
	-- BNET Friends on WoW
	local numTotal, numOnline = BNGetNumFriends()
	for i = 1, numOnline do
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
				local msg1, msg2 = unpack(gf.Friends.formatFriend(toonName, level, race, class, location))
				tooltip.Double(HEX.lightblue.."BN: |r"..msg1, msg2, "WHT", "LBL")
			end
		end

		--[[
		local accountInfo = C_BattleNet.GetFriendAccountInfo(j)
		local numToons = C_BattleNet.GetFriendNumGameAccounts(j);
		print("numtoons "..tostring(numToons))

		for t = 1, numToons do			
			local f = C_BattleNet.GetFriendGameAccountInfo(j, t)
			print(f)
			if( f.clientProgram == _G.BNET_CLIENT_WOW ) then
				local msg1, msg2 = unpack(gf.Friends.formatFriend(f.name, f.level, f.race, f.className, f.area))
				tooltip.Double(HEX.lightblue.."BN: |r"..msg1, msg2, "WHT", "LBL")
			end
		end
		--]]
	end

	-- BNET Friends elsewhere
	tooltip.Space()
	tooltip.Double(numOnline.." BattleNet Friend(s) Online","Game","GLD","GLD")
	for i = 1, numOnline do
		local bnetIDAccount, accountName, battleTag, isBattleTagPresence, _, _, _, _, _, isAFK, isDND, broadcastText, noteText = BNGetFriendInfo(i)
		for j=1, BNGetNumFriendGameAccounts(i) do
			local location
			local hasFocus, toonName, client, realmName, realmID, faction, race, class, _, zoneName, level, gameText, _, _, _, bnetIDGameAccount = BNGetFriendGameAccountInfo(i, j)
			if( client ~= _G.BNET_CLIENT_WOW ) then
				location = gameText
				local msg1, msg2 = unpack(gf.Friends.formatBNET(accountName, client))
				tooltip.Double(msg1, msg2, "LBL", "WHT")
			end
		end
	end
	
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
-- tired of concatenation errors
---------------------------
function gf.Friends.bp(str,val)
	if not str then
		str = ""
	end
	if val then
		str = str..tostring(val)
	end
	return str
end

---------------------------
-- format friends
---------------------------
function gf.Friends.formatFriend(name, level, race, class, area)
	local color, msg1, msg2 = "","",""
	if class then 
		local clss= string.upper(class) or "PRIEST"
		color = CLS[clss]
		msg1 = gf.Friends.bp(msg1,color)
	end
	if name then
		msg1 = gf.Friends.bp(msg1,name)
		if level ~= nil and level ~= "" then
			msg1 = gf.Friends.bp(msg1," |r("..HEX.green)
			msg1 = gf.Friends.bp(msg1,level)
			msg1 = gf.Friends.bp(msg1,"|r")
			if race then 
				msg1 = gf.Friends.bp(msg1," ")
				msg1 = gf.Friends.bp(msg1,race)
			end
			if class then 
				msg1 = gf.Friends.bp(msg1," ")
				msg1 = gf.Friends.bp(msg1, color)
				msg1 = gf.Friends.bp(msg1,class)
			end
			msg1 = gf.Friends.bp(msg1,"|r)")
		else
			area = "MIA"
		end
		if area then
			msg2 = gf.Friends.bp(msg2,area)
		end
	end
	return {msg1,msg2}
end

---------------------------
-- format BNET friends
---------------------------
function gf.Friends.formatBNET(name, client)
	local msg1, msg2 = "","",""
	if name then
		msg1 = gf.Friends.bp(msg1,HEX.lightblue)
		msg1 = gf.Friends.bp(msg1,name)
		if client then
			client = ga.Clients[client] or client		
			msg2 = gf.Friends.bp(msg2,client)
		end
	end
	return {msg1,msg2}
end

---------------------------
-- load on demand
---------------------------
if gv.loaded then
	gf.Enable("Friends")
end