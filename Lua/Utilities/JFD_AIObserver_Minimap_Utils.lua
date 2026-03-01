-- JFD_AIObserver_Minimap_Utils
-- Author: JFD
-- DateCreated: 3/15/2024 9:15:12 AM
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
	
	--Game.IsDarkAgesActive
	function Game.IsDarkAgesActive()
		return Game_IsModActive("71600d15-1646-4cfc-b6c8-79efa0021724")
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
----------------------------------------------------------------------------------------------------------------------------
--==========================================================================================================================
-- MINIMAP UTILS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
--JFD_GetMiniMapLegend
function JFD_GetMiniMapLegend(miniMapID, playerID, iFilterPlayer)
	local miniMap = GameInfo.JFD_MinimapOverlays[miniMapID]
	local miniMapType = miniMap.Type
	if miniMap.IsDefault then
		return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsPlayer = 1")()
	else
		local pPlayer = Players[playerID]
		if miniMap.IsCultureTypes and Player.GetCultureType then
			local iCultureType = pPlayer:GetCultureType()
			if iCultureType > 0 then
				local pCultureType = GameInfo.JFD_CultureTypes[iCultureType].Type
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = '" .. pCultureType .. "'")()
			end
		elseif miniMap.IsEras then
			local iEraType = pPlayer:GetCurrentEra()
			local pEraType = GameInfo.Eras[iEraType].Type
			return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = '" .. pEraType .. "'")()
		elseif miniMap.IsGovernments and Player.GetCurrentGovernment then
			if pPlayer:IsMinorCiv() then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'GOVERNMENT_JFD_CITY_STATE'")()
			else
				local iGovType = pPlayer:GetCurrentGovernment()
				local pGovType = GameInfo.JFD_Governments[iGovType].Type
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = '" .. pGovType .. "'")()
			end
		elseif miniMap.IsFactions and Player.GetDominantFaction then
			if pPlayer:IsMinorCiv() then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'FACTION_JFD_TRADITIONAL'")()
			else
				local iFactType = pPlayer:GetDominantFaction()
				if iFactType > -1 then
					local pFactType = GameInfo.JFD_Factions[iFactType].Type
					local pLegendType = GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = '" .. pFactType .. "'")()
					if pLegendType then
						return pLegendType
					else
						return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'FACTION_JFD_TRADITIONAL'")()
					end
				else
					return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'FACTION_JFD_TRADITIONAL'")()
				end
			end
		elseif miniMap.IsIdeologies then
			local iIdeologyType = -1
			if Player.GetIdeology then
				iIdeologyType = pPlayer:GetIdeology()
			else
				iIdeologyType = pPlayer:GetLateGamePolicyTree()
			end
			if iIdeologyType == -1 then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'POLICY_BRANCH_NONE'")()
			else
				local pIdeologyType = GameInfo.PolicyBranchTypes[iIdeologyType].Type
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = '" .. pIdeologyType .. "'")()
			end
		elseif miniMap.IsRelations and iFilterPlayer then
			local iTeam = pPlayer:GetTeam()
			local pTeam = Teams[iTeam]
			local pFilterPlayer = Players[iFilterPlayer]
			local iFilterTeam = pFilterPlayer:GetTeam()
			local pFilterTeam = Teams[iFilterTeam]
			if playerID == iFilterPlayer then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'RELATION_US'")()
			elseif (not pFilterTeam:IsHasMet(iTeam)) then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'RELATION_UNMET'")()
			elseif pFilterTeam:IsAtWar(iTeam) then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'RELATION_WAR'")()
			elseif pPlayer:IsDenouncingPlayer(iFilterPlayer) then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'RELATION_ENEMIES'")()
			elseif pFilterTeam:IsDefensivePact(iTeam) or pPlayer:IsAllies(iFilterPlayer) then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'RELATION_ALLIES'")()
			elseif pPlayer:IsDoF(iFilterPlayer) or pPlayer:IsFriends(iFilterPlayer) then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'RELATION_FRIENDS'")()
			else
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'RELATION_NEUTRAL'")()
			end
		elseif miniMap.IsStability then
			if Player.IsDarkAge and pPlayer:IsDarkAge() then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'STABILITY_DARK_AGE'")()
			elseif pPlayer:IsGoldenAge() then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'STABILITY_GOLDEN_AGE'")()
			elseif pPlayer:IsAnarchy() then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'STABILITY_ANARCHY'")()
			elseif pPlayer:IsEmpireSuperUnhappy() then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'STABILITY_REBELLION'")()
			elseif pPlayer:IsEmpireVeryUnhappy() then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'STABILITY_V_UNSTABLE'")()
			elseif pPlayer:IsEmpireUnhappy() then
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'STABILITY_UNSTABLE'")()
			else
				return GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "' AND IsType = 'STABILITY_STABLE'")()
			end
		end
	end
end
--==========================================================================================================================
--==========================================================================================================================


