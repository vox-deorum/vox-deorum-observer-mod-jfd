-- JFD_Utils_OverlayMaps
-- Author: JFD
-- DateCreated: 4/30/2019 8:35:10 AM
--==========================================================================================================================
-- INCLUDES
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
--==========================================================================================================================
-- GLOBALS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
local g_ConvertTextKey  = Locale.ConvertTextKey
local g_GetRandom		= Game.GetRandom
local g_GetRound		= Game.GetRound
local g_MapGetPlot		= Map.GetPlot
local g_MathCeil		= math.ceil
local g_MathFloor		= math.floor
local g_MathMax			= math.max
local g_MathMin			= math.min
				
local Players 			= Players
local HexToWorld 		= HexToWorld
local ToHexFromGrid 	= ToHexFromGrid
local Teams 			= Teams

local gameSpeedID		= Game.GetGameSpeedType()
local gameSpeed			= GameInfo.GameSpeeds[gameSpeedID]
local gameSpeedMod		= (gameSpeed.BuildPercent/100) 

local handicapID		= Game.GetHandicapType()
local handicap			= GameInfo.HandicapInfos[handicapID]

local defineMaxMajorCivs = GameDefines["MAX_MAJOR_CIVS"]
local defineMaxMinorCivs = GameDefines["MAX_MINOR_CIVS"]
--==========================================================================================================================
-- CACHED TABLES
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
--==========================================================================================================================
-- ACTIVE MODS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
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
	
	--Game.IsJFDLLActive
	function Game.IsJFDLLActive()
		return Game_IsModActive("dedf47d7-6428-4e62-b48e-18e07e4fcc53")
	end
	
	--Game.IsVMCDLLActive
	function Game.IsVMCDLLActive()
		return Game_IsModActive("d1b6328c-ff44-4b0d-aad7-c657f83610cd")
	end
	
	--Game.IsCulDivActive
	function Game.IsCulDivActive()
		return Game_IsModActive("31a31d1c-b9d7-45e1-842c-23232d66cd47")
	end
	
	--Game.IsSovereigntyActive
	function Game.IsSovereigntyActive()
		return Game_IsModActive("d769cac9-5608-4826-9f7f-2d308b287ea6")
	end
end
----------------------------------------------------------------------------------------------------------------------------
local isJFDLLActive = Game.IsJFDLLActive()
local isVMCDLLActive = (isJFDLLActive or Game.IsVMCDLLActive())
--==========================================================================================================================
-- MATH UTILS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
--Game.GetRound
function Game.GetRound(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end
local g_GetRound = Game.GetRound
--==========================================================================================================================
-- RANKING UTILS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
--Player:GetValueForRankForOverlayMap
function Player.GetValueForRankForOverlayMap(player, overlayMapID)
	local playerID = player:GetID()
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayLegendRankings = GameInfo.JFD_OverlayMap_Rankings("OverlayMapType = '" .. overlayMapType .. "'")()
	local numVal = 0
	if player:IsAlive() then	
		local iTeam = player:GetTeam()
		local pTeam = Teams[iTeam];
		local pTeamTechs = pTeam:GetTeamTechs()
		if overlayMapLegend.IsNumLand then
			numVal = (player:GetNumPlots() * 10000)
		elseif overlayMapLegend.IsNumFood then
			numVal = player:CalculateTotalYield(YieldTypes.YIELD_FOOD);
		elseif overlayMapLegend.IsNumHappiness then
			numVal = player:GetExcessHappiness()
		elseif overlayMapLegend.IsNumProduction then
			numVal = player:CalculateTotalYield(YieldTypes.YIELD_PRODUCTION);
		elseif overlayMapLegend.IsNumMilStrength then
			numVal = math.sqrt( player:GetMilitaryMight() ) * 2000;
		elseif overlayMapLegend.IsNumPopulation then
			numVal = player:GetRealPopulation() 
		elseif overlayMapLegend.IsNumTechs then
			numVal = Teams[player:GetTeam()]:GetTeamTechs():GetTechCount()
		elseif overlayMapLegend.IsNumGold then
			numVal = player:CalculateGrossGold() 
		end
	end
	return numVal
end
----------------------------------------------------------------------------------------------------------------------------
--GetColourAdjustedForRank
function GetColourAdjustedForRank(colour, rank, rankHighestVal, rankTotal, rankVal) 
	local rankPercentMod = 1
	if rankVal == 0 and rankHighestVal == 0 then
		rankPercentMod = 0
	else
		rankPercentMod = g_GetRound((rankVal/rankHighestVal),2)
	end
	rankPercentMod = (rankPercentMod*100)		
	
	return {Red = Game.GetRound(((colour.Red*rankPercentMod)/100),2), Green = Game.GetRound(((colour.Green*rankPercentMod)/100),2), Blue = Game.GetRound(((colour.Blue*rankPercentMod)/100),2), colour.Alpha}
end
--==========================================================================================================================
-- OVERLAY MAPS UTILS
--==========================================================================================================================
--JFD_GetNumResearchAgreements
function JFD_GetNumResearchAgreements(iTeam)
	local team = Teams[iTeam]
	local numRAs = 0
	
	for otherPlayerID = 0, defineMaxMajorCivs do
		local otherPlayer = Players[otherPlayerID]
		if otherPlayer:IsAlive() then
			local otherTeamID = otherPlayer:GetTeam()
			if team:IsHasResearchAgreement(otherTeamID) then
				numRAs = numRAs + 1
			end
		end
	end
	
	return numRAs 
end
----------------------------------------------------------------------------------------------------------------------------
-- OVERLAY LEGEND UTILS
----------------------------------------------------------------------------------------------------------------------------
--GetOverlayMapLegend
function GetOverlayMapLegend(overlayMapID, overlayMapFilterID, overlayMapFilterPlayerID, overlayMapFilterTeamID, iPlayer, iTeam, pCity, pPlot, pUnit, iReligion)
	local pPlayer = Players[iPlayer]
	local pTeam = Teams[iTeam]
	local iFilterPlayer = overlayMapFilterPlayerID 
	local pFilterPlayer 
	local iFilterTeam = overlayMapFilterTeamID 
	local pFilterTeam 
	if iFilterPlayer ~= -1 then
		pFilterPlayer = Players[iFilterPlayer]
	end
	if iFilterTeam ~= -1 then
		pFilterTeam = Teams[iFilterTeam]
	end
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	----------------------------------------------------------------------		
	--PLAYERS
	----------------------------------------------------------------------
	if overlayMap.IsPlayerBorder and pPlayer then
		return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerBorder = 1")().LegendType
	-----------------------------------		
	--PLAYERS: CULTURE
	-----------------------------------
	elseif overlayMap.IsPlayerCultureType and Player.GetCultureType then
		local iCultureType = pPlayer:GetCultureType()
		if iCultureType > 0 then
			local pCultureType = GameInfo.JFD_Cultures[iCultureType].Type
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerCultureType = '" .. pCultureType .. "'")().LegendType
		end
	elseif overlayMap.IsPlayerSubCultureType and Player.GetCultureType then
		local iCultureType, iSubCultureType = pPlayer:GetCultureType()
		if iSubCultureType then
			local pSubCultureType = GameInfo.JFD_CultureSubTypes[iSubCultureType].Type
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerSubCultureType = '" .. pSubCultureType .. "'")().LegendType
		elseif iCultureType > 0 then
			local pCultureType = GameInfo.JFD_Cultures[iCultureType],Type
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerSubCultureType = '" .. pCultureType .. "'")().LegendType
		end
	-----------------------------------		
	--PLAYERS: GOVERNMENT
	-----------------------------------
	elseif overlayMap.IsPlayerGovernmentType and Player.GetCurrentGovernment then
		if (not pPlayer:IsMinorCiv()) then
			local iGovernmentType = pPlayer:GetCurrentGovernment()
			if iGovernmentType > -1 then
				local pGovernmentType = GameInfo.JFD_Governments[iGovernmentType].Type
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerGovernmentType = '" .. pGovernmentType .. "'")().LegendType
			end
		else
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerGovernmentType = 'GOVERNMENT_JFD_CITY_STATE'")().LegendType
		end
	-----------------------------------		
	--PLAYERS: GROWTH
	-----------------------------------
	elseif overlayMap.IsPlayerGrowth then
		local iNumWLTKD = 0
		local iNumGrowing = 0
		local iNumStagnant = 0
		local iNumStarving = 0
		for pOtherCity in pPlayer:Cities() do
			local iFoodDiff = pOtherCity:FoodDifference()
			if pOtherCity:GetWeLoveTheKingDayCounter() > 0 then
				iNumWLTKD = iNumWLTKD + 1
			elseif iFoodDiff < 0 then
				iNumStarving = iNumStarving + 1
			elseif iFoodDiff == 0 then
				iNumStagnant = iNumStagnant + 1
			else
				iNumGrowing = iNumGrowing + 1
			end
		end
		if (iNumWLTKD+iNumGrowing) > (iNumStagnant+iNumStarving) then
			if iNumWLTKD > iNumGrowing then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerGrowthVPos = 1")().LegendType
			else
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerGrowthPos = 1")().LegendType
			end
		else
			if iNumStagnant > iNumStarving then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerGrowthNeu = 1")().LegendType
			else
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerGrowthNeg = 1")().LegendType
			end
		end
	-----------------------------------		
	--PLAYERS: HAPPINESS
	-----------------------------------
	elseif overlayMap.IsPlayerHappiness then
		if pPlayer:IsGoldenAge() then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerGoldenAge = '1'")().LegendType
		elseif pPlayer:IsAnarchy() then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerAnarchy = '1'")().LegendType
		elseif pPlayer:IsEmpireSuperUnhappy() then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerSuperUnhappy = '1'")().LegendType
		elseif pPlayer:IsEmpireVeryUnhappy() then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerVeryUnhappy = '1'")().LegendType
		elseif pPlayer:IsEmpireUnhappy() then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerUnhappy = '1'")().LegendType
		else
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerHappy = '1'")().LegendType
		end
	-----------------------------------		
	--PLAYERS: IDEOLOGY
	-----------------------------------
	elseif overlayMap.IsPlayerIdeology then
		local iIdeologyType
		if Player.GetIdeology then
			iIdeologyType = pPlayer:GetIdeology()
		else
			iIdeologyType = pPlayer:GetLateGamePolicyTree()
		end
		if iIdeologyType > -1 then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerIdeology = '1'")().LegendType
		else
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerIdeologyNOT = '1'")().LegendType
		end
	elseif overlayMap.IsPlayerIdeologyType then
		local iIdeologyType
		if Player.GetIdeology then
			iIdeologyType = pPlayer:GetIdeology()
		else
			iIdeologyType = pPlayer:GetLateGamePolicyTree()
		end
		if iIdeologyType > -1 then
			local pIdeologyType = GameInfo.PolicyBranchTypes[iIdeologyType].Type
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerIdeologyType = '" .. pIdeologyType .. "'")().LegendType
		else
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerIdeologyNOT = '1'")().LegendType
		end
	-----------------------------------		
	--PLAYERS: RELIGION
	-----------------------------------
	elseif overlayMap.IsPlayerReligion then
		local iReligion = player:GetReligionCreatedByPlayer()
		if iReligion <= 0 then
			if Player.GetMajorityReligion then
				return player:GetMajorityReligion()
			else
				for religion in GameInfo.Religions("ID > 0") do
					local religionID = religion.ID
					for city in player:Cities() do
						if city:GetNumFollowers(religionID) > 0 then
							if city:HasReligionInMostCities(religionID) then
								return religionID
							end
						end
					end
				end
			end
		end
		if iReligion > 0 then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerReligionType = '1'")().LegendType
		end
	-----------------------------------		
	--PLAYERS: TECHNOLOGY
	-----------------------------------
	elseif overlayMap.IsPlayerTechnology then
		if pPlayer:GetScience() < 0 then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerTechnologyNeg = 1")().LegendType
		else
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerTechnologyPos = '1'")().LegendType
		end
	elseif overlayMap.IsPlayerTechnologyEraType then
		local iEraType = pPlayer:GetCurrentEra()
		if iEraType >= 0 then
			local pEraType = GameInfo.Eras[iEraType].Type
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerEraType = '" .. pEraType .. "'")().LegendType
		end
	-----------------------------------		
	--PLAYERS: TREASURY
	-----------------------------------
	elseif overlayMap.IsPlayerTreasury then
		local iGoldRate = pPlayer:CalculateGoldRate()
		if iGoldRate < 0 and pPlayer:GetGold() <= 0 then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerTreasuryVNeg = 1")().LegendType
		elseif iGoldRate < 0 then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerTreasuryNeg = 1")().LegendType
		elseif iGoldRate == 0 then
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerTreasuryNeu = 1")().LegendType
		else
			return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsPlayerTreasuryPos = '1'")().LegendType
		end
	----------------------------------------------------------------------		
	--DIPLOMACY
	----------------------------------------------------------------------
	elseif overlayMap.IsDiplomacyRelation then
		if pFilterTeam then
			if pPlayer:IsMinorCiv() then
				-- local iMinorCivApproach = pFilterPlayer:GetApproachTowardsUsGuess(iPlayer)
				-- local pMinorCivApproachType = GameInfo.MinorCivApproachTypes[iMinorCivApproach].Type
				-- return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyApproach = '" .. pMajorCivApproachType .. "'")().LegendType
			else
				if (not pFilterTeam:IsHasMet(iTeam)) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyApproach = 'MAJOR_CIV_RELATIONS_UNMET'")().LegendType
				elseif pFilterTeam:IsAtWar(iTeam) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyApproach = 'MAJOR_CIV_RELATIONS_WAR'")().LegendType
				elseif pPlayer:IsDenouncingPlayer(iFilterPlayer) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyApproach = 'MAJOR_CIV_RELATIONS_DENOUNCING'")().LegendType
				-- elseif pPlayer:WasResurrectedThisTurnBy(iFilterPlayer) then
					-- return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyApproach = 'MAJOR_CIV_RELATIONS_LIBERATED'")().LegendType
				else
					local iMajorCivApproach = pFilterPlayer:GetApproachTowardsUsGuess(iPlayer)
					local pMajorCivApproachType = GameInfo.MajorCivApproachTypes[iMajorCivApproach].Type
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyApproach = '" .. pMajorCivApproachType .. "'")().LegendType
				end
			end
		end
	elseif overlayMap.IsDiplomacyDefensivePact then
		if pFilterTeam then
			if iPlayer == iFilterPlayer then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyUs = 1")().LegendType
			else
				if pTeam:IsDefensivePact(iFilterTeam) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyDefensivePact = 1")().LegendType
				else
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyDefensivePactNOT = 1")().LegendType
				end
			end
		else
			if pTeam:GetDefensivePactCount() > 0 then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyDefensivePact = 1")().LegendType
			else
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyDefensivePactNOT = 1")().LegendType
			end
		end
	elseif overlayMap.IsDiplomacyDOF then
		if pFilterTeam then
			if iPlayer == iFilterPlayer then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyUs = 1")().LegendType
			else
				if pPlayer:IsDoF(iFilterPlayer) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyDOF = 1")().LegendType
				else
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyDOFNOT = 1")().LegendType
				end
			end
		end
	elseif overlayMap.IsDiplomacyEmbassyFrom then
		if pFilterTeam then
			if iPlayer == iFilterPlayer then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyUs = 1")().LegendType
			else
				if pTeam:HasEmbassyAtTeam(iFilterTeam) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyEmbassyFrom = 1")().LegendType
				else
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyEmbassyNOT = 1")().LegendType
				end
			end
		end
	elseif overlayMap.IsDiplomacyEmbassyTo then
		if pFilterTeam then
			if iPlayer == iFilterPlayer then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyUs = 1")().LegendType
			else
				if pFilterTeam:HasEmbassyAtTeam(iTeam) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyEmbassyTo = 1")().LegendType
				else
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyEmbassyNOT = 1")().LegendType
				end
			end
		end
	elseif overlayMap.IsDiplomacyOpenBordersFrom then
		if pFilterTeam then
			if iPlayer == iFilterPlayer then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyUs = 1")().LegendType
			else
				if pPlayer:IsPlayerHasOpenBorders(iFilterPlayer) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyOpenBordersFrom = 1")().LegendType
				else
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyOpenBordersNOT = 1")().LegendType
				end
			end
		end
	elseif overlayMap.IsDiplomacyOpenBordersTo then
		if pFilterTeam then
			if iPlayer == iFilterPlayer then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyUs = 1")().LegendType
			else
				if pFilterPlayer:IsPlayerHasOpenBorders(iPlayer) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyOpenBordersTo = 1")().LegendType
				else
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyOpenBordersNOT = 1")().LegendType
				end
			end
		end
	elseif overlayMap.IsDiplomacyResearchAgreement then
		if pFilterTeam then
			if iPlayer == iFilterPlayer then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyUs = 1")().LegendType
			else
				if pTeam:IsHasResearchAgreement(iFilterTeam) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyResearchAgreement = 1")().LegendType
				else
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyResearchAgreementNOT = 1")().LegendType
				end
			end
		else
			if JFD_GetNumResearchAgreements(iTeam) > 0 then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyResearchAgreement = 1")().LegendType
			else
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyResearchAgreementNOT = 1")().LegendType
			end
		end
	elseif overlayMap.IsDiplomacyWarPeace then
		if pFilterTeam then
			if iPlayer == iFilterPlayer then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyUs = 1")().LegendType
			else
				if pTeam:IsAtWar(iFilterTeam) then
					return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyWar = 1")().LegendType
				else
					if pTeam:IsForcePeace(iFilterTeam) then
						return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyPeaceForced = 1")().LegendType
					else
						return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyPeace = 1")().LegendType
					end
				end
			end
		else
			if pTeam:GetAtWarCount(false) > 0 then
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyWar = 1")().LegendType
			else
				return GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "' AND IsDiplomacyPeace = 1")().LegendType
			end
		end
	end
end
--==========================================================================================================================
--==========================================================================================================================