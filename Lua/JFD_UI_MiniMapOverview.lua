-------------------------------------------------
-- MiniMap Overview Popup
-------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );
include( "JFD_AIObserver_Minimap_Utils.lua" );

local isBNW = ContentManager.IsActive("6DA07636-4123-4018-B643-6575B4EC336B", ContentType.GAMEPLAY)
local isJFDLLActive = Game.IsJFDLLActive()
-------------------------------------------------
-- Global Constants
-------------------------------------------------

local Colours = {
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
local CityColours = {}
local PlayerColours = {}
local ReligionColours = {}

local iFeatureIce = GameInfoTypes.FEATURE_ICE
local iTerrainCoast = GameInfoTypes.TERRAIN_COAST
local iTerrainOcean = GameInfoTypes.TERRAIN_OCEAN
local iTerrainDesert = GameInfoTypes.TERRAIN_DESERT

g_LegendInstanceManager = InstanceManager:new("LegendInstance", "LegendButton", Controls.LegendStack);
g_LegendPlayerInstanceManager = InstanceManager:new("PlayerInstance", "PlayerButton", Controls.LegendPlayersStack);
g_LegendMinorPlayerInstanceManager = InstanceManager:new("MinorPlayerInstance", "MinorPlayerButton", Controls.LegendMinorPlayersStack);

local mapWidth, mapHeight = Map.GetGridSize()
Controls.Map:SetMapSize(mapWidth, mapHeight, 0,-1)

local iCBRXWidth, iCBRXHeight = 180,94
local iMainGridCBRX, iMainGridCBRY = 1110,653
local iMapCBRX, iMapCBRXY = -50,-10
local iScrollGridCBRX, iScrollGridCBRY = -40,-10
local iShowPlayersButtonCBRX, iShowPlayersButtonCBRY = -40,25
local iOverlayPulldownCBRX, iOverlayPulldownCBRY = -55,-10
local iOverlayFilterPulldownCBRX, iOverlayFilterPulldownCBRY = -55,-70
local iHorizontalTrimTopCBRSizeX, iHorizontalTrimTopCBRSizeY = 1030,5
local iHorizontalTrimTopCBRX, iHorizontalTrimTopCBRY = 0,25
local iBottomTrimTopCBRX, iBottomTrimTopCBRY = 1030,5
local iCloseButtonCBRX, iCloseButtonCBRY = -65,54
local iMapSubPulldownCBRX, iMapSubPulldownCBRY = 120,-10
local iOptionsStackX, iOptionsStackY = 60,-35

if mapWidth == iCBRXWidth and mapHeight == iCBRXHeight then
	Controls.MainGrid:SetSizeVal(iMainGridCBRX, iMainGridCBRY)
	Controls.Map:SetOffsetVal(iMapCBRX,iMapCBRXY)
	Controls.ScrollGrid:SetOffsetVal(iScrollGridCBRX,iScrollGridCBRY)
	-- Controls.PlayersButton:SetOffsetVal(iShowPlayersButtonCBRX,iShowPlayersButtonCBRY)
	Controls.MiniMapOverlayPulldown:SetOffsetVal(iOverlayPulldownCBRX,iOverlayPulldownCBRY)
	Controls.MiniMapFilterPulldown:SetOffsetVal(iOverlayFilterPulldownCBRX,iOverlayFilterPulldownCBRY)
	-- Controls.OverlayMapSubsPulldownStack:SetOffsetVal(iMapSubPulldownCBRX,iMapSubPulldownCBRY)
	Controls.HorizontalTrimTop:SetSizeVal(iHorizontalTrimTopCBRSizeX,iHorizontalTrimTopCBRSizeY)
	Controls.HorizontalTrimTop:SetOffsetVal(iHorizontalTrimTopCBRX,iHorizontalTrimTopCBRY)
	Controls.CloseButtonBox:SetOffsetVal(iCloseButtonCBRX,iCloseButtonCBRY)
	Controls.MapTrimBottom:SetSizeVal(iBottomTrimTopCBRX,iBottomTrimTopCBRY)
	Controls.OptionsStack:SetOffsetVal(iOptionsStackX,iOptionsStackY)
end
-------------------------------------------------
-- Global Variables
-------------------------------------------------
local showAllRevealed = false
local showBarbs = false
local showCitiesAlways = true
local showUnits = false
local showWaterTiles = false

local iBarbPlayer = 63
local iFilterPlayer = Game.GetActivePlayer()
local pFilterPlayer = Players[iFilterPlayer]
local iFilterTeam = pFilterPlayer:GetTeam()
local pFilterTeam = Teams[iFilterTeam]
-------------------------------------------------
local g_MiniMapChosenID = 1

local g_ActiveLegends = {}
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
-------------------------------------------------------------------------------
local isLegendHeaderOpen = true
function RefreshLegends()
	g_LegendInstanceManager:ResetInstances();	
	
	local numLegends = 0
	local miniMap = GameInfo.JFD_MinimapOverlays[g_MiniMapChosenID]
	local miniMapType = miniMap.Type
	local miniMapLegend = JFD_GetMiniMapLegend(g_MiniMapChosenID, iFilterPlayer)
	if (not miniMap.IsDefault) then
		
		if miniMap.IsReligions then
			local religions = {};
			
			for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do	
				local pPlayer = Players[iPlayer];
				if (pPlayer:IsEverAlive()) then
					if (pPlayer:HasCreatedReligion()) then
						local eReligion = pPlayer:GetReligionCreatedByPlayer();
						local religion = GameInfo.Religions[eReligion];
						
						table.insert(religions, {eReligion, Locale.Lookup(Game.GetReligionName(eReligion)), religion.IconString})
					end
				end
			end
			
			local f = function(a, b) 
				return a[2] < b[2];
			end
			table.sort(religions, f)
	
			for _, tReligion in ipairs(religions) do
				local legendInstance = g_LegendInstanceManager:GetInstance();
				
				local strShortDesc = tReligion[2]
				legendInstance.LegendName:LocalizeAndSetText(strShortDesc);
				legendInstance.LegendButton:LocalizeAndSetToolTip(strShortDesc);
				
				local legendColour = ReligionColours[tReligion[1]]
				legendInstance.LegendLine:SetColorVal(legendColour.r/255, legendColour.g/255, legendColour.b/255, legendColour.a);	
				
				legendInstance.LegendFont:SetText(tReligion[3])
				legendInstance.LegendFont:SetHide(false)
				legendInstance.PlayerIcon:SetHide(true)
				
				numLegends = numLegends + 1
			end		
			
			local legendInstance = g_LegendInstanceManager:GetInstance();
			local strShortDesc = "TXT_KEY_RELIGION_PANTHEON"
			legendInstance.LegendName:LocalizeAndSetText(strShortDesc);
			legendInstance.LegendButton:LocalizeAndSetToolTip(strShortDesc);
			
			local legendColour = ReligionColours[GameInfoTypes["RELIGION_PANTHEON"]]
			legendInstance.LegendLine:SetColorVal(legendColour.r/255, legendColour.g/255, legendColour.b/255, legendColour.a);	
			
			legendInstance.LegendFont:SetText("[ICON_RELIGION_PANTHEON]")
			legendInstance.LegendFont:SetHide(false)
			legendInstance.PlayerIcon:SetHide(true)
			
			local legendInstance = g_LegendInstanceManager:GetInstance();
			local strShortDesc = "TXT_KEY_NO_RELIGION"
			legendInstance.LegendName:LocalizeAndSetText(strShortDesc);
			legendInstance.LegendButton:LocalizeAndSetToolTip(strShortDesc);
			
			local legendColour = ReligionColours["NONE"]
			legendInstance.LegendLine:SetColorVal(legendColour.r/255, legendColour.g/255, legendColour.b/255, legendColour.a);	
			
			legendInstance.LegendFont:SetText("[ICON_PANTHEON_A]")
			legendInstance.LegendFont:SetHide(false)
			legendInstance.PlayerIcon:SetHide(true)
			
			numLegends = numLegends + 1
		else
			for row in GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = '" .. miniMapType .. "'") do
				local legendType = row.LegendType
				
				local isValid = true
				if legendType == "JFD_MINIMAP_LEGEND_DARK_AGE" then
					isValid = Game.IsDarkAgesActive()
				end
				if row.IsTypeRequired then
					isValid = GameInfoTypes[row.IsType]
				end
				if isValid and g_ActiveLegends[row.LegendType] then
			
					local legendInstance = g_LegendInstanceManager:GetInstance();
					
					local strShortDesc = row.Description
					legendInstance.LegendName:LocalizeAndSetText(strShortDesc);
					legendInstance.LegendButton:LocalizeAndSetToolTip(strShortDesc);
						
					if row.UseFilterPlayerColor then
						local legendColour = PlayerColours[iFilterPlayer]
						legendInstance.LegendLine:SetColorVal(legendColour.r/255, legendColour.g/255, legendColour.b/255, legendColour.a);	
						legendInstance.LegendName:LocalizeAndSetText(Players[iFilterPlayer]:GetCivilizationShortDescription());
					else	
						local colour = GameInfo.Colors[row.ColorType]
						legendInstance.LegendLine:SetColorVal(colour.Red, colour.Green, colour.Blue, colour.Alpha);	
					end
					
					-- if miniMapLegend and miniMapLegend.LegendType == legendType then
						-- legendInstance.LegendSelectHighlight:SetHide(false)
					-- end
					
					if row.UseFilterPlayerIcon then
						local civ = GameInfo.Civilizations[Players[iFilterPlayer]:GetCivilizationType()]
						IconHookup( civ.PortraitIndex, 32, civ.IconAtlas, legendInstance.PlayerIcon );
						legendInstance.LegendFont:SetHide(true)
						legendInstance.PlayerIcon:SetHide(false)
					else
						legendInstance.LegendFont:SetText(row.FontIcon)
						legendInstance.LegendFont:SetHide(false)
						legendInstance.PlayerIcon:SetHide(true)
					end
					
					numLegends = numLegends + 1
				end
			end
		end
	end
	
	if numLegends > 0 then
		Controls.LegendButton:SetHide(false)
		Controls.LegendGrid:SetHide(false)
		Controls.LegendLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_LEGENDS"));
		
		Controls.LegendStack:CalculateSize();
		Controls.LegendStack:ReprocessAnchoring();
		Controls.LegendGrid:SetSizeY(Controls.LegendStack:GetSizeY() + 5)
		
		isLegendHeaderOpen = true
	else
		Controls.LegendButton:SetHide(true)
		Controls.LegendGrid:SetHide(true)
	end
	
	Controls.MainStack:CalculateSize();
	Controls.MainStack:ReprocessAnchoring();
	Controls.LegendScrollPanel:CalculateInternalSize();
	Controls.LegendScrollPanel:ReprocessAnchoring();
end	
-------------------------------------------------------------------------------
function OnLegendButton()
	if Controls.LegendGrid:IsHidden() then
		Controls.LegendLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_LEGENDS"));
		Controls.LegendGrid:SetHide(false)
			
		isLegendHeaderOpen = true
	else
		Controls.LegendLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_LEGENDS"));
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
-------------------------------------------------------------------------------
local isPlayersHeaderOpen = false
local isMinorPlayersHeaderOpen = false

function RefreshPlayers()
	local iActivePlayer = Game.GetActivePlayer()
	local iActiveTeam = Game.GetActiveTeam()
	
	g_LegendPlayerInstanceManager:ResetInstances();	
	g_LegendMinorPlayerInstanceManager:ResetInstances();	
	
	local miniMap = GameInfo.JFD_MinimapOverlays[g_MiniMapChosenID]
	
	local numPlayers = 0
	local numMinorPlayers = 0
	-- if (not miniMap.IsReligions) then
		local defineCivs = GameDefines.MAX_CIV_PLAYERS-1
		if showBarbs then
			defineCivs = defineCivs+1
		end
		for iPlayer=0, defineCivs do	
			local pPlayer = Players[iPlayer]	
			local iTeam = pPlayer:GetTeam()
			local pTeam = Teams[iTeam]
			if pPlayer:IsEverAlive() then
				if pTeam:IsHasMet(iFilterTeam) or showAllRevealed then
					if pPlayer:IsMinorCiv() then
						local miniMapLegend = JFD_GetMiniMapLegend(g_MiniMapChosenID, iPlayer, iFilterPlayer)
						
						if miniMapLegend then
							local legendInstance = g_LegendMinorPlayerInstanceManager:GetInstance();
							
							local strPlayerShortDesc = pPlayer:GetCivilizationShortDescription()
							legendInstance.PlayerName:LocalizeAndSetText(strPlayerShortDesc);
							
							if miniMapLegend.IsPlayer then
								legendInstance.MinorPlayerButton:LocalizeAndSetToolTip(strPlayerShortDesc);
								
								local legendColour = PlayerColours[iPlayer]
								legendInstance.PlayerLine:SetColorVal(legendColour.r/255, legendColour.g/255, legendColour.b/255, legendColour.a);	
							else
								legendInstance.MinorPlayerButton:LocalizeAndSetToolTip(miniMapLegend.Description);
								
								local colour = GameInfo.Colors[miniMapLegend.ColorType]
								legendInstance.PlayerLine:SetColorVal(colour.Red, colour.Green, colour.Blue, colour.Alpha);	
							end					
						
							local minorCivID = pPlayer:GetMinorCivType()
							local minorCivTraitType = GameInfo.MinorCivilizations[minorCivID].MinorCivTrait
							local minorCivTrait = GameInfo.MinorCivTraits[minorCivTraitType]
							local traitTexture = minorCivTrait.TraitIcon
							legendInstance.PlayerTexture:SetTexture(traitTexture)
							local _, minorCivColour = pPlayer:GetPlayerColors()
							legendInstance.PlayerTexture:SetColor(minorCivColour)
							
							numMinorPlayers = numMinorPlayers + 1
						end
					else
						local miniMapLegend = JFD_GetMiniMapLegend(g_MiniMapChosenID, iPlayer, iFilterPlayer)
						
						if miniMapLegend then
							local legendInstance = g_LegendPlayerInstanceManager:GetInstance();
					
							local strPlayerShortDesc = pPlayer:GetCivilizationShortDescription()
							if iPlayer == iFilterPlayer then
								strPlayerShortDesc = "[COLOR_UNIT_TEXT]" .. strPlayerShortDesc .. "[ENDCOLOR]"
								-- legendInstance.PlayerSelectHighlight:SetHide(false)
							end
							legendInstance.PlayerName:LocalizeAndSetText(strPlayerShortDesc);
							
							if miniMapLegend.IsPlayer or miniMapLegend.UseFilterPlayerColor then
								legendInstance.PlayerButton:LocalizeAndSetToolTip(strPlayerShortDesc);
								
								local legendColour = PlayerColours[iPlayer]
								legendInstance.PlayerLine:SetColorVal(legendColour.r/255, legendColour.g/255, legendColour.b/255, legendColour.a);	
							else
								legendInstance.PlayerButton:LocalizeAndSetToolTip(miniMapLegend.Description);
								
								local colour = GameInfo.Colors[miniMapLegend.ColorType]
								legendInstance.PlayerLine:SetColorVal(colour.Red, colour.Green, colour.Blue, colour.Alpha);	
							end
							
							-- local legendColour = PlayerColours[iPlayer]
							-- legendInstance.PlayerLine:SetColorVal(legendColour.r/255, legendColour.g/255, legendColour.b/255, legendColour.a);	
							
							local civ = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
							IconHookup( civ.PortraitIndex, 32, civ.IconAtlas, legendInstance.PlayerIcon );
							
							numPlayers = numPlayers + 1
						end
					end
				end
			end
		end
	-- end
	
	if numPlayers > 0 then
		Controls.PlayersButton:SetHide(false)
		Controls.PlayerGrid:SetHide(false)
		Controls.PlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_CIVS"));
		
		Controls.LegendPlayersStack:CalculateSize();
		Controls.LegendPlayersStack:ReprocessAnchoring();
		Controls.PlayerGrid:SetSizeY(Controls.LegendPlayersStack:GetSizeY() + 5)
		
		isPlayersHeaderOpen = true
	else
		Controls.PlayersButton:SetHide(true)
		Controls.PlayerGrid:SetHide(true)
	end
	
	if numMinorPlayers > 0 then
		Controls.MinorPlayersButton:SetHide(false)
		Controls.MinorPlayerGrid:SetHide(false)
		Controls.MinorPlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_CITY_STATES"));
		
		Controls.LegendMinorPlayersStack:CalculateSize();
		Controls.LegendMinorPlayersStack:ReprocessAnchoring();
		Controls.MinorPlayerGrid:SetSizeY(Controls.LegendMinorPlayersStack:GetSizeY() + 5)
		
		isMinorPlayersHeaderOpen = true
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
function OnPlayersButton()
	if Controls.PlayerGrid:IsHidden() then
		Controls.PlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_CIVS"));
		Controls.PlayerGrid:SetHide(false)
			
		isPlayersHeaderOpen = true
	else
		Controls.PlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_CIVS"));
		Controls.PlayerGrid:SetHide(true)
			
		isPlayersHeaderOpen = false
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
function OnMinorPlayersButton()
	if Controls.MinorPlayerGrid:IsHidden() then
		Controls.MinorPlayersLabel:SetText("[ICON_MINUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_CITY_STATES"));
		Controls.MinorPlayerGrid:SetHide(false)		
		
		isMinorPlayersHeaderOpen = true
	else
		Controls.MinorPlayersLabel:SetText("[ICON_PLUS]" .. Locale.ConvertTextKey("TXT_KEY_JFD_MINIMAP_OVERVIEW_CITY_STATES"));
		Controls.MinorPlayerGrid:SetHide(true)		
		
		isMinorPlayersHeaderOpen = false
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
function AssignPlayerColours()
	g_ActiveLegends = {}
	
	local miniMap = GameInfo.JFD_MinimapOverlays[g_MiniMapChosenID]
	local defineCivs = GameDefines.MAX_CIV_PLAYERS-1
	if showBarbs then
		defineCivs = defineCivs+1
	end
	for iPlayer=0, defineCivs-1 do	
		local pPlayer = Players[iPlayer]
		if (pPlayer:IsEverAlive()) then
			if Teams[pPlayer:GetTeam()]:IsHasMet(iFilterTeam) or showAllRevealed then
				local miniMapLegend = JFD_GetMiniMapLegend(g_MiniMapChosenID, iPlayer, iFilterPlayer)
				if miniMapLegend then
					if	miniMapLegend.IsPlayer then
						local colour1, colour2
						if (pPlayer:IsMinorCiv()) then
							colour2, colour1 = pPlayer:GetPlayerColors()
						else
							colour2, colour1 = pPlayer:GetPlayerColors()
						end
						PlayerColours[iPlayer] = {r=(255*colour1.x), g=(255*colour1.y), b=(255*colour1.z), a=colour1.w}
						if showCitiesAlways then
							CityColours[iPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
						else
							CityColours[iPlayer] = {r=(255*colour1.x), g=(255*colour1.y), b=(255*colour1.z), a=colour1.w}	
						end
					else
						if iPlayer == iFilterPlayer and miniMapLegend.UseFilterPlayerColor then
							g_ActiveLegends[miniMapLegend.LegendType] = true
							local colour1, colour2
							if (pPlayer:IsMinorCiv()) then
								colour2, colour1 = pPlayer:GetPlayerColors()
							else
								colour2, colour1 = pPlayer:GetPlayerColors()
							end
							PlayerColours[iPlayer] = {r=(255*colour1.x), g=(255*colour1.y), b=(255*colour1.z), a=colour1.w}
							if showCitiesAlways then
								CityColours[iPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
							else
								CityColours[iPlayer] = {r=(255*colour1.x), g=(255*colour1.y), b=(255*colour1.z), a=colour1.w}	
							end
						else
							g_ActiveLegends[miniMapLegend.LegendType] = true
							local colour = GameInfo.Colors[miniMapLegend.ColorType]
							PlayerColours[iPlayer] = {r=(255*colour.Red), g=(255*colour.Green), b=(255*colour.Blue), a=colour.Alpha}
							if showCitiesAlways then
								local colour1, colour2
								if (pPlayer:IsMinorCiv()) then
									colour2, colour1 = pPlayer:GetPlayerColors()
								else
									colour2, colour1 = pPlayer:GetPlayerColors()
								end
								CityColours[iPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
							else
								CityColours[iPlayer] = {r=(255*colour.Red), g=(255*colour.Green), b=(255*colour.Blue), a=colour.Alpha}
							end
						end
					end
				end
			end
		end
	end
end
AssignPlayerColours()
-------------------------------------------------------------------------------
function AssignReligionColours()
	local colourMap = GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = 'JFD_MINIMAP_RELIGIONS' AND LegendType = 'JFD_MINIMAP_LEGEND_NO_RELIGION'")()
	local colour
	if (colourMap ~= nil) then
		colour = GameInfo.Colors[colourMap.ColorType]
		ReligionColours["NONE"] = {r=(255*colour.Red), g=(255*colour.Green), b=(255*colour.Blue), a=colour.Alpha}
	end
	
	local iPantheon = GameInfoTypes["RELIGION_PANTHEON"]
	local pPantheon = GameInfo.Religions[iPantheon].Type
	local colourMap = GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = 'JFD_MINIMAP_RELIGIONS' AND IsType = '" .. pPantheon .. "'")()
	local colour
	if (colourMap ~= nil) then
		colour = GameInfo.Colors[colourMap.ColorType]
		ReligionColours[iPantheon] = {r=(255*colour.Red), g=(255*colour.Green), b=(255*colour.Blue), a=colour.Alpha}
	end
	
	for iPlayer=0, GameDefines.MAX_CIV_PLAYERS-1 do	
		local pPlayer = Players[iPlayer]

		if (pPlayer:IsEverAlive()) then
			if showCitiesAlways then
				local colour1, colour2
				if (pPlayer:IsMinorCiv()) then
					colour2, colour1 = pPlayer:GetPlayerColors()
				else
					colour2, colour1 = pPlayer:GetPlayerColors()
				end
				CityColours[iPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
			end
		
			if (pPlayer:HasCreatedReligion()) then
				local iReligion = pPlayer:GetReligionCreatedByPlayer()
				local pReligionType = GameInfo.Religions[iReligion].Type
				local colourMap = GameInfo.JFD_MinimapOverlay_Legends("MinimapOverlayType = 'JFD_MINIMAP_RELIGIONS' AND IsType = '" .. pReligionType .. "'")()
				local colour
				if (colourMap ~= nil) then
					colour = GameInfo.Colors[colourMap.ColorType]
					ReligionColours[iReligion] = {r=(255*colour.Red), g=(255*colour.Green), b=(255*colour.Blue), a=colour.Alpha}
					if showCitiesAlways then
						local colour1, colour2
						if (pPlayer:IsMinorCiv()) then
							colour2, colour1 = pPlayer:GetPlayerColors()
						else
							colour2, colour1 = pPlayer:GetPlayerColors()
						end
						CityColours[iPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
					else
						CityColours[iPlayer] = {r=(255*colour.Red), g=(255*colour.Green), b=(255*colour.Blue), a=colour.Alpha}
					end
				else
					if (pPlayer:IsMinorCiv()) then
						colour, _ = pPlayer:GetPlayerColors()
					else
						_, colour = pPlayer:GetPlayerColors()
					end
					ReligionColours[iReligion] = {r=(255*colour.x), g=(255*colour.y), b=(255*colour.z), a=colour.w}
					CityColours[iPlayer] = {r=(255*colour.x), g=(255*colour.y), b=(255*colour.z), a=colour.w}
				end
			end
		end
	end
end
AssignReligionColours()
-------------------------------------------------------------------------------
function ShadeCities(iTeam)
	local miniMap = GameInfo.JFD_MinimapOverlays[g_MiniMapChosenID]
	local isReligions = miniMap.IsReligions
	
	local defineCivs = GameDefines.MAX_CIV_PLAYERS-1
	if showBarbs then
		defineCivs = defineCivs+1
	end
	for iPlayer=0, defineCivs do	
		local pPlayer = Players[iPlayer]
	
		if (pPlayer:IsAlive()) then
			for pCity in pPlayer:Cities() do
				if pCity then
					if isReligions then
						local iReligion = pCity:GetReligiousMajority()
						if iReligion > -1 then
							if (ReligionColours[iReligion] == nil) then
								AssignReligionColours()
							end
							if showCitiesAlways then
								local iPlayer = pCity:GetOwner()
								local pPlayer = Players[iPlayer]
								local colour1, colour2
								if (pPlayer:IsMinorCiv()) then
									colour2, colour1 = pPlayer:GetPlayerColors()
								else
									colour2, colour1 = pPlayer:GetPlayerColors()
								end
								CityColours[iPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
								ShadeCity(iTeam, pCity, ReligionColours[iReligion], CityColours[iPlayer])
							else
								ShadeCity(iTeam, pCity, ReligionColours[iReligion], ReligionColours[iReligion])
							end
						else
							if showCitiesAlways then
								local iPlayer = pCity:GetOwner()
								local pPlayer = Players[iPlayer]
								local colour1, colour2
								if (pPlayer:IsMinorCiv()) then
									colour2, colour1 = pPlayer:GetPlayerColors()
								else
									colour2, colour1 = pPlayer:GetPlayerColors()
								end
								CityColours[iPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
								ShadeCity(iTeam, pCity, ReligionColours["NONE"], CityColours[iPlayer])
							else
								ShadeCity(iTeam, pCity, ReligionColours["NONE"], ReligionColours["NONE"])
							end
						end
					else
						if (PlayerColours[iPlayer] == nil) then
							AssignPlayerColours()
						end
			
						ShadeCity(iTeam, pCity, PlayerColours[iPlayer], CityColours[iPlayer])
					end
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function ShadeCity(iTeam, pCity, colour, cityColour)
  for i = 1, pCity:GetNumCityPlots()-1, 1 do
    local pPlot = pCity:GetCityIndexPlot(i)
    
    if (pPlot ~= nil and (pPlot:IsRevealed(iTeam) or showAllRevealed)) then
      if (pPlot:GetOwner() == pCity:GetOwner()) then
        if (pPlot:IsLake() or ((not pPlot:IsWater()) or showWaterTiles)) then 
          if (pPlot:IsMountain() or pPlot:GetTerrainType() == iTerrainDesert or pCity:IsWorkingPlot(pPlot) or pCity:CanWork(pPlot)) then
			if (not colour) then print("pCity", pCity:GetName()) end
            Controls.Map:SetPlot(pPlot:GetX(), pPlot:GetY(), pPlot:GetTerrainType(), colour.r/255, colour.g/255, colour.b/255, colour.a)
          end
        end
      end
    end
  end
  local pCityPlot = pCity:Plot()
  if (pCityPlot ~= nil and (pCityPlot:IsRevealed(iTeam) or showAllRevealed)) then
	if (not cityColour) then
		if showCitiesAlways then
			local iPlayer = pCity:GetOwner()
			local pPlayer = Players[iPlayer]
			local colour1, colour2
			if (pPlayer:IsMinorCiv()) then
				colour2, colour1 = pPlayer:GetPlayerColors()
			else
				colour2, colour1 = pPlayer:GetPlayerColors()
			end
			CityColours[iPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
			cityColour = CityColours[iPlayer]
		else
			CityColours[iPlayer] = colour
			cityColour = CityColours[iPlayer]
		end
	end
  	Controls.Map:SetPlot(pCity:GetX(), pCity:GetY(), pCityPlot:GetTerrainType(), cityColour.r/255, cityColour.g/255, cityColour.b/255, cityColour.a)
	end
end
-------------------------------------------------------------------------------
function ShadeUnits(iTeam)
	local miniMap = GameInfo.JFD_MinimapOverlays[g_MiniMapChosenID]
	local isReligions = miniMap.IsReligions
	local defineCivs = GameDefines.MAX_CIV_PLAYERS-1
	if showBarbs then
		defineCivs = defineCivs+1
	end
	for iPlayer=0, defineCivs do	
		local pPlayer = Players[iPlayer]
	
		if (pPlayer:IsAlive()) then
			for pUnit in pPlayer:Units() do
				if isReligions then
					local iReligion = pUnit:GetReligion()
					if iReligion > -1 then
						if (ReligionColours[iReligion] == nil) then
							AssignReligionColours()
						end
		
						ShadeCity(iTeam, pCity, ReligionColours[iReligion], CityColours[iPlayer])
					else
						ShadeCity(iTeam, pCity, ReligionColours["NONE"], CityColours[iPlayer])
					end
				else
					if (PlayerColours[iPlayer] == nil) then
						AssignPlayerColours()
					end
					ShadeUnit(iTeam, pUnit, PlayerColours[iPlayer], CityColours[iPlayer])
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function ShadeUnit(iTeam, pUnit, colour, cityColour)
    local pPlot = Map.GetPlot(pUnit:GetX(), pUnit:GetY())
    
    if (pPlot ~= nil and (pPlot:IsRevealed(iTeam) or showAllRevealed)) then
        if (pPlot:IsLake() or ((not pPlot:IsWater()) or showWaterTiles)) then 	
			if (pPlot:IsCity() and (not showCitiesAlways)) or (not pPlot:IsCity()) then
				Controls.Map:SetPlot(pPlot:GetX(), pPlot:GetY(), pPlot:GetTerrainType(), colour.r/255, colour.g/255, colour.b/255, colour.a)
			end
		end
    end
end
-------------------------------------------------------------------------------
local improvementBarbID = GameInfoTypes["IMPROVEMENT_BARBARIAN_CAMP"]
function ShadeBarbEncampments(iTeam)
	for y = 0, mapHeight-1, 1 do  
	for x = 0, mapWidth-1, 1 do
		local pPlot = Map.GetPlot(x, y)
		if pPlot then
			if pPlot:GetImprovementType() == improvementBarbID then
				ShadeImprovement(iTeam, pPlot, PlayerColours[iBarbPlayer])
			end
		end
	end		
	end		
end
-------------------------------------------------------------------------------
function ShadeImprovement(iTeam, pPlot, colour)
    local pPlot = Map.GetPlot(pPlot:GetX(), pPlot:GetY())
    
    if (pPlot ~= nil and (pPlot:IsRevealed(iTeam) or showAllRevealed)) then
       if (not colour) then
			local colour1, colour2 = Players[iBarbPlayer]:GetPlayerColors()
			PlayerColours[iBarbPlayer] = {r=(255*colour1.x), g=(255*colour1.y), b=(255*colour1.z), a=colour1.w}
			if showCitiesAlways then
				CityColours[iBarbPlayer] = {r=(255*colour2.x), g=(255*colour2.y), b=(255*colour2.z), a=colour2.w}
			else
				CityColours[iBarbPlayer] = {r=(255*colour1.x), g=(255*colour1.y), b=(255*colour1.z), a=colour1.w}	
			end
			colour = PlayerColours[iBarbPlayer]
		end
	   Controls.Map:SetPlot(pPlot:GetX(), pPlot:GetY(), pPlot:GetTerrainType(), colour.r/255, colour.g/255, colour.b/255, colour.a)
    end
end
-------------------------------------------------------------------------------
function RefreshMiniMap(miniMapID)	
	local mapControl = Controls.Map;
	for y = 0, mapHeight-1, 1 do  
		for x = 0, mapWidth-1, 1 do
			local pPlot = Map.GetPlot(x, y)
			if pPlot ~= nil then
				local colour = Colours.UNKNOWN			
				if (pPlot:IsRevealed(iFilterTeam) or showAllRevealed) then
					if (pPlot:GetFeatureType() == iFeatureIce) then
						colour = Colours.ICE
					elseif (pPlot:IsWater()) then
						if pPlot:GetTerrainType() == iTerrainCoast then
							colour = Colours.COAST
						else
							colour = Colours.OCEAN
						end
					else
						if pPlot:IsMountain() then
							colour = Colours.MOUNTAIN
						else
							colour = Colours.LAND
						end
					end
				end	
				
				local colourRed = Game.GetRound(colour.Red/255,3)
				local colourGreen = Game.GetRound(colour.Green/255,3)
				local colourBlue = Game.GetRound(colour.Blue/255,3)
				local colourAlpha = colour.Alpha
				mapControl:SetPlot(x, y, pPlot:GetTerrainType(), colourRed, colourGreen, colourBlue, colour.Alpha)
			end	
		end		
	end		
	
	ShadeCities(iFilterTeam)
	if showBarbs then
		ShadeBarbEncampments(iFilterTeam)
	end
	if showUnits then
		ShadeUnits(iFilterTeam)
	end	
end
-------------------------------------------------------------------------------
function RefreshMiniMapOverview(miniMapID)	
	RefreshShowAsFilters()	
	if miniMapID ~= g_MiniMapChosenID then
		g_MiniMapChosenID = miniMapID
		AssignReligionColours()
		AssignPlayerColours()
	end
	local miniMap = GameInfo.JFD_MinimapOverlays[miniMapID]
	Controls.MiniMapOverlayPulldownLabel:LocalizeAndSetText("OVERLAY: [COLOR_CYAN]{1_Desc}[ENDCOLOR]", miniMap.Description)
	RefreshMiniMap(miniMapID)
	RefreshPlayers(miniMapID)
	RefreshLegends(miniMapID)
end

-------------------------------------------------------------------------------
function OnShowRevealed(bCheck)
	showAllRevealed = bCheck
	AssignReligionColours()
	AssignPlayerColours()
	RefreshShowAs(Game.GetActivePlayer(), true)
end
Controls.ShowRevealed:RegisterCheckHandler(OnShowRevealed);

function OnShowBarbs(bCheck)
	showBarbs = bCheck
	AssignReligionColours()
	AssignPlayerColours()
	RefreshMiniMap(g_MiniMapChosenID)
	RefreshPlayers(miniMapID)
end
Controls.ShowBarbs:RegisterCheckHandler(OnShowBarbs);

function OnShowCities(bCheck)
	showCitiesAlways = bCheck
	AssignReligionColours()
	AssignPlayerColours()
	RefreshMiniMap(g_MiniMapChosenID)
end
Controls.ShowCities:RegisterCheckHandler(OnShowCities);

function OnShowUnits(bCheck)
	showUnits = bCheck
	RefreshMiniMap(g_MiniMapChosenID)
end
Controls.ShowUnits:RegisterCheckHandler(OnShowUnits);

function OnShowWater(bCheck)
	showWaterTiles = bCheck
	RefreshMiniMap(g_MiniMapChosenID)
end
Controls.ShowWater:RegisterCheckHandler(OnShowWater);
-------------------------------------------------------------------------------
function RefreshShowAs(iPlayer, isShowRevealed)
	if iPlayer ~= iFilterPlayer or isShowRevealed then
		iFilterPlayer = iPlayer
		pFilterPlayer = Players[iFilterPlayer]
		iFilterTeam = pFilterPlayer:GetTeam()
		pFilterTeam = Teams[iFilterTeam]
		RefreshMiniMapOverview(g_MiniMapChosenID)	
	end
	Controls.MiniMapFilterPulldownLabel:LocalizeAndSetText("SHOW AS: [COLOR_UNIT_TEXT]{1_Desc}[ENDCOLOR]", Players[iPlayer]:GetCivilizationShortDescription())
end
-------------------------------------------------------------------------------
function RefreshShowAsFilters()
	Controls.MiniMapFilterPulldown:ClearEntries()	
	
	local entry = {}
	Controls.MiniMapFilterPulldown:BuildEntry("InstanceOne", entry)
	entry.Button:SetVoid1(iFilterPlayer)
	entry.Button:LocalizeAndSetText("[COLOR_UNIT_TEXT]{1_Desc}[ENDCOLOR]", pFilterPlayer:GetCivilizationShortDescription())
	
	for iPlayer=0, GameDefines.MAX_CIV_PLAYERS-1 do	
		local pPlayer = Players[iPlayer]
		if (pPlayer:IsAlive()) and iPlayer ~= iFilterPlayer and (not pPlayer:IsMinorCiv()) then
			if Teams[pPlayer:GetTeam()]:IsHasMet(iFilterTeam) or showAllRevealed then
				local entry = {}
				Controls.MiniMapFilterPulldown:BuildEntry("InstanceOne", entry)
				entry.Button:SetVoid1(iPlayer)
				entry.Button:LocalizeAndSetText(pPlayer:GetCivilizationShortDescription())
			end
		end
	end
	Controls.MiniMapFilterPulldown:CalculateInternals()
	Controls.MiniMapFilterPulldown:RegisterSelectionCallback(RefreshShowAs)
	Controls.MiniMapFilterPulldown:SetHide(false) 
	RefreshShowAs(iFilterPlayer)
end
------------------------------------------------------------------------------
function RefreshMiniMapOverlay()	
	Controls.MiniMapOverlayPulldown:ClearEntries()	
	for row in GameInfo.JFD_MinimapOverlays() do
		local isValid = true
		if row.IsCultureTypes then
			isValid = GameInfoTypes["CULTURE_JFD_BANTU"]
		elseif row.IsGovernments or row.IsFactions then
			isValid = GameInfoTypes["GOVERNMENT_JFD_MONARCHY"]
		end
		if isValid then
			local entry = {}
			Controls.MiniMapOverlayPulldown:BuildEntry("InstanceOne", entry)
			entry.Button:SetVoid1(row.ID)
			entry.Button:LocalizeAndSetText("Overlay: [COLOR_CYAN]{1_Desc}[ENDCOLOR]", row.Description)
			entry.Button:LocalizeAndSetToolTip("Choose Minimap Overlay")
		end
	end
	Controls.MiniMapOverlayPulldown:CalculateInternals()
	Controls.MiniMapOverlayPulldown:RegisterSelectionCallback(RefreshMiniMapOverview)
	Controls.MiniMapOverlayPulldown:SetHide(false) 
	
	RefreshMiniMapOverview(g_MiniMapChosenID)
end
RefreshMiniMapOverlay()	
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();  
        	--Events.SerialEventGameMessagePopupShown(g_PopupInfo);
        	
           RefreshMiniMapOverview(g_MiniMapChosenID)
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
--		text=Locale.Lookup("TXT_KEY_JFD_MINIMAP_OVERVIEW"),
--		call=function()
--			UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
--		end,
--	});
--	-- table.insert(entries, {
--		-- text=Locale.Lookup("Open Civilopedia"),
--		-- call=function()
--			-- Events.SearchForPediaEntry("");
--		-- end,
--	-- });
--end);

-- Just in case :)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();

function JFD_UI_ShowMiniMapOverview()
	if ContextPtr:IsHidden() then
		UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
	else
		UIManager:DequeuePopup(ContextPtr)
	end
end
LuaEvents.JFD_UI_ShowMiniMapOverview.Add(JFD_UI_ShowMiniMapOverview);


UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
UIManager:DequeuePopup(ContextPtr)
