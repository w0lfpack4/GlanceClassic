local ga = Glance.Arrays
ga.Quests = {}

OldGetQuestLogTitle = GetQuestLogTitle
function GetQuestLogTitle(questLogID)
	-- get original settings
	local title, level, groupCnt, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden = OldGetQuestLogTitle(questLogID);
	
	if isComplete then
		-- failed
		if isComplete == -1 then 
			if not isHeader then ga.Quests[title] = { ["complete"] = nil,} end	
		-- complete
		elseif isComplete == 1 then 
			-- found quest, play sound
			if ga.Quests[title] and not ga.Quests[title].complete then
				--play sound
				PlaySoundFile("Interface\\AddOns\\Glance_Quests\\QuestComplete.ogg")
				if not isHeader then ga.Quests[title] = { ["complete"] = true,} end
			else
				-- no quest entry, first run
				if not isHeader then ga.Quests[title] = { ["complete"] = true,} end
			end
		end
	-- quest active, populate the quest in db
	else
		if title and not isHeader then ga.Quests[title] = { ["complete"] = nil,} end
	end
	
	--CancelEmote()
	return title, level, groupCnt, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory, isHidden
end