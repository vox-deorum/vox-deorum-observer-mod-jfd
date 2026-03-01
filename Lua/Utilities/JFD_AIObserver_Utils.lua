-- JFD_Utilities_AIObserver
-- Author: JFD
-- DateCreated: 9/25/2023 1:33:42 AM
--=======================================================================================================================
-- INCLUDES
--=======================================================================================================================
-------------------------------------------------------------------------------------------------------------------------
include("JFDLC_Utils_ActiveMods.lua");
include("PlotIterators.lua");
--=======================================================================================================================
-- DEBUG UTILTIIES
--=======================================================================================================================
-------------------------------------------------------------------------------------------------------------------------
-- Returns an array of strings, one for each call level. 
-- We could use debug.traceback instead but this ones truncates path and we cannot easily ignore the topmost levels.
function getStackTrace()
    -- Level 1 is getStackTrace, 2 is its caller
    local level = 2 
    local trace = {}
    while true do
        -- Gets that level's informations: function name, source file and line.
        local info = debug.getinfo(level, "nSl") 
        if not info then break end

        -- C code or Lua code?
        if info.what == "C" then
            table.insert(trace, "C function");
        else   
            local userStr = Path.GetFileName(info.source)..": "..info.currentline;
            if info.name and string.len(info.name) then
                userStr = userStr.." ("..info.name..")";
            end
            table.insert(trace, userStr);
        end
        level = level + 1
    end
    return trace;
end
--=======================================================================================================================
-- GLOBAL UTILITIES
--=======================================================================================================================
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-- GLOBALS
-------------------------------------------------------------------------------------------------------------------------
if Game then
	--Game_IsModActive
	function Game_IsModActive(modID)
		for _, mod in pairs(Modding.GetActivatedMods()) do
			if mod.ID == modID then
				return true
			end
		end
		return false
	end
	--Game_IsCulDivActive()
	function Game_IsCulDivActive()
		return Game_IsModActive("31a31d1c-b9d7-45e1-842c-23232d66cd47")
	end
	--Game_IsIGEActive()
	function Game_IsIGEActive()
		return Game_IsModActive("170c8ed1-b516-4fe2-b571-befeac39d220")
	end
	--Game_IsInfoAddictActive()
	function Game_IsInfoAddictActive()
		return Game_IsModActive("aec5d10d-f00f-4fc7-b330-c3a1e86c91c3")
	end
	--Game_IsSovereigntyActive()
	function Game_IsInfoAddictActive()
		return Game_IsModActive("aec5d10d-f00f-4fc7-b330-c3a1e86c91c3")
	end
	--Game_IsVMCActive()
	function Game_IsVMCActive()
		return Game_IsModActive("d1b6328c-ff44-4b0d-aad7-c657f83610cd")
	end
end
-------------------------------------------------------------------------------------------------------------------------
--MATH UTILS
-------------------------------------------------------------------------------------------------------------------------
--Game.GetRandom
function Game.GetRandom(lower, upper)
	return Game.Rand((upper + 1) - lower, "") + lower
end
local g_GetRandom = Game.GetRandom
-------------------------------------------------------------------------------------------------------------------------
--Game.GetRound
function Game.GetRound(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end
local g_GetRound = Game.GetRound
-------------------------------------------------------------------------------------------------------------------------
--NOTIFICATION UTILS
-------------------------------------------------------------------------------------------------------------------------
--Player:SendWorldEvent
local notificationWorldEventID = NotificationTypes["NOTIFICATION_DIPLOMACY_DECLARATION"]
function Player.SendWorldEvent(player, description)
	print("Sending World Event: ", description)
	local activePlayer = Players[Game.GetActivePlayer()]
	local playerTeam = Teams[player:GetTeam()]
	if (not playerTeam:IsHasMet(Game.GetActiveTeam())) then return end
	activePlayer:AddNotification(notificationWorldEventID, description, "[COLOR_POSITIVE_TEXT]World Events[ENDCOLOR]", -1, -1)
end 
-------------------------------------------------------------------------------------------------------------------------
--Player:SendNotification
function Player.SendNotification(player, notificationType, description, descriptionShort, global, data1, data2, unitID, data3, metOnly, includesSerialMessage)
	local notificationID = NotificationTypes[notificationType]
	local teamID = player:GetTeam()
	local data1 = data1 or -1
	local data2 = data2 or -1
	local unitID = unitID or -1
	local data3 = data3 or -1
	if global then
		if (metOnly and Teams[Game.GetActiveTeam()]:IsHasMet(teamID) or (not metOnly)) then
			Players[Game.GetActivePlayer()]:AddNotification(notificationID, description, descriptionShort, data1, data2, unitID, data3)
			if (includesSerialMessage and description) then Events.GameplayAlertMessage(description) end
		end
	else
		if (not player:IsHuman()) then return end
		if (metOnly and Teams[Game.GetActiveTeam()]:IsHasMet(teamID) or (not metOnly)) then
			player:AddNotification(notificationID, description, descriptionShort, data1, data2, unitID, data3)
			if (includesSerialMessage and description) then Events.GameplayAlertMessage(description) end
		end
	end
end  
--=======================================================================================================================
-- PLAYER UTILITIES
--=======================================================================================================================
-------------------------------------------------------------------------------------------------------------------------
--LEADER UTILS
-------------------------------------------------------------------------------------------------------------------------
--JFD_AIObserver_PopulateLeaderFlavours
local g_Leader_Flavors_Table = {}
local g_Leader_Flavors_Count = 1
for row in DB.Query("SELECT * FROM Leader_Flavors;") do 	
	g_Leader_Flavors_Table[g_Leader_Flavors_Count] = row
	g_Leader_Flavors_Count = g_Leader_Flavors_Count + 1
end
local g_LeaderFlavours_Table
function JFD_AIObserver_PopulateLeaderFlavours()
	g_LeaderFlavours_Table = {}
	for otherPlayerID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
		local otherPlayer = Players[otherPlayerID]
		if otherPlayer:IsAlive() then
			local leaderID = otherPlayer:GetLeaderType()
			local leader = GameInfo.Leaders[leaderID]
			local leaderType = leader.Type
			g_LeaderFlavours_Table[otherPlayerID] = {}
			--g_Leader_Flavors_Table
			local flavorsTable = g_Leader_Flavors_Table
			local numFlavors = #flavorsTable
			for index = 1, numFlavors do
				local row = flavorsTable[index]
				if row.LeaderType == leaderType then
					g_LeaderFlavours_Table[otherPlayerID][row.FlavorType] = row.Flavor
				end
			end
		end
	end
end
JFD_AIObserver_PopulateLeaderFlavours()
-------------------------------------------------------------------------------------------------------------------------
--Player:GetFlavorValue
function Player.GetFlavorValue(player, flavorType)
	return g_LeaderFlavours_Table[player:GetID()][flavorType] or 5
end	
-------------------------------------------------------------------------------------------------------------------------
--JFD_AIObserver_PopulateDefaultLeaderNames
local g_DefaultLeaderNames_Table = {}
function JFD_AIObserver_PopulateDefaultLeaderNames() 
	for otherPlayerID = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
		local otherPlayer = Players[otherPlayerID]
		if otherPlayer:IsAlive() then
			local leaderID = otherPlayer:GetLeaderType()
			local leader = GameInfo.Leaders[leaderID]
			local leaderDesc = leader.Description
			g_DefaultLeaderNames_Table[otherPlayerID] = leaderDesc
		end
	end
end
JFD_AIObserver_PopulateDefaultLeaderNames()

--Player:GetDefaultName
function Player.GetDefaultName(player)
	local strDefaultName = g_DefaultLeaderNames_Table[player:GetID()]
	if (not strDefaultName) then
		strDefaultName = GameInfo.Leaders[player:GetLeaderType()].Description
	end
	return strDefaultName
end
-------------------------------------------------------------------------------------------------------------------------
--POLICY UTILS
-------------------------------------------------------------------------------------------------------------------------
--Player_GetIdeology
local ideologySpiritID = GameInfoTypes["POLICY_BRANCH_JFD_SPIRIT"]
function Player_GetIdeology(player, notSpirit)
	local ideologyID = player:GetLateGamePolicyTree()
	if ((notSpirit) or (not ideologySpiritID)) then
		return ideologyID
	elseif player:IsPolicyBranchUnlocked(ideologySpiritID) then
		return ideologySpiritID
	end
	return ideologyID
end
-------------------------------------------------------------------------------------------------------------------------
--Player_GetFakeGovernment
local policyBranchTraditionID = GameInfoTypes["POLICY_BRANCH_TRADITION"]
local policyMonarchyID = GameInfoTypes["POLICY_MONARCHY"]

local policyBranchLibertyID = GameInfoTypes["POLICY_BRANCH_LIBERTY"]
local policyRepublicID = GameInfoTypes["POLICY_REPUBLIC"]

local policyBranchPietyID = GameInfoTypes["POLICY_BRANCH_PIETY"]
local policyTheocracyID = GameInfoTypes["POLICY_THEOCRACY"]

local ideologyAutocracyID = GameInfoTypes["POLICY_BRANCH_AUTOCRACY"]
local ideologyFreedomID = GameInfoTypes["POLICY_BRANCH_FREEDOM"]
local ideologyOrderID = GameInfoTypes["POLICY_BRANCH_ORDER"]
local ideologySpiritID = GameInfoTypes["POLICY_BRANCH_JFD_SPIRIT"] or -1

local ideologyFakeGov = {}
ideologyFakeGov[ideologyAutocracyID] = {}
ideologyFakeGov[ideologyAutocracyID][policyMonarchyID] = {}
ideologyFakeGov[ideologyAutocracyID][policyMonarchyID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyAutocracyID][policyMonarchyID].Font = "[ICON_JFD_LEGEND_GOV_MONARCHY_A]"
ideologyFakeGov[ideologyAutocracyID][policyRepublicID] = {}
ideologyFakeGov[ideologyAutocracyID][policyRepublicID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyAutocracyID][policyRepublicID].Font = "[ICON_JFD_LEGEND_GOV_REPUBLIC_A]"
ideologyFakeGov[ideologyAutocracyID][policyTheocracyID] = {}
ideologyFakeGov[ideologyAutocracyID][policyTheocracyID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyAutocracyID][policyTheocracyID].Font = "[ICON_JFD_LEGEND_GOV_THEOCRACY_A]"
ideologyFakeGov[ideologyFreedomID] = {}
ideologyFakeGov[ideologyFreedomID][policyMonarchyID] = {}
ideologyFakeGov[ideologyFreedomID][policyMonarchyID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyFreedomID][policyMonarchyID].Font = "[ICON_JFD_LEGEND_GOV_MONARCHY_F]"
ideologyFakeGov[ideologyFreedomID][policyRepublicID] = {}
ideologyFakeGov[ideologyFreedomID][policyRepublicID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyFreedomID][policyRepublicID].Font = "[ICON_JFD_LEGEND_GOV_REPUBLIC_F]"
ideologyFakeGov[ideologyFreedomID][policyTheocracyID] = {}
ideologyFakeGov[ideologyFreedomID][policyTheocracyID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyFreedomID][policyTheocracyID].Font = "[ICON_JFD_LEGEND_GOV_THEOCRACY_F]"
ideologyFakeGov[ideologyOrderID] = {}
ideologyFakeGov[ideologyOrderID][policyMonarchyID] = {}
ideologyFakeGov[ideologyOrderID][policyMonarchyID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyOrderID][policyMonarchyID].Font = "[ICON_JFD_LEGEND_GOV_MONARCHY_O]"
ideologyFakeGov[ideologyOrderID][policyRepublicID] = {}
ideologyFakeGov[ideologyOrderID][policyRepublicID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyOrderID][policyRepublicID].Font = "[ICON_JFD_LEGEND_GOV_REPUBLIC_O]"
ideologyFakeGov[ideologyOrderID][policyTheocracyID] = {}
ideologyFakeGov[ideologyOrderID][policyTheocracyID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologyOrderID][policyTheocracyID].Font = "[ICON_JFD_LEGEND_GOV_THEOCRACY_O]"
ideologyFakeGov[ideologySpiritID] = {}
ideologyFakeGov[ideologySpiritID][policyMonarchyID] = {}
ideologyFakeGov[ideologySpiritID][policyMonarchyID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologySpiritID][policyMonarchyID].Font = "[ICON_JFD_LEGEND_GOV_MONARCHY_S]"
ideologyFakeGov[ideologySpiritID][policyRepublicID] = {}
ideologyFakeGov[ideologySpiritID][policyRepublicID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologySpiritID][policyRepublicID].Font = "[ICON_JFD_LEGEND_GOV_REPUBLIC_S]"
ideologyFakeGov[ideologySpiritID][policyTheocracyID] = {}
ideologyFakeGov[ideologySpiritID][policyTheocracyID].Desc = "Absolute Monarchy"
ideologyFakeGov[ideologySpiritID][policyTheocracyID].Font = "[ICON_JFD_LEGEND_GOV_THEOCRACY_S]"

function Player_GetFakeGovernment(player)
	local strFakeGovDesc
	local strFakeGovFont
	
	local playerPolicyBranchID = player:GetDominantPolicyBranchForTitle()
	local playerIdeology = Player_GetIdeology(player)
	
	local flavourGold = player:GetFlavorValue("FLAVOR_GOLD")
	local flavourCulture = player:GetFlavorValue("FLAVOR_CULTURE")
	local flavourFaith = player:GetFlavorValue("FLAVOR_RELIGION")
	local flavourBest
	if flavourGold > flavourCulture and flavourGold > flavourFaith then
		flavourBest = flavourGold
	elseif flavourFaith > flavourGold and flavourFaith > flavourCulture then
		flavourBest = flavourFaith
	else
		flavourBest = flavourCulture
	end
	
	if flavourBest == flavourFaith and playerPolicyBranchID == policyBranchPietyID and player:HasPolicy(policyTheocracyID) and player:HasCreatedReligion() then
		if playerIdeologyID ~= -1 then
			local ideologyFakeGov = ideologyFakeGov[playerIdeologyID]
			if ideologyFakeGov then
				strFakeGovDesc = ideologyFakeGov[policyRepublicID].Desc
				strFakeGovFont = ideologyFakeGov[policyRepublicID].Font
			end
		else
			strFakeGovDesc = "Republic"
			strFakeGovFont = "[ICON_JFD_LEGEND_GOV_REPUBLIC]"
		end
	elseif flavourBest == flavourGold and playerPolicyBranchID == policyBranchLibertyID and player:HasPolicy(policyRepublicID) then
		if playerIdeologyID ~= -1 then
			local ideologyFakeGov = ideologyFakeGov[playerIdeologyID]
			if ideologyFakeGov then
				strFakeGovDesc = ideologyFakeGov[policyRepublicID].Desc
				strFakeGovFont = ideologyFakeGov[policyRepublicID].Font
			end
		else
			strFakeGovDesc = "Republic"
			strFakeGovFont = "[ICON_JFD_LEGEND_GOV_REPUBLIC]"
		end
	elseif flavourBest == flavourCulture and playerPolicyBranchID == policyBranchTraditionID and player:HasPolicy(policyMonarchyID) then
		if playerIdeologyID ~= -1 then
			local ideologyFakeGov = ideologyFakeGov[playerIdeologyID]
			if ideologyFakeGov then
				strFakeGovDesc = ideologyFakeGov[policyMonarchyID].Desc
				strFakeGovFont = ideologyFakeGov[policyMonarchyID].Font
			end
		else
			strFakeGovDesc = "Monarchy"
			strFakeGovFont = "[ICON_JFD_LEGEND_GOV_MONARCHY]"
		end
	end
	
	return strFakeGovDesc, strFakeGovFont
end
-------------------------------------------------------------------------------------------------------------------------
--RELIGION UTILS
-------------------------------------------------------------------------------------------------------------------------
--Player_GetMajorityReligion
function Player_GetMajorityReligion(player)
	local religionID = -1
	if player:HasCreatedReligion() then
		religionID = player:GetReligionCreatedByPlayer()
		if religionID > -1 then
			return religionID
		end
		for row in GameInfo.Religions() do
			if player:HasReligionInMostCities(row.ID) then
				religionID = row.ID
				break
			end
		end
		if religionID > -1 then
			return religionID
		end
	end
	return religionID
end
-------------------------------------------------------------------------------------------------------------------------
--Player_GetMainReligion
function Player_GetMainReligion(player)
	local mainReligionID = player:GetReligionCreatedByPlayer()
	if Player.GetCurrentStateReligion then
		mainReligionID = player:GetCurrentStateReligion()
	else
		if mainReligionID == -1 then
			local playerCapital = player:GetCapitalCity()
			if playerCapital then
				mainReligionID = playerCapital:GetReligiousMajority()
			end
		end
	end
	if mainReligionID == -1 and (not ignorePantheon) then
		mainReligionID = 0
	end
	return mainReligionID
end
-------------------------------------------------------------------------------------------------------------------------
--SCORE/RANK UTILS
-------------------------------------------------------------------------------------------------------------------------
--JFD_GetScoreRank
local rankColours = {}
	rankColours[1] = "COLOR_RANK_GOLD"
	rankColours[2] = "COLOR_RANK_SILVER"
	rankColours[3] = "COLOR_RANK_BRONZE"
	rankColours[64] = "COLOR_RANK_COAL"
function JFD_GetScoreRank(player)
	local rankTable = {}

	local numScore = player:GetScore()
	--local numHappiness = player:GetExcessHappiness()
	--local numFood = player:CalculateTotalYield(YieldTypes.YIELD_FOOD)
	--local numGold = player:CalculateGrossGold()
	--local numProd = player:CalculateTotalYield(YieldTypes.YIELD_PRODUCTION)
	--local numTech = Teams[player:GetTeam()]:GetTeamTechs():GetTechCount()
	--local numLand = (player:GetNumPlots() * 10000)
	--local numMil = math.sqrt( player:GetMilitaryMight() ) * 2000;
	--local numPop = player:GetRealPopulation() 

	local numScoreRank = 1
	--local numHappinessRank = 1
	--local numFoodRank = 1
	--local numGoldRank = 1
	--local numProdRank = 1
	--local numTechRank = 1
	--local numLandRank = 1
	--local numMilRank = 1
	--local numPopRank = 1

	local numScoreRankColour 
	--local numHappinessRankColour 
	--local numFoodRankColour 
	--local numGoldRankColour 
	--local numProdRankColour 
	--local numTechRankColour 
	--local numLandRankColour 
	--local numMilRankColour 
	--local numPopRankColour 

	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		
		local pOtherPlayer = Players[iPlayerLoop];
		if (pOtherPlayer:IsEverAlive()) then

			if pOtherPlayer:GetScore() > numScore then
				numScoreRank = numScoreRank + 1
			end
			--if pOtherPlayer:GetExcessHappiness() > numHappiness then
			--	numHappinessRank = numHappinessRank + 1
			--end
			--if pOtherPlayer:CalculateTotalYield(YieldTypes.YIELD_FOOD) > numFood then
			--	numFoodRank = numFoodRank + 1
			--end
			--if pOtherPlayer:CalculateGrossGold() > numGold then
			--	numGoldRank = numGoldRank + 1
			--end
			--if pOtherPlayer:CalculateTotalYield(YieldTypes.YIELD_PRODUCTION) > numProd then
			--	numProdRank = numProdRank + 1
			--end
			--if Teams[pOtherPlayer:GetTeam()]:GetTeamTechs():GetTechCount() > numTech then
			--	numTechRank = numTechRank + 1
			--end
			--if pOtherPlayer:GetNumPlots() > numLand then
			--	numLandRank = numLandRank + 1
			--end
			--if pOtherPlayer:GetMilitaryMight() > numMil then
			--	numMilRank = numMilRank + 1
			--end
			--if pOtherPlayer:GetRealPopulation() > numPop then
			--	numPopRank = numPopRank + 1
			--end

		end
	end

	rankTable.NumScore = numScore
	rankTable.NumScoreRank = numScoreRank
	rankTable.NumScoreRankColour = (rankColours[numScoreRank] or "COLOR_RANK_IRON")
	--rankTable.NumHappiness = numHappiness
	--rankTable.NumHappinessRank = numHappinessRank
	--rankTable.NumHappinessRankColour = (rankColours[numHappinessRank] or "COLOR_RANK_IRON")
	--rankTable.NumFood = numFood
	--rankTable.NumFoodRank = numFoodRank
	--rankTable.NumFoodRankColour = (rankColours[numFoodRank] or "COLOR_RANK_IRON")
	--rankTable.NumGold = numGold
	--rankTable.NumGoldRank = numGoldRank
	--rankTable.NumGoldRankColour = (rankColours[numGoldRank] or "COLOR_RANK_IRON")
	--rankTable.NumProduction = numProd
	--rankTable.NumProductionRank = numProdRank
	--rankTable.NumProductionRankColour = (rankColours[numProdRank] or "COLOR_RANK_IRON")
	--rankTable.NumTech = numTech
	--rankTable.NumTechRank = numTechRank
	--rankTable.NumTechRankColour = (rankColours[numTechRank] or "COLOR_RANK_IRON")
	--rankTable.NumLand = numLand
	--rankTable.NumLandRank = numLandRank
	--rankTable.NumLandRankColour = (rankColours[numLandRank] or "COLOR_RANK_IRON")
	--rankTable.NumMilitary = numMil
	--rankTable.NumMilitaryRank = numMilRank
	--rankTable.NumMilitaryRankColour = (rankColours[numMilRank] or "COLOR_RANK_IRON")
	--rankTable.NumPopulation = numPop
	--rankTable.NumPopulationRank = numPopRank
	--rankTable.NumPopulationRankColour = (rankColours[numPopRank] or "COLOR_RANK_IRON")

	return rankTable
end
--=======================================================================================================================
-- CITY UTILITIES
--=======================================================================================================================
-------------------------------------------------------------------------------------------------------------------------
--CITY DESC UTILS
-------------------------------------------------------------------------------------------------------------------------
--Player:GetCityDescriptor
local g_JFD_CityDescriptors_Table = {}
local g_JFD_CityDescriptors_Count = 1
for row in DB.Query("SELECT * FROM JFD_CityDescriptors;") do 	
	g_JFD_CityDescriptors_Table[g_JFD_CityDescriptors_Count] = row
	g_JFD_CityDescriptors_Count = g_JFD_CityDescriptors_Count + 1
end

function Player.GetCityDescriptor(player, city)
	local playerID = player:GetID()
	local playerTeamID = player:GetTeam()
	local playerTeam = Teams[playerTeamID]

	local civAdj = player:GetCivilizationAdjective()
	local civilizationID = player:GetCivilizationType()
	local cityPop = city:GetPopulation()

	local strDesc
	local strAdj
	local strDescriptor
	
	--g_JFD_CityDescriptors_Table
	local cityDescriptorsTable = g_JFD_CityDescriptors_Table
	local numCityDescriptors = #cityDescriptorsTable
	for index = 1, numCityDescriptors do
		local row = cityDescriptorsTable[index]

		if (not row.PrereqCiv) or (row.PrereqCiv and GameInfoTypes[row.PrereqCiv] == civilizationID) then

			--ADJ
			if row.IsResistance and city:IsResistance() then
				strAdj = Locale.ConvertTextKey(row.Adjective)
			--elseif row.IsColony and City.IsColony then
			--	if city:IsColony() then
			--		strAdj = Locale.ConvertTextKey(row.Adjective)
			--	end
			elseif row.IsPuppet and city:IsPuppet() then
				strAdj = Locale.ConvertTextKey(row.Adjective)
			end

			if row.IsOccupied then
				local originalOwnerID = city:GetOriginalOwner()
				if originalOwnerID ~= playerID then
					local originalOwner = Players[originalOwnerID]
					local originalTeamID = originalOwner:GetTeam()
					local originalTeam = Teams[originalTeamID]
					if ((not originalTeam:IsForcePeace(playerTeamID)) and (not playerTeam:IsForcePeace(originalTeamID))) then
						if strAdj then
							strAdj = strAdj .. " " .. Locale.ConvertTextKey(row.Adjective, civAdj)
						else
							strAdj = Locale.ConvertTextKey(row.Adjective, civAdj)
						end
					end
				end
			end

			--DESC
			local minPop = row.MinPop
			local maxPop = row.MaxPop
			if minPop and cityPop >= minPop then
				if (maxPop and cityPop <= maxPop) or (not maxPop) then
					strDesc = Locale.ConvertTextKey(row.Description)
				end
			end
		end
	end
	
	--strDescriptor = Locale.ConvertTextKey("TXT_KEY_JFD_CITY_DESCRIPTOR_THE")
	strDescriptor = civAdj
	if strAdj then
		strDescriptor = strDescriptor .. " " .. strAdj
	end
	strDescriptor = strDescriptor .. " " .. strDesc
	strDescriptor = strDescriptor .. " " .. Locale.ConvertTextKey("TXT_KEY_JFD_CITY_DESCRIPTOR_OF")

	return strDescriptor
end
--=======================================================================================================================
--=======================================================================================================================