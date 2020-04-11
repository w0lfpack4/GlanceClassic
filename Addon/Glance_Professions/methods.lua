---------------------------
-- lets simplify a bit..
---------------------------
local gf = Glance.Functions
local ga = Glance.Arrays

---------------------------
-- variables
---------------------------
ga.professionInfoTable = {
	-- First Aid
	["135966"] = { numAbilities = 1, spellIds = { 3273, 3274, 7924, 10846 }, skillLine = 129 },
	-- Blacksmithing
	["136241"] = { numAbilities = 1, spellIds = { 2018, 3100, 3538, 9785 }, skillLine = 164 },
	-- Leatherworking
	["136247"] = { numAbilities = 1, spellIds = { 8613, 8617, 8618, 10768 }, skillLine = 165 },
	-- Alchemy
	["136240"] = { numAbilities = 1, spellIds = { 2259, 3101, 3464, 11611 }, skillLine = 171 },
	-- Herbalism
	["136065"] = { numAbilities = 1, spellIds = { }, skillLine = 182 },
	-- Mining
	["136248"] = { numAbilities = 2, spellIds = { 2656 }, skillLine = 186 },
	-- Engineering
	["136243"] = { numAbilities = 1, spellIds = { 4036, 4037, 4038, 12656 }, skillLine = 202 },
	-- Enchanting
	["136244"] = { numAbilities = 1, spellIds = { 7411, 7412, 7413, 13920 }, skillLine = 333 },
	-- Fishing
	["136245"] = { numAbilities = 1, spellIds = { }, skillLine = 356 },
	-- Cooking
	["133971"] = { numAbilities = 1, spellIds = { 2550, 3102, 3413, 18260 }, skillLine = 185 },
	-- Tailoring
	["136249"] = { numAbilities = 1, spellIds = { 3908, 3909, 3910, 12180 }, skillLine = 197 },
	-- Skinning
	["134366"] = { numAbilities = 1, spellIds = { }, skillLine = 393 },
}

---------------------------
-- GetProfessions()
---------------------------
function gf.GetProfessions()
	local professions = {
		first = nil,
		second = nil,
		cooking = nil,
		first_aid = nil,
		fishing = nil
	}

	for skillIndex = 1, GetNumSkillLines() do
		local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier,
		skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
		skillDescription = GetSkillLineInfo(skillIndex)

		if not isHeader then
			if isAbandonable then
				-- primary
				if not professions.first then
					professions.first = skillIndex
				else
					professions.second = skillIndex
				end
			else
				if skillName == PROFESSIONS_COOKING then
					professions.cooking = skillIndex
				elseif skillName == PROFESSIONS_FIRST_AID then
					professions.first_aid = skillIndex
				elseif skillName == PROFESSIONS_FISHING then
					professions.fishing = skillIndex
				end
			end
		end
	end

	-- original: prof1, prof2, archaeology, fishing, cooking, firstAid = GetProfessions()
	return professions.first, professions.second, nil, professions.fishing, professions.cooking, professions.first_aid
end

---------------------------
-- Find slot by spell id
---------------------------
function gf.FindSpellBookSlotBySpellIDs(t)
	if not t then return end

	for i, id in ipairs(t) do
		local spellIndex = FindSpellBookSlotBySpellID(id)
		if (spellIndex) then
			return spellIndex
		end
	end
end

---------------------------
-- find icon by skill name
---------------------------
function gf.findSpellTexture(skillName)
	local texture = GetSpellBookItemTexture(skillName)
	if texture then return tostring(texture) end

	-- find herbs
	if (FindSpellBookSlotBySpellID(2383)) then return "136065" end

	-- smiting
	if (FindSpellBookSlotBySpellID(2656)) then return "136248" end
end

---------------------------
-- GetProfessionInfo()
---------------------------
function gf.GetProfessionInfo(skillIndex)
	local skillName, isHeader, isExpanded, skillRank, numTempPoints, skillModifier,
	skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
	skillDescription = GetSkillLineInfo(skillIndex)

	local texture = gf.findSpellTexture(skillName)
	local info = ga.professionInfoTable[texture or 0] or {}
	local spellOffset = gf.FindSpellBookSlotBySpellIDs(info.spellIds or {})
	if spellOffset then
		spellOffset = spellOffset - 1
	end

	return skillName, texture, skillRank, skillMaxRank, info.numAbilities, spellOffset, info.skillLine, skillModifier + numTempPoints, nil, nil
end