
-------------------------------
-- JFD Observer Stuff
-------------------------------
include("IconSupport");
include("InstanceManager");
include("JFD_AIObserver_Utils.lua");
include("VD_Observer_Utils.lua");

local g_iPlayerForView = Game.GetActivePlayer()

-- VD: Per-player state for LLM data
local VD_Players = {}  -- [playerID] = aiLabel string
local VD_Actions = {}  -- [playerID] = { turn=N, list={ {actionType, summary, rationale}, ... } }
local VD_CachedRationale = {} -- [playerID] = { rationale=string, turn=number }
local VD_AutoOpenedPanel = nil  -- nil | "civs_list" | "league_overview"

-- VD: Per-player event message cache for playback on panel switch
local VD_EventMessages = {}          -- [playerID] = { turn=N, messages={string, ...} }
local VD_EVENT_MESSAGE_LIMIT = 12

-- Returns true when a World Congress / UN session is within `threshold` turns.
local function VD_IsLeagueSessionClose(threshold)
	if Game.GetNumActiveLeagues == nil or Game.GetNumActiveLeagues() <= 0 then
		return false
	end
	local pLeague = Game.GetActiveLeague()
	if pLeague == nil then return false end
	if pLeague:IsInSession() then return true end
	local turns = pLeague:GetTurnsUntilSession()
	if turns > 0 and turns <= threshold then return true end
	if Game.IsUnitedNationsActive and Game.IsUnitedNationsActive() then
		local vTurns = pLeague:GetTurnsUntilVictorySession()
		if vTurns > 0 and vTurns <= threshold then return true end
	end
	return false
end

-- VD: Combat-gate state for delaying auto-switch until animations finish
local VD_CombatInFlight = 0       -- count of active combat animations
local VD_PendingSwitch = nil      -- { playerID, reason, preWork, eventOnly } or nil
local VD_MinorDialogShownTurn = -1 -- last game turn on which the minor civ dialog was opened

-- VD: Shared camera-focus debounce (applies across combat + ambient events)
local VD_FOCUS_DEBOUNCE_SECONDS = 5.0
local VD_LastFocusTime = -math.huge -- os.clock() timestamp of last camera move
local VD_PendingLookAt = nil        -- { plot, player, label } or nil; retried until CameraViewChanged

-- VD: Record a game event message for later playback (major civs only).
local function VD_RecordEventMessage(iPlayer, message)
	if iPlayer == nil then return end
	local pPlayer = Players[iPlayer]
	if not pPlayer or not pPlayer:IsAlive() then return end
	if pPlayer:IsMinorCiv() or pPlayer:IsBarbarian() then return end

	local currentTurn = Game.GetGameTurn()
	local cache = VD_EventMessages[iPlayer]
	if cache == nil or cache.turn ~= currentTurn then
		VD_EventMessages[iPlayer] = { turn = currentTurn, messages = {} }
		cache = VD_EventMessages[iPlayer]
	end

	if #cache.messages >= VD_EVENT_MESSAGE_LIMIT then return end
	table.insert(cache.messages, message)
	VD_Log("EventRecord: player=" .. tostring(iPlayer) .. " msg=" .. message)
end

-- VD: Play back cached event messages for a player via AddMessage, then clear.
local function VD_PlaybackEventMessages(playerID)
	local cache = VD_EventMessages[playerID]
	if cache == nil or #cache.messages == 0 then return end

	local pActivePlayer = Players[Game.GetActivePlayer()]
	if not pActivePlayer or not pActivePlayer.AddMessage then
		VD_Log("EventPlayback: AddMessage not available, skipping " .. #cache.messages .. " messages")
		VD_EventMessages[playerID] = nil
		return
	end

	VD_Log("EventPlayback: player=" .. tostring(playerID) .. " count=" .. #cache.messages)
	for _, msg in ipairs(cache.messages) do
		pActivePlayer:AddMessage(msg)
	end

	VD_EventMessages[playerID] = nil
end

-- VD: Unconditionally moves the camera to `plot`, stamps the debounce clock,
-- and emits VD_AnimationStarted. Use for high-priority events (combat) whose
-- caller has already done its own gating.
local function VD_FocusPlot(plot, playerID, sourceLabel, description)
	if plot == nil then
		VD_Log("Focus skipped: nil plot (" .. tostring(sourceLabel) .. ")")
		return false
	end
	UI.LookAt(plot, 1)
	VD_LastFocusTime = os.clock()
	if playerID ~= nil then
		local eventInfo = VD_BuildEventInfo(plot, sourceLabel, description)
		LuaEvents.VD_AnimationStarted(playerID, eventInfo)
	end
	VD_Log("Focus: " .. tostring(sourceLabel) .. " player=" .. tostring(playerID))
	return true
end

-- VD: Guarded focus for ambient "interesting moment" events. Skips if the
-- event is not for the currently viewed player, any combat sim is in flight,
-- or another focus fired within VD_FOCUS_DEBOUNCE_SECONDS.
local function VD_TryFocusPlot(plot, playerID, sourceLabel, description)
	if playerID ~= g_iPlayerForView then
		VD_Log("TryFocus skipped: not viewed player (" .. tostring(sourceLabel)
			.. ") player=" .. tostring(playerID))
		return false
	end
	if VD_CombatInFlight > 0 then
		VD_Log("TryFocus skipped: combat in flight (" .. tostring(sourceLabel) .. ")")
		return false
	end
	local dt = os.clock() - VD_LastFocusTime
	if dt < VD_FOCUS_DEBOUNCE_SECONDS then
		VD_Log("TryFocus skipped: debounced (" .. tostring(sourceLabel)
			.. ") dt=" .. string.format("%.2f", dt))
		return false
	end
	return VD_FocusPlot(plot, playerID, sourceLabel, description)
end

-- Emits after the top panel has auto-switched to a different player.
-- Args: newPlayerID, previousPlayerID, reason
-- When eventOnly is true, emits the switch event without actually changing g_iPlayerForView
-- (used for the minor civ dialog path, where the top panel stays pinned to the last major civ).
local function VD_AutoSwitchToPlayer(playerID, reason, eventOnly)
	local previousPlayerID = g_iPlayerForView
	if playerID == nil or previousPlayerID == playerID then
		VD_Log("TopPanelAutoSwitchSkipped: from=" .. tostring(previousPlayerID) .. " to=" .. tostring(playerID) .. " reason=" .. tostring(reason))
		return false
	end

	if not eventOnly then
		VD_LastFocusTime = -math.huge
		OnCivPlayerSelected(playerID)
	end
	VD_Log("TopPanelAutoSwitch" .. (eventOnly and "(eventOnly)" or "") .. ": from=" .. tostring(previousPlayerID) .. " to=" .. tostring(playerID) .. " reason=" .. tostring(reason))
	LuaEvents.VD_TopPanelAutoSwitchedPlayer(playerID, previousPlayerID, reason)

	-- Play back cached event messages for the player we just switched to
	if not eventOnly then
		VD_PlaybackEventMessages(playerID)
	end

	return true
end

local function VD_FlushPendingSwitch()
	if VD_PendingSwitch and VD_CombatInFlight == 0 then
		local ps = VD_PendingSwitch
		VD_PendingSwitch = nil
		if ps.preWork then ps.preWork() end
		VD_AutoSwitchToPlayer(ps.playerID, ps.reason, ps.eventOnly)
	end
end

-- Opens League Overview (if session ≤ 3 turns) or WorldCivsList as an auto-opened panel.
-- League Overview is treated as an animation (increments VD_CombatInFlight).
local function VD_AutoOpenSidePanel()
	if VD_IsLeagueSessionClose(3) then
		VD_AutoOpenedPanel = "league_overview"
		local pLeague = Game.GetActiveLeague()
		local hostID = pLeague:GetHostMember()
		local hostCiv = Players[hostID] and Players[hostID]:GetCivilizationShortDescription() or "unknown"
		local inSession = pLeague:IsInSession()
		local results = VD_GetSessionResults()
		local showingResults = not inSession and #results > 0
		local desc
		if showingResults then
			local parts = {}
			for _, r in ipairs(results) do
				parts[#parts + 1] = (r.Passed and "PASSED" or "FAILED") .. ": "
					.. (r.IsEnact and "Enact" or "Repeal") .. " "
					.. pLeague:GetResolutionName(r.Type, -1, r.Choice, false)
			end
			desc = "World Congress results — " .. table.concat(parts, "; ")
		elseif inSession then
			desc = "World Congress in session (host: " .. hostCiv .. ")"
		else
			desc = "World Congress session in " .. pLeague:GetTurnsUntilSession()
				.. " turns (host: " .. hostCiv .. ")"
		end
		local eventInfo = VD_BuildEventInfo(nil, "world_congress", desc)
		eventInfo.showingResults = showingResults
		if showingResults then eventInfo.results = results end
		LuaEvents.VD_AnimationStarted(hostID, eventInfo)
		Events.SerialEventGameMessagePopup({ Type = ButtonPopupTypes.BUTTONPOPUP_LEAGUE_OVERVIEW })
		VD_Log("AutoOpen: league_overview (inflight=" .. VD_CombatInFlight .. ")")
	else
		if Controls.WorldCivsList:IsHidden() then
			VD_AutoOpenedPanel = "civs_list"
			OnWorldCivsListUpdated()
			VD_Log("AutoOpen: civs_list")
		end
	end
end

local function VD_CloseAutoOpenedPanel()
	if VD_AutoOpenedPanel == "civs_list" then
		if not Controls.WorldCivsList:IsHidden() then
			Controls.WorldCivsList:SetHide(true)
			Controls.Tab:SetHide(false)
		end
	elseif VD_AutoOpenedPanel == "league_overview" then
		LuaEvents.VD_CloseLeagueOverview()
		VD_Log("AutoClose: league_overview (inflight=" .. VD_CombatInFlight .. ")")
	end
	VD_AutoOpenedPanel = nil
end

-- Returns first strategy/flavors/status-quo rationale and turn, or nil.
-- Falls back to VD_CachedRationale so rationale persists across turn boundaries.
local function VD_GetFirstRationale(playerID)
	local actionData = VD_Actions[playerID]
	if actionData and #actionData.list > 0 then
		for _, action in ipairs(actionData.list) do
			if action.rationale and action.rationale ~= "" then
				local t = action.actionType
				if t == "strategy" or t == "flavors" or t == "status-quo" then
					return action.rationale, actionData.turn
				end
			end
		end
	end
	-- Fall back to cached rationale from a previous turn
	local cached = VD_CachedRationale[playerID]
	if cached then
		return cached.rationale, cached.turn
	end
	return nil
end

-------------------------------------------------

local function VD_UpdatePanelExtras(playerID)
	local pPlayer = Players[playerID]
	if not pPlayer or pPlayer:IsMinorCiv() then
		Controls.VD_InfoBox:SetHide(true)
		return
	end

	local firstRationale = VD_GetFirstRationale(playerID)

	if firstRationale then
		Controls.VD_RationaleText:SetText(firstRationale)
		Controls.VD_RationaleBox:DoAutoSize()
		local rationaleX = Controls.VD_RationaleBox:GetSizeX()
		local rationaleY = Controls.VD_RationaleBox:GetSizeY()
		Controls.VD_InfoBox:SetSizeX(rationaleX)
		Controls.VD_InfoBox:SetSizeY(rationaleY + 3)
		Controls.VD_InfoBoxBG:SetSizeX(rationaleX)
		Controls.VD_InfoBoxBG:SetSizeY(rationaleY + 3)
		Controls.VD_InfoBoxHL:SetSizeX(rationaleX)
		Controls.VD_InfoBoxHL:SetSizeY(rationaleY + 3)
		Controls.VD_InfoBoxHLBox:SetSizeX(rationaleX)
		Controls.VD_InfoBoxHLBox:SetSizeY(rationaleY + 3)
		Controls.VD_InfoBox:SetHide(false)
	else
		Controls.VD_InfoBox:SetHide(true)
	end
end

local g_RelationsCivManager  = InstanceManager:new("RelationsCivInstance", "RelationsCivBase", Controls.RelationsCivStack)

function RefreshAdditionalInformationEntries()

	local function Popup(popupType, data1, data2)
		Events.SerialEventGameMessagePopup{ 
			Type = popupType,
			Data1 = data1,
			Data2 = data2
		};
	end

	local additionalEntries = {
		{ text = Locale.Lookup("TXT_KEY_ADVISOR_COUNSEL"),					call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_ADVISOR_COUNSEL); end};
		{ text = Locale.Lookup("TXT_KEY_ADVISOR_SCREEN_TECH_TREE_DISPLAY"), call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_TECH_TREE, nil, -1); end };
		{ text = Locale.Lookup("TXT_KEY_DIPLOMACY_OVERVIEW"),				call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_DIPLOMATIC_OVERVIEW); end };
		{ text = Locale.Lookup("TXT_KEY_MILITARY_OVERVIEW"),				call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_MILITARY_OVERVIEW); end };
		{ text = Locale.Lookup("TXT_KEY_ECONOMIC_OVERVIEW"),				call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_ECONOMIC_OVERVIEW); end };
		{ text = Locale.Lookup("TXT_KEY_VP_TT"),							call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_VICTORY_INFO); end };
		{ text = Locale.Lookup("TXT_KEY_DEMOGRAPHICS"),						call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_DEMOGRAPHICS); end };
		{ text = Locale.Lookup("TXT_KEY_POP_NOTIFICATION_LOG"),				call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_NOTIFICATION_LOG,Game.GetActivePlayer()); end };
		{ text = Locale.Lookup("TXT_KEY_TRADE_ROUTE_OVERVIEW"),				call=function() Popup(ButtonPopupTypes.BUTTONPOPUP_TRADE_ROUTE_OVERVIEW); end };
	};

	-- Obtain any modder/dlc entries.
	LuaEvents.AdditionalInformationDropdownGatherEntries(additionalEntries);
	
	-- Now that we have all entries, call methods to sort them
	LuaEvents.AdditionalInformationDropdownSortEntries(additionalEntries);

	 Controls.MultiPull:ClearEntries();

	Controls.MultiPull:RegisterSelectionCallback(function(id)
		local entry = additionalEntries[id];
		if(entry and entry.call ~= nil) then
			entry.call();
		end
	end);
		 
	for i,v in ipairs(additionalEntries) do
		local controlTable = {};
		Controls.MultiPull:BuildEntry( "InstanceOne", controlTable );

		controlTable.Button:SetText( v.text );
		controlTable.Button:LocalizeAndSetToolTip( v.tip );
		controlTable.Button:SetVoid1(i);
		
	end

	-- STYLE HACK
	-- The grid has a nice little footer that will overlap entries if it is not resized to be larger than everything else.
	Controls.MultiPull:CalculateInternals();
	local dropDown = Controls.MultiPull;
	local width, height = dropDown:GetGrid():GetSizeVal();
	dropDown:GetGrid():SetSizeVal(width, height+100);

end
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries.Add(RefreshAdditionalInformationEntries);

function SortAdditionalInformationDropdownEntries(entries)
	table.sort(entries, function(a,b)
		return (Locale.Compare(a.text, b.text) == -1);
	end);
end
LuaEvents.AdditionalInformationDropdownSortEntries.Add(SortAdditionalInformationDropdownEntries);
-------------------------------------------------
function UpdateNewData(playerID)
	ContextPtr:LookUpControl("/InGame/WorldView/InfoCorner"):SetHide(true)
	Events.OpenInfoCorner(nil)
	
	if (not playerID) then playerID = g_iPlayerForView end
	if playerID ~= g_iPlayerForView then return end
	if(PreGame.IsMultiplayerGame()) then
		-- Turn Queue UI (see ActionInfoPanel.lua) replaces the turn processing UI in multiplayer.  
		return;
	end
	
	local player = Players[playerID]
	if (player == nil) then
		return;	
	end
	
	local bIsBarbarian = player:IsBarbarian();
	if (bIsBarbarian) then
		-- Even if there are no barbarians, we will get this call, just skip out if they are turned off
		return;
	end

	
	--Update date
	local date;
	local traditionalDate = Game.GetTurnString();
	if (player:IsUsingMayaCalendar()) then
		date = player:GetMayaCalendarString();
	else
		date = traditionalDate;
	end
	
	--Update turn counter
	local turn = Locale.ConvertTextKey("TXT_KEY_TP_TURN_COUNTER", Game.GetGameTurn());
	local strDate = Locale.ConvertTextKey(date)
	local strTurn = Locale.ConvertTextKey("{1_Num}", turn)
	Controls.CurrentTern:SetText(strDate);
	Controls.LabelStack:ReprocessAnchoring()
	
	--Update era
	local eraDesc = Locale.ConvertTextKey(GameInfo.Eras[player:GetCurrentEra()].Description) .. " - " .. strTurn;
	Controls.CurrentEra:SetText(eraDesc)
	Controls.CurrentTern:SetHide(false)
	
	local bIsMinor = player:IsMinorCiv() 
	if (not bIsMinor) and player:IsAlive() then
		local iPlayerLoop = playerID
		local pPlayer = Players[iPlayerLoop];
		local srCivName = pPlayer:GetCivilizationDescription()
		
		local civilization = GameInfo.Civilizations[player:GetCivilizationType()]
		local leader = GameInfo.Leaders[player:GetLeaderType()]
		IconHookup( civilization.PortraitIndex, 80, civilization.IconAtlas, Controls.CivIcon )
		IconHookup( leader.PortraitIndex, 128, leader.IconAtlas, Controls.LeaderIcon )
		
		local pCapital = pPlayer:GetCapitalCity()
		if pCapital then
			--GRAND STRATEGY (repurposed capital slot)
			local strGSFont, strGSShort, strGSDesc = VD_GetGrandStrategy(pPlayer)
			local strGSTT = Locale.ConvertTextKey("{1_Desc} Grand Strategy: {2_Desc}", strGSFont, strGSDesc)
			Controls.CapIcon:SetText(strGSFont)
			Controls.CapIcon:SetToolTipString(strGSTT)
			Controls.CapInfo:SetText(strGSShort)
			Controls.CapInfo:SetToolTipString(strGSTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--CITIES
			local iCities =  pPlayer:GetNumCities()
			local strCities = tostring(iCities)
			local strCitiesShortDesc = Locale.ConvertTextKey("{1_Desc}", strCities)
			local strCitiesTT = Locale.ConvertTextKey("[ICON_CITY] Cities: {1_Desc}", strCities)
			Controls.CitiesIcon:SetText("[ICON_CITY]")
			Controls.CitiesIcon:SetToolTipString(strCitiesTT)
			Controls.CitiesInfo:SetText(strCitiesShortDesc)
			Controls.CitiesInfo:SetToolTipString(strCitiesTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--POP.
			local strPop = VD_FormatPopulation(pPlayer)
			local strPopTT = Locale.ConvertTextKey("[ICON_CITIZEN] Population: {1_Desc}", strPop)
			VD_SetStatControl(Controls.PopIcon, Controls.PopInfo, "[ICON_CITIZEN]", strPop, strPopTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()

			--CULTURE (policy + tenet count)
			local iPolicies = pPlayer:GetNumPolicies()
			local strCulFont = "[ICON_CULTURE]"
			local strCulShortDesc = tostring(iPolicies)
			local iCulturePerTurn = pPlayer:GetTotalJONSCulturePerTurn()
			local strCulTT = Locale.ConvertTextKey("[ICON_CULTURE] Policies + Tenets: {1_Num} | +{2_Num}/turn", iPolicies, iCulturePerTurn)
			Controls.CulIcon:SetText(strCulFont)
			Controls.CulIcon:SetToolTipString(strCulTT)
			Controls.CulInfo:SetText(strCulShortDesc)
			Controls.CulInfo:SetToolTipString(strCulTT)

			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()

			--RELIGION
			local iReli = pPlayer:GetReligionCreatedByPlayer()
			if iReli == 0 then
				Controls.PlayerReli:SetHide(false)
				Controls.PlayerReliLabel:LocalizeAndSetText("[ICON_RELIGION_PANTHEON]")
			else
				if iReli > 0 then
					local strReliFont = GameInfo.Religions[iReli].IconString
					Controls.PlayerReli:SetHide(false)
					Controls.PlayerReliLabel:SetText(strReliFont)
				else
					for row in GameInfo.Religions("ID > 0") do
						if pPlayer:HasReligionInMostCities(row.ID) then
							iReli = row.ID
							break
						end
					end
					if iReli > 0 then
						local strReliFont = GameInfo.Religions[iReli].IconString
						Controls.PlayerReli:SetHide(false)
						Controls.PlayerReliLabel:SetText(strReliFont)
					end
					Controls.PlayerReli:SetHide(false)
					Controls.PlayerReliLabel:LocalizeAndSetText("[ICON_PANTHEON_A]")
					Controls.PlayerReli:LocalizeAndSetToolTip("[COLOR_BEIGE_ALPHA]No Pantheon[ENDCOLOR]")			
				end
			end
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--MIL (supply: used/limit)
			local iToSupply = pPlayer:GetNumUnitsToSupply()
			local iSupplied = pPlayer:GetNumUnitsSupplied()
			local strMilShortDesc = tostring(iToSupply) .. "/" .. tostring(iSupplied)
			local strMilTT = Locale.ConvertTextKey("[ICON_STRENGTH] Supply: {1_Num}/{2_Num}", iToSupply, iSupplied)
			Controls.MilIcon:SetText("[ICON_STRENGTH]")
			Controls.MilIcon:SetToolTipString(strMilTT)
			Controls.MilInfo:SetText(strMilShortDesc)
			Controls.MilInfo:SetToolTipString(strMilTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			local strStatusDesc
			
			--HAPPINESS
			local iHappiness = pPlayer:GetExcessHappiness() 	
			local strHappFont = "[ICON_HAPPINESS_1]"
			local strHappDesc = "[COLOR_JFD_OVERLAY_HAPPINESS]Happy![ENDCOLOR]"
			
			strStatusDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_HAPPINESS]{1_Num}[ENDCOLOR]", iHappiness)
			 
			if pPlayer:IsEmpireUnhappy() then
				strHappFont = "[ICON_HAPPINESS_3]"
				strHappDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_3]Unhappy![ENDCOLOR]"
				strStatusDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_UNHAPPINESS_3]{1_Num}[ENDCOLOR]", iHappiness)
			elseif pPlayer:IsEmpireVeryUnhappy() then
				strHappFont = "[ICON_HAPPINESS_4]"
				strHappDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_4]Very Unhappy![ENDCOLOR]"
				strStatusDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_UNHAPPINESS_4]{1_Num}[ENDCOLOR]", iHappiness)
			elseif pPlayer:IsEmpireSuperUnhappy() then
				strHappFont = "[ICON_HAPPINESS_4]"
				strHappDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_4]Super Unhappy![ENDCOLOR]"
				strStatusDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_UNHAPPINESS_4]{1_Num}[ENDCOLOR]", iHappiness)
			elseif pPlayer:IsGoldenAge() then
				strHappFont = "[ICON_GOLDEN_AGE]"
				strHappDesc = "[COLOR_JFD_OVERLAY_GOLDEN_AGE]G. Age![ENDCOLOR]"
				strStatusDesc = "[COLOR_JFD_OVERLAY_GOLDEN_AGE]GA![ENDCOLOR]"
			end
			local strHappTT = Locale.ConvertTextKey("{1_Desc} Stability: {2_Desc}", strHappFont, strHappDesc)
			Controls.HappInfo:SetText(strStatusDesc)
			Controls.HappInfo:SetToolTipString(strHappTT)
			Controls.HappIcon:SetText(strHappFont)
			Controls.HappIcon:SetToolTipString(strHappTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--SCIENCE (tech count; tooltip shows current research)
			local iTechs = Teams[pPlayer:GetTeam()]:GetTeamTechs():GetTechCount()
			local strResFont = "[ICON_RESEARCH]"
			local strResShortDesc = tostring(iTechs)
			local currentResearchID = pPlayer:GetCurrentResearch()
			local iSciencePerTurn = pPlayer:GetScience()
			local strResTT
			if currentResearchID > -1 then
				local techName = Locale.ConvertTextKey(GameInfo.Technologies[currentResearchID].Description)
				strResTT = Locale.ConvertTextKey("[ICON_RESEARCH] Techs: {1_Num} | +{2_Num}/turn | Researching: {3_Desc}", iTechs, iSciencePerTurn, techName)
			else
				strResTT = Locale.ConvertTextKey("[ICON_RESEARCH] Techs: {1_Num} | +{2_Num}/turn | Researching: None", iTechs, iSciencePerTurn)
			end
			Controls.ResInfo:SetText(strResShortDesc)
			Controls.ResInfo:SetToolTipString(strResTT)
			Controls.ResIcon:SetText(strResFont)
			Controls.ResIcon:SetToolTipString(strResTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--GOLD (net income display; tooltip shows treasury total)
			local strTreFont, strTreShortDesc, strTreTT = VD_GetGoldDisplay(pPlayer)
			Controls.TreInfo:LocalizeAndSetText(strTreShortDesc)
			Controls.TreInfo:SetToolTipString(strTreTT)
			Controls.TreIcon:LocalizeAndSetText(strTreFont)
			Controls.TreIcon:SetToolTipString(strTreTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--IDEOLOGY
			local ideologyID = Player_GetIdeology(pPlayer)
			if ideologyID ~= -1 then
				local policyBranch = GameInfo.PolicyBranchTypes[ideologyID]
				local policyBranchType = policyBranch.Type
				local strPolicyBranchDesc = policyBranch.Description
				local strIdeoFont = "[" .. Locale.Substring(policyBranchType, 14, Locale.Length(policyBranchType) - 14) .. "]"
				local strIdeoDesc = Locale.ConvertTextKey("{1_Font} {2_Desc}", strIdeoFont, strPolicyBranchDesc)
				
				Controls.PlayerIdeo:SetHide(false)
				Controls.PlayerIdeoLabel:SetText(strIdeoFont)
				Controls.PlayerIdeo:LocalizeAndSetToolTip(strIdeoDesc)
				
			else
				Controls.PlayerIdeo:SetHide(false)
				Controls.PlayerIdeoLabel:SetText("[ICON_IDEOLOGY_A]")
				Controls.PlayerIdeo:LocalizeAndSetToolTip("[COLOR_BEIGE_ALPHA]No Ideology[ENDCOLOR]")
			end
			
		end

		Controls.PlayerNameText:SetText(Locale.ToUpper(srCivName));
		Controls.PlayerNameText:SetFontByName("TwCenMT16");
		if Controls.PlayerNameText:GetSizeX() > 180 then
			Controls.PlayerNameText:SetFontByName("TwCenMT14");	
		end
		-- VD Stage 2: show aiLabel for LLM players, "Unknown" until data arrives
		local vdLabel = VD_Players[playerID]
		if vdLabel then
			Controls.PlayerLeaderNameText:SetText(vdLabel:gsub("-strategist", ""))
		else
			Controls.PlayerLeaderNameText:SetText("Unknown")
		end
		-- VD Stage 4: update summary and rationale rows
		VD_UpdatePanelExtras(playerID)

		--Update Relationships
		local civRelationsCount = 0
		
		g_RelationsCivManager:ResetInstances()
		local pTeam = Teams[pPlayer:GetTeam()]
		local iWarCount = pTeam:GetAtWarCount(true)
		if iWarCount > 0 then
			for iOtherPlayer=0, GameDefines.MAX_MAJOR_CIVS do
				if civRelationsCount < 10 then
					local pOtherPlayer = Players[iOtherPlayer]	
					local iOtherTeam = pOtherPlayer:GetTeam()
					if pOtherPlayer:IsAlive() and (not pOtherPlayer:IsMinorCiv()) and iOtherPlayer ~= iPlayerLoop and pTeam:IsHasMet(iOtherTeam) then
						if pTeam:IsAtWar(iOtherTeam) then
							local instance = g_RelationsCivManager:GetInstance()
							
							CivIconHookup(iOtherPlayer, 32, instance.RelationsCivIcon, instance.RelationsCivIconBG, instance.RelationsCivIconShadow, false, true, instance.RelationsCivIconHighlight)
							instance.RelationsCivBase:LocalizeAndSetToolTip(pOtherPlayer:GetCivilizationDescription())
							
							instance.RelationsIcon:SetText("[ICON_WAR]")
							instance.RelationsIcon:SetToolTipString("[COLOR_NEGATIVE_TEXT]WAR![ENDCOLOR]")
							
							civRelationsCount = civRelationsCount + 1
						end
					end
				end
			end
		end
		Controls.RelationsCivStack:ReprocessAnchoring()
	end
end
GameEvents.PlayerDoTurn.Add(UpdateNewData)
Events.LoadScreenClose.Add(UpdateNewData);
Events.AIProcessingStartedForPlayer.Add(UpdateNewData)
-- VD: Switch logic lives here — AIProcessingEnded fires after the previous
-- player's combat animations have resolved, so setting VD_PendingSwitch here
-- avoids the premature-flush bug that occurred when it was set in Started.
Events.AIProcessingEndedForPlayer.Add(function(playerID)
	local pPlayer = Players[playerID]
	if not pPlayer then return end
	if not pPlayer:IsAlive() then return end

	VD_Log("AIProcessingEnded: player=" .. tostring(playerID)
		.. " combatinflight=" .. VD_CombatInFlight)

	-- Flush any stale pending switch from a previous cycle
	VD_FlushPendingSwitch()

	if pPlayer:IsMinorCiv() then
		local currentTurn = Game.GetGameTurn()
		if VD_MinorDialogShownTurn == currentTurn then
			-- Already shown (and possibly closed by user) on this turn: do not restage.
			return
		end
		VD_MinorDialogShownTurn = currentTurn
		VD_PendingSwitch = {
			playerID  = playerID,
			reason    = "minor_civ_turn_ended",
			eventOnly = true,
			preWork = VD_AutoOpenSidePanel,
		}
		VD_Log("DeferredSwitch: player=" .. tostring(playerID)
			.. " reason=minor_civ_turn_ended")
		VD_FlushPendingSwitch()
		return
	end

	if pPlayer:IsBarbarian() then return end

	-- LLM player
	local vdLabel = VD_Players[playerID]
	if vdLabel and vdLabel ~= "VPAI / none-strategist" then
		VD_PendingSwitch = { playerID = playerID, reason = "llm_turn_ended" }
		VD_Log("DeferredSwitch: player=" .. tostring(playerID) .. " reason=llm_turn_ended")
		VD_FlushPendingSwitch()
		return
	end

	-- VPAI/unknown
	VD_PendingSwitch = { playerID = playerID, reason = "vpai_turn_ended" }
	VD_Log("DeferredSwitch: player=" .. tostring(playerID) .. " reason=vpai_turn_ended")
	VD_FlushPendingSwitch()
end)
Events.SerialEventGameDataDirty.Add(UpdateNewData);
Events.SerialEventTurnTimerDirty.Add(UpdateNewData);
Events.SerialEventCityInfoDirty.Add(UpdateNewData);
Events.SequenceGameInitComplete.Add(UpdateNewData);

-- VD: Move camera to combat scenes & gate auto-switch until animation finishes
Events.RunCombatSim.Add(function(m_AttackerPlayerID,
		m_AttackerUnitID,
		m_AttackerUnitDamage,
		m_AttackerFinalUnitDamage,
		m_AttackerMaxHitPoints,
		m_DefenderPlayerID,
		m_DefenderUnitID,
		m_DefenderUnitDamage,
		m_DefenderFinalUnitDamage,
		m_DefenderMaxHitPoints,
		m_bContinuation)
	VD_CombatInFlight = VD_CombatInFlight + 1
	VD_Log("RunCombatSim: attacker=" .. m_AttackerPlayerID
		.. " defender=" .. m_DefenderPlayerID
		.. " continuation=" .. tostring(m_bContinuation)
		.. " inflight=" .. VD_CombatInFlight)
	-- Notify downstream of every combat involving the viewed player.
	-- Camera moves only on the first combat (avoid ping-pong); subsequent
	-- combats emit VD_AnimationStarted without a camera move.
	if m_AttackerPlayerID == g_iPlayerForView or m_DefenderPlayerID == g_iPlayerForView then
		local unit = Players[m_AttackerPlayerID]:GetUnitByID(m_AttackerUnitID)
		local defUnit = Players[m_DefenderPlayerID]:GetUnitByID(m_DefenderUnitID)
		local desc = VD_BuildCombatDescription(
			m_AttackerPlayerID, m_DefenderPlayerID,
			unit, defUnit,
			m_AttackerUnitDamage, m_AttackerFinalUnitDamage, m_AttackerMaxHitPoints,
			m_DefenderUnitDamage, m_DefenderFinalUnitDamage, m_DefenderMaxHitPoints)
		if VD_CombatInFlight == 1 and unit and m_AttackerPlayerID == g_iPlayerForView then
			VD_FocusPlot(defUnit:GetPlot(), m_AttackerPlayerID, "combat", desc)
		else
			local plot = unit and unit:GetPlot() or (defUnit and defUnit:GetPlot() or nil)
			local eventInfo = VD_BuildEventInfo(plot, "combat", desc)
			LuaEvents.VD_AnimationStarted(g_iPlayerForView, eventInfo)
		end
	end
end)

Events.EndCombatSim.Add(function(m_AttackerPlayerID,
		_,
		_,
		_,
		_,
		_,
		_,
		_,
		_,
		_,
		m_bContinuation)
	VD_CombatInFlight = math.max(0, VD_CombatInFlight - 1)
	VD_Log("EndCombatSim: attacker=" .. m_AttackerPlayerID
		.. " continuation=" .. tostring(m_bContinuation)
		.. " inflight=" .. VD_CombatInFlight)
	if VD_CombatInFlight == 0 then
		VD_FlushPendingSwitch()
	end
end)

-- VD: City events worth focusing the camera on. Guarded by VD_TryFocusPlot
-- (viewed-player + combat gate + 5s debounce).
Events.SerialEventCityCaptured.Add(function(hexPos, playerID, cityID)
	local plot = VD_ResolveCityPlot(hexPos, playerID, cityID)
	local civName = Players[playerID] and Players[playerID]:GetCivilizationShortDescription() or "unknown"
	local pCity = Players[playerID] and Players[playerID]:GetCityByID(cityID)
	local cityName = pCity and pCity:GetName() or "a city"
	VD_TryFocusPlot(plot, playerID, "city_captured", civName .. " captured " .. cityName)
end)
Events.SerialEventCityCreated.Add(function(hexPos, playerID, cityID)
	local plot = VD_ResolveCityPlot(hexPos, playerID, cityID)
	local civName = Players[playerID] and Players[playerID]:GetCivilizationShortDescription() or "unknown"
	local pCity = Players[playerID] and Players[playerID]:GetCityByID(cityID)
	local cityName = pCity and pCity:GetName() or "a new city"
	VD_TryFocusPlot(plot, playerID, "city_created", civName .. " founded " .. cityName)
end)
Events.SerialEventCityDestroyed.Add(function(hexPos, playerID, cityID)
	local plot = VD_ResolveCityPlot(hexPos, playerID, cityID)
	local civName = Players[playerID] and Players[playerID]:GetCivilizationShortDescription() or "unknown"
	local pCity = Players[playerID] and Players[playerID]:GetCityByID(cityID)
	local cityName = pCity and pCity:GetName() or "a city"
	VD_TryFocusPlot(plot, playerID, "city_destroyed", civName .. " destroyed " .. cityName)
end)

-- VD: Record production / goody-hut events for playback on panel switch
GameEvents.CityTrained.Add(function(iPlayer, iCity, iUnit, bGold, bFaith)
	local pPlayer = Players[iPlayer]
	if not pPlayer then return end
	local pCity = pPlayer:GetCityByID(iCity)
	local cityName = pCity and pCity:GetName() or "a city"
	local civName = pPlayer:GetCivilizationShortDescription()
	local pUnit = pPlayer:GetUnitByID(iUnit)
	local unitInfo = pUnit and GameInfo.Units[pUnit:GetUnitType()]
	local unitName = unitInfo and Locale.ConvertTextKey(unitInfo.Description) or "a unit"
	local suffix = ""
	if bGold then suffix = " (purchased with Gold)"
	elseif bFaith then suffix = " (purchased with Faith)" end
	VD_RecordEventMessage(iPlayer, civName .. " trained " .. unitName .. " in " .. cityName .. suffix)
end)
GameEvents.CityConstructed.Add(function(iPlayer, iCity, iBuilding, bGold, bFaith)
	local pPlayer = Players[iPlayer]
	if not pPlayer then return end
	local pCity = pPlayer:GetCityByID(iCity)
	local cityName = pCity and pCity:GetName() or "a city"
	local civName = pPlayer:GetCivilizationShortDescription()
	local buildingInfo = GameInfo.Buildings[iBuilding]
	local buildingName = buildingInfo and Locale.ConvertTextKey(buildingInfo.Description) or "a building"
	local suffix = ""
	if bGold then suffix = " (purchased with Gold)"
	elseif bFaith then suffix = " (purchased with Faith)" end
	VD_RecordEventMessage(iPlayer, civName .. " constructed " .. buildingName .. " in " .. cityName .. suffix)
end)
GameEvents.CityCreated.Add(function(iPlayer, iCity, iProject, bGold, bFaith)
	local pPlayer = Players[iPlayer]
	if not pPlayer then return end
	local pCity = pPlayer:GetCityByID(iCity)
	local cityName = pCity and pCity:GetName() or "a city"
	local civName = pPlayer:GetCivilizationShortDescription()
	local projectInfo = GameInfo.Projects[iProject]
	local projectName = projectInfo and Locale.ConvertTextKey(projectInfo.Description) or "a project"
	local suffix = ""
	if bGold then suffix = " (purchased with Gold)"
	elseif bFaith then suffix = " (purchased with Faith)" end
	VD_RecordEventMessage(iPlayer, civName .. " completed " .. projectName .. " in " .. cityName .. suffix)
end)
GameEvents.GoodyHutReceivedBonus.Add(function(iPlayer, _, eGoody)
	local pPlayer = Players[iPlayer]
	if not pPlayer then return end
	local civName = pPlayer:GetCivilizationShortDescription()
	local goodyInfo = GameInfo.GoodyHuts[eGoody]
	local rewardDesc = goodyInfo and Locale.ConvertTextKey(goodyInfo.Description) or "unknown reward"
	VD_RecordEventMessage(iPlayer, civName .. " received rewards from Ancient Ruins: " .. rewardDesc)
end)

-- VD: CameraViewChanged confirms the engine actually moved the camera.
-- Clear any pending retry so we stop re-issuing UI.LookAt.
Events.CameraViewChanged.Add(function()
	if VD_PendingLookAt then
		VD_Log("CameraViewChanged: cleared pending LookAt for player=" .. tostring(VD_PendingLookAt.player))
		VD_PendingLookAt = nil
	end
end)

-- VD: Per-frame retry — if UI.LookAt was dropped (no CameraViewChanged), re-issue it.
-- Log and retry at most once per second to avoid flooding.
local VD_LastRetryLogTime = -math.huge
ContextPtr:SetUpdate(function()
	if VD_PendingLookAt then
		local now = os.clock()
		if now - VD_LastRetryLogTime >= 1.0 then
			UI.LookAt(VD_PendingLookAt.plot)
			VD_LastRetryLogTime = now
			VD_Log("LookAtRetry: player=" .. tostring(VD_PendingLookAt.player)
				.. " plot=(" .. tostring(VD_PendingLookAt.plot:GetX()) .. "," .. tostring(VD_PendingLookAt.plot:GetY()) .. ")"
				.. " capital=" .. tostring(VD_PendingLookAt.label))
		end
	end
end)

-------------------------------------------------
-- VD Stage 1: Accumulate per-player LLM state
-------------------------------------------------
local function VD_OnPlayerInfo(playerID, aiLabel)
	VD_Log("PlayerInfo: player=" .. tostring(playerID) .. " label=" .. tostring(aiLabel))
	VD_Players[playerID] = aiLabel
	if playerID == g_iPlayerForView then
		UpdateNewData(playerID)
	end
	if not Controls.WorldCivsList:IsHidden() then
		OnWorldCivsListUpdated()
	end
end
LuaEvents.VoxDeorumPlayerInfo.Add(VD_OnPlayerInfo)

local function VD_OnAction(playerID, turn, actionType, summary, rationale)
	local existing = VD_Actions[playerID]
	if existing == nil or existing.turn ~= turn then
		VD_Actions[playerID] = { turn = turn, list = {} }
	end
	table.insert(VD_Actions[playerID].list, { actionType = actionType, summary = summary, rationale = rationale })

	-- Persist qualifying rationale in cache so it survives turn rollover
	if (actionType == "strategy" or actionType == "flavors" or actionType == "status-quo")
		and rationale and rationale ~= "" then
		VD_CachedRationale[playerID] = { rationale = rationale, turn = turn }
	end

	if playerID == g_iPlayerForView then
		UpdateNewData(playerID)
	end

	if not Controls.WorldCivsList:IsHidden() then
		OnWorldCivsListUpdated()
	end
end
LuaEvents.VoxDeorumAction.Add(VD_OnAction)

Events.OpenInfoCorner( nil )
-------------------------------------------------
-------------------------------------------------
function OnCivPlayerSelected(iPlayer)
	g_iPlayerForView = iPlayer
	local pPlayer = Players[iPlayer]
	local pPlayerCap = pPlayer:GetCapitalCity()
	
	local strName = pPlayer:GetCivilizationShortDescription()
	if g_iPlayerForView == Game.GetActivePlayer() then
		strName = "[COLOR_POSITIVE_TEXT]" .. strName .. "[ENDCOLOR]"
	end
	Controls.CivPlayerIcon:SetToolTipString(strName)

	local pPlot
	if pPlayerCap then
		local iPlotX = pPlayerCap:GetX()
		local iPlotY = pPlayerCap:GetY()
		pPlot = Map.GetPlot(iPlotX, iPlotY)
	else
		pPlot = pPlayer:GetStartingPlot()
	end
	if pPlot then
		local capitalLabel = pPlayerCap and pPlayerCap:GetName() or "<starting-plot>"
		VD_PendingLookAt = { plot = pPlot, player = iPlayer, label = capitalLabel }
		VD_LastRetryLogTime = -math.huge
		UI.LookAt(pPlot)
		VD_Log("LookAt: player=" .. tostring(iPlayer)
			.. " plot=(" .. tostring(pPlot:GetX()) .. "," .. tostring(pPlot:GetY()) .. ")"
			.. " capital=" .. tostring(capitalLabel))
	else
		VD_Log("Didn't look at a plot for " .. tostring(iPlayer))
	end
	UpdateNewData(iPlayer)
	PopulateCivPulldown()
end
-------------------------------------------------
-- VD Stage 3: Auto-switch panel to the active AI player
-- Early UI feedback only — the actual player switch (VD_PendingSwitch) is set
-- in AIProcessingEndedForPlayer, which fires after the previous player's combat
-- animations have resolved.
local function VD_OnAIProcessingStarted(playerID)
	local pPlayer = Players[playerID]
	if not pPlayer then return end
	if not pPlayer:IsAlive() then return end
	local displayMode = VD_GetTurnProcessingDisplayMode(playerID)
	if not displayMode then return end

	if pPlayer:IsMinorCiv() then
		VD_ShowTurnProcessing(playerID)
		return
	end

	if pPlayer:IsBarbarian() then
		VD_CloseAutoOpenedPanel()
		VD_ShowTurnProcessing(playerID)
		return
	end

	-- LLM player — close auto-opened dialog, show thinking indicator
	local vdLabel = VD_Players[playerID]
	if vdLabel and vdLabel ~= "VPAI / none-strategist" then
		VD_CloseAutoOpenedPanel()
		local cached = VD_CachedRationale[playerID]
		if cached and cached.turn >= Game.GetGameTurn() - 1 then
			VD_ShowTurnProcessing(playerID)
		else
			if displayMode == "known" then
				VD_ShowTurnProcessing(playerID, VD_GetThinkingTitle(vdLabel))
			else
				VD_ShowTurnProcessing(playerID)
			end
		end
		return
	end

	-- VPAI/unknown
	VD_CloseAutoOpenedPanel()
	VD_ShowTurnProcessing(playerID)
end
Events.AIProcessingStartedForPlayer.Add(VD_OnAIProcessingStarted)
-------------------------------------------------
-- VD Stage 4: click rationale to open action dialog
-------------------------------------------------
Controls.VD_InfoBox:RegisterCallback(Mouse.eLClick, function()
	LuaEvents.VD_ShowActionDialog(g_iPlayerForView)
end)
-------------------------------------------------
function SetCivPlayerDetails(iPlayer, pPlayer, strName, entry)	
	local civ = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
	IconHookup(civ.PortraitIndex, 32, civ.IconAtlas, entry.CivPlayerIcon);
	
	if iPlayer == Game.GetActivePlayer() then
		strName = "[COLOR_POSITIVE_TEXT]" .. strName .. "[ENDCOLOR]"
	end
	entry.Button:SetToolTipString(strName)
	entry.CivPlayerName:SetText(strName)
	
	entry.CivPlayerIcon:SetHide(false)
end
-------------------------------------------------
local g_SortTable
function SortByName(a, b)
	local sNameA = g_SortTable[tostring(a)].Name
	local sNameB = g_SortTable[tostring(b)].Name
	return sNameA < sNameB
end
-------------------------------------------------
function PopulateCivPulldown()	

	--CIV PULLDOWN
	Controls.CivPlayerMenu:ClearEntries()
	g_SortTable = {}
	
	for iPlayer=0, GameDefines.MAX_MAJOR_CIVS do
		local pPlayer = Players[iPlayer]	
		if pPlayer:IsEverAlive() and (not pPlayer:IsMinorCiv()) and iPlayer ~= g_iPlayerForView then
			local strName = pPlayer:GetCivilizationShortDescription()
			
			local entry = {}
			Controls.CivPlayerMenu:BuildEntry("InstanceOne", entry)
			g_SortTable[tostring(entry.Button)] = {Name=strName}
		
			entry.Button:SetVoid1(iPlayer)
	
			SetCivPlayerDetails(iPlayer, pPlayer, strName, entry)
		end
	end
	
	Controls.CivPlayerMenuStack:SortChildren(SortByName)
	
	local pPlayer = Players[g_iPlayerForView]
	
	local civ = GameInfo.Civilizations[pPlayer:GetCivilizationType()]
	IconHookup(civ.PortraitIndex, 32, civ.IconAtlas, Controls.CivPlayerIcon);
	
	local strName = pPlayer:GetCivilizationShortDescription()
	if g_iPlayerForView == Game.GetActivePlayer() then
		strName = "[COLOR_POSITIVE_TEXT]" .. strName .. "[ENDCOLOR]"
	end
	Controls.CivPlayerIcon:SetToolTipString(strName)
	Controls.CivPlayerName:SetText(strName)
	
	Controls.CivPlayerIcon:SetHide(false)
	
	Controls.CivPlayerMenu:CalculateInternals()
	Controls.CivPlayerMenu:ReprocessAnchoring()
	Controls.CivPlayerMenu:RegisterSelectionCallback(OnCivPlayerSelected)
end
PopulateCivPulldown()
-------------------------------------------------
-------------------------------------------------
local g_PlayerListInstanceManager = InstanceManager:new( "PlayerEntryInstance", "PlayerEntryBox", Controls.PlayerListStack );
function OnWorldCivsListUpdated()
	Controls.WorldCivsList:SetHide(false)
	Controls.Tab:SetHide(true)

	g_PlayerListInstanceManager:ResetInstances();
	
	local worldCivsTable = {}
	local worldCivsCount = 1
	
	for iPlayerLoop = 0, GameDefines.MAX_MAJOR_CIVS-1, 1 do
		
		-- Player has to be alive to be in the list
		local pPlayer = Players[iPlayerLoop];
		if (pPlayer:IsAlive()) then
		
			local iTeam = pPlayer:GetTeam();
			local pTeam = Teams[iTeam];
		
			if pTeam:IsHasMet(Game.GetActiveTeam()) then
			
				local greatPowerRank = iPlayerLoop
				if LuaTypes.Player.CalculateGreatPowerStats then
					greatPowerRank = pPlayer:CalculateGreatPowerStats()
				end
				
				worldCivsTable[worldCivsCount] = {PlayerID = iPlayerLoop, GreatPowerRank = greatPowerRank}
				worldCivsCount = worldCivsCount + 1
			end
		end
	end	
		
	table.sort(worldCivsTable, function(a,b) return a.GreatPowerRank > b.GreatPowerRank end)
	
	for _, worldCiv in pairs(worldCivsTable) do
		local iPlayerLoop = worldCiv.PlayerID
		local pPlayer = Players[iPlayerLoop]
		local iTeam = pPlayer:GetTeam()
		local pTeam = Teams[iTeam]

		local controlTable = g_PlayerListInstanceManager:GetInstance()

		-- Leader portrait & civ icon
		local leader = GameInfo.Leaders[pPlayer:GetLeaderType()]
		CivIconHookup(iPlayerLoop, 32, controlTable.Icon, controlTable.CivIconBG, controlTable.CivIconShadow, false, true)
		IconHookup(leader.PortraitIndex, 64, leader.IconAtlas, controlTable.Portrait)

		-- ROW 1: Header — "CIV NAME (model)"
		local civDesc = Locale.ToUpper(pPlayer:GetCivilizationDescription())
		if pPlayer:GetID() == Game.GetActivePlayer() then
			civDesc = civDesc .. " (YOU)"
		end
		local vdLabel = VD_Players[iPlayerLoop]
		if vdLabel then
			civDesc = civDesc .. " (" .. vdLabel:gsub("-strategist", "") .. ")"
		end
		controlTable.VD_HeaderText:SetText(civDesc)

		-- ROW 1 right: Victory icon + short label
		local gsIcon, gsShort = VD_GetGrandStrategy(pPlayer)
		controlTable.VD_VictoryText:SetText(gsIcon .. " Goal: " .. gsShort)

		-- ROW 2: Stats bar
		-- Cities
		local iCities = pPlayer:GetNumCities()
		local strCitiesTT = Locale.ConvertTextKey("[ICON_CITY] Cities: {1_Num}", iCities)
		VD_SetStatControl(controlTable.VD_CitiesIcon, controlTable.VD_CitiesInfo, nil, tostring(iCities), strCitiesTT)

		-- Population
		local strPop = VD_FormatPopulation(pPlayer)
		local strPopTT = Locale.ConvertTextKey("[ICON_CITIZEN] Population: {1_Desc}", strPop)
		VD_SetStatControl(controlTable.VD_PopIcon, controlTable.VD_PopInfo, nil, strPop, strPopTT)

		-- Military supply
		local iToSupply = pPlayer:GetNumUnitsToSupply()
		local iSupplied = pPlayer:GetNumUnitsSupplied()
		local strMil = tostring(iToSupply) .. "/" .. tostring(iSupplied)
		local strMilTT = Locale.ConvertTextKey("[ICON_STRENGTH] Supply: {1_Num}/{2_Num}", iToSupply, iSupplied)
		VD_SetStatControl(controlTable.VD_MilIcon, controlTable.VD_MilInfo, nil, strMil, strMilTT)

		-- Tech
		local iTechs = pTeam:GetTeamTechs():GetTechCount()
		local iSciencePerTurn = pPlayer:GetScience()
		local currentResearchID = pPlayer:GetCurrentResearch()
		local strResTT
		if currentResearchID > -1 then
			local techName = Locale.ConvertTextKey(GameInfo.Technologies[currentResearchID].Description)
			strResTT = Locale.ConvertTextKey("[ICON_RESEARCH] Techs: {1_Num} | +{2_Num}/turn | Researching: {3_Desc}", iTechs, iSciencePerTurn, techName)
		else
			strResTT = Locale.ConvertTextKey("[ICON_RESEARCH] Techs: {1_Num} | +{2_Num}/turn", iTechs, iSciencePerTurn)
		end
		VD_SetStatControl(controlTable.VD_ResIcon, controlTable.VD_ResInfo, nil, tostring(iTechs), strResTT)

		-- Culture/Policy
		local iPolicies = pPlayer:GetNumPolicies()
		local iCulturePerTurn = pPlayer:GetTotalJONSCulturePerTurn()
		local strCulTT = Locale.ConvertTextKey("[ICON_CULTURE] Policies + Tenets: {1_Num} | +{2_Num}/turn", iPolicies, iCulturePerTurn)
		VD_SetStatControl(controlTable.VD_CulIcon, controlTable.VD_CulInfo, nil, tostring(iPolicies), strCulTT)

		-- Treasury/Gold
		local strTreIcon, strTreRate, strTreTT = VD_GetGoldDisplay(pPlayer)
		VD_SetStatControl(controlTable.VD_TreIcon, controlTable.VD_TreInfo, strTreIcon, strTreRate, strTreTT)

		controlTable.VD_StatsStack:ReprocessAnchoring()

		-- ROW 3: Rationale (optional) — with dynamic height
		local rationale, turn = VD_GetFirstRationale(iPlayerLoop)
		if rationale then
			controlTable.VD_RationaleLabel:SetText("(Turn " .. tostring(turn) .. ") " .. rationale)
			controlTable.VD_RationaleLabel:SetHide(false)
			local rationaleH = controlTable.VD_RationaleLabel:GetSizeY()
			VD_ResizeEntryBox(controlTable, VD_ENTRY_BASE_HEIGHT + rationaleH)
		else
			controlTable.VD_RationaleLabel:SetHide(true)
			VD_ResizeEntryBox(controlTable, VD_ENTRY_NO_RATIONALE_HEIGHT)
		end

		-- Background color from player colors
		local _, secondaryColor = pPlayer:GetPlayerColors()
		local backgroundColor = {x = secondaryColor.x, y = secondaryColor.y, z = secondaryColor.z, w = 0.3}
		controlTable.PlayerEntryAnimGrid:SetColor(backgroundColor)
		controlTable.PlayerEntryAnim:Stop()
	end
	
	Controls.PlayerListStack:CalculateSize();
	Controls.PlayerListStack:ReprocessAnchoring();
	Controls.PlayerListScrollPanel:CalculateInternalSize();
end
Controls.WorldCivsButton:RegisterCallback(Mouse.eLClick, function()
	VD_AutoOpenedPanel = nil
	OnWorldCivsListUpdated()
end);

-------------------------------------------------
-------------------------------------------------
function OnWorldCivsListClose()
	Controls.WorldCivsList:SetHide(true)
	Controls.Tab:SetHide(false)
	VD_AutoOpenedPanel = nil
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnWorldCivsListClose );

local function OnGoldClicked()
	Events.SerialEventGameMessagePopup({ Type = ButtonPopupTypes.BUTTONPOPUP_ECONOMIC_OVERVIEW })
end

local function OnMilitaryClicked()
	Events.SerialEventGameMessagePopup({ Type = ButtonPopupTypes.BUTTONPOPUP_MILITARY_OVERVIEW })
end

local function OnTechClicked()
	Events.SerialEventGameMessagePopup({ Type = ButtonPopupTypes.BUTTONPOPUP_TECH_TREE, Data2 = -1 })
end

Controls.CapInfo:RegisterCallback(Mouse.eLClick, OnGoldClicked)
Controls.CitiesInfo:RegisterCallback(Mouse.eLClick, OnGoldClicked)
Controls.PopInfo:RegisterCallback(Mouse.eLClick, OnGoldClicked)
Controls.MilInfo:RegisterCallback(Mouse.eLClick, OnMilitaryClicked)
Controls.TreInfo:RegisterCallback(Mouse.eLClick, OnGoldClicked)
Controls.ResInfo:RegisterCallback(Mouse.eLClick, OnTechClicked)

LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

Events.OpenInfoCorner(nil)
if ContextPtr:LookUpControl("/InGame/WorldView/InfoCorner") then
	ContextPtr:LookUpControl("/InGame/WorldView/InfoCorner"):SetHide(true)
end
