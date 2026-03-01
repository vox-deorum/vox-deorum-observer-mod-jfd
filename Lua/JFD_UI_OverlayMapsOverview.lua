-------------------------------------------------
-- OverlayMaps Overview Popup
-------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );
include( "JFD_OverlayMaps_Utils.lua" );

local isBNW = ContentManager.IsActive("6DA07636-4123-4018-B643-6575B4EC336B", ContentType.GAMEPLAY)
local isJFDLLActive = Game.IsJFDLLActive()
-------------------------------------------------
-- Global Constants
-------------------------------------------------

local DefaultColours = {
  UNKNOWN   = {Red=190, Green=190, Blue=190, Alpha=1.0},
  NONE      = {Red=0,   Green=0,   Blue=0,   Alpha=0.0},
  LAND      = {Red=90,   Green=131,   Blue=65,   Alpha=1.0},
  MOUNTAIN      = {Red=89,   Green=118,   Blue=74,   Alpha=1.0},
  WATER     = {Red=88,   Green=128,   Blue=143,   Alpha=1.0},
  COAST     = {Red=95,   Green=137,   Blue=155,   Alpha=1.0},
  OCEAN     = {Red=88,   Green=128,   Blue=143,   Alpha=1.0},
  ICE       = {Red=189, Green=242, Blue=255, Alpha=0.7},
  CITY      = {Red=255,   Green=255,   Blue=255,   Alpha=1.0},
  CAPITAL_CITY  = {Red=208,   Green=208,   Blue=208,   Alpha=1.0},
  HOLY_CITY = {Red=255, Green=255, Blue=0,   Alpha=1.0}
}
local Colours = {}

local iFeatureIce = GameInfoTypes.FEATURE_ICE
local iTerrainCoast = GameInfoTypes.TERRAIN_COAST
local iTerrainOcean = GameInfoTypes.TERRAIN_OCEAN
local iTerrainDesert = GameInfoTypes.TERRAIN_DESERT

local mapWidth, mapHeight = Map.GetGridSize()
Controls.Map:SetMapSize(mapWidth, mapHeight, 0,-1)

g_LegendInstanceManager = InstanceManager:new("LegendInstance", "LegendButton", Controls.LegendStack);
g_LegendPlayerInstanceManager = InstanceManager:new("PlayerInstance", "PlayerButton", Controls.LegendPlayersStack);
g_LegendBarbPlayerInstanceManager = InstanceManager:new("PlayerInstance", "PlayerButton", Controls.LegendBarbPlayersStack);
g_LegendMinorPlayerInstanceManager = InstanceManager:new("PlayerInstance", "PlayerButton", Controls.LegendMinorPlayersStack);
g_LegendReligionInstanceManager = InstanceManager:new("ReligionInstance", "ReligionButton", Controls.LegendReligionsStack);

local iCBRXWidth, iCBRXHeight = 180,94
local iMainGridCBRX, iMainGridCBRY = 1110,653
local iMapCBRX, iMapCBRXY = -50,15
local iScrollGridCBRX, iScrollGridCBRY = -40,15
local iShowPlayersButtonCBRX, iShowPlayersButtonCBRY = -40,25
local iOverlayClassPulldownCBRX, iOverlayClassPulldownCBRY = -56,-10
local iOverlayFilterPulldownCBRX, iOverlayFilterPulldownCBRY = -15,38
local iHorizontalTrimTopCBRSizeX, iHorizontalTrimTopCBRSizeY = 1030,5
local iHorizontalTrimTopCBRX, iHorizontalTrimTopCBRY = 0,25
local iBottomTrimTopCBRX, iBottomTrimTopCBRY = 1030,5
local iCloseButtonCBRX, iCloseButtonCBRY = -65,54
local iMapSubPulldownCBRX, iMapSubPulldownCBRY = 120,-10

if mapWidth == iCBRXWidth and mapHeight == iCBRXHeight then
	-- if Controls.MainGrid:GetSizeX() ~= iMainGridCBRX and Controls.MainGrid:GetSizeY() ~= iMainGridCBRY then
		Controls.MainGrid:SetSizeVal(iMainGridCBRX, iMainGridCBRY)
		Controls.Map:SetOffsetVal(iMapCBRX,iMapCBRXY)
		Controls.ScrollGrid:SetOffsetVal(iScrollGridCBRX,iScrollGridCBRY)
		Controls.ShowPlayersButton:SetOffsetVal(iShowPlayersButtonCBRX,iShowPlayersButtonCBRY)
		Controls.OverlayMapClassesPullDown:SetOffsetVal(iOverlayClassPulldownCBRX,iOverlayClassPulldownCBRY)
		Controls.OverlayMapFilerPulldownStack:SetOffsetVal(iOverlayFilterPulldownCBRX,iOverlayFilterPulldownCBRY)
		Controls.OverlayMapSubsPulldownStack:SetOffsetVal(iMapSubPulldownCBRX,iMapSubPulldownCBRY)
		Controls.HorizontalTrimTop:SetSizeVal(iHorizontalTrimTopCBRSizeX,iHorizontalTrimTopCBRSizeY)
		Controls.HorizontalTrimTop:SetOffsetVal(iHorizontalTrimTopCBRX,iHorizontalTrimTopCBRY)
		Controls.CloseButtonBox:SetOffsetVal(iCloseButtonCBRX,iCloseButtonCBRY)
		Controls.MapTrimBottom:SetSizeVal(iBottomTrimTopCBRX,iBottomTrimTopCBRY)
	-- end
end
-------------------------------------------------
-- Global Variables
-------------------------------------------------
local g_SelectedOverlayMapID = -1
local g_SelectedOverlayMapClassID = -1
local g_SelectedOverlayMapSubID = -1
local g_SelectedOverlayMapFilterID = -1
local g_SelectedOverlayMapFilterPlayerID = -1
local g_SelectedOverlayMapFilterTeamID = -1

local g_SelectedMapOverlayPlayers = nil
local g_SelectedMapOverlayOptions = {}

local numHeadersOpen = 0
local numPlayers = 0
local numMinorPlayers = 0
local numBarbPlayers = 0
local numReligions = 0
local numLegends = 0
	
local isCivHeaderOpen = true
local isCSHeaderOpen = false
local isLegendHeaderOpen = false
local isOptionsHeaderOpen = false
local isReliHeaderOpen = false
local isBarbHeaderOpen = false
local isShowPlayers = false
-------------------------------------------------
-------------------------------------------------

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function IgnoreLeftClick( Id )
	-- just swallow it
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function InputHandler( uiMsg, wParam, lParam )
    ----------------------------------------------------------------        
    -- Key Down Processing
    ----------------------------------------------------------------        
    if(uiMsg == KeyEvents.KeyDown) then
        if (wParam == Keys.VK_ESCAPE) then
			OnClose();
			return true;
        end
        
        -- Do Nothing.
        if(wParam == Keys.VK_RETURN) then
			return true;
        end
    end
end
ContextPtr:SetInputHandler( InputHandler );
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function OnClose()
	UIManager:DequeuePopup(ContextPtr);
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose);
-------------------------------------------------------------------------------
--PLAYERS
-------------------------------------------------------------------------------
local g_PlayerLegendsTable = {}
local g_ReligionLegendsTable = {}
local g_SortedPlayerEntryTable = {}
local g_SortedPlayerPlusBarbsEntryTable = {}
local g_SortedBarbarianPlayerEntryTable = {}
local g_SortedMajorPlayerEntryTable = {}
local g_SortedMinorPlayerEntryTable = {}
function PopulateSortedPlayers()
	local iActivePlayer = Game.GetActivePlayer()
	local pActivePlayer = Players[iActivePlayer]
	local sActivePlayerDesc = Locale.ConvertTextKey("{Civ} ([COLOR_POSITIVE_TEXT]YOU[ENDCOLOR])", pActivePlayer:GetCivilizationShortDescription())
	
	for iPlayer=0, GameDefines.MAX_CIV_PLAYERS do	
		local pPlayer = Players[iPlayer]
		-- if pPlayer:IsEverAlive() and iPlayer ~= iActivePlayer then
		if pPlayer:IsEverAlive() then
			local civDesc = pPlayer:GetCivilizationShortDescription()
			if pPlayer:IsMinorCiv() then
				table.insert(g_SortedMinorPlayerEntryTable, {iPlayer, civDesc})
			elseif pPlayer:IsBarbarian() then
				table.insert(g_SortedBarbarianPlayerEntryTable, {iPlayer, civDesc})
			else
				table.insert(g_SortedMajorPlayerEntryTable, {iPlayer, civDesc})
			end
			g_PlayerLegendsTable[iPlayer] = {}
		end
	end
	
	local f = function(a, b) 
		return a[2] < b[2];
	end
	table.sort(g_SortedMajorPlayerEntryTable, f)
	table.sort(g_SortedMinorPlayerEntryTable, f)
	table.sort(g_SortedBarbarianPlayerEntryTable, f)
	
	--Put player first silly!
	-- table.insert(g_SortedPlayerEntryTable, {iActivePlayer, sActivePlayerDesc})
	-- table.insert(g_SortedPlayerPlusBarbsEntryTable, {iActivePlayer, sActivePlayerDesc})
		
	for _, tPlayer in ipairs(g_SortedMajorPlayerEntryTable) do
		table.insert(g_SortedPlayerEntryTable, {tPlayer[1], tPlayer[2]})
		table.insert(g_SortedPlayerPlusBarbsEntryTable, {tPlayer[1], tPlayer[2]})
	end
	for _, tPlayer in ipairs(g_SortedMinorPlayerEntryTable) do
		table.insert(g_SortedPlayerEntryTable, {tPlayer[1], tPlayer[2]})
		table.insert(g_SortedPlayerPlusBarbsEntryTable, {tPlayer[1], tPlayer[2]})
	end
	for _, tPlayer in ipairs(g_SortedBarbarianPlayerEntryTable) do
		table.insert(g_SortedPlayerEntryTable, {tPlayer[1], tPlayer[2]})
		table.insert(g_SortedPlayerPlusBarbsEntryTable, {tPlayer[1], tPlayer[2]})
	end
	g_SelectedMapOverlayPlayers = g_SortedPlayerEntryTable
end		
PopulateSortedPlayers()
-------------------------------------------------------------------------------
local g_SortedRankedPlayerEntryTable
function PopulateRankedPlayers(overlayMapID)
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	
	g_SortedRankedPlayerEntryTable = {}
	local tablePlayers = g_SortedPlayerEntryTable
	if g_SelectedOverlayMapFilterID ~= -1 then
		local overlayMapFilter = GameInfo.JFD_OverlayMapFilters[g_SelectedOverlayMapFilterID]
		local overlayMapFilterType = overlayMapFilter.Type
		if overlayMapFilterType == "FILTER_ALL_MAJORS" then
			tablePlayers = g_SortedMajorPlayerEntryTable
		elseif overlayMapFilterType == "FILTER_ALL_MINORS" then
			tablePlayers = g_SortedMinorPlayerEntryTable
		end
	end
	
	local numRankHighestVal = 0
	local numRankHighestPlayerID = 0
	for _, tPlayer in ipairs(tablePlayers) do
		local iPlayer = tPlayer[1]
		local pPlayer = Players[iPlayer]
		if pPlayer:IsAlive() and ((isActiveTeam and pOtherTeam:IsHasMet(iActiveTeam)) or (not isActiveTeam)) then
			local numRankVal = pPlayer:GetValueForRankForOverlayMap(overlayMapID)
			if numRankVal > numRankHighestVal then
				numRankHighestVal = numRankVal
				numRankHighestPlayerID = iPlayer
			end
			table.insert(g_SortedRankedPlayerEntryTable, {iPlayer, numRankVal})
		end
	end
	
	local f = function(a, b) 
		return a[2] > b[2];
	end
	table.sort(g_SortedRankedPlayerEntryTable, f)
	
	local numRankTotal = #g_SortedRankedPlayerEntryTable
	for numRank, tPlayer in ipairs(g_SortedRankedPlayerEntryTable) do
		local iPlayer = tPlayer[1]
		local numRankVal = tPlayer[2]
		g_PlayerLegendsTable[iPlayer].RankInfo = {Rank = numRank, RankTotal = numRankTotal, RankVal = numRankVal, RankHighestVal = numRankHighestVal}
	end
end
-------------------------------------------------------------------------------
local g_SortedPlayersEntryTable
local g_SortedActivePlayerEntryTable
function PopulatePlayers(overlayMapID)
	g_SortedPlayersEntryTable = {}
	g_SortedActivePlayerEntryTable = {}
	local iActivePlayer = g_SelectedOverlayMapFilterPlayerID
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	table.insert(g_SortedActivePlayerEntryTable, {iActivePlayer})
	for i, tPlayer in ipairs(g_SelectedMapOverlayPlayers) do
		local iPlayer = tPlayer[1]
		local pPlayer = Players[iPlayer]
		local pOtherTeam = Teams[pPlayer:GetTeam()]
		if pPlayer:IsAlive() and ((isActiveTeam and pOtherTeam:IsHasMet(iActiveTeam)) or (not isActiveTeam)) then
			table.insert(g_SortedPlayersEntryTable, {iPlayer})
			g_PlayerLegendsTable[iPlayer] = {}
			g_PlayerLegendsTable[iPlayer].Checked = true
			g_PlayerLegendsTable[iPlayer].Visible = true
		end
	end
end
-------------------------------------------------------------------------------
local g_SortedPlayerReligionEntryTable
function PopulateReligions(overlayMapID)
	g_SortedPlayerReligionEntryTable = {}
	for i, tPlayer in ipairs(g_SelectedMapOverlayPlayers) do
		local iPlayer = tPlayer[1]
		local pPlayer = Players[iPlayer]
		if pPlayer:IsEverAlive() then
			if pPlayer:HasCreatedReligion() then
				local iReligion = pPlayer:GetReligionCreatedByPlayer()
				table.insert(g_SortedPlayerReligionEntryTable, {iReligion, Game.GetReligionName(iReligion), iPlayer})
				g_ReligionLegendsTable[iReligion] = {}
				g_ReligionLegendsTable[iReligion].Checked = true
				g_ReligionLegendsTable[iReligion].Visible = true
			end
		end
	end
	
	local f = function(a, b) 
		return a[2] < b[2];
	end
	table.sort(g_SortedReligionEntryTable, f)
end
-------------------------------------------------------------------------------
local g_ActiveOverlayMap
function PopulateActiveOverlayMap(overlayMapID)	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	g_ActiveOverlayMap = {}
	g_ActiveOverlayMap[overlayMapType] = {}
	for row in GameInfo.JFD_OverlayMap_Legends("OverlayMapType='" .. overlayMapType .. "'") do
		local legendType = row.LegendType
		g_ActiveOverlayMap[overlayMapType][legendType] = {}
		g_ActiveOverlayMap[overlayMapType][legendType].Checked = row.DefaultChecked
		g_ActiveOverlayMap[overlayMapType][legendType].Visible = false
	end
	if overlayMap.PopulatePlayers then
		PopulatePlayers(overlayMapID)
	end
	if overlayMap.PopulateRankings then
		PopulateRankedPlayers(overlayMapID)
	end
	if overlayMap.PopulateReligions then
		PopulateReligions(overlayMapID)
	end
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function GetColour(overlayMapID, thisLegend, thisLegendInfo, iPlayer, iReligion, pPlot)
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayLegend = GameInfo.JFD_OverlayMap_Legends("OverlayMapType = '".. overlayMapType .. "' AND LegendType = '" .. thisLegend .. "'")()
	
	local colour
	local colourAlpha
	local colorType = overlayLegend.ColorType
	local colorAlpha = overlayLegend.ColorAlpha
	
	if colorType then
		colour = GameInfo.Colors[colorType]
		colourAlpha = colour.Alpha
	end
	
	if overlayLegend.UseReligionColor and (iReligion  and iReligion > 0) then
		local religionType = GameInfo.Religions[iReligion].Type
		local religionColour = GameInfo.Religion_MapColors("ReligionType = '" .. religionType .. "'")()
		colour = GameInfo.Colors[religionColour]
		colourAlpha = colour.Alpha
	end
	
	if overlayLegend.UseAreaColorType and pPlot then
		local iArea = pPlot:Area():GetID()
		if iArea > -1 then
			colour = GameInfo.Colors[iArea]
		end
	elseif overlayLegend.UseFilteredPlayerColor and (g_SelectedOverlayMapFilterPlayerID and g_SelectedOverlayMapFilterPlayerID > -1) then
		local pPlayer = Players[g_SelectedOverlayMapFilterPlayerID]
		local playerColour = GameInfo.PlayerColors[pPlayer:GetPlayerColor()]
		colour = GameInfo.Colors[playerColour.SecondaryColor]
	elseif overlayLegend.UsePlayerColor and (iPlayer and iPlayer > -1) then
		local pPlayer = Players[iPlayer]
		local playerColour = GameInfo.PlayerColors[pPlayer:GetPlayerColor()]
		colour = GameInfo.Colors[playerColour.SecondaryColor]
	elseif overlayLegend.UsePlayerColorInverted and (iPlayer and iPlayer > -1) then
		local pPlayer = Players[iPlayer]
		local playerColour = GameInfo.PlayerColors[pPlayer:GetPlayerColor()]
		colour = GameInfo.Colors[playerColour.PrimaryColor]
		colourAlpha = colour.Alpha
	end		
	
	if (not colour) and overlayLegend.UsePlayerColorFallback then
		local pPlayer = Players[iPlayer]
		local playerColour = GameInfo.PlayerColors[pPlayer:GetPlayerColor()]
		colour = GameInfo.Colors[playerColour.SecondaryColor]
		colourAlpha = colour.Alpha
	end
	
	if overlayLegend.UseRankedColor and (iPlayer and iPlayer > -1) then
		colour = GameInfo.Colors[overlayLegendRankings.ColorType]
		colourAlpha = colour.Alpha
		
		local rankInfo = g_PlayerLegendsTable[iPlayer].RankInfo
		local rank = rankInfo.Rank
		local rankHighestVal = rankInfo.RankHighestVal
		local rankTotal = rankInfo.RankTotal
		local rankVal = rankInfo.RankVal
		local overlayLegendRankings = GameInfo.JFD_OverlayMap_Rankings("OverlayMapType = '" .. overlayMapType .. "'")()
		local colorTypeAlt = overlayLegendRankings.ColorTypeAlt
		if colorTypeAlt then
			local numValEquals = overlayLegendRankings.ColorTypeAltEqualToValue
			local numValLessOrEquals = overlayLegendRankings.ColorTypeAltLessOrEqualToValue
			local numValLess = overlayLegendRankings.ColorTypeAltLessThanValue
			local numValGreaterOrEquals = overlayLegendRankings.ColorTypeAltGreaterOrEqualToValue
			local numValGreater = overlayLegendRankings.ColorTypeAltGreaterThanValue
			if numValEquals ~= -1 and rankVal == numValEquals then
				colour = GameInfo.Colors[colorTypeAlt]
			elseif numValLessOrEquals ~= -1 and rankVal <= numValLessOrEquals then
				colour = GameInfo.Colors[colorTypeAlt]
			elseif numValLess ~= -1 and rankVal < numValLess then
				colour = GameInfo.Colors[colorTypeAlt]
			elseif numValGreaterOrEquals ~= -1 and rankVal >= numValGreaterOrEquals then
				colour = GameInfo.Colors[colorTypeAlt]
			elseif numValGreater ~= -1 and rankVal > numValGreater then
				colour = GameInfo.Colors[colorTypeAlt]
			end
		else
			colour = GetColourAdjustedForRank(colour, rank, rankHighestVal, rankTotal, rankVal) 
		end
	end
	if colour then
		if colorAlpha ~= colourAlpha then
			colourAlpha = colorAlpha
		end
		return {Red=(255*colour.Red), Green=(255*colour.Green), Blue=(255*colour.Blue), Alpha=colourAlpha}
	end
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function GetColourForPlayer(iPlayer)
	local pPlayer = Players[iPlayer]
	
	local colour
		
	-- if (not pPlayer:IsMinorCiv()) then
		local playerColour = GameInfo.PlayerColors[pPlayer:GetPlayerColor()]
		colour = GameInfo.Colors[playerColour.SecondaryColor]
	-- else
		-- local playerColour = GameInfo.PlayerColors[pPlayer:GetPlayerColor()]
		-- colour = GameInfo.Colors[playerColour.PrimaryColor]
	-- end		
	
	return {Red=(255*colour.Red), Green=(255*colour.Green), Blue=(255*colour.Blue), Alpha=colour.Alpha}
end
-------------------------------------------------------------------------------
function GetColourForCityPlot(overlayMapID, iPlayer, pCity)
	local pPlayer = Players[iPlayer]
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local optionShowBorders = g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_BORDERS"]
	
	local colour
	local colourAlpha = 1
	
	if pCity:IsCapital() then
		colour = DefaultColours.CAPITAL_CITY
	else
		colour = DefaultColours.CITY
	end
	
	if (optionShowBorders.Check and optionShowBorders.IsValid) or overlayMapType == "OVERLAY_MAP_JFD_PLAYERS_BORDERS_OWNER" then
		if pPlayer:IsMinorCiv() then
			local playerColour, _ = pPlayer:GetPlayerColors()
			colour = {Red=(255*playerColour.x), Green=(255*playerColour.y), Blue=(255*playerColour.z), Alpha=playerColour.w}
		else
			local playerColour, _ = pPlayer:GetPlayerColors()
			colour = {Red=(255*playerColour.x), Green=(255*playerColour.y), Blue=(255*playerColour.z), Alpha=playerColour.w}
		end							
	end	

	return colour
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShadeMap(overlayMapID)
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	
	-- local overlayMapOptionShowTerrain = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_TERRAIN"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_TERRAIN"].IsValid)
	local overlayMapOptionShowTerrain = true
	
	if (not overlayMapLegendToHL) then
		for y = 0, mapHeight-1, 1 do  
			for x = 0, mapWidth-1, 1 do
				local pPlot = Map.GetPlot(x, y)
				if pPlot then
					local colour = DefaultColours.UNKNOWN			
					if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
						if (pPlot:GetFeatureType() == iFeatureIce) then
							colour = DefaultColours.ICE
						elseif (pPlot:IsWater()) then
							if overlayMapOptionShowTerrain then
								colour = DefaultColours.WATER
							else
								if pPlot:GetTerrainType() == iTerrainCoast then
									colour = DefaultColours.COAST
								else
									colour = DefaultColours.OCEAN
								end
							end
						else
							if overlayMapOptionShowTerrain then
								colour = DefaultColours.NONE	
							else
								if pPlot:IsMountain() then
									colour = DefaultColours.MOUNTAIN
								else
									colour = DefaultColours.LAND
								end
							end
						end
					end	  
					Controls.Map:SetPlot(x, y, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colour.Alpha)
				end	
			end	
		end
	end
	ShadeTiles(overlayMapID)
end
-------------------------------------------------------------------------------
function ShadeTiles(overlayMapID)
	local iActivePlayer = g_SelectedOverlayMapFilterPlayerID
	local isActivePlayer = (iActivePlayer ~= -1)
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]	
	local overlayMapType = overlayMap.Type
	local overlayMapIterateTiles = overlayMap.IterateTiles
	local overlayMapIteratePlayers = overlayMap.IteratePlayers
	local overlayMapIteratePlayerCities = overlayMap.IteratePlayerCities
	local overlayMapIteratePlayerTiles = overlayMap.IteratePlayerTiles
	local overlayMapIteratePlayerUnits = overlayMap.IteratePlayerUnits
	
	local overlayMapFilterID = g_SelectedOverlayMapFilterID
	local overlayMapOptionExcInactive = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_EXCLUDE_INACTIVE"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_EXCLUDE_INACTIVE"].IsValid)
	local overlayMapOptionExcPillagedTiles = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_EXCLUDE_PILLAGED_TILES"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_EXCLUDE_PILLAGED_TILES"].IsValid)
	local overlayMapOptionExcWaterTiles = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_EXCLUDE_WATER_TILES"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_EXCLUDE_WATER_TILES"].IsValid)
	local overlayMapOptionIncBarbs = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS"].IsValid)
	local overlayMapOptionIncCityTiles = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_CITY_TILES"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_CITY_TILES"].IsValid)
	local overlayMapOptionIncEmbarkUnits = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_EMARBKED_UNITS"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_EMARBKED_UNITS"].IsValid)
	local overlayMapOptionShowBorders = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_BORDERS"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_BORDERS"].IsValid)
	local overlayMapOptionShowCities = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_CITIES"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_CITIES"].IsValid)
	local overlayMapOptionShowStarts = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_STARTS"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_STARTS"].IsValid)
	local overlayMapOptionShowTerrain = (g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_TERRAIN"].Check and g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_SHOW_TERRAIN"].IsValid)
	
	local playersTable = g_SortedPlayersEntryTable
	if overlayMapOptionExcInactive then
		playersTable = g_SortedActivePlayerEntryTable
	end
	if (overlayMapOptionShowBorders or overlayMapOptionShowCities or overlayMapOptionShowStarts) and (not overlayMapOptionIncCityTiles) then
		for i, tPlayer in ipairs(playersTable) do
			local iOtherPlayer = tPlayer[1]
			local pOtherPlayer = Players[iOtherPlayer]
			local iOtherTeam = pOtherPlayer:GetTeam()
			local thisLegendPlayer = g_PlayerLegendsTable[iOtherPlayer]
			if (thisLegendPlayer and thisLegendPlayer.Checked) then
				if overlayMapOptionShowBorders and pOtherPlayer:GetNumCities() > 0 then	
					local colour = GetColourForPlayer(iOtherPlayer)
					local colourA = colour.Alpha
					for pCity in pOtherPlayer:Cities() do
						local pPlotX = pCity:GetX()
						local pPlotY = pCity:GetY()
						local pPlot = Map.GetPlot(pPlotX, pPlotY)
						if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
							ShadeCityTiles(iActiveTeam, pCity, colour, colourA, (not overlayMapOptionShowCities), (not overlayMapOptionExcWaterTiles))
						end
					end
				end
				if overlayMapOptionShowCities then
					for pCity in pOtherPlayer:Cities() do
						local pPlotX = pCity:GetX()
						local pPlotY = pCity:GetY()
						local pPlot = Map.GetPlot(pPlotX, pPlotY)
						if pPlot then
							if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
								local colour = GetColourForCityPlot(overlayMapID, iOtherPlayer, pCity)
								local colourA = colour.Alpha
								Controls.Map:SetPlot(pPlotX, pPlotY, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
							end
						end
					end
				end
				if overlayMapOptionShowStarts and pOtherPlayer:GetNumCities() == 0 then
					local pPlot = pOtherPlayer:GetStartingPlot()
					if pPlot then
						local pPlotX = pPlot:GetX()
						local pPlotY = pPlot:GetY()
						if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
							local colour = GetColourForPlayer(iOtherPlayer)
							local colourA = colour.Alpha
							Controls.Map:SetPlot(pPlotX, pPlotY, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
						end
					end
				end
			end
			-- if overlayMapOptionShowCities then
				-- for pCity in pOtherPlayer:Cities() do
				-- print("pOtherPlayer", pOtherPlayer:GetName(), "am illegal")
					-- local pPlotX = pCity:GetX()
					-- local pPlotY = pCity:GetY()
					-- local pPlot = Map.GetPlot(pPlotX, pPlotY)
					-- if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
						-- local colour = GetColourForCityPlot(overlayMapID, iOtherPlayer, pCity)
						-- local colourA = colour.Alpha
						-- Controls.Map:SetPlot(pPlotX, pPlotY, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
					-- end
				-- end
			-- end
			-- if overlayMapOptionShowStarts and pOtherPlayer:GetNumCities() == 0 then
				-- local pPlot = pOtherPlayer:GetStartingPlot()
				-- if pPlot then
					-- local pPlotX = pPlot:GetX()
					-- local pPlotY = pPlot:GetY()
					-- if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
						-- local colour = GetColourForPlayer(iOtherPlayer)
						-- local colourA = colour.Alpha
						-- Controls.Map:SetPlot(pPlotX, pPlotY, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
					-- end
				-- end
			-- end
		end		
	end		
					
	if overlayMapIterateTiles then
		for y = 0, mapHeight-1, 1 do  
		for x = 0, mapWidth-1, 1 do
			local pPlot = Map.GetPlot(x, y)
			if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
				local iOtherPlayer = pPlot:GetOwner()
				local iFeature = pPlot:GetFeatureType()
				local iTerrain = pPlot:GetTerrainType()
				if iTerrain ~= iTerrainOcean and iTerrain ~= iTerrainCoast and pPlot:GetFeatureType() ~= iFeatureIce then
					local thisLegend = GetOverlayMapLegend(overlayMapID, overlayMapFilterID, iActivePlayer, iActiveTeam, iOtherPlayer, iOtherTeam, pCity, pPlot, pUnit, iReligion)
					if thisLegend then
						local thisLegendInfo = g_ActiveOverlayMap[overlayMapType][thisLegend]
						if thisLegendInfo then
							local colour = GetColour(overlayMapID, thisLegend, thisLegendInfo, iOtherPlayer, pPlot)
							local colourA = colour.Alpha
							if colour then
								if thisLegendInfo.Checked then
									Controls.Map:SetPlot(x, y, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
								end
								if (not thisLegendInfo.Colour) or thisLegendInfo.Colour ~= colour then
									thisLegendInfo.Colour = colour
								end
								if (not thisLegendInfo.Visible) then
									thisLegendInfo.Visible = true
								end
							end
						end
					end
				end
			end
		end
		end
	elseif overlayMapIteratePlayerTiles then
		if overlayMapOptionExcInactive and isActivePlayer then
			local iOtherPlayer = iActivePlayer
			local pOtherPlayer = Players[iOtherPlayer]
			for pCity in pOtherPlayer:Cities() do
				for i = 1, pCity:GetNumCityPlots()-1, 1 do
					local pPlot = pCity:GetCityIndexPlot(i)
					if pPlot and (pPlot:GetOwner() == pCity:GetOwner()) then
						if ((overlayMapOptionExcPillagedTiles and (not pPlot:IsImprovementPillaged()) and (not pPlot:IsRoutePillaged())) or (not overlayMapOptionExcPillagedTiles)) 
						and ((overlayMapOptionExcWaterTiles and (not pPlot:IsWater())) or (not overlayMapOptionExcWaterTiles)) then
							local thisLegendPlayer = g_PlayerLegendsTable[iOtherPlayer]
							if (thisLegendPlayer and thisLegendPlayer.Checked) then
								local thisLegend = GetOverlayMapLegend(overlayMapID, overlayMapFilterID, iActivePlayer, iActiveTeam, iOtherPlayer, iOtherTeam, pCity, pPlot, pUnit, iReligion)
								if thisLegend then
									local thisLegendInfo = g_ActiveOverlayMap[overlayMapType][thisLegend]
									if thisLegendInfo then
										local colour = GetColour(overlayMapID, thisLegend, thisLegendInfo, iOtherPlayer)
										local colourA = colour.Alpha
										if thisLegendInfo.Checked then
											Controls.Map:SetPlot(x, y, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
										end
										if (not thisLegendInfo.Colour) or thisLegendInfo.Colour ~= colour then
											thisLegendInfo.Colour = colour
										end
										if (not thisLegendInfo.Visible) then
											thisLegendInfo.Visible = true
										end
										if (not thisLegendPlayer.Colour) or thisLegendPlayer.Colour ~= colour then
											thisLegendPlayer.Colour = colour
										end
										if (not thisLegendPlayer.Legend) or thisLegendPlayer.Legend ~= thisLegend then
											thisLegendPlayer.Legend = thisLegend
										end
									end
								end
							end
						end
					end
				end
			end
		else
			for y = 0, mapHeight-1, 1 do  
			for x = 0, mapWidth-1, 1 do
				local pPlot = Map.GetPlot(x, y)
				if ((overlayMapOptionExcPillagedTiles and (not pPlot:IsImprovementPillaged()) and (not pPlot:IsRoutePillaged())) or (not overlayMapOptionExcPillagedTiles)) then
					if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
						local iOtherPlayer = pPlot:GetOwner()
						if iOtherPlayer > -1 then
							local pOtherPlayer = Players[iOtherPlayer]
							if pOtherPlayer:IsAlive() then
								local iOtherTeam = pOtherPlayer:GetTeam()
								local pOtherTeam = Teams[iPlayerTeam]
								if ((isActiveTeam and pOtherTeam:IsHasMet(iActiveTeam)) or (not isActiveTeam)) then
									local thisLegendPlayer = g_PlayerLegendsTable[iOtherPlayer]
									if (thisLegendPlayer and thisLegendPlayer.Checked) then
										local thisLegend = GetOverlayMapLegend(overlayMapID, overlayMapFilterID, iActivePlayer, iActiveTeam, iOtherPlayer, iOtherTeam, pCity, pPlot, pUnit, iReligion)
										if thisLegend then
											local thisLegendInfo = g_ActiveOverlayMap[overlayMapType][thisLegend]
											if thisLegendInfo then
												local colour = GetColour(overlayMapID, thisLegend, thisLegendInfo, iOtherPlayer)
												local colourA = colour.Alpha
												if thisLegendInfo.Checked then
													Controls.Map:SetPlot(x, y, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
												end
												if (not thisLegendInfo.Colour) or thisLegendInfo.Colour ~= colour then
													thisLegendInfo.Colour = colour
												end
												if (not thisLegendInfo.Visible) then
													thisLegendInfo.Visible = true
												end
												if (not thisLegendPlayer.Colour) or thisLegendPlayer.Colour ~= colour then
													thisLegendPlayer.Colour = colour
												end
												if (not thisLegendPlayer.Legend) or thisLegendPlayer.Legend ~= thisLegend then
													thisLegendPlayer.Legend = thisLegend
												end
											end
										end
									end
								end
							end
						else
							local thisLegend = GetOverlayMapLegend(overlayMapID, overlayMapFilterID, iActivePlayer, iActiveTeam, iOtherPlayer, iOtherTeam, pCity, pPlot, pUnit, iReligion)
							if thisLegend then
								local thisLegendInfo = g_ActiveOverlayMap[overlayMapType][thisLegend]
								if thisLegendInfo then
									local colour = GetColour(overlayMapID, thisLegend, thisLegendInfo, iOtherPlayer)
									local colourA = colour.Alpha
									if colour then
										if thisLegendInfo.Checked then
											Controls.Map:SetPlot(x, y, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)	
										end
										if (not thisLegendInfo.Colour) or thisLegendInfo.Colour ~= colour then
											thisLegendInfo.Colour = colour
										end
										if (not thisLegendInfo.Visible) then
											thisLegendInfo.Visible = true
										end
									end
								end
							end
						end
					end
				end
			end
			end
		end
	elseif overlayMapIteratePlayers then 
		for i, tPlayer in ipairs(playersTable) do
			local iOtherPlayer = tPlayer[1]
			local thisLegendPlayer = g_PlayerLegendsTable[iOtherPlayer]
			if (thisLegendPlayer and thisLegendPlayer.Checked) then
				local pOtherPlayer = Players[iOtherPlayer]
				local iOtherTeam = pOtherPlayer:GetTeam()
				local pOtherTeam = Teams[iOtherTeam]
				local thisLegend = GetOverlayMapLegend(overlayMapID, overlayMapFilterID, iActivePlayer, iActiveTeam, iOtherPlayer, iOtherTeam, pCity, pPlot, pUnit, iReligion)
				if thisLegend then
					local thisLegendInfo = g_ActiveOverlayMap[overlayMapType][thisLegend]
					if thisLegendInfo then
						local colour = GetColour(overlayMapID, thisLegend, thisLegendInfo, iOtherPlayer)
						local colourA = colour.Alpha
						-- if overlayMapOptionShowStarts and pOtherPlayer:GetNumCities() == 0 then
							-- local pPlot = pOtherPlayer:GetStartingPlot()
							-- if pPlot then
								-- local pPlotX = pPlot:GetX()
								-- local pPlotY = pPlot:GetY()
								-- if (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
									-- local colour = GetColourForPlayer(iOtherPlayer)
									-- local colourA = colour.Alpha
									-- Controls.Map:SetPlot(pPlotX, pPlotY, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
								-- end
							-- end
						-- end
						if thisLegendInfo.Checked then
							for pCity in pOtherPlayer:Cities() do
								ShadeCityTiles(iActiveTeam, pCity, colour, colourA, (not overlayMapOptionShowCities), (not overlayMapOptionExcWaterTiles))
							end
						end
						if (not thisLegendInfo.Colour) or thisLegendInfo.Colour ~= colour then
							thisLegendInfo.Colour = colour
						end
						if (not thisLegendInfo.Visible) then
							thisLegendInfo.Visible = true
						end
						if (not thisLegendPlayer.Colour) or thisLegendPlayer.Colour ~= colour then
							thisLegendPlayer.Colour = colour
						end
						if (not thisLegendPlayer.Legend) or thisLegendPlayer.Legend ~= thisLegend then
							thisLegendPlayer.Legend = thisLegend
						end
					end
				end
			end
		end
	elseif overlayMapIteratePlayerCities then 
		for i, tPlayer in ipairs(playersTable) do
			local iOtherPlayer = tPlayer[1]
			local thisLegendPlayer = g_PlayerLegendsTable[iOtherPlayer]
			if (thisLegendPlayer and thisLegendPlayer.Checked) then
				local pOtherPlayer = Players[iOtherPlayer]
				local iOtherTeam = pOtherPlayer:GetTeam()
				local pOtherTeam = Teams[iOtherTeam]
				for pCity in pOtherPlayer:Cities() do
					local thisLegend = GetOverlayMapLegend(overlayMapID, overlayMapFilterID, iActivePlayer, iActiveTeam, iOtherPlayer, iOtherTeam, pCity, pPlot, pUnit, iReligion)
					if thisLegend then
						local thisLegendInfo = g_ActiveOverlayMap[overlayMapType][thisLegend]
						if thisLegendInfo then
							local colour = GetColour(overlayMapID, thisLegend, thisLegendInfo, iOtherPlayer)
							local colourA = colour.Alpha
							local pPlotX = pCity:GetX()
							local pPlotY = pCity:GetY()
							local pPlot = Map.GetPlot(pPlotX, pPlotY)
							if thisLegendInfo.Checked then
								Controls.Map:SetPlot(pPlotX, pPlotY, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
								if overlayMapOptionIncCityTiles then
									ShadeCityTiles(iActiveTeam, pCity, colour, colourA, (not overlayMapOptionShowCities), (not overlayMapOptionExcWaterTiles))
								end	
							end	
							if (not thisLegendInfo.Colour) or thisLegendInfo.Colour ~= colour then
								thisLegendInfo.Colour = colour
							end
							if (not thisLegendInfo.Visible) then
								thisLegendInfo.Visible = true
							end
							if (not thisLegendPlayer.Colour) or thisLegendPlayer.Colour ~= colour then
								thisLegendPlayer.Colour = colour
							end
							if (not thisLegendPlayer.Legend) or thisLegendPlayer.Legend ~= thisLegend then
								thisLegendPlayer.Legend = thisLegend
							end 
						end
					end
				end
			end
		end
	elseif overlayMapIteratePlayerUnits then 
		for i, tPlayer in ipairs(playersTable) do
			local iOtherPlayer = tPlayer[1]
			local thisLegendPlayer = g_PlayerLegendsTable[iOtherPlayer]
			if (thisLegendPlayer and thisLegendPlayer.Checked) then
				local pOtherPlayer = Players[iOtherPlayer]
				local iOtherTeam = pOtherPlayer:GetTeam()
				local pOtherTeam = Teams[iOtherTeam]
				for pUnit in pOtherPlayer:Units() do
					if (pUnit:IsEmbarked() and overlayMapOptionIncEmbarkUnits) or (not pUnit:IsEmbarked()) then
						local thisLegend = GetOverlayMapLegend(overlayMapID, overlayMapFilterID, iActivePlayer, iActiveTeam, iOtherPlayer, iOtherTeam, pCity, pPlot, pUnit, iReligion)
						if thisLegend then
							local thisLegendInfo = g_ActiveOverlayMap[overlayMapType][thisLegend]
							if thisLegendInfo then
								local colour = GetColour(overlayMapID, thisLegend, thisLegendInfo, iOtherPlayer)
								local colourA = colour.Alpha
								local pPlotX = pUnit:GetX()
								local pPlotY = pUnit:GetY()
								local pPlot = Map.GetPlot(pPlotX, pPlotY)
								if thisLegendInfo.Checked then
									Controls.Map:SetPlot(pPlotX, pPlotY, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)
								end
								if (not thisLegendInfo.Colour) or thisLegendInfo.Colour ~= colour then
									thisLegendInfo.Colour = colour
								end
								if (not thisLegendInfo.Visible) then
									thisLegendInfo.Visible = true
								end
								if (not thisLegendPlayer.Colour) or thisLegendPlayer.Colour ~= colour then
									thisLegendPlayer.Colour = colour
								end
								if (not thisLegendPlayer.Legend) or thisLegendPlayer.Legend ~= thisLegend then
									thisLegendPlayer.Legend = thisLegend
								end 
							end
						end
					end
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
--Original func. by Whoward
function ShadeCityTiles(iActiveTeam, pCity, colour, colourA, isShadeCityTile, isIncludeWaterTiles)
	local isActiveTeam = (iActiveTeam ~= -1)
	for i = 1, pCity:GetNumCityPlots()-1, 1 do
		local pPlot = pCity:GetCityIndexPlot(i)
		if (pPlot and (isActiveTeam and pPlot:IsRevealed(iActiveTeam))) or (pPlot and (not isActiveTeam)) then
			if (pPlot:GetOwner() == pCity:GetOwner()) then
				if (((not pPlot:IsWater()) and (not isIncludeWaterTiles)) or isIncludeWaterTiles) then 
					if (pPlot:IsMountain() or pPlot:GetTerrainType() == iTerrainDesert or pCity:IsWorkingPlot(pPlot) or pCity:CanWork(pPlot)) then
						Controls.Map:SetPlot(pPlot:GetX(), pPlot:GetY(), pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)	
					end
				end
			end
		end
	end
	if isShadeCityTile then
		local pPlotX = pCity:GetX()
		local pPlotY = pCity:GetY()
		local pPlot = Map.GetPlot(pPlotX, pPlotY)
		if pPlot and (isActiveTeam and pPlot:IsRevealed(iActiveTeam)) or (not isActiveTeam) then
			Controls.Map:SetPlot(pPlotX, pPlotY, pPlot:GetTerrainType(), colour.Red/255, colour.Green/255, colour.Blue/255, colourA)	
		end
	end
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function PopulateOverlayPlayerRankings(overlayMapID)
	local iActivePlayer = g_SelectedOverlayMapFilterPlayerID
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	
	local tableMapOverlay = g_ActiveOverlayMap[overlayMapType]	
	
	for i, tPlayer in ipairs(g_SortedRankedPlayerEntryTable) do
		local iPlayer = tPlayer[1]
		local pPlayer = Players[iPlayer]	
		local iPlayerTeam = pPlayer:GetTeam()
		local pTeam = Teams[iPlayerTeam]
		if pPlayer:IsAlive() and ((isActiveTeam and pTeam:IsHasMet(iActiveTeam)) or (not isActiveTeam)) then
			local thisPlayerInfo = g_PlayerLegendsTable[iPlayer]
			local thisLegend = thisPlayerInfo.Legend
			local thisLegendInfo = tableMapOverlay[thisLegend]
			if thisPlayerInfo and thisPlayerInfo.Visible and thisLegendInfo and (thisLegendInfo.Visible) then
				local legend = GameInfo.JFD_OverlayMapLegends[thisLegend]
				local legendInstance = g_LegendPlayerInstanceManager:GetInstance();
				local legendRanking = GameInfo.JFD_OverlayMap_Rankings("OverlayMapType = '" .. overlayMapType .. "'")()
				
				local playerRankInfo = thisPlayerInfo.RankInfo
				local strPlayerRank = tostring(playerRankInfo.Rank)
				local strPlayerRankVal = tostring(playerRankInfo.RankVal)
				local strPlayerShortDesc = pPlayer:GetCivilizationShortDescription()
				local strLeaderShortDesc = pPlayer:GetName()
				
				local strShortDesc = Locale.ConvertTextKey(legend.ShortDescription, strPlayerShortDesc, strPlayerRank, strLeaderShortDesc)
				local strRankShortDesc = Locale.ConvertTextKey(legendRanking.ShortDescription, legendRanking.IconFont, strPlayerRankVal)
				legendInstance.PlayerName:SetText(strShortDesc);
				legendInstance.PlayerRankVal:SetText(strRankShortDesc);
				legendInstance.PlayerRankVal:SetHide(false)
				
				if legend.UsePlayerIcon then
					if pPlayer:IsMinorCiv() then
						local minorCivID = pPlayer:GetMinorCivType()
						local minorCivTraitType = GameInfo.MinorCivilizations[minorCivID].MinorCivTrait
						local minorCivTrait = GameInfo.MinorCivTraits[minorCivTraitType]
						local _, minorCivColour = pCS:GetPlayerColors(); csColour.w = 1
						local traitTexture = minorCivTrait.TraitIcon
						legendInstance.PlayerTexture:SetTexture(traitTexture)
						legendInstance.PlayerTexture:SetColor(minorCivColour)
						legendInstance.PlayerTexture:SetHide(false)
					else
						local civ = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
						IconHookup( civ.PortraitIndex, 32, civ.IconAtlas, legendInstance.PlayerIcon );
						legendInstance.PlayerIcon:SetHide(false)
					end
				else
					local strFont = legend.IconFont
					if strFont then
						legendInstance.PlayerFont:SetText(strFont)
						legendInstance.PlayerFont:SetHide(false)
					end
				end
				
				local legendColour = thisPlayerInfo.Colour
				local legendColourR = legendColour.Red
				local legendColourG = legendColour.Green
				local legendColourB = legendColour.Blue
				local legendColourA = legendColour.Alpha
				local strColour = "[COLOR:" .. 255 .. ":" .. legendColourG .. ":" .. legendColourB .. ":" .. legendColourA .. "]"
				legendInstance.PlayerLine:SetColorVal(legendColourR/255, legendColourG/255, legendColourB/255, legendColourA);	
				legendInstance.PlayerLine:SetHide(false)
	
				local strRankDesc = Locale.ConvertTextKey(legendRanking.Description, strColour, strPlayerRank, strPlayerShortDesc, strPlayerRankVal, legendRanking.IconFont)
				legendInstance.PlayerButton:SetToolTipString(strRankDesc);
				
				legendInstance.PlayerSelectHighlight:SetHide(true)
				
				local checked = thisLegendInfo.Checked
				legendInstance.ShowHide:SetHide(true)
				legendInstance.ShowHide:SetCheck(checked);
				legendInstance.ShowHide:SetHide(showInLegendAlways)
				
				legendInstance.ShowHide:RegisterCheckHandler( function(bCheck)
					thisPlayerInfo.Checked = bCheck
					ShadeMap(overlayMapID, overlayMapFilterID, overlayMapFilterPlayerID, overlayMapFilterReligionID, legendGroupID)
				end);
			end
		end
	end
	Controls.LegendPlayersStack:CalculateSize();
	Controls.LegendPlayersStack:ReprocessAnchoring();
	Controls.PlayerGrid:SetSizeY(Controls.LegendPlayersStack:GetSizeY() + 5)
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
-------------------------------------------------------------------------------
function PopulateOverlayPlayers(overlayMapID)
	local iActivePlayer = g_SelectedOverlayMapFilterPlayerID
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	
	local tableMapOverlay = g_ActiveOverlayMap[overlayMapType]	
	
	for i, tPlayer in ipairs(g_SortedMajorPlayerEntryTable) do
		local iPlayer = tPlayer[1]
		local pPlayer = Players[iPlayer]	
		local iPlayerTeam = pPlayer:GetTeam()
		local pTeam = Teams[iPlayerTeam]
		if pPlayer:IsAlive() and (not pPlayer:IsMinorCiv()) and (not pPlayer:IsBarbarian()) and ((isActiveTeam and pTeam:IsHasMet(iActiveTeam)) or (not isActiveTeam)) then
			local thisPlayerInfo = g_PlayerLegendsTable[iPlayer]
			local thisLegend = thisPlayerInfo.Legend
			local thisLegendInfo = tableMapOverlay[thisLegend]
			if thisPlayerInfo and thisPlayerInfo.Visible and (thisLegendInfo and thisLegendInfo.Visible) then
				local legend = GameInfo.JFD_OverlayMap_Legends("OverlayMapType = '" .. overlayMapType .. "' AND LegendType = '" .. thisLegend .. "'")()
				local legendInstance = g_LegendPlayerInstanceManager:GetInstance();
				
				numPlayers = numPlayers + 1
				
				local strShortDesc = legend.ShortDescription
				local strPlayerShortDesc = pPlayer:GetCivilizationShortDescription()
				-- if iPlayer == Game.GetActivePlayer() then
					-- strPlayerShortDesc = "[COLOR_POSITIVE_TEXT]" .. strPlayerShortDesc .. " (You)[ENDCOLOR]"
				-- end
				legendInstance.PlayerName:LocalizeAndSetText(strPlayerShortDesc);
				legendInstance.PlayerButton:LocalizeAndSetToolTip(strShortDesc);
				
				if legend.UsePlayerIcon or legend.UseFilteredPlayerIcon then
					if pPlayer:IsMinorCiv() then
						local minorCivID = pPlayer:GetMinorCivType()
						local minorCivTraitType = GameInfo.MinorCivilizations[minorCivID].MinorCivTrait
						local minorCivTrait = GameInfo.MinorCivTraits[minorCivTraitType]
						local _, minorCivColour = pPlayer:GetPlayerColors()
						local traitTexture = minorCivTrait.TraitIcon
						legendInstance.PlayerTexture:SetTexture(traitTexture)
						legendInstance.PlayerTexture:SetColor(minorCivColour)
						legendInstance.PlayerTexture:SetHide(false)
						legendInstance.PlayerIcon:SetHide(true)
						legendInstance.PlayerFont:SetHide(true)
					else
						local civ = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
						IconHookup( civ.PortraitIndex, 32, civ.IconAtlas, legendInstance.PlayerIcon );
						legendInstance.PlayerIcon:SetHide(false)
						legendInstance.PlayerTexture:SetHide(true)
						legendInstance.PlayerFont:SetHide(true)
					end
				else
					local strFont = legend.IconFont
					if strFont then
						legendInstance.PlayerTexture:SetHide(true)
						legendInstance.PlayerIcon:SetHide(true)
						legendInstance.PlayerFont:SetText(strFont)
						legendInstance.PlayerFont:SetHide(false)
					end
				end
				
				local legendColour = thisPlayerInfo.Colour
				legendInstance.PlayerLine:SetColorVal(legendColour.Red/255, legendColour.Green/255, legendColour.Blue/255, legendColour.Alpha);	
				legendInstance.PlayerLine:SetHide(false)
	
				legendInstance.PlayerSelectHighlight:SetHide(true)
				
				local checked = thisLegendInfo.Checked
				legendInstance.ShowHide:SetHide(false)
				legendInstance.ShowHide:SetCheck(checked);
				
				legendInstance.ShowHide:RegisterCheckHandler( function(bCheck)
					thisPlayerInfo.Checked = bCheck
					ShadeMap(overlayMapID)
				end);
			end
		end
	end
	if numPlayers > 0 then
		Controls.PlayersButton:SetHide(not isShowPlayers)
		if numHeadersOpen == 0 then
			Controls.PlayerGrid:SetHide(not isShowPlayers)
			Controls.PlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CIVILIZATIONS"));
		
			isCivHeaderOpen = true
			numHeadersOpen = numHeadersOpen + 1
		else
			Controls.PlayerGrid:SetHide(true)
			Controls.PlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CIVILIZATIONS"));
			
			isCivHeaderOpen = false
		end
		Controls.LegendPlayersStack:CalculateSize();
		Controls.LegendPlayersStack:ReprocessAnchoring();
		Controls.PlayerGrid:SetSizeY(Controls.LegendPlayersStack:GetSizeY() + 5)
		-- Controls.PlayersButton:SetHide(false)
		-- Controls.PlayerGrid:SetHide(not isCivHeaderOpen)
	else
		Controls.PlayersButton:SetHide(true)
		Controls.PlayerGrid:SetHide(true)
	end
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
-------------------------------------------------------------------------------
function OnPlayersButton()
	local overlayMapID = g_SelectedOverlayMapSubID 
	if overlayMapID == -1 then
		overlayMapID = g_SelectedOverlayMapID
	end
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	if Controls.PlayerGrid:IsHidden() then
		Controls.PlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CIVILIZATIONS"));
		Controls.PlayerGrid:SetHide(false)
			
		isCivHeaderOpen = true
	else
		Controls.PlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CIVILIZATIONS"));
		Controls.PlayerGrid:SetHide(true)
			
		isCivHeaderOpen = false
	end
	Controls.LegendPlayersStack:CalculateSize();
	Controls.LegendPlayersStack:ReprocessAnchoring();
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
Controls.PlayersButton:RegisterCallback(Mouse.eLClick, OnPlayersButton);
-------------------------------------------------------------------------------
function PopulateOverlayMinorPlayers(overlayMapID)
	local iActivePlayer = g_SelectedOverlayMapFilterPlayerID
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	
	local tableMapOverlay = g_ActiveOverlayMap[overlayMapType]	
	
	for i, tPlayer in ipairs(g_SortedMinorPlayerEntryTable) do
		local iPlayer = tPlayer[1]
		local pPlayer = Players[iPlayer]	
		local iPlayerTeam = pPlayer:GetTeam()
		local pTeam = Teams[iPlayerTeam]
		if pPlayer:IsAlive() and pPlayer:IsMinorCiv() and ((isActiveTeam and pTeam:IsHasMet(iActiveTeam)) or (not isActiveTeam)) then
			local thisPlayerInfo = g_PlayerLegendsTable[iPlayer]
			local thisLegend = thisPlayerInfo.Legend
			local thisLegendInfo = tableMapOverlay[thisLegend]
			if thisPlayerInfo and thisPlayerInfo.Visible and (thisLegendInfo and thisLegendInfo.Visible) then
				local legend = GameInfo.JFD_OverlayMap_Legends("OverlayMapType = '" .. overlayMapType .. "' AND LegendType = '" .. thisLegend .. "'")()
				local legendInstance = g_LegendMinorPlayerInstanceManager:GetInstance();
				
				numMinorPlayers = numMinorPlayers + 1
				
				local strShortDesc = legend.ShortDescription
				local strPlayerShortDesc = pPlayer:GetCivilizationShortDescription()
				legendInstance.PlayerName:LocalizeAndSetText(strPlayerShortDesc);
				legendInstance.PlayerButton:LocalizeAndSetToolTip(strShortDesc);
				
				if legend.UsePlayerIcon then
					if pPlayer:IsMinorCiv() then
						local minorCivID = pPlayer:GetMinorCivType()
						local minorCivTraitType = GameInfo.MinorCivilizations[minorCivID].MinorCivTrait
						local minorCivTrait = GameInfo.MinorCivTraits[minorCivTraitType]
						local _, minorCivColour = pPlayer:GetPlayerColors()
						local traitTexture = minorCivTrait.TraitIcon
						legendInstance.PlayerTexture:SetTexture(traitTexture)
						legendInstance.PlayerTexture:SetColor(minorCivColour)
						legendInstance.PlayerTexture:SetHide(false)
						legendInstance.PlayerIcon:SetHide(true)
						legendInstance.PlayerFont:SetHide(true)
					else
						local civ = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
						IconHookup( civ.PortraitIndex, 32, civ.IconAtlas, legendInstance.PlayerIcon );
						legendInstance.PlayerIcon:SetHide(false)
						legendInstance.PlayerTexture:SetHide(true)
						legendInstance.PlayerFont:SetHide(true)
					end
				else
					local strFont = legend.IconFont
					if strFont then
						legendInstance.PlayerTexture:SetHide(true)
						legendInstance.PlayerIcon:SetHide(true)
						legendInstance.PlayerFont:SetText(strFont)
						legendInstance.PlayerFont:SetHide(false)
					end
				end
				
				local legendColour = thisPlayerInfo.Colour
				legendInstance.PlayerLine:SetColorVal(legendColour.Red/255, legendColour.Green/255, legendColour.Blue/255, legendColour.Alpha);	
				legendInstance.PlayerLine:SetHide(false)
	
				legendInstance.PlayerSelectHighlight:SetHide(true)
				
				local checked = thisLegendInfo.Checked
				legendInstance.ShowHide:SetHide(false)
				legendInstance.ShowHide:SetCheck(checked);
				
				legendInstance.ShowHide:RegisterCheckHandler( function(bCheck)
					thisPlayerInfo.Checked = bCheck
					ShadeMap(overlayMapID)
				end);
			end
		end
	end
	if numMinorPlayers > 0 then
		Controls.MinorPlayersButton:SetHide(not isShowPlayers)
		if numHeadersOpen == 0 then
			Controls.MinorPlayerGrid:SetHide(not isShowPlayers)
			Controls.MinorPlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CITY_STATES"));
		
			numHeadersOpen = numHeadersOpen + 1			
			isCSHeaderOpen = true
		else
			Controls.MinorPlayerGrid:SetHide(true)
			Controls.MinorPlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CITY_STATES"));		
			
			isCSHeaderOpen = false
		end
		Controls.LegendMinorPlayersStack:CalculateSize();
		Controls.LegendMinorPlayersStack:ReprocessAnchoring();
		Controls.MinorPlayerGrid:SetSizeY(Controls.LegendMinorPlayersStack:GetSizeY() + 5)
		-- Controls.MinorPlayersButton:SetHide(false)
		-- Controls.MinorPlayerGrid:SetHide(not isCSHeaderOpen)
	else
		Controls.MinorPlayersButton:SetHide(true)
		Controls.MinorPlayerGrid:SetHide(true)
	end
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
-------------------------------------------------------------------------------
function OnMinorPlayersButton()
	local overlayMapID = g_SelectedOverlayMapSubID 
	if overlayMapID == -1 then
		overlayMapID = g_SelectedOverlayMapID
	end
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	if Controls.MinorPlayerGrid:IsHidden() then
		Controls.MinorPlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CITY_STATES"));
		Controls.MinorPlayerGrid:SetHide(false)		
		
		isCSHeaderOpen = true
	else
		Controls.MinorPlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CITY_STATES"));
		Controls.MinorPlayerGrid:SetHide(true)		
		
		isCSHeaderOpen = false
	end
	Controls.LegendMinorPlayersStack:CalculateSize();
	Controls.LegendMinorPlayersStack:ReprocessAnchoring();
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
Controls.MinorPlayersButton:RegisterCallback(Mouse.eLClick, OnMinorPlayersButton);
-------------------------------------------------------------------------------
function PopulateOverlayBarbPlayers(overlayMapID)
	local iActivePlayer = g_SelectedOverlayMapFilterPlayerID
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	
	g_LegendBarbPlayerInstanceManager:ResetInstances();	
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	
	local tableMapOverlay = g_ActiveOverlayMap[overlayMapType]	
	for i, tPlayer in ipairs(g_SortedBarbarianPlayerEntryTable) do
		local iPlayer = tPlayer[1]
		local pPlayer = Players[iPlayer]	
		local iPlayerTeam = pPlayer:GetTeam()
		local pTeam = Teams[iPlayerTeam]
		if pPlayer:IsAlive() and pPlayer:IsBarbarian() then
			local thisPlayerInfo = g_PlayerLegendsTable[iPlayer]
			local thisLegend = thisPlayerInfo.Legend
			local thisLegendInfo = tableMapOverlay[thisLegend]
			if thisPlayerInfo and thisPlayerInfo.Visible and (thisLegendInfo and thisLegendInfo.Visible) then
				local legend = GameInfo.JFD_OverlayMap_Legends("OverlayMapType = '" .. overlayMapType .. "' AND LegendType = '" .. thisLegend .. "'")()
				local legendInstance = g_LegendBarbPlayerInstanceManager:GetInstance();
				
				numBarbPlayers = 1
				
				local strShortDesc = legend.ShortDescription
				local strPlayerShortDesc = pPlayer:GetCivilizationShortDescription()
				local strHelp = legend.Help
				legendInstance.PlayerName:LocalizeAndSetText(strPlayerShortDesc);
				legendInstance.PlayerButton:LocalizeAndSetToolTip(strShortDesc);
				
				if legend.UsePlayerIcon then
					if pPlayer:IsMinorCiv() then
						local minorCivID = pPlayer:GetMinorCivType()
						local minorCivTraitType = GameInfo.MinorCivilizations[minorCivID].MinorCivTrait
						local minorCivTrait = GameInfo.MinorCivTraits[minorCivTraitType]
						local _, minorCivColour = pPlayer:GetPlayerColors()
						local traitTexture = minorCivTrait.TraitIcon
						legendInstance.PlayerTexture:SetTexture(traitTexture)
						legendInstance.PlayerTexture:SetColor(minorCivColour)
						legendInstance.PlayerTexture:SetHide(false)
						legendInstance.PlayerIcon:SetHide(true)
						legendInstance.PlayerFont:SetHide(true)
					else
						local civ = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
						IconHookup( civ.PortraitIndex, 32, civ.IconAtlas, legendInstance.PlayerIcon );
						legendInstance.PlayerIcon:SetHide(false)
						legendInstance.PlayerTexture:SetHide(true)
						legendInstance.PlayerFont:SetHide(true)
					end
				else
					local strFont = legend.IconFont
					if strFont then
						legendInstance.PlayerTexture:SetHide(true)
						legendInstance.PlayerIcon:SetHide(true)
						legendInstance.PlayerFont:SetText(strFont)
						legendInstance.PlayerFont:SetHide(false)
					end
				end
				
				local legendColour = thisPlayerInfo.Colour
				legendInstance.PlayerLine:SetColorVal(legendColour.Red/255, legendColour.Green/255, legendColour.Blue/255, legendColour.Alpha);	
				legendInstance.PlayerLine:SetHide(false)
	
				legendInstance.PlayerSelectHighlight:SetHide(true)
				
				local checked = thisLegendInfo.Checked
				legendInstance.ShowHide:SetHide(false)
				legendInstance.ShowHide:SetCheck(checked);
				
				legendInstance.ShowHide:RegisterCheckHandler( function(bCheck)
					thisPlayerInfo.Checked = bCheck
					ShadeMap(overlayMapID)
				end);
			end
		end
	end
	if numBarbPlayers > 0 then
		Controls.BarbPlayersButton:SetHide(not isShowPlayers)
		if numHeadersOpen == 0 then
			Controls.BarbPlayerGrid:SetHide(not isShowPlayers)
			Controls.BarbPlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_BARBARIANS"));
		
			numHeadersOpen = numHeadersOpen + 1		
			isBarbHeaderOpen = true
		else
			Controls.BarbPlayerGrid:SetHide(true)
			Controls.BarbPlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_BARBARIANS"));	
			
			isBarbHeaderOpen = false
		end
		Controls.LegendBarbPlayersStack:CalculateSize();
		Controls.LegendBarbPlayersStack:ReprocessAnchoring();
		Controls.BarbPlayerGrid:SetSizeY(Controls.LegendBarbPlayersStack:GetSizeY() + 5)
		-- Controls.BarbPlayersButton:SetHide(false)
		-- Controls.BarbPlayerGrid:SetHide(false)
	else
		Controls.BarbPlayersButton:SetHide(true)
		Controls.BarbPlayerGrid:SetHide(true)
	end
	Controls.LegendBarbPlayersStack:CalculateSize();
	Controls.LegendBarbPlayersStack:ReprocessAnchoring();
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
-------------------------------------------------------------------------------
function OnBarbPlayersButton()
	local overlayMapID = g_SelectedOverlayMapSubID 
	if overlayMapID == -1 then
		overlayMapID = g_SelectedOverlayMapID
	end
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	if Controls.BarbPlayerGrid:IsHidden() then
		Controls.BarbPlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_BARBARIANS"));
		Controls.BarbPlayerGrid:SetHide(false)	
		
		isBarbHeaderOpen = true
	else
		Controls.BarbPlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_BARBARIANS"));
		Controls.BarbPlayerGrid:SetHide(true)
		
		isBarbHeaderOpen = false
	end
	Controls.LegendBarbPlayersStack:CalculateSize();
	Controls.LegendBarbPlayersStack:ReprocessAnchoring();
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
Controls.BarbPlayersButton:RegisterCallback(Mouse.eLClick, OnBarbPlayersButton);
-------------------------------------------------------------------------------
function PopulateOverlayReligions(overlayMapID)
	local iActivePlayer = g_SelectedOverlayMapFilterPlayerID
	local iActiveTeam = g_SelectedOverlayMapFilterTeamID
	local isActiveTeam = (iActiveTeam ~= -1)
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	
	local tableMapOverlay = g_ActiveOverlayMap[overlayMapType]	

	for i, tPlayer in ipairs(g_SortedPlayerReligionEntryTable) do
		local iPlayer = tPlayer[3]
		local pPlayer = Players[iPlayer]	
		if pPlayer:IsEverAlive() then
			if pPlayer:HasCreatedReligion() then
				local iPlayerTeam = pPlayer:GetTeam()			
				local pTeam = Teams[iPlayerTeam]
				if pPlayer:IsAlive() and ((isActiveTeam and pTeam:IsHasMet(iActiveTeam)) or (not isActiveTeam)) then
					local iReligion = tPlayer[1]
					local thisReligionInfo = g_ReligionLegendsTable[iReligion]
					local thisLegend = thisReligionInfo.Legend
					local thisLegendInfo = tableMapOverlay[thisLegend]
					if thisReligionInfo and thisReligionInfo.Visible and (thisLegendInfo and thisLegendInfo.Visible) then
						local legend = GameInfo.JFD_OverlayMap_Legends("OverlayMapType = '" .. overlayMapType .. "' AND LegendType = '" .. thisLegend .. "'")()
						local legendInstance = g_LegendReligionInstanceManager:GetInstance();
					
						numReligions = numReligions + 1
						
						local strShortDesc = legend.ShortDescription
						local strReligionDesc = Game.GetReligionName(iReligion)
						local strHelp = legend.Help
						legendInstance.ReligionName:LocalizeAndSetText(strShortDesc, strReligionDesc);
						
						if legend.UseReligionFontIcon then
							local religion = GameInfo.Religions[iReligion]
							legendInstance.ReligionFont:SetText(religion.IconString)
							legendInstance.ReligionFont:SetHide(false)
						else
							local strFont = legend.IconFont
							if strFont then
								legendInstance.ReligionFont:SetText(strFont)
								legendInstance.ReligionFont:SetHide(false)
							end
						end
						
						local legendColour = thisReligionInfo.Colour
						legendInstance.ReligionLine:SetColorVal(legendColour.Red/255, legendColour.Green/255, legendColour.Blue/255, legendColour.Alpha);	
						legendInstance.ReligionLine:SetHide(false)
			
						legendInstance.ReligionSelectHighlight:SetHide(true)
						
						local checked = thisLegendInfo.Checked
						legendInstance.ShowHide:SetHide(false)
						legendInstance.ShowHide:SetCheck(checked);
						
						legendInstance.ShowHide:RegisterCheckHandler( function(bCheck)
							thisReligionInfo.Checked = bCheck
							ShadeMap(overlayMapID)
						end);
					end
				end
			end
		end
	end
	if numReligions > 0 then
		Controls.ReligionsButton:SetHide(false)
		if numHeadersOpen == 0 then
			Controls.ReligionGrid:SetHide(false)
			Controls.ReligionsLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_RELIGIONS"));
		
			numHeadersOpen = numHeadersOpen + 1	
			isReliHeaderOpen = true
		else
			Controls.ReligionGrid:SetHide(true)
			Controls.ReligionsLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_RELIGIONS"));
			
			isReliHeaderOpen = false
		end
		Controls.LegendReligionsStack:CalculateSize();
		Controls.LegendReligionsStack:ReprocessAnchoring();
		Controls.ReligionGrid:SetSizeY(Controls.LegendReligionsStack:GetSizeY() + 5)
	else
		Controls.ReligionsButton:SetHide(true)
		Controls.ReligionGrid:SetHide(true)
	end
	Controls.LegendReligionsStack:CalculateSize();
	Controls.LegendReligionsStack:ReprocessAnchoring();
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
-------------------------------------------------------------------------------
function PopulateOverlayMapLegends(overlayMapID)
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	local tableMapOverlay = g_ActiveOverlayMap[overlayMapType]	
	for row in GameInfo.JFD_OverlayMap_Legends("OverlayMapType ='" .. overlayMapType .. "'") do
		local addLegend = true
		local legendType = row.LegendType
		local showInLegendOnlyFiltered = row.ShowInLegendOnlyFiltered
		local showInLegendOption = row.ShowInLegendOption
		local showInLegendOptionNOT = row.ShowInLegendOptionNOT
		if showInLegendOnlyFiltered then
			if g_SelectedOverlayMapFilterPlayerID == -1 then
				addLegend = false
			end	
		end
		if showInLegendOption then
			if (not g_SelectedMapOverlayOptions[showInLegendOption].Check) then
				addLegend = false
			end
		end
		if showInLegendOptionNOT then
			if g_SelectedMapOverlayOptions[showInLegendOptionNOT].Check then
				addLegend = false
			end
		end
		if addLegend then
			local thisLegendInfo = tableMapOverlay[legendType]
			if (thisLegendInfo.Visible or row.ShowInLegendAlways) then
				local legendInstance = g_LegendInstanceManager:GetInstance();
				
				numLegends = numLegends + 1
				
				local strShortDesc = row.ShortDescription
				if row.UseFilteredPlayerDescription then
					strShortDesc = Players[g_SelectedOverlayMapFilterPlayerID]:GetCivilizationShortDescription()
				end
				-- if row.UseTableDescription then
					-- strShortDesc = loadstring("return " .. row.UseTableDescription .. "(...)").Description
				-- end
				--if row.IsPlayerEraType then
				--	strShortDesc = Locale.ConvertTextKey(GameInfo.Eras[row.IsPlayerEraType].Description)
				--end
				legendInstance.LegendName:LocalizeAndSetText(strShortDesc);

				local strHelp = row.Help
				if strHelp then
					legendInstance.LegendButton:LocalizeAndSetToolTip(strHelp);
				else
					legendInstance.LegendButton:LocalizeAndSetToolTip(strShortDesc);
				end
				
				if row.UseFilteredPlayerIcon then
					local pPlayer = Players[g_SelectedOverlayMapFilterPlayerID]
					if pPlayer:IsMinorCiv() then
						local minorCivID = pPlayer:GetMinorCivType()
						local minorCivTraitType = GameInfo.MinorCivilizations[minorCivID].MinorCivTrait
						local minorCivTrait = GameInfo.MinorCivTraits[minorCivTraitType]
						local _, minorCivColour = pPlayer:GetPlayerColors()
						local traitTexture = minorCivTrait.TraitIcon
						legendInstance.PlayerTexture:SetTexture(traitTexture)
						legendInstance.PlayerTexture:SetColor(minorCivColour)
						legendInstance.PlayerTexture:SetHide(false)
						legendInstance.PlayerIcon:SetHide(true)
						legendInstance.LegendFont:SetHide(true)
					else
						local civ = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
						IconHookup( civ.PortraitIndex, 32, civ.IconAtlas, legendInstance.PlayerIcon );
						legendInstance.PlayerIcon:SetHide(false)
						legendInstance.PlayerTexture:SetHide(true)
						legendInstance.LegendFont:SetHide(true)
					end
				else
					local strFont = row.IconFont
					if strFont then
						legendInstance.PlayerTexture:SetHide(true)
						legendInstance.PlayerIcon:SetHide(true)
						legendInstance.LegendFont:SetText(strFont)
						legendInstance.LegendFont:SetHide(false)
					end
				end
				
				local legendColour = thisLegendInfo.Colour
				if (not legendColour) then
					legendColour = GetColour(overlayMapID, legendType, thisLegendInfo)
				end
				legendInstance.LegendLine:SetColorVal(legendColour.Red/255, legendColour.Green/255, legendColour.Blue/255, legendColour.Alpha);	
				legendInstance.LegendLine:SetHide(false)
				
				-- if legendID == g_SelectedMapOverlayLegendID then
					-- legendInstance.LegendSelectHighlight:SetHide(true)			
				-- else
					-- legendInstance.LegendSelectHighlight:SetHide(true)			
				-- end
				-- legendInstance.LegendButton:SetVoid1(row.ID) 
				-- legendInstance.LegendButton:RegisterCallback(Mouse.eLClick, function() 
					-- g_SelectedMapOverlayLegendID = legendID
					-- legendInstance.LegendSelectHighlight:SetHide(false)
					-- RefreshMapLegend(overlayMapID, overlayMapFilterID, overlayMapFilterPlayerID)
				-- end)
				legendInstance.LegendButton:SetHide(false)
				
				local checked = thisLegendInfo.Checked
				legendInstance.ShowHide:SetHide(false)
				legendInstance.ShowHide:SetCheck(checked);
				
				legendInstance.ShowHide:RegisterCheckHandler( function(bCheck)
					thisLegendInfo.Checked = bCheck
					ShadeMap(overlayMapID)
				end);
			end
		end
	end
	if numLegends > 0 then
		Controls.LegendButton:SetHide(isShowPlayers)
		if numHeadersOpen == 0 then
			Controls.LegendGrid:SetHide(isShowPlayers)
			Controls.LegendLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_LEGEND"));
		
			numHeadersOpen = numHeadersOpen + 1
			isLegendHeaderOpen = true
		else
			Controls.LegendGrid:SetHide(true)
			Controls.LegendLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_LEGEND"));
			
			isLegendHeaderOpen = false
		end
		Controls.LegendStack:CalculateSize();
		Controls.LegendStack:ReprocessAnchoring();
		Controls.LegendGrid:SetSizeY(Controls.LegendStack:GetSizeY() + 5)
		-- Controls.LegendButton:SetHide(false)
		-- Controls.LegendGrid:SetHide(false)
	else
		Controls.LegendButton:SetHide(true)
		Controls.LegendGrid:SetHide(true)
	end
	Controls.LegendStack:CalculateSize();
	Controls.LegendStack:ReprocessAnchoring();
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
-------------------------------------------------------------------------------
function OnLegendButton()
	local overlayMapID = g_SelectedOverlayMapSubID 
	if overlayMapID == -1 then
		overlayMapID = g_SelectedOverlayMapID
	end
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	if Controls.LegendGrid:IsHidden() then
		Controls.LegendLabel:SetText("[ICON_MINUS]" ..  Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_LEGEND"));
		Controls.LegendGrid:SetHide(false)
		
		isLegendHeaderOpen = true
	else
		Controls.LegendLabel:SetText("[ICON_PLUS]" ..  Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_LEGEND"));
		Controls.LegendGrid:SetHide(true)
		
		isLegendHeaderOpen = false
	end
	Controls.LegendStack:CalculateSize();
	Controls.LegendStack:ReprocessAnchoring();
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
Controls.LegendButton:RegisterCallback(Mouse.eLClick, OnLegendButton);
-------------------------------------------------------------------------------
function PopulateOverlayMapOptions(overlayMapID)
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	
	Controls.ShowHideInactive:SetHide(true)
	Controls.ShowHidePillagedTiles:SetHide(true)
	Controls.ShowHideWaterTiles:SetHide(true)
	Controls.ShowHideBarbs:SetHide(true)
	Controls.ShowHideCityTiles:SetHide(true)
	Controls.ShowHideEmbarkedUnits:SetHide(true)
	Controls.ShowHideBorders:SetHide(true)
	Controls.ShowHideCities:SetHide(true)
	-- Controls.ShowHideCitiesLabel:SetHide(true)
	Controls.ShowHideStarts:SetHide(true)
	
	local numOptions = 0
	for row in GameInfo.JFD_OverlayMapOptions() do
		local optionType = row.Type
		local isValid = GameInfo.JFD_OverlayMap_Options("OverlayMapType = '" .. overlayMapType .. "' AND OptionType = '" .. optionType .. "'")()
		if (not g_SelectedMapOverlayOptions[optionType]) then
			g_SelectedMapOverlayOptions[optionType] = {}
		end
		local option = g_SelectedMapOverlayOptions[optionType]
		option.IsValid = isValid
		
		if isValid then
			local isDefaultChecked = isValid.DefaultChecked
		
			numOptions = numOptions + 1
			
			local optionChecked = option.Check or isDefaultChecked
			local strShortDesc = row.ShortDescription
			local strHelp = row.Help
			
			function OnShowHideOption(bCheck)
				option.Check = bCheck
				ShadeMap(overlayMapID)
			end
			function OnShowHideOptionBarbs(bCheck)
				option.Check = bCheck
				ShadeMap(g_SelectedOverlayMapSubID)
				
				local optionIncludeBarbs = g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS"]
				if optionIncludeBarbs.Check and optionIncludeBarbs.IsValid then
					PopulateOverlayBarbPlayers(g_SelectedOverlayMapSubID)
						
					Controls.BarbPlayersButton:SetHide(false)
					-- Controls.BarbPlayerGrid:SetHide(not isShowPlayers)
					Controls.BarbPlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_BARBARIANS"));
				else
					Controls.BarbPlayersButton:SetHide(true)
					Controls.BarbPlayerGrid:SetHide(true)
				end
			end
			option.Check = optionChecked
			
			-- if optionType == "OVERLAY_JFD_OPTION_EXCLUDE_INACTIVE" then
				-- Controls.ShowHideInactive:SetHide(false)
				-- Controls.ShowHideInactive:RegisterCheckHandler(OnShowHideOption);
				-- Controls.ShowHideInactive:SetCheck(optionChecked);
				-- if strHelp then
					-- Controls.ShowHideInactive:LocalizeAndSetToolTip(strHelp);
				-- end
			-- elseif optionType == "OVERLAY_JFD_OPTION_EXCLUDE_PILLAGED_TILES" then
			if optionType == "OVERLAY_JFD_OPTION_EXCLUDE_PILLAGED_TILES" then
				Controls.ShowHidePillagedTiles:SetHide(false)
				Controls.ShowHidePillagedTiles:RegisterCheckHandler(OnShowHideOption);
				Controls.ShowHidePillagedTiles:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHidePillagedTiles:LocalizeAndSetToolTip(strHelp);
				end
			elseif optionType == "OVERLAY_JFD_OPTION_EXCLUDE_WATER_TILES" then
				Controls.ShowHideWaterTiles:SetHide(false)
				Controls.ShowHideWaterTiles:RegisterCheckHandler(OnShowHideOption);
				Controls.ShowHideWaterTiles:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHideWaterTiles:LocalizeAndSetToolTip(strHelp);
				end
			elseif optionType == "OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS" then
				Controls.ShowHideBarbs:SetHide(false)
				Controls.ShowHideBarbs:RegisterCheckHandler(OnShowHideOptionBarbs);
				Controls.ShowHideBarbs:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHideBarbs:LocalizeAndSetToolTip(strHelp);
				end
			elseif optionType == "OVERLAY_JFD_OPTION_INCLUDE_CITY_TILES" then
				Controls.ShowHideCityTiles:SetHide(false)
				Controls.ShowHideCityTiles:RegisterCheckHandler(OnShowHideOption);
				Controls.ShowHideCityTiles:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHideCityTiles:LocalizeAndSetToolTip(strHelp);
				end
			elseif optionType == "OVERLAY_JFD_OPTION_INCLUDE_EMARBKED_UNITS" then
				Controls.ShowHideEmbarkedUnits:SetHide(false)
				Controls.ShowHideEmbarkedUnits:RegisterCheckHandler(OnShowHideOption);
				Controls.ShowHideEmbarkedUnits:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHideEmbarkedUnits:LocalizeAndSetToolTip(strHelp);
				end
			elseif optionType == "OVERLAY_JFD_OPTION_SHOW_BORDERS" then
				Controls.ShowHideBorders:SetHide(false)
				Controls.ShowHideBorders:RegisterCheckHandler(OnShowHideOption);
				Controls.ShowHideBorders:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHideBorders:LocalizeAndSetToolTip(strHelp);
				end
			elseif optionType == "OVERLAY_JFD_OPTION_SHOW_CITIES" then
				Controls.ShowHideCities:SetHide(false)
				-- Controls.ShowHideCitiesLabel:SetHide(false)
				Controls.ShowHideCities:RegisterCheckHandler(OnShowHideOption);
				Controls.ShowHideCities:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHideCities:LocalizeAndSetToolTip(strHelp);
				end
			elseif optionType == "OVERLAY_JFD_OPTION_SHOW_STARTS" then
				Controls.ShowHideStarts:SetHide(false)
				Controls.ShowHideStarts:RegisterCheckHandler(OnShowHideOption);
				Controls.ShowHideStarts:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHideStarts:LocalizeAndSetToolTip(strHelp);
				end
			elseif optionType == "OVERLAY_JFD_OPTION_SHOW_TERRAIN" then
				Controls.ShowHideTerrain:SetHide(false)
				Controls.ShowHideTerrain:RegisterCheckHandler(OnShowHideOption);
				Controls.ShowHideTerrain:SetCheck(optionChecked);
				if strHelp then
					Controls.ShowHideTerrain:LocalizeAndSetToolTip(strHelp);
				end
			end	
		end	
	end
	if numOptions > 0 then
		Controls.OptionsButton:SetHide(false)
		Controls.OptionsGrid:SetHide(false)
		Controls.OptionsLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_OPTIONS"));
		Controls.LegendOptionsStack:CalculateSize();
		Controls.LegendOptionsStack:ReprocessAnchoring();
		Controls.OptionsGrid:SetSizeY(Controls.LegendOptionsStack:GetSizeY())
	end
end
-------------------------------------------------------------------------------
function OnOptionsButton()
	if Controls.OptionsGrid:IsHidden() then
		Controls.OptionsLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_OPTIONS"));
		Controls.OptionsGrid:SetHide(false)
		
		isOptionsHeaderOpen = true
	else
		Controls.OptionsLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_OPTIONS"));
		Controls.OptionsGrid:SetHide(true)
		
		isOptionsHeaderOpen = false
	end
end
Controls.OptionsButton:RegisterCallback(Mouse.eLClick, OnOptionsButton);
-------------------------------------------------------------------------------
function OnShowPlayersButton()
	if Controls.PlayerGrid:IsHidden() then
		isShowPlayers = true
		
		Controls.PlayersButton:SetHide(false)
		Controls.PlayerGrid:SetHide(false)
		Controls.PlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CIVILIZATIONS"));
		
		if numMinorPlayers > 0 then
			Controls.MinorPlayersButton:SetHide(false)
			-- Controls.MinorPlayerGrid:SetHide(false)
			Controls.MinorPlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_OVERLAY_JFD_CITY_STATES"));
		end
		
		local optionIncludeBarbs = g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS"]
		if optionIncludeBarbs.Check and optionIncludeBarbs.IsValid then
			Controls.BarbPlayersButton:SetHide(false)
		end
		
		Controls.LegendButton:SetHide(true)
		Controls.LegendGrid:SetHide(true)
		
		Controls.ShowPlayersButtonLabel:LocalizeAndSetText("TXT_KEY_OVERLAY_JFD_SHOW_LEGEND")
	else	
		isShowPlayers = false
		
		Controls.PlayersButton:SetHide(true)
		Controls.PlayerGrid:SetHide(true)
		Controls.MinorPlayersButton:SetHide(true)
		Controls.MinorPlayerGrid:SetHide(true)
		Controls.BarbPlayersButton:SetHide(true)
		Controls.BarbPlayerGrid:SetHide(true)
		Controls.LegendButton:SetHide(false)
		Controls.LegendGrid:SetHide(false)
		
		Controls.ShowPlayersButtonLabel:LocalizeAndSetText("TXT_KEY_OVERLAY_JFD_SHOW_PLAYERS")
	end
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
Controls.ShowPlayersButton:RegisterCallback(Mouse.eLClick, OnShowPlayersButton);
-------------------------------------------------------------------------------
function RefreshMapLegend(overlayMapID)
	numHeadersOpen = 0 
	
	g_LegendInstanceManager:ResetInstances();	
	g_LegendPlayerInstanceManager:ResetInstances();	
	g_LegendBarbPlayerInstanceManager:ResetInstances();	
	g_LegendMinorPlayerInstanceManager:ResetInstances();	
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	local overlayMasterMapType = overlayMap.MasterOverlayMapType
	local overlayMapDontShowLegend = overlayMap.DontShowLegend
	local overlayMapPopulateReligions = overlayMap.PopulateReligions
	local overlayMapPopulatePlayers = overlayMap.PopulatePlayers
	local overlayMapPopulateRankings = overlayMap.PopulateRankings
	if (not overlayMapDontShowLegend) then
		if overlayMapPopulateReligions then
			PopulateOverlayReligions(overlayMapID)
		else
			PopulateOverlayMapLegends(overlayMapID)
		end
		isShowPlayers = false
		Controls.ShowPlayersButtonLabel:LocalizeAndSetText("TXT_KEY_OVERLAY_JFD_SHOW_PLAYERS")
		Controls.ShowPlayersButton:SetDisabled(true)
		
		Controls.LegendButton:SetHide(false)
		Controls.LegendGrid:SetHide(false)
		
		Controls.ReligionsButton:SetHide(true)
		Controls.ReligionGrid:SetHide(true)
		Controls.PlayersButton:SetHide(true)
		Controls.PlayerGrid:SetHide(true)
		Controls.MinorPlayersButton:SetHide(true)
		Controls.MinorPlayerGrid:SetHide(true)
		Controls.BarbPlayersButton:SetHide(true)
		Controls.BarbPlayerGrid:SetHide(true)
		
	else
		isShowPlayers = true
		Controls.ShowPlayersButtonLabel:LocalizeAndSetText("TXT_KEY_OVERLAY_JFD_SHOW_LEGEND")
		Controls.ShowPlayersButton:SetDisabled(true)
		
		Controls.LegendButton:SetHide(true)
		Controls.LegendGrid:SetHide(true)
	end
	if overlayMapPopulateRankings then
		PopulateOverlayPlayerRankings(overlayMapID)
	elseif overlayMapPopulatePlayers then
		if g_SelectedOverlayMapFilterID ~= -1 then
			local overlayMapFilter = GameInfo.JFD_OverlayMapFilters[g_SelectedOverlayMapFilterID]
			local overlayMapFilterType = overlayMapFilter.Type
			if overlayMapFilterType == "OVERLAY_FILTER_JFD_ALL_PLAYERS" then
				PopulateOverlayPlayers(overlayMapID)
				PopulateOverlayMinorPlayers(overlayMapID)
				
				Controls.PlayersButton:SetHide(not isShowPlayers)
				Controls.PlayerGrid:SetHide(not isShowPlayers)
			elseif overlayMapFilterType == "OVERLAY_FILTER_JFD_ALL_MAJORS" then
				PopulateOverlayPlayers(overlayMapID)
				Controls.MinorPlayersButton:SetHide(true)
				Controls.MinorPlayerGrid:SetHide(true)
				
				Controls.PlayersButton:SetHide(not isShowPlayers)
				Controls.PlayerGrid:SetHide(not isShowPlayers)
			elseif overlayMapFilterType == "OVERLAY_FILTER_JFD_ALL_MINORS" then
				PopulateOverlayMinorPlayers(overlayMapID)
				Controls.PlayersButton:SetHide(true)
				Controls.PlayerGrid:SetHide(true)
				
				Controls.MinorPlayersButton:SetHide(not isShowPlayers)
				Controls.MinorPlayerGrid:SetHide(not isShowPlayers)
			end
		end
		local optionIncludeBarbs = g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS"]
		if optionIncludeBarbs.Check and optionIncludeBarbs.IsValid then
			PopulateOverlayBarbPlayers(overlayMapID)
				
			Controls.BarbPlayersButton:SetHide(not isShowPlayers)
			-- Controls.BarbPlayerGrid:SetHide(not isShowPlayers)
		end
		Controls.ShowPlayersButton:SetDisabled(overlayMapDontShowLegend)
	end
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function RefreshMap(overlayMapID)
	PopulateActiveOverlayMap(overlayMapID)
	PopulateOverlayMapOptions(overlayMapID)
	ShadeMap(overlayMapID)
	RefreshMapLegend(overlayMapID)
end
-------------------------------------------------------------------------------
function RefreshOverlayMapFilterPlayer(overlayMapClassID, overlayMapFilterPlayerID)

	if g_SelectedOverlayMapFilterPlayerID ~= overlayMapFilterPlayerID then
		g_SelectedOverlayMapFilterPlayerID = overlayMapFilterPlayerID
		if overlayMapFilterPlayerID ~= -1 then
			g_SelectedOverlayMapFilterTeamID = Players[overlayMapFilterPlayerID]:GetTeam()
		else
			g_SelectedOverlayMapFilterTeamID = -1
		end	
	end	

	if overlayMapFilterPlayerID ~= -1 then
		local strCivDesc = Players[overlayMapFilterPlayerID]:GetCivilizationShortDescription()
		Controls.OverlayMapFilterPlayerPullDown:GetButton():LocalizeAndSetText("TXT_KEY_OVERLAY_FILTER_JFD_PLAYER_SHOW_PLAYER", Locale.ToUpper(strCivDesc))
		Controls.OverlayMapFilterPlayerPullDown:GetButton():LocalizeAndSetToolTip("TXT_KEY_OVERLAY_FILTER_JFD_PLAYER_SHOW_PLAYER_TT")
	else
		Controls.OverlayMapFilterPlayerPullDown:GetButton():LocalizeAndSetText("TXT_KEY_OVERLAY_FILTER_JFD_PLAYER_SHOW_ALL")
		Controls.OverlayMapFilterPlayerPullDown:GetButton():LocalizeAndSetToolTip("TXT_KEY_OVERLAY_FILTER_JFD_PLAYER_SHOW_ALL_TT")
	end
	
	RefreshOverlayMaps(overlayMapClassID)
end
-------------------------------------------------------------------------------
function RefreshOverlayMapFilterPlayers(overlayMapClassID, overlayMapFilterID)
	local overlayMapClass = GameInfo.JFD_OverlayMapClasses[overlayMapClassID]
	local overlayMapClassType = overlayMapClass.Type
	
	local overlayMapFilter = GameInfo.JFD_OverlayMapFilters[overlayMapFilterID]
	local overlayMapFilterType = overlayMapFilter.Type
	if overlayMapFilterType == "OVERLAY_FILTER_JFD_ALL_MAJORS" then
		g_SelectedMapOverlayPlayers = g_SortedMajorPlayerEntryTable
	elseif overlayMapFilterType == "OVERLAY_FILTER_JFD_ALL_MINORS" then
		g_SelectedMapOverlayPlayers = g_SortedMinorPlayerEntryTable
	else	
		local optionIncludeBarbs = g_SelectedMapOverlayOptions["OVERLAY_JFD_OPTION_INCLUDE_BARBARIANS"]
		if optionIncludeBarbs and (optionIncludeBarbs.Check and optionIncludeBarbs.IsValid) then
			g_SelectedMapOverlayPlayers = g_SortedPlayerPlusBarbsEntryTable
		else
			g_SelectedMapOverlayPlayers = g_SortedPlayerEntryTable
		end
	end
	
	Controls.OverlayMapFilterPlayerPullDown:ClearEntries()
	
	if (not overlayMapClass.OnlyValidActivePlayer) then
		local entry = {}
		Controls.OverlayMapFilterPlayerPullDown:BuildEntry("InstanceOne", entry)
		entry.Button:SetVoids(overlayMapClassID, -1)
		entry.Button:LocalizeAndSetText("TXT_KEY_OVERLAY_FILTER_JFD_PLAYER_SHOW_ALL")
	end

	Controls.OverlayMapFilterPlayerPullDown:SetHide(false)
	Controls.OverlayMapFilterPlayerPullDown:CalculateInternals()
	Controls.OverlayMapFilterPlayerPullDown:RegisterSelectionCallback(RefreshOverlayMapFilterPlayer)
	
	for i, tPlayer in ipairs(g_SelectedMapOverlayPlayers) do
		local iPlayer = tPlayer[1]
		local pPlayer = Players[iPlayer]	
		if pPlayer:IsAlive() 
		and ((isOnlyMajorPlayers and (not pPlayer:IsMinorCiv())) or (not isOnlyMajorPlayers)) 
		and ((isOnlyMinorPlayers and pPlayer:IsMinorCiv()) or (not isOnlyMinorPlayers)) then
			local entry = {}
			local strCivShortDesc = pPlayer:GetCivilizationShortDescription()
			Controls.OverlayMapFilterPlayerPullDown:BuildEntry("InstanceOne", entry)
			entry.Button:SetVoids(overlayMapClassID, iPlayer)
			entry.Button:SetText(strCivShortDesc)
		end
	end
	
	Controls.OverlayMapFilterPlayerPullDown:SetHide(false)
	Controls.OverlayMapFilterPlayerPullDown:CalculateInternals()
	Controls.OverlayMapFilterPlayerPullDown:RegisterSelectionCallback(RefreshOverlayMapFilterPlayer)
	
	if overlayMapClass.OnlyValidActivePlayer then
		if g_SelectedOverlayMapFilterPlayerID == -1 then
			RefreshOverlayMapFilterPlayer(overlayMapClassID, Game.GetActivePlayer())
		else
			RefreshOverlayMapFilterPlayer(overlayMapClassID, g_SelectedOverlayMapFilterPlayerID)
		end
	else
		RefreshOverlayMapFilterPlayer(overlayMapClassID, -1)
	end
end
-------------------------------------------------------------------------------
function RefreshOverlayMapFilter(overlayMapClassID, overlayMapFilterID)
	
	if g_SelectedOverlayMapFilterID ~= overlayMapFilterID then
		g_SelectedOverlayMapFilterID = overlayMapFilterID
		g_SelectedOverlayMapFilterPlayerID = -1
		g_SelectedOverlayMapFilterTeamID = -1
	end	

	local overlayMapFilter = GameInfo.JFD_OverlayMapFilters[overlayMapFilterID]
	local overlayMapFilterType = overlayMapFilter.Type
	local strShortDesc = overlayMapFilter.ShortDescription
	local strHelp = overlayMapFilter.Help
	Controls.OverlayMapFilterPullDown:GetButton():LocalizeAndSetText(strShortDesc)
	if strHelp then
		Controls.OverlayMapFilterPullDown:GetButton():LocalizeAndSetToolTip(strHelp)
	end
	
	RefreshOverlayMapFilterPlayers(overlayMapClassID, overlayMapFilterID)
end
-------------------------------------------------------------------------------
function RefreshOverlayMapFilters(overlayMapClassID)
	local numFilters = 0
	local defaultActiveID = 0
	Controls.OverlayMapFilterPullDown:ClearEntries()

	local overlayMapClass = GameInfo.JFD_OverlayMapClasses[overlayMapClassID]
	local isOnlyMajorPlayers = overlayMapClass.OnlyValidMajorPlayers
	local isOnlyMinorPlayers = overlayMapClass.OnlyValidMinorPlayers
	for row in GameInfo.JFD_OverlayMapFilters() do
		local overlayMapFilterID = row.ID
		local overlayMapFilterType = row.Type
		local strShortDesc = row.ShortDescription
		local strHelp = row.Help

		local addEntry = true
		if overlayMapFilterType == "OVERLAY_FILTER_JFD_ALL_PLAYERS" then
			addEntry = ((not isOnlyMinorPlayers) and (not isOnlyMajorPlayers))
		elseif overlayMapFilterType == "OVERLAY_FILTER_JFD_ALL_MAJORS" then
			addEntry = (not isOnlyMinorPlayers)
		elseif overlayMapFilterType == "OVERLAY_FILTER_JFD_ALL_MINORS" then
			addEntry = (not isOnlyMajorPlayers)
		end
		
		local entry = {}
		Controls.OverlayMapFilterPullDown:BuildEntry("InstanceOne", entry)
		entry.Button:SetVoids(overlayMapClassID, overlayMapFilterID)
		entry.Button:LocalizeAndSetText(strShortDesc)
		if strHelp then
			entry.Button:LocalizeAndSetToolTip(strHelp)
		end
	
		if g_SelectedOverlayMapFilterID == -1 then
			g_SelectedOverlayMapFilterID = overlayMapFilterID
		end
		numFilters = numFilters + 1
	end
	if numFilters > 0 then
		Controls.OverlayMapFilterPullDown:SetHide(false) 	
		Controls.OverlayMapFilterPullDown:CalculateInternals()
		Controls.OverlayMapFilterPullDown:RegisterSelectionCallback(RefreshOverlayMapFilter)
	else
		Controls.OverlayMapFilterPullDown:SetHide(true) 	
	end
	RefreshOverlayMapFilter(overlayMapClassID, g_SelectedOverlayMapFilterID)
end
-------------------------------------------------------------------------------
function RefreshOverlayMapSub(overlayMapSubID)
	local overlayMapSub = GameInfo.JFD_OverlayMaps[overlayMapSubID]
	Controls.OverlayMapSubsPullDown:GetButton():LocalizeAndSetText(overlayMapSub.ShortDescription)
	
	RefreshMap(overlayMapSubID)
end
-------------------------------------------------------------------------------
function RefreshOverlayMap(overlayMapID)

	if g_SelectedOverlayMapID ~= overlayMapID then
		g_SelectedOverlayMapID = overlayMapID
		g_SelectedOverlayMapSubID = -1
	end		
	
	local overlayMap = GameInfo.JFD_OverlayMaps[overlayMapID]
	local overlayMapType = overlayMap.Type
	Controls.OverlayMapsPullDown:GetButton():SetText(Locale.ToUpper(overlayMap.ShortDescription))
	
	Controls.OverlayMapSubsPullDown:ClearEntries()	
	local numOverlayMapSubs = 0
	for row in GameInfo.JFD_OverlayMaps("MasterOverlayMapType = '" .. overlayMapType .. "'") do
		local overlayMapSubType = row.Type
		local overlayMapSubID = GameInfoTypes[overlayMapSubType]
		local overlayMapSub = GameInfo.JFD_OverlayMaps[overlayMapSubID]
		local strShortDesc = overlayMapSub.ShortDescription
		
		local entry = {}
		local addEntry = true
		if addEntry then
			Controls.OverlayMapSubsPullDown:BuildEntry("InstanceOne", entry)
			entry.Button:SetVoid1(overlayMapSubID)
			entry.Button:LocalizeAndSetText(strShortDesc)
		
			if g_SelectedOverlayMapSubID == -1 then
				g_SelectedOverlayMapSubID = overlayMapSubID
			end
			numOverlayMapSubs = numOverlayMapSubs + 1
		end
	end
	if numOverlayMapSubs > 0 then
		Controls.OverlayMapSubsPullDown:CalculateInternals()
		Controls.OverlayMapSubsPullDown:RegisterSelectionCallback(RefreshOverlayMapSub)
		Controls.OverlayMapSubsPullDown:SetHide(false) 
		Controls.OverlayMapSubsPulldownStack:ReprocessAnchoring();
		RefreshOverlayMapSub(g_SelectedOverlayMapSubID)
	else
		RefreshMap(overlayMapID)
	end
end
-------------------------------------------------------------------------------
function RefreshOverlayMaps(overlayMapClassID)	
	local overlayMapClass = GameInfo.JFD_OverlayMapClasses[overlayMapClassID]
	local overlayMapClassType = overlayMapClass.Type
	Controls.OverlayMapsPullDown:ClearEntries()	
	for row in GameInfo.JFD_OverlayMaps("ClassType = '" .. overlayMapClassType .. "' AND MasterOverlayMapType IS NULL") do
		local overlayMapID = row.ID
		local strShortDesc = row.ShortDescription
		local strHelp = row.Help
		
		local addEntry = true
		if row.RequiresJFDLL then
			addEntry = isJFDLLActive
		end
		if row.RequiresToExist then
			addEntry = GameInfoTypes[row.RequiresToExist]
		end

		if addEntry then
			local entry = {}
			Controls.OverlayMapsPullDown:BuildEntry("InstanceOne", entry)
			entry.Button:SetVoid1(overlayMapID)
			entry.Button:SetText(Locale.ToUpper(strShortDesc))
			if strHelp then
				entry.Button:LocalizeAndSetToolTip(Locale.ToUpper(strShortDesc))
			end
		
			if g_SelectedOverlayMapID == -1 then
				g_SelectedOverlayMapID = overlayMapID
			end
		end
	end
	Controls.OverlayMapsPullDown:CalculateInternals()
	Controls.OverlayMapsPullDown:RegisterSelectionCallback(RefreshOverlayMap)
	Controls.OverlayMapsPullDown:SetHide(false) 

	RefreshOverlayMap(g_SelectedOverlayMapID)
end
-------------------------------------------------------------------------------
function RefreshOverlayMapClass(overlayMapClassID)

	if g_SelectedOverlayMapClassID ~= overlayMapClassID then
		g_SelectedOverlayMapClassID = overlayMapClassID
		g_SelectedOverlayMapID = -1
		g_SelectedOverlayMapSubID = -1
		g_SelectedOverlayMapFilterID = -1
		g_SelectedOverlayMapFilterPlayerID = -1
		g_SelectedOverlayMapFilterTeamID = -1
	end		
	
	local overlayMapClass = GameInfo.JFD_OverlayMapClasses[overlayMapClassID]
	local overlayMapClassType = overlayMapClass.Type
	local strDesc = overlayMapClass.ShortDescription
	local strHelp = overlayMapClass.Help
	Controls.OverlayMapClassesPullDownLabel:SetText(Locale.ToUpper(strDesc))
	
	RefreshOverlayMapFilters(overlayMapClassID)
end
-------------------------------------------------------------------------------
function RefreshOverlayMapsOverview()	
	Controls.OverlayMapClassesPullDown:ClearEntries()	
	for row in GameInfo.JFD_OverlayMapClasses() do
		local strDesc = row.ShortDescription
		local strHelp = row.Help
		
		local entry = {}
		Controls.OverlayMapClassesPullDown:BuildEntry("InstanceOne", entry)
		entry.Button:SetVoid1(row.ID)
		entry.Button:SetText(Locale.ToUpper(strDesc))
		if strHelp then
			entry.Button:LocalizeAndSetToolTip(strHelp)
		end
		
		if g_SelectedOverlayMapClassID == -1 then
			g_SelectedOverlayMapClassID = row.ID
		end
	end
	Controls.OverlayMapClassesPullDown:CalculateInternals()
	Controls.OverlayMapClassesPullDown:RegisterSelectionCallback(RefreshOverlayMapClass)
	Controls.OverlayMapClassesPullDown:SetHide(false) 
	RefreshOverlayMapClass(g_SelectedOverlayMapClassID)
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();  
        	--Events.SerialEventGameMessagePopupShown(g_PopupInfo);
        	
           RefreshOverlayMapsOverview()
			 -- MODS END
        else
			if(g_PopupInfo ~= nil) then
				--Events.SerialEventGameMessagePopupProcessed.CallImmediate(g_PopupInfo.Type, 0);
            end
            UI.decTurnTimerSemaphore();
        end
    end
end
ContextPtr:SetShowHideHandler( ShowHideHandler );

----------------------------------------------------------------
-- 'Active' (local human) player has changed
----------------------------------------------------------------
function OnActivePlayerChanged()
	--if (not Controls.ChooseConfirm:IsHidden()) then
	--	Controls.ChooseConfirm:SetHide(true);
	--end
end
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged);

-----------------------------------------------------------------
-- Add Religion Overview to Dropdown (if enabled)
-----------------------------------------------------------------
--LuaEvents.AdditionalInformationDropdownGatherEntries.Add(function(entries)
--	table.insert(entries, {
--		text=Locale.Lookup("TXT_KEY_OVERLAY_JFD_OVERVIEW"),
--		call=function()
--			UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
--		end,
--	});
--	table.insert(entries, {
--		text=Locale.Lookup("Open Civilopedia"),
--		call=function()
--			Events.SearchForPediaEntry("");
--		end,
--	});
--end);

-- Just in case :)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();

function JFD_UI_ShowOverlayMapsOverview()
	if ContextPtr:IsHidden() then
		UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
	else
		UIManager:DequeuePopup(ContextPtr)
	end
end
LuaEvents.JFD_UI_ShowOverlayMapsOverview.Add(JFD_UI_ShowOverlayMapsOverview);


UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
UIManager:DequeuePopup(ContextPtr)
