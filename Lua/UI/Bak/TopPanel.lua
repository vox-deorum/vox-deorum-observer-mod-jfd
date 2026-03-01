
-------------------------------
-- JFD Observer Stuff
-------------------------------
include("IconSupport");
include("InstanceManager");
include("JFD_AIObserver_Utils.lua");

local g_iPlayerForView = Game.GetActivePlayer()

local eraNumerals = {}
eraNumerals[0] = "I"
eraNumerals[1] = "II"
eraNumerals[2] = "III"
eraNumerals[3] = "IV"
eraNumerals[4] = "V"
eraNumerals[5] = "VI"
eraNumerals[6] = "VII"
eraNumerals[7] = "VIII"
eraNumerals[8] = "IX"
eraNumerals[9] = "X"
eraNumerals[10] = "XI"

local g_PolicyBranchIcons = {}
g_PolicyBranchIcons["POLICY_BRANCH_TRADITION"] = "[ICON_FOOD]"
g_PolicyBranchIcons["POLICY_BRANCH_LIBERTY"] = "[ICON_HAPPINESS_1]"
g_PolicyBranchIcons["POLICY_BRANCH_PIETY"] = "[ICON_PEACE]"
g_PolicyBranchIcons["POLICY_BRANCH_HONOR"] = "[ICON_STRENGTH]"
g_PolicyBranchIcons["POLICY_BRANCH_COMMERCE"] = "[ICON_GOLD]"
g_PolicyBranchIcons["POLICY_BRANCH_AESTHETICS"] = "[ICON_GREAT_WORK]"
g_PolicyBranchIcons["POLICY_BRANCH_PATRONAGE"] = "[ICON_INFLUENCE]"
g_PolicyBranchIcons["POLICY_BRANCH_EXPLORATION"] = "[ICON_MOVES]"
g_PolicyBranchIcons["POLICY_BRANCH_RATIONALISM"] = "[ICON_RESEARCH]"
g_PolicyBranchIcons["POLICY_BRANCH_JFD_INTRIGUE"] = "[ICON_SPY]"
g_PolicyBranchIcons["POLICY_BRANCH_JFD_CONSERVATION"] = "[ICON_TOURISM]"
g_PolicyBranchIcons["POLICY_BRANCH_JFD_INDUSTRY"] = "[ICON_PRODUCTION]"
g_PolicyBranchIcons["POLICY_BRANCH_FREEDOM"] = "[ICON_GREAT_PEOPLE]"
g_PolicyBranchIcons["POLICY_BRANCH_AUTOCRACY"] = "[ICON_WAR]"
g_PolicyBranchIcons["POLICY_BRANCH_ORDER"] = "[ICON_WORKER]"
g_PolicyBranchIcons["POLICY_BRANCH_JFD_SPIRIT"] = "[ICON_TEAM_1]"
g_PolicyBranchIcons["POLICY_BRANCH_JFD_NEUTRALITY"] = "[ICON_FLOWER]"

local g_PolicyBranchFakeGovDescs = {}
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_TRADITION"] = "Monarchy"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_LIBERTY"] = "Republic"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_PIETY"] = "Theocracy"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_HONOR"] = "Horde"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_COMMERCE"] = "Merchant Republic"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_AESTHETICS"] = "Republic of Letters"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_PATRONAGE"] = "Principality"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_EXPLORATION"] = "Empire"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_RATIONALISM"] = "Absolute Monarchy"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_JFD_INTRIGUE"] = "Sneaky Republic"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_JFD_CONSERVATION"] = "Hippy Republic"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_JFD_INDUSTRY"] = "Socialist Republic"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_FREEDOM"] = "Constitutional Monarchy (cope!)"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_AUTOCRACY"] = "Presidential Republic"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_ORDER"] = "Totally Normal Democratic Peaceocracy Here"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_JFD_SPIRIT"] = "French Republic"
g_PolicyBranchFakeGovDescs["POLICY_BRANCH_JFD_NEUTRALITY"] = "Swiss Cheese"
			

local gridX = 635
local gridY = 235

local civTitleGridX = 615
local civTitleGridY = 55

local diploGridX = 150
local diploGridY = 210

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
local g_SortTable
-------------------------------------------------
function SortByName(a, b)
  local sNameA = g_SortTable[tostring(a)].Name
  local sNameB = g_SortTable[tostring(b)].Name
	
	return sNameA < sNameB
end
-------------------------------------------------
function SortByScore(a, b)
  local sScoreA = g_SortTable[a].Score
  local sScoreB = g_SortTable[b].Score
	
	return sScoreA < sScoreB
end
-------------------------------------------------
function UpdateNewData(playerID, szTag)
	ContextPtr:LookUpControl("/InGame/WorldView/InfoCorner"):SetHide(true)
	Events.OpenInfoCorner(nil)
	
	if (not playerID) then playerID = Game.GetActivePlayer() end
	if(PreGame.IsMultiplayerGame()) then
		-- Turn Queue UI (see ActionInfoPanel.lua) replaces the turn processing UI in multiplayer.  
		return;
	end
	
	local player = Players[playerID]
	if (player == nil) then
		return;	
	end
	
	-- if (not player:IsTurnActive()) then
		-- return;
	-- end

	local civDescription;
	local bIsBarbarian = player:IsBarbarian();
	if (bIsBarbarian) then
		-- Even if there are no barbarians, we will get this call, just skip out if they are turned off
		return;
	end

	
	local dateGridX = 175
	
	--Update date
	local date;
	local traditionalDate = Game.GetTurnString();
	if (player:IsUsingMayaCalendar()) then
		date = player:GetMayaCalendarString();
		local toolTipString = Locale.ConvertTextKey("TXT_KEY_MAYA_DATE_TOOLTIP", player:GetMayaCalendarLongString(), traditionalDate);
	else
		date = traditionalDate;
	end
	Controls.CurrentDate:SetText(date);
	
	--Update turn counter
	local turn = Locale.ConvertTextKey("TXT_KEY_TP_TURN_COUNTER", Game.GetGameTurn());
	-- Controls.CurrentEra:LocalizeAndSetText(Locale.ConvertTextKey("{1_Num}", turn));
	local strDate = Locale.ConvertTextKey(date)
	local strTurn = Locale.ConvertTextKey("{1_Num}", turn)
	Controls.CurrentTern:SetText(strDate);
	-- Controls.CurrentTorn:SetText(Locale.ConvertTextKey("{1_Num}", turn));
	-- Controls.CurrentTern:SetText(Locale.ConvertTextKey(date));
	Controls.LabelStack:ReprocessAnchoring()
	-- Controls.CurrentTern2:SetText(Locale.ConvertTextKey(date) .. "[NEWLINE]" .. Locale.ConvertTextKey(eraDesc));
	
	--Update era
	local eraDesc = Locale.ConvertTextKey(GameInfo.Eras[player:GetCurrentEra()].Description) .. " - " .. strTurn;
	Controls.CurrentEra:SetText(eraDesc)
	Controls.CurrentTern:SetHide(false)
	
	local bIsMinor = player:IsMinorCiv() 
	if (not bIsMinor) and player:IsAlive() then
		local iPlayerLoop = playerID
		local pPlayer = Players[iPlayerLoop];
		local iTeam = pPlayer:GetTeam();
		local pTeam = Teams[iTeam];
		-- local civDesc = Locale.ToUpper(pPlayer:GetCivilizationDescription())
		local civDesc = pPlayer:GetCivilizationDescription()
		local leaderDesc = pPlayer:GetName()
		-- local leaderDesc = Locale.ToUpper(pPlayer:GetName())
		
		-- Use the Civilization_Leaders table to cross reference from this civ to the Leaders table
		local leader = GameInfo.Leaders[pPlayer:GetLeaderType()];
		local leaderDescription = leader.Description;
			
		local strName
		local srCivName = pPlayer:GetCivilizationDescription()
		local srCivShortName = pPlayer:GetCivilizationShortDescription()
		local strLeaderName = leaderDesc
		local srGovtName
		
		strName = srCivName
		
		local civilization = GameInfo.Civilizations[player:GetCivilizationType()]
		local leader = GameInfo.Leaders[player:GetLeaderType()]
		IconHookup( civilization.PortraitIndex, 80, civilization.IconAtlas, Controls.CivIcon )
		IconHookup( civilization.PortraitIndex, 64, civilization.IconAtlas, Controls.CivIconSmall )
		IconHookup( leader.PortraitIndex, 128, leader.IconAtlas, Controls.LeaderIcon )
		
		local ranksTable = JFD_GetScoreRank(pPlayer)
		
		--SCORE
		local numScore = ranksTable.NumScore
		local numScoreRank = ranksTable.NumScoreRank
		local colourScore = ranksTable.NumScoreRankColour
		local strScoreFont = "[ICON_TROPHY_IRON]"
		if numScoreRank == 1 then
			strScoreFont =  "[ICON_TROPHY_GOLD]"
		elseif numScoreRank == 2 then
			strScoreFont =  "[ICON_TROPHY_SILVER]"
		elseif numScoreRank == 3 then
			strScoreFont =  "[ICON_TROPHY_BRONZE]"
		elseif numScoreRank >= 61 then
			strScoreFont =  "[ICON_TROPHY_GRAPHITE]"
		end
		local strScoreShortDesc = Locale.ConvertTextKey("[{1_Color}]{2_Num}[ENDCOLOR]", colourScore, tostring(numScoreRank))
		local strScoreDesc = Locale.ConvertTextKey("Rank: [{3_Colour}]{1_Desc}. Score: {2_Num}[ENDCOLOR]", numScoreRank, numScore, colourScore)
		Controls.PlayerScoreLabel:SetText(strScoreShortDesc)
		Controls.PlayerScoreLabel:SetToolTipString(strScoreDesc)
		Controls.PlayerScoreIcon:SetText(strScoreFont)
		
		local numString = 1
		
		local pCapital = pPlayer:GetCapitalCity()
		if pCapital then
			-- CAPITAL
			local strCapName = pCapital:GetName()
			local strCapIcon = "[ICON_CAPITAL]"
			local strCapShortDesc
			local strCapTT
			if pCapital:IsOriginalCapital() then
				strCapShortDesc = Locale.ConvertTextKey("{1_Desc}", strCapName)
				strCapTT = Locale.ConvertTextKey("[ICON_CAPITAL] Capital (Original): {1_Desc}", strCapName)
			else	
				strCapName = pCapital:GetName()
				strCapIcon = "[ICON_CAPITAL_CAPTURED]"
				strCapShortDesc = Locale.ConvertTextKey("[ICON_CAPITAL_CAPTURED]{1_Desc}", strCapName)
				strCapTT = Locale.ConvertTextKey("[ICON_CAPITAL_CAPTURED] Capital (New): {1_Desc}", strCapName)
			end	
			Controls.CapIcon:SetText(strCapIcon)
			Controls.CapIcon:SetToolTipString(strCapTT)
			Controls.CapInfo:SetText(strCapShortDesc)
			Controls.CapInfo:SetToolTipString(strCapTT)
			
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
			-- local iPop = Game.GetRound(pPlayer:GetRealPopulation())			
			local iPop = pPlayer:GetTotalPopulation()
			local strPop = tostring(iPop)
			if iPop >= 1000 then
				iPop = Game.GetRound(iPop/1000)
				strPop = tostring(iPop) .. "k"
			end
			local strPopShortDesc = Locale.ConvertTextKey("{1_Desc}", strPop)
			local strPopTT = Locale.ConvertTextKey("[ICON_CITIZEN] Population: {1_Desc}", strPop)
			Controls.PopIcon:SetText("[ICON_CITIZEN]")
			Controls.PopIcon:SetToolTipString(strPopTT)
			Controls.PopInfo:SetText(strPopShortDesc)
			Controls.PopInfo:SetToolTipString(strPopTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--FOL.
			-- local iFReli = pPlayer:GetReligionCreatedByPlayer()
			-- local iReli = iFReli
			-- local strReliFont
			-- local strReliName
			-- if iReli == 0 then
				-- local iReliPop = 0
				-- for city in pPlayer:Cities() do
					-- iReliPop = iReliPop + city:GetNumFollowers(iReli)
				-- end
				-- local strReliPop = tostring(iReliPop)
				-- if iReliPop >= 1000 then
					-- iReliPop = Game.GetRound(iPop/1000)
					-- strReliPop = tostring(iReliPop) .. "k"
				-- end
				-- strReliFont = "[ICON_RELIGION_PANTHEON]"
				-- strReliName = Game.GetReligionName(iReli)
				-- local strReliPopShortDesc = Locale.ConvertTextKey("{1_Desc}", strReliPop)
				-- local strReliPopTT = Locale.ConvertTextKey("{2_Font} Followers ({3_Desc}): {1_Desc}", strReliPop, strReliFont, strReliName)	
				-- Controls.FolIcon:SetText(strReliFont)
				-- Controls.FolIcon:SetToolTipString(strReliPopTT)
				-- Controls.FolInfo:SetText(strReliPopShortDesc)
				-- Controls.FolInfo:SetToolTipString(strReliPopTT)	
			-- elseif iReli == -1 then
				-- for row in GameInfo.Religions("ID > 0") do
					-- if pPlayer:HasReligionInMostCities(row.ID) then
						-- iReli = row.ID
						-- strReliFont = row.IconString
						-- break
					-- end
				-- end
				-- if iReli > 0 then
					-- local iReliPop = 0
					-- for city in pPlayer:Cities() do
						-- iReliPop = iReliPop + city:GetNumFollowers(iReli)
					-- end
					-- local strReliPop = tostring(iReliPop)
					-- if iReliPop >= 1000 then
						-- iReliPop = Game.GetRound(iPop/1000)
						-- strReliPop = tostring(iReliPop) .. "k"
					-- end
					-- strReliName = Game.GetReligionName(iReli)
					-- local strReliPopShortDesc = Locale.ConvertTextKey("{1_Desc}", strReliPop)
					-- local strReliPopTT = Locale.ConvertTextKey("{2_Font} Followers ({3_Desc}): {1_Desc}", strReliPop, strReliFont, strReliName)
					-- Controls.FolIcon:SetText(strReliFont)
					-- Controls.FolIcon:SetToolTipString(strReliPopTT)
					-- Controls.FolInfo:SetText(strReliPopShortDesc)
					-- Controls.FolInfo:SetToolTipString(strReliPopTT)
				-- else
					-- Controls.FolInfo:SetHide(true)
					-- Controls.FolDivider:SetHide(true)
				-- end
			-- elseif iReli > 0 then
				-- local iReliPop = 0
				-- for city in pPlayer:Cities() do
					-- iReliPop = iReliPop + city:GetNumFollowers(iReli)
				-- end
				-- local strReliFont = GameInfo.Religions[iReli].IconString
				-- local strReliPop = tostring(iReliPop)
				-- if iReliPop >= 1000 then
					-- iReliPop = Game.GetRound(iPop/1000)
					-- strReliPop = tostring(iReliPop) .. "k"
				-- end
				-- strReliName = Game.GetReligionName(iReli)
				-- local strReliPopShortDesc = Locale.ConvertTextKey("{1_Desc}", strReliPop)
				-- local strReliPopTT = Locale.ConvertTextKey("{2_Font} Followers ({3_Desc}): {1_Desc}", strReliPop, strReliFont, strReliName)
				-- Controls.FolIcon:SetText(strReliFont)
				-- Controls.FolIcon:SetToolTipString(strReliPopTT)
				-- Controls.FolInfo:SetText(strReliPopShortDesc)
				-- Controls.FolInfo:SetToolTipString(strReliPopTT)
			-- end
			
			-- Controls.InfoStack:SetHide(false)
			-- Controls.InfoStack:ReprocessAnchoring()
			
			--ERA
			-- local iCurrentEra = player:GetCurrentEra() + 1
			-- local strEraFont = "[ICON_LEGEND_ERA_" .. tostring(iCurrentEra) .. "]"
			-- Controls.EraInfoFrame:SetHide(false)
			-- Controls.EraInfo:LocalizeAndSetText(strEraFont)
			-- Controls.EraInfo:LocalizeAndSetToolTip("Era: {1_Font} {2_Desc}", strEraFont, GameInfo.Eras[iCurrentEra].Description)	
			
			--RELIGION
			local iReli = pPlayer:GetReligionCreatedByPlayer()
			if iReli == 0 then
				local strReliFont = "[ICON_RELIGION_PANTHEON]"
				Controls.PlayerReli:SetHide(false)
				Controls.PlayerReliLabel:LocalizeAndSetText("[ICON_RELIGION_PANTHEON]")
			else
				if iReli > 0 then
					local strReliFont = GameInfo.Religions[iReli].IconString
					local strReliShortDesc = Game.GetReligionName(iReli)
					local strReliDesc = Locale.ConvertTextKey("{2_Font}{1_Desc}", strReliShortDesc, strReliFont)
					Controls.PlayerReli:SetHide(false)
					Controls.PlayerReliLabel:SetText(strReliFont)
				else
					for row in GameInfo.Religions("ID > 0") do
						if pPlayer:HasReligionInMostCities(row.ID) then
							iReli = row.ID
							strReliFont = row.IconString
							break
						end
					end
					if iReli > 0 then
						local strReliFont = GameInfo.Religions[iReli].IconString
						local strReliShortDesc = Game.GetReligionName(iReli)
						local strReliDesc = Locale.ConvertTextKey("{2_Font}{1_Desc}", strReliShortDesc, strReliFont)
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
			
			--MIL.
			-- local iMil = Game.GetRound(math.sqrt((pPlayer:GetMilitaryMight())*2000))
			local iMil = pPlayer:GetNumMilitaryUnits()
			local strMil = tostring(iMil)
			if iMil >= 1000 then
				iMil = Game.GetRound(iMil/1000)
				strMil = tostring(iMil) .. "k"
			end
			local strMilShortDesc = Locale.ConvertTextKey("{1_Desc}", strMil)
			-- local strMilTT = Locale.ConvertTextKey("[ICON_STRENGTH] Soldiers: {1_Desc}", strMil)
			local strMilTT = Locale.ConvertTextKey("[ICON_STRENGTH] Units: {1_Desc}", strMil)
			Controls.MilIcon:SetText("[ICON_STRENGTH]")
			Controls.MilIcon:SetToolTipString(strMilTT)
			Controls.MilInfo:SetText(strMilShortDesc)
			Controls.MilInfo:SetToolTipString(strMilTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			local strStatusDesc = "[COLOR_JFD_OVERLAY_HAPPINESS]STABLE![ENDCOLOR]"
			
			--HAPPINESS
			local iHappiness = pPlayer:GetExcessHappiness() 	
			local strHappFont = "[ICON_HAPPINESS_1]"
			local strHappDesc = "[COLOR_JFD_OVERLAY_HAPPINESS]Happy![ENDCOLOR]"
			local strHappShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_HAPPINESS]{1_Num}[ENDCOLOR]", iHappiness)
			
			if pPlayer:IsEmpireUnhappy() then
				strHappFont = "[ICON_HAPPINESS_3]"
				strHappDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_3]Unhappy![ENDCOLOR]"
				strHappShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_UNHAPPINESS_3]{1_Num}[ENDCOLOR]", iHappiness)
				
				strStatusDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_3]UNSTABLE![ENDCOLOR]"
			elseif pPlayer:IsEmpireVeryUnhappy() then
				strHappFont = "[ICON_HAPPINESS_4]"
				strHappDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_4]Very Unhappy![ENDCOLOR]"
				strHappShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_UNHAPPINESS_4]{1_Num}[ENDCOLOR]", iHappiness)
				
				strStatusDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_3]UNSTABLE![ENDCOLOR]"
			elseif pPlayer:IsEmpireSuperUnhappy() then
				strHappFont = "[ICON_HAPPINESS_4]"
				strHappDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_4]Super Unhappy![ENDCOLOR]"
				strHappShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_UNHAPPINESS_4]{1_Num}[ENDCOLOR]", iHappiness)
				
				strStatusDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_3]UNSTABLE![ENDCOLOR]"
			elseif pPlayer:IsGoldenAge() then
				strHappFont = "[ICON_GOLDEN_AGE]"
				strHappDesc = "[COLOR_JFD_OVERLAY_GOLDEN_AGE]G. Age![ENDCOLOR]"
				strHappShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_GOLDEN_AGE]{1_Num}[ENDCOLOR]", pPlayer:GetGoldenAgeTurns())
				
				strStatusDesc = "[COLOR_JFD_OVERLAY_GOLDEN_AGE]GA![ENDCOLOR]"
			elseif Player.IsDarkAge and pPlayer:IsDarkAge() then
				strHappFont = "[ICON_DARK_AGE]"
				strHappDesc = "[COLOR_JFD_OVERLAY_DARK_AGE]D. Age![ENDCOLOR]"
				strHappShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_DARK_AGE]{1_Num}[ENDCOLOR]", pPlayer:GetGoldenAgeTurns())
				
				strStatusDesc = "[COLOR_JFD_OVERLAY_DARK_AGE]DA![ENDCOLOR]"
			elseif pPlayer:IsAnarchy() then
				strHappFont = "[ICON_LEGEND_ANARCHY]"
				strHappDesc = "[COLOR_JFD_OVERLAY_ANARCHY]Anarchy![ENDCOLOR]"
				strHappShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_ANARCHY]{1_Num}[ENDCOLOR]", pPlayer:GetAnarchyTurns())
				
				strStatusDesc = "[COLOR_JFD_OVERLAY_ANARCHY]ANARCHY![ENDCOLOR]"
			end
			local strHappTT = Locale.ConvertTextKey("{1_Desc} Stability: {2_Desc}", strHappFont, strHappDesc)
			-- Controls.HappInfo:SetText(strHappDesc)
			-- Controls.HappInfo:SetText(strHappShortDesc)
			Controls.HappInfo:SetText(strStatusDesc)
			Controls.HappInfo:SetToolTipString(strHappTT)
			Controls.HappIcon:SetText(strHappFont)
			Controls.HappIcon:SetToolTipString(strHappTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--SCIENCE
			local iScience = pPlayer:GetScience() 			
			local strResFont = "[ICON_SCIENCE_POS]"
			local strResDesc = "[COLOR_JFD_OVERLAY_YIELD_SCIENCE]Progressing![ENDCOLOR]"
			local strResShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_YIELD_SCIENCE]+{1_Num}[ENDCOLOR]", iScience)
			if iScience <= 0 then
				strResFont = "[ICON_SCIENCE_EMP]"
				strResDesc = "[COLOR_WARNING_TEXT]Stalled![ENDCOLOR]"
				if iScience == 0 then
					strResShortDesc = Locale.ConvertTextKey("[COLOR_WARNING_TEXT]!{1_Num}[ENDCOLOR]", iScience)
				else
					strResShortDesc = Locale.ConvertTextKey("[COLOR_WARNING_TEXT]-{1_Num}[ENDCOLOR]", iScience)
				end
			end
			local strResTT = Locale.ConvertTextKey("{1_Desc} Research: {2_Desc}", strResFont, strResDesc)
			-- Controls.ResInfo:SetText(strResDesc)
			Controls.ResInfo:SetText(strResShortDesc)
			Controls.ResInfo:SetToolTipString(strResTT)
			Controls.ResIcon:SetText(strResFont)
			Controls.ResIcon:SetToolTipString(strResTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--GOLD
			local iGold = pPlayer:GetGold() 
			local iGoldRate = pPlayer:CalculateGoldRate()			
			-- local iNumTurnsTilBankrupt = JFD_GetTurnsTilBankruptcy(playerID)
			local strTreFont = "[ICON_GOLD_POS]"
			local strTreDesc = "[COLOR_JFD_OVERLAY_YIELD_GOLD]Prospering![ENDCOLOR]"
			local strTreShortDesc = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_YIELD_GOLD]+{1_Num}[ENDCOLOR]", iGoldRate)
			if iGold == 0 and iGoldRate < 0 then
				strTreFont = "[ICON_GOLD_EMP]"
				strTreDesc = "[COLOR_WARNING_TEXT]Bankrupt![ENDCOLOR]"
				strTreShortDesc = Locale.ConvertTextKey("[COLOR_WARNING_TEXT]!{1_Num}[ENDCOLOR]", 0)
			elseif iGoldRate == 0 then
				strTreFont = "[ICON_GOLD_NEU]"
				strTreDesc = "[COLOR_WARNING_TEXT]Flat![ENDCOLOR]"
				strTreShortDesc = Locale.ConvertTextKey("[COLOR_WARNING_TEXT]!{1_Num}[ENDCOLOR]", iGoldRate)
			elseif iGoldRate < 0 then
				strTreFont = "[ICON_GOLD_NEG]"
				strTreDesc = "[COLOR_WARNING_TEXT]Depleting![ENDCOLOR]"
				strTreShortDesc = Locale.ConvertTextKey("[COLOR_WARNING_TEXT]!{1_Num}[ENDCOLOR]", iGoldRate)
			end
			local strTreTT = Locale.ConvertTextKey("{1_Desc} Treasury: {2_Desc}", strTreFont, strTreDesc) 
			-- Controls.TreInfo:LocalizeAndSetText(strTreDesc)
			Controls.TreInfo:LocalizeAndSetText(strTreShortDesc)
			Controls.TreInfo:SetToolTipString(strTreTT)
			Controls.TreIcon:LocalizeAndSetText(strTreFont)
			Controls.TreIcon:SetToolTipString(strTreTT)
			
			Controls.InfoStack:SetHide(false)
			Controls.InfoStack:ReprocessAnchoring()
			
			--GOVERNMENT
			-- if pPlayer:IsAnarchy() then
				-- Controls.GovInfoFrame:SetHide(false)
				-- Controls.GovInfo:SetText("[ICON_RESISTANCE]")
				-- Controls.GovInfo:LocalizeAndSetToolTip("Government: [ICON_RESISTANCE][COLOR_JFD_OVERLAY_ANARCHY]Anarchy![ENDCOLOR]")
			-- else
				-- if Player.GetCurrentGovernment then		
					-- local governmentID = pPlayer:GetCurrentGovernment()
					-- local government = GameInfo.JFD_Governments[governmentID]
					-- local strGovFont = "[ICON_" .. government.Type .. "]"
					-- local strGovShortDesc = GameInfo.JFD_Governments[governmentID].Description
					-- local strGovDesc = Locale.ConvertTextKey("{2_Font} {1_Desc}", strGovShortDesc, strGovFont)
					
					-- Controls.GovInfoFrame:SetHide(false)
					-- Controls.GovInfo:SetText(strGovFont)
					-- Controls.GovInfo:LocalizeAndSetToolTip(strGovTT)
					
					-- Controls.GovInfo:SetText(strGovDesc)
					-- Controls.GovInfo:SetHide(false)
							
					-- local factionID = pPlayer:GetDominantFaction()
					-- if factionID ~= -1 then
						-- local faction = GameInfo.JFD_Factions[factionID]
						-- local strFactFont = faction.IconString
						-- local strFactDesc = Locale.ConvertTextKey("{1_Font} {2_Desc}", strFactFont, faction.Description)
						-- Controls.FactInfoFrame:SetHide(false)
						-- Controls.FactInfo:SetText(strFactFont)
						-- Controls.FactInfo:SetHide(false)
					-- else
						-- Controls.FactInfoFrame:SetHide(true)
					-- end
				-- else
					-- local strGovFakeDesc, strGovFakeFont = Player_GetFakeGovernment(pPlayer)
					-- if strGovFakeDesc and strGovFakeFont then
						-- local strGovFakeDesc = Locale.ConvertTextKey("{1_Font} {2_Desc}", strGovFakeFont, strGovFakeDesc)
						-- Controls.GovInfoFrame:SetHide(false)
						-- Controls.GovInfo:SetText(strGovFakeDesc)
						-- Controls.GovInfo:SetHide(false)
					-- else
						-- Controls.GovInfoFrame:SetHide(false)
						-- Controls.GovInfo:SetText("[ICON_GOVERNMENT_A]")
						-- Controls.GovInfo:LocalizeAndSetToolTip("[ICON_GOVERNMENT_A] No Government")
					-- end
					-- Controls.FactInfoFrame:SetHide(true)
				-- end
			-- end
		
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
				
				-- local strIdeoOpinionFont
				-- local strIdeoOpinionShortDesc
				-- local iPublicOpinionType = pPlayer:GetPublicOpinionType()
				-- if iPublicOpinionType == PublicOpinionTypes["PUBLIC_OPINION_DISSIDENTS"] then
					-- strIdeoOpinionFont = "[ICON_HAPPINESS_3]"
					-- strIdeoOpinionShortDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_3]Dissidents![ENDCOLOR]"
				-- elseif iPublicOpinionType == PublicOpinionTypes["PUBLIC_OPINION_CIVIL_RESISTANCE"] then
					-- strIdeoOpinionFont = "[ICON_HAPPINESS_4]"
					-- strIdeoOpinionShortDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_3]Civil Resistance![ENDCOLOR]"
				-- elseif iPublicOpinionType == PublicOpinionTypes["PUBLIC_OPINION_REVOLUTIONARY_WAVE"] then
					-- strIdeoOpinionFont = "[ICON_RESISTENCE]"
					-- strIdeoOpinionShortDesc = "[COLOR_JFD_OVERLAY_UNHAPPINESS_4]Revolutionary Wave![ENDCOLOR]"
				-- else
					-- strIdeoOpinionFont = "[ICON_HAPPINESS_1]"
					-- strIdeoOpinionShortDesc = "[COLOR_JFD_OVERLAY_HAPPINESS]Content[ENDCOLOR]"
				-- end
				-- local strIdeoOpinionTT = Locale.ConvertTextKey("Public Opinion: {1_Font} {2_Desc}", strIdeoOpinionFont, strIdeoOpinionShortDesc)
				
				-- Controls.IdeoInfo2:SetHide(false)
				-- Controls.IdeoInfo2:SetText(strIdeoOpinionFont)
				-- Controls.IdeoInfo2:LocalizeAndSetToolTip(strIdeoOpinionTT)
				
			else
				Controls.PlayerIdeo:SetHide(false)
				Controls.PlayerIdeoLabel:SetText("[ICON_IDEOLOGY_A]")
				Controls.PlayerIdeo:LocalizeAndSetToolTip("[COLOR_BEIGE_ALPHA]No Ideology[ENDCOLOR]")
			end
			
			Controls.StatsStack:ReprocessAnchoring()
			-- Controls.StatsStack:SetHide(false)
		end
				
		--EPITHET
		strLeaderName = strLeaderName
		if Player.GetEpithetTitle then
			local strEpithet = pPlayer:GetEpithetTitle()
			if strEpithet then
				strLeaderName = strLeaderName .. " " .. Locale.ConvertTextKey(strEpithet)
			end
		end
		-- if pPlayer:IsGoldenAge() then
			-- srCivName = "[COLOR_JFD_OVERLAY_GOLDEN_AGE][ICON_GOLDEN_AGE] " .. strCivName .. "[ENDCOLOR]"
		-- elseif Player.IsDarkAge and pPlayer:IsDarkAge() then
			-- srCivName = "[COLOR_JFD_OVERLAY_DARK_AGE][ICON_JFD_DARK_AGE] " .. strCivName .. "[ENDCOLOR]"
		-- end
		Controls.PlayerNameText:SetText(Locale.ToUpper(srCivName));
		Controls.PlayerNameText:SetFontByName("TwCenMT16");
		if Controls.PlayerNameText:GetSizeX() > 180 then
			Controls.PlayerNameText:SetFontByName("TwCenMT14");	
		end
		Controls.PlayerLeaderNameText:SetText(strLeaderName);
		
		--Update Relationships
		local civRelationsCount = 0
		
		g_RelationsCivManager:ResetInstances()
		g_SortTable = {}
	
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
							
							if civRelationsCount == 10 then
								instance.RelationsIconPlus:SetHide(false)
								instance.RelationsIconPlus:LocalizeAndSetText("[ICON_PLUS}{1_Num}", iWarCount)
							end
						end
					end
				end
			end
		end
		-- Controls.RelationsCivStack:SortChildren(SortByScore)
		Controls.RelationsCivStack:ReprocessAnchoring()
	end
	
	-- Controls.LeftInfoStack:ReprocessAnchoring()
	-- Controls.RightInfoStack:ReprocessAnchoring()
end
-- GameEvents.PlayerDoTurn.Add(UpdateNewData)
Events.LoadScreenClose.Add(UpdateNewData);
-- Events.AIProcessingStartedForPlayer.Add(UpdateNewData)
-- Events.SerialEventGameDataDirty.Add(UpdateNewData);
-- Events.SerialEventTurnTimerDirty.Add(UpdateNewData);
-- Events.SerialEventCityInfoDirty.Add(UpdateNewData);
-- Events.SequenceGameInitComplete.Add(UpdateNewData);

function OnShowInterfaceButton()
	if Controls.PlayerInfoGrid:IsHidden() then
		Controls.PlayerInfoGrid:SetHide(false)
		Controls.DiploPanelLeft:SetHide(false)
		Controls.ShowInterfaceButton:SetTexture("mainclose.dds")
		Controls.ShowInterfaceMO:SetTexture("mainclose.dds")
		Controls.ShowInterfaceHL:SetTexture("mainclosehl.dds")
	else
		Controls.PlayerInfoGrid:SetHide(true)
		Controls.DiploPanelLeft:SetHide(true)
		Controls.ShowInterfaceButton:SetTexture("mainopen.dds")
		Controls.ShowInterfaceMO:SetTexture("mainopen.dds")
		Controls.ShowInterfaceHL:SetTexture("mainopenhl.dds")
	end
end
Controls.ShowInterfaceButton:RegisterCallback( Mouse.eLClick, OnShowInterfaceButton );
Events.OpenInfoCorner( nil )
-------------------------------------------------
-------------------------------------------------
local g_bPlayerForViewLookup = true

function OnCivPlayerSelected(iPlayer)
	g_iPlayerForView = iPlayer
	local pPlayer = Players[iPlayer]
	local pPlayerCap = pPlayer:GetCapitalCity()
	
	local strName = pPlayer:GetCivilizationShortDescription()
	if iPlayer == Game.GetActivePlayer() then
		strName = "[COLOR_POSITIVE_TEXT]" .. strName .. "[ENDCOLOR]"
	end
	Controls.CivPlayerIcon:SetToolTipString(strName)

	if g_bPlayerForViewLookup then
		local pPlot
		if pPlayerCap then
			local iPlotX = pPlayerCap:GetX()
			local iPlotY = pPlayerCap:GetY()
			pPlot = Map.GetPlot(iPlotX, iPlotY)
		else
			pPlot = pPlayer:GetStartingPlot()
		end
		if pPlot then
			UI.LookAt(pPlot);
		end
	end
	UpdateNewData(iPlayer)
	PopulateCivPulldown()
end
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
	if iPlayer == Game.GetActivePlayer() then
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
function OnIGEButton()
	LuaEvents.IGE_ShowHideMainButton()
end
if Game_IsIGEActive() then
	Controls.IGEButton:RegisterCallback( Mouse.eLClick, OnIGEButton );
else
	Controls.IGEButton:SetHide(true)
	Controls.InfoButtonStack:ReprocessAnchoring()
end
-------------------------------------------------
-------------------------------------------------
function OnPediaButton()
	Events.SearchForPediaEntry("");
end
Controls.PediaButton:RegisterCallback( Mouse.eLClick, OnPediaButton );

function OnPediaButton2()
	
	-- In City View, return to main game
	if (UI.GetHeadSelectedCity() ~= nil) then
		Events.SerialEventExitCityScreen();
		--UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION);
	-- In Main View, open Menu Popup
	else
	    UIManager:QueuePopup( LookUpControl( "/InGame/GameMenu" ), PopupPriority.InGameMenu );
	end
end
Controls.PediaButton:RegisterCallback( Mouse.eRClick, OnPediaButton2 );
-------------------------------------------------
-------------------------------------------------
function OnInfoAddictButton()
	 UIManager:PushModal(MapModData.InfoAddict.InfoAddictScreenContext)
end
if Game_IsInfoAddictActive() then
	Controls.InfoAddictButton:RegisterCallback( Mouse.eLClick, OnInfoAddictButton );
else
	Controls.InfoAddictButton:SetHide(true)
	Controls.InfoButtonStack:ReprocessAnchoring()
end
-------------------------------------------------
-------------------------------------------------
function OnOverlayMapsButton()
	LuaEvents.JFD_UI_ShowOverlayMapsOverview()
end
Controls.OverlayMapsButton:RegisterCallback( Mouse.eLClick, OnOverlayMapsButton );

-------------------------------------------------
-------------------------------------------------
local g_PlayerListInstanceManager = InstanceManager:new( "PlayerEntryInstance", "PlayerEntryBox", Controls.PlayerListStack );
function OnWorldCivsListUpdated()
	Controls.WorldCivsList:SetHide(false)
	
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
				if Player.CalculateGreatPowerStats then
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
		local pPlayer = Players[iPlayerLoop];
		local iTeam = pPlayer:GetTeam();
		local pTeam = Teams[iTeam];
			
		local civDesc = Locale.ToUpper(pPlayer:GetCivilizationDescription())
		local leaderDesc = pPlayer:GetName()
		
		-- Use the Civilization_Leaders table to cross reference from this civ to the Leaders table
		local leader = GameInfo.Leaders[pPlayer:GetLeaderType()];
		local leaderDescription = leader.Description;
			
		local strName
		local srCivName = pPlayer:GetCivilizationDescription()
		local strLeaderName = leaderDesc
		local srGovtName
		local strGovtStatsName = ""
		local strEcoStatsName = ""
		
		local controlTable = g_PlayerListInstanceManager:GetInstance();
		
		if (pPlayer:GetID() == Game.GetActivePlayer()) then
			strName = civDesc .. " (" .. Locale.ToUpper( "TXT_KEY_POP_VOTE_RESULTS_YOU" ) .. ")"
		else
			strName = civDesc
		end	
		
		CivIconHookup( iPlayerLoop, 32, controlTable.Icon, controlTable.CivIconBG, controlTable.CivIconShadow, false, true);  
		IconHookup( leader.PortraitIndex, 64, leader.IconAtlas, controlTable.Portrait );
		
		--CYCLES OF POWER
		local cyclePowerID = -1
		if Player.GetCyclePower then
			cyclePowerID = pPlayer:GetCyclePower() or -1
		end				
		if cyclePowerID ~= -1 then
			local cyclePower = GameInfo.JFD_CyclePowers[cyclePowerID]
			controlTable.CyclePower:SetHide(false)		
			strGovtStatsName = "[COLOR_JFD_VIRTUE][ICON_BULLET][ICON_JFD_CYCLE_OF_POWER] " .. Locale.ToUpper(cyclePower.Description) .. "[ENDCOLOR]"
		else
			controlTable.CyclePower:SetHide(true)
		end
		
		--SOVEREIGNTY
		local governmentID = -1
		if Player.GetCurrentGovernment then		
			governmentID = pPlayer:GetCurrentGovernment()
			srGovtName = pPlayer:GetGovernmentName(governmentID)	
			strGovtStatsName = strGovtStatsName .. "[COLOR_JFD_SOVEREIGNTY][ICON_BULLET][ICON_JFD_GOVERNMENT] " .. Locale.ConvertTextKey(GameInfo.JFD_Governments[governmentID].Description) .. "[ENDCOLOR]" 
			-- strGovtStatsName = strGovtStatsName .. " (" .. srGovtName .. ")" 
			
			local factionID = pPlayer:GetDominantFaction()
			if factionID ~= -1 then
				strGovtStatsName = strGovtStatsName .. "[COLOR_JFD_SOVEREIGNTY][ICON_BULLET]" .. GameInfo.JFD_Factions[factionID].IconString .. " " .. Locale.ConvertTextKey(GameInfo.JFD_Factions[factionID].Adjective) .. "[ENDCOLOR]" 
				-- strGovtStatsName = strGovtStatsName .. " (" .. pPlayer:GetFactionName(factionID) .. ")" 
			end
		end
		
		--IDEOLOGY
		local ideologyID = Player_GetIdeology(pPlayer)
		local ideologyFont = nil
		if ideologyID == -1 then
			ideologyID = pPlayer:GetDominantPolicyBranchForTitle()
			ideologyFont = "[ICON_CULTURE]"
		else
			ideologyFont = GameInfo.PolicyBranchTypes[ideologyID].IconString
		end
		if ideologyID ~= -1 then
			strGovtStatsName = strGovtStatsName .. "[COLOR_MAGENTA][ICON_BULLET]" .. ideologyFont .. " " .. Locale.ConvertTextKey(GameInfo.PolicyBranchTypes[ideologyID].Description) .. "[ENDCOLOR]	"
		end
		
		--RELIGION
		local religionID = Player_GetMainReligion(pPlayer)
		local religionFont = nil
		if religionID >= 0 and pPlayer:HasCreatedPantheon() then
			religionFont = GameInfo.Religions[religionID].IconString
			strGovtStatsName = strGovtStatsName .. "[COLOR_WHITE][ICON_BULLET]" .. religionFont .. Locale.ConvertTextKey(GameInfo.Religions[religionID].Description) .. "[ENDCOLOR]"
		end
		
		--STABILITY
		--Update status
		controlTable.PlayerStabilityStatsText:LocalizeAndSetText("[ICON_HAPPINESS_1] [COLOR_HAPPINESS]STABLE[ENDCOLOR]")
		controlTable.PlayerStabilityStatsText:LocalizeAndSetToolTip("[ICON_HAPPINESS_1] [COLOR_HAPPINESS]STABLE[ENDCOLOR]")
		if pPlayer:IsEmpireSuperUnhappy() then
			controlTable.PlayerStabilityStatsText:LocalizeAndSetText("[ICON_HAPPINESS_4] [COLOR_NEGATIVE_TEXT]CIVIL WAR![ENDCOLOR]")
			controlTable.PlayerStabilityStatsText:LocalizeAndSetToolTip("[ICON_HAPPINESS_4] [COLOR_NEGATIVE_TEXT]CIVIL WAR![ENDCOLOR]")
		end
		if pPlayer:IsEmpireVeryUnhappy() then
			controlTable.PlayerStabilityStatsText:LocalizeAndSetText("[ICON_HAPPINESS_4] [COLOR_NEGATIVE_TEXT]CIVIL WAR![ENDCOLOR]")
			controlTable.PlayerStabilityStatsText:LocalizeAndSetToolTip("[ICON_HAPPINESS_4] [COLOR_NEGATIVE_TEXT]CIVIL WAR![ENDCOLOR]")
		end
		if pPlayer:IsEmpireUnhappy() then
			controlTable.PlayerStabilityStatsText:LocalizeAndSetText("[ICON_HAPPINESS_3] [COLOR_UNHAPPINESS]REBELLION![ENDCOLOR]")
			controlTable.PlayerStabilityStatsText:LocalizeAndSetToolTip("[ICON_HAPPINESS_3] [COLOR_UNHAPPINESS]REBELLION![ENDCOLOR]")
		end
		if pPlayer:IsGoldenAge() then
			controlTable.PlayerStabilityStatsText:LocalizeAndSetText("[ICON_GOLDEN_AGE] [COLOR_GOLDEN_AGE]GOLDEN AGE![ENDCOLOR]")
			controlTable.PlayerStabilityStatsText:LocalizeAndSetToolTip("[ICON_GOLDEN_AGE] [COLOR_GOLDEN_AGE]GOLDEN AGE![ENDCOLOR]")
		end
		if Player.IsDarkAge and pPlayer:IsDarkAge() then
			controlTable.PlayerStabilityStatsText:LocalizeAndSetText("[ICON_DARK_AGE] [COLOR_DARK_AGE]DARK AGE![ENDCOLOR]")
			controlTable.PlayerStabilityStatsText:LocalizeAndSetToolTip("[ICON_DARK_AGE] [COLOR_DARK_AGE]DARK AGE![ENDCOLOR]")
		end
		if pPlayer:IsAnarchy() then
			controlTable.PlayerStabilityStatsText:LocalizeAndSetText("[ICON_RESISTANCE] [COLOR_RED]ANARCHY![ENDCOLOR]")
			controlTable.PlayerStabilityStatsText:LocalizeAndSetToolTip("[ICON_RESISTANCE] [COLOR_RED]ANARCHY![ENDCOLOR]")
		end
		
		--AGES
		-- if pPlayer:IsGoldenAge() then
			-- controlTable.AgeIcon:SetText("[ICON_GOLDEN_AGE]")
			-- controlTable.AgeIcon:SetHide(false)
			-- controlTable.PlayerEntryAnim:Play()
			-- controlTable.PlayerEntryAnimGridDA:SetHide(true)
			-- controlTable.PlayerEntryAnimGridNA:SetHide(true)
			-- controlTable.PlayerEntryAnimGridGA:SetHide(true)
		-- elseif Player.IsDarkAge and pPlayer:IsDarkAge() then
			-- controlTable.AgeIcon:SetText("[ICON_DARK_AGE]")
			-- controlTable.AgeIcon:SetHide(false)
			-- controlTable.PlayerEntryAnim:Play()
			-- controlTable.PlayerEntryAnimGridDA:SetHide(true)
			-- controlTable.PlayerEntryAnimGridNA:SetHide(true)
			-- controlTable.PlayerEntryAnimGridGA:SetHide(true)
		-- else
			controlTable.AgeIcon:SetHide(true)
			controlTable.PlayerEntryAnim:Stop()
			controlTable.PlayerEntryAnimGridDA:SetHide(true)
			controlTable.PlayerEntryAnimGridNA:SetHide(true)
			controlTable.PlayerEntryAnimGridGA:SetHide(true)
		-- end
		local primaryColor, secondaryColor = pPlayer:GetPlayerColors();
		local backgroundColor = {x = secondaryColor.x, y = secondaryColor.y, z = secondaryColor.z, w = 0.3};
		controlTable.PlayerEntryAnimGrid:SetColor(backgroundColor)
			
		--GREAT POWER STATUS
		-- if Player.GetGreatPowerStatus then
			-- local greatPowerStatusID = pPlayer:GetGreatPowerStatus()
			-- if greatPowerStatusID ~= -1 then
				-- local greatPowerStatus = GameInfo.JFD_GreatPowers[greatPowerStatusID]
				-- strName = greatPowerStatus.IconString .. "[" .. greatPowerStatus.ColorString .. "]" .. strName .. "[ENDCOLOR]"
				
				-- local secondaryColor = GameInfo.Colors[greatPowerStatus.ColorString]
				-- local backgroundColor = {x = secondaryColor.Red, y = secondaryColor.Green, z = secondaryColor.Blue, w = 0.3};
				-- controlTable.PlayerEntryAnimGrid:SetColor(backgroundColor)
			-- end
		-- end
		
		--EPITHET
		if Player.GetEpithetTitle then
			local strEpithet = pPlayer:GetEpithetTitle()
			if strEpithet then
				strLeaderName = strLeaderName .. " " .. Locale.ConvertTextKey(strEpithet)
			end
		end
		
		--LAND PERCENT
		local numPlotPercent = Game.GetRound(((pPlayer:GetNumPlots()/Map.GetNumPlots())*100),2)
		if strEcoStatsName ~= "" then
			strEcoStatsName = strEcoStatsName .. "[ICON_BULLET]"
		end
		strEcoStatsName = strEcoStatsName .. "[ICON_BULLET]"
		strEcoStatsName = strEcoStatsName .. "Land: " .. numPlotPercent .. "%" 
			
		--POPULATION PERCENT
		local numPopPercent = Game.GetRound(((pPlayer:GetTotalPopulation()/Game.GetTotalPopulation())*100),2)
		strEcoStatsName = strEcoStatsName .. "[ICON_BULLET]"
		strEcoStatsName = strEcoStatsName .. "Population: " .. numPopPercent .. "%" 
		
		--MILITARY PERCENT
		local numMilitary = pPlayer:GetMilitaryMight()
		local numGlobalMilitary = 0
		for otherPlayerID = 0, GameDefines["MAX_MINOR_CIVS"], 1 do
			local otherPlayer = Players[otherPlayerID]
			if otherPlayer:IsAlive() and otherPlayerID ~= playerID then
				numGlobalMilitary = numGlobalMilitary + otherPlayer:GetMilitaryMight()
			end
		end
		local numMilitaryPercent = Game.GetRound(((numMilitary/numGlobalMilitary)*100),2)
		strEcoStatsName = strEcoStatsName .. "[ICON_BULLET]"
		strEcoStatsName = strEcoStatsName .. "Military: " .. numMilitaryPercent .. "%" 
			
		controlTable.PlayerGovtStatsText:LocalizeAndSetText(strGovtStatsName)
		controlTable.PlayerEcoStatsText:LocalizeAndSetText(strEcoStatsName)
		controlTable.PlayerEcoStatsText:LocalizeAndSetToolTip("TXT_KEY_JFD_WORLD_CIVILIZATIONS_ECO_STATS", numPlotPercent, numPopPercent, numMilitaryPercent)
		controlTable.PlayerNameText:SetText(strName);
		controlTable.PlayerCivNameText:SetText("[ICON_BULLET]" .. srCivName);
		controlTable.PlayerLeaderNameText:SetText("[ICON_BULLET]" .. strLeaderName);
		controlTable.RightInfoStack:ReprocessAnchoring()
	end
	
	Controls.PlayerListStack:CalculateSize();
	Controls.PlayerListStack:ReprocessAnchoring();
	Controls.PlayerListScrollPanel:CalculateInternalSize();
end
Controls.WorldCivsButton:RegisterCallback( Mouse.eLClick, OnWorldCivsListUpdated );

function OnWorldCivsRClicked()
	LuaEvents.UI_ShowGovernmentOverview()
end
Controls.WorldCivsButton:RegisterCallback( Mouse.eRClick, OnWorldCivsRClicked );
-------------------------------------------------
-------------------------------------------------
function OnWorldCivsListClose()
	Controls.WorldCivsList:SetHide(true)
end
Controls.CloseButton:RegisterCallback( Mouse.eLClick, OnWorldCivsListClose );
-------------------------------
-- TopPanel.lua
-------------------------------

function UpdateData()

	local iPlayerID = Game.GetActivePlayer();

	if( iPlayerID >= 0 ) then
		local pPlayer = Players[iPlayerID];
		local pTeam = Teams[pPlayer:GetTeam()];
		local pCity = UI.GetHeadSelectedCity();
		
		if (pPlayer:GetNumCities() > 0) then
			
			-- Controls.TopPanelInfoStack:SetHide(false);
			
			if (pCity ~= nil and UI.IsCityScreenUp()) then		
				Controls.MenuButton:SetText(Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_RETURN")));
				Controls.MenuButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_CITY_SCREEN_EXIT_TOOLTIP"));
			else
				Controls.MenuButton:SetText(Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_MENU")));
				Controls.MenuButton:SetToolTipString(Locale.ConvertTextKey("TXT_KEY_MENU_TOOLTIP"));
			end
			-----------------------------
			-- Update science stats
			-----------------------------
			local strScienceText;
			
			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
				strScienceText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_SCIENCE_OFF");
			else
			
				local sciencePerTurn = pPlayer:GetScience();
			
				-- No Science
				if (sciencePerTurn <= 0) then
					strScienceText = string.format("[COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_NO_SCIENCE") .. "[/COLOR]");
				-- We have science
				else
					strScienceText = string.format("+%i", sciencePerTurn);

					local iGoldPerTurn = pPlayer:CalculateGoldRate();
					
					-- Gold being deducted from our Science
					if (pPlayer:GetGold() + iGoldPerTurn < 0) then
						strScienceText = "[COLOR:255:60:0:255]" .. strScienceText .. "[/COLOR]";
					-- Normal Science state
					else
						strScienceText = "[COLOR:33:190:247:255]" .. strScienceText .. "[/COLOR]";
					end
				end
			
				strScienceText = "[ICON_RESEARCH]" .. strScienceText;
			end
			
			Controls.SciencePerTurn:SetText(strScienceText);
			
			-----------------------------
			-- Update gold stats
			-----------------------------
			local iTotalGold = pPlayer:GetGold();
			local iGoldPerTurn = pPlayer:CalculateGoldRate();
			
			-- Accounting for positive or negative GPT - there's obviously a better way to do this.  If you see this comment and know how, it's up to you ;)
			-- Text is White when you can buy a Plot
			--if (iTotalGold >= pPlayer:GetBuyPlotCost(-1,-1)) then
				--if (iGoldPerTurn >= 0) then
					--strGoldStr = string.format("[COLOR:255:255:255:255]%i (+%i)[/COLOR]", iTotalGold, iGoldPerTurn)
				--else
					--strGoldStr = string.format("[COLOR:255:255:255:255]%i (%i)[/COLOR]", iTotalGold, iGoldPerTurn)
				--end
			---- Text is Yellow or Red when you can't buy a Plot
			--else
			local strGoldStr = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_GOLD", iTotalGold, iGoldPerTurn);
			--end
			
			Controls.GoldPerTurn:SetText(strGoldStr);

			-----------------------------
			-- Update international trade routes
			-----------------------------
			local iUsedTradeRoutes = pPlayer:GetNumInternationalTradeRoutesUsed();
			local iAvailableTradeRoutes = pPlayer:GetNumInternationalTradeRoutesAvailable();
			local strInternationalTradeRoutes = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES", iUsedTradeRoutes, iAvailableTradeRoutes);
			Controls.InternationalTradeRoutes:SetText(strInternationalTradeRoutes);
			
			-----------------------------
			-- Update Happiness
			-----------------------------
			local strHappiness;
			
			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)) then
				strHappiness = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_HAPPINESS_OFF");
			else
				local iHappiness = pPlayer:GetExcessHappiness();
				local tHappinessTextColor;

				-- Empire is Happiness
				if (not pPlayer:IsEmpireUnhappy()) then
					strHappiness = string.format("[ICON_HAPPINESS_1][COLOR:60:255:60:255]%i[/COLOR]", iHappiness);
				
				-- Empire Really Unhappy
				elseif (pPlayer:IsEmpireVeryUnhappy()) then
					strHappiness = string.format("[ICON_HAPPINESS_4][COLOR:255:60:60:255]%i[/COLOR]", -iHappiness);
				
				-- Empire Unhappy
				else
					strHappiness = string.format("[ICON_HAPPINESS_3][COLOR:255:60:60:255]%i[/COLOR]", -iHappiness);
				end
			end
			
			Controls.HappinessString:SetText(strHappiness);
			
			-----------------------------
			-- Update Golden Age Info
			-----------------------------
			local strGoldenAgeStr;

			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)) then
				strGoldenAgeStr = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_GOLDEN_AGES_OFF");
			else
				if (pPlayer:GetGoldenAgeTurns() > 0) then
				    if (pPlayer:GetGoldenAgeTourismModifier() > 0) then
						strGoldenAgeStr = string.format(Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_UNIQUE_GOLDEN_AGE_ANNOUNCE")) .. " (%i)", pPlayer:GetGoldenAgeTurns());
					else
						strGoldenAgeStr = string.format(Locale.ToUpper(Locale.ConvertTextKey("TXT_KEY_GOLDEN_AGE_ANNOUNCE")) .. " (%i)", pPlayer:GetGoldenAgeTurns());
					end
				else
					strGoldenAgeStr = string.format("%i/%i", pPlayer:GetGoldenAgeProgressMeter(), pPlayer:GetGoldenAgeProgressThreshold());
				end
			
				strGoldenAgeStr = "[ICON_GOLDEN_AGE][COLOR:255:255:255:255]" .. strGoldenAgeStr .. "[/COLOR]";
			end
			
			Controls.GoldenAgeString:SetText(strGoldenAgeStr);
			
			-----------------------------
			-- Update Culture
			-----------------------------

			local strCultureStr;
			
			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES)) then
				strCultureStr = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_POLICIES_OFF");
			else
			
				if (pPlayer:GetNextPolicyCost() > 0) then
					strCultureStr = string.format("%i/%i (+%i)", pPlayer:GetJONSCulture(), pPlayer:GetNextPolicyCost(), pPlayer:GetTotalJONSCulturePerTurn());
				else
					strCultureStr = string.format("%i (+%i)", pPlayer:GetJONSCulture(), pPlayer:GetTotalJONSCulturePerTurn());
				end
			
				strCultureStr = "[ICON_CULTURE][COLOR:255:0:255:255]" .. strCultureStr .. "[/COLOR]";
			end
			
			Controls.CultureString:SetText(strCultureStr);
			
			-----------------------------
			-- Update Tourism
			-----------------------------
			local strTourism;
			strTourism = string.format("[ICON_TOURISM] +%i", pPlayer:GetTourism());
			Controls.TourismString:SetText(strTourism);
			
			-----------------------------
			-- Update Faith
			-----------------------------
			local strFaithStr;
			if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
				strFaithStr = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_RELIGION_OFF");
			else
				strFaithStr = string.format("%i (+%i)", pPlayer:GetFaith(), pPlayer:GetTotalFaithPerTurn());
				strFaithStr = "[ICON_PEACE]" .. strFaithStr;
			end
			Controls.FaithString:SetText(strFaithStr);
	
			-----------------------------
			-- Update Resources
			-----------------------------
			local pResource;
			local bShowResource;
			local iNumAvailable;
			local iNumUsed;
			local iNumTotal;
			
			local strResourceText = "";
			local strTempText = "";
			
			for pResource in GameInfo.Resources() do
				local iResourceLoop = pResource.ID;
				
				if (Game.GetResourceUsageType(iResourceLoop) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC) then
					
					bShowResource = false;
					
					if (pTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechReveal])) then
						if (pTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechCityTrade])) then
							bShowResource = true;
						end
					end
					
					iNumAvailable = pPlayer:GetNumResourceAvailable(iResourceLoop, true);
					iNumUsed = pPlayer:GetNumResourceUsed(iResourceLoop);
					iNumTotal = pPlayer:GetNumResourceTotal(iResourceLoop, true);
					
					if (iNumUsed > 0) then
						bShowResource = true;
					end
							
					if (bShowResource) then
						local text = Locale.ConvertTextKey(pResource.IconString);
						strTempText = string.format("%i %s   ", iNumAvailable, text);
						
						-- Colorize for amount available
						if (iNumAvailable > 0) then
							strTempText = "[COLOR_POSITIVE_TEXT]" .. strTempText .. "[ENDCOLOR]";
						elseif (iNumAvailable < 0) then
							strTempText = "[COLOR_WARNING_TEXT]" .. strTempText .. "[ENDCOLOR]";
						end
						
						strResourceText = strResourceText .. strTempText;
					end
				end
			end
			
			Controls.ResourceString:SetText(strResourceText);
			
		-- No Cities, so hide science
		else
			
			Controls.TopPanelInfoStack:SetHide(true);
			
		end
		
		-- Update turn counter
		local turn = Locale.ConvertTextKey("TXT_KEY_TP_TURN_COUNTER", Game.GetGameTurn());
		Controls.CurrentTurn:SetText(turn);
		
		-- Update Unit Supply
		local iUnitSupplyMod = pPlayer:GetUnitProductionMaintenanceMod();
		if (iUnitSupplyMod ~= 0) then
			local iUnitsSupplied = pPlayer:GetNumUnitsSupplied();
			local iUnitsOver = pPlayer:GetNumUnitsOutOfSupply();
			local strUnitSupplyToolTip = Locale.ConvertTextKey("TXT_KEY_UNIT_SUPPLY_REACHED_TOOLTIP", iUnitsSupplied, iUnitsOver, -iUnitSupplyMod);
			
			Controls.UnitSupplyString:SetToolTipString(strUnitSupplyToolTip);
			Controls.UnitSupplyString:SetHide(false);
		else
			Controls.UnitSupplyString:SetHide(true);
		end
		
		-- Update date
		local date;
		local traditionalDate = Game.GetTurnString();
		
		if (pPlayer:IsUsingMayaCalendar()) then
			date = pPlayer:GetMayaCalendarString();
			local toolTipString = Locale.ConvertTextKey("TXT_KEY_MAYA_DATE_TOOLTIP", pPlayer:GetMayaCalendarLongString(), traditionalDate);
			Controls.CurrentDate:SetToolTipString(toolTipString);
		else
			date = traditionalDate;
		end
		
		Controls.CurrentDate:SetText(date);
	end
end

function OnTopPanelDirty()
	UpdateData();
end
-------------------------------------------------
-------------------------------------------------
function OnCivilopedia()	
	-- In City View, return to main game
	--if (UI.GetHeadSelectedCity() ~= nil) then
		--Events.SerialEventExitCityScreen();
	--end
	--
	-- opens the Civilopedia without changing its current state
	Events.SearchForPediaEntry("");
end
Controls.CivilopediaButton:RegisterCallback( Mouse.eLClick, OnCivilopedia );


-------------------------------------------------
-------------------------------------------------
function OnMenu()
	
	-- In City View, return to main game
	if (UI.GetHeadSelectedCity() ~= nil) then
		Events.SerialEventExitCityScreen();
		--UI.SetInterfaceMode(InterfaceModeTypes.INTERFACEMODE_SELECTION);
	-- In Main View, open Menu Popup
	else
	    UIManager:QueuePopup( LookUpControl( "/InGame/GameMenu" ), PopupPriority.InGameMenu );
	end
end
Controls.MenuButton:RegisterCallback( Mouse.eLClick, OnMenu );


-------------------------------------------------
-------------------------------------------------
function OnCultureClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_CHOOSEPOLICY } );

end
Controls.CultureString:RegisterCallback( Mouse.eLClick, OnCultureClicked );


-------------------------------------------------
-------------------------------------------------
function OnTechClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_TECH_TREE, Data2 = -1} );

end
Controls.SciencePerTurn:RegisterCallback( Mouse.eLClick, OnTechClicked );

-------------------------------------------------
-------------------------------------------------
function OnTourismClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_CULTURE_OVERVIEW, Data2 = 4 } );

end
Controls.TourismString:RegisterCallback( Mouse.eLClick, OnTourismClicked );


-------------------------------------------------
-------------------------------------------------
function OnFaithClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_RELIGION_OVERVIEW } );

end
Controls.FaithString:RegisterCallback( Mouse.eLClick, OnFaithClicked );
-------------------------------------------------
-------------------------------------------------
function OnGoldClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_ECONOMIC_OVERVIEW } );

end
Controls.GoldPerTurn:RegisterCallback( Mouse.eLClick, OnGoldClicked );
-------------------------------------------------
-------------------------------------------------
function OnTradeRouteClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_TRADE_ROUTE_OVERVIEW } );

end
Controls.InternationalTradeRoutes:RegisterCallback( Mouse.eLClick, OnTradeRouteClicked );
-------------------------------------------------
-------------------------------------------------
function OnScoreClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_DEMOGRAPHICS } );

end
-------------------------------------------------
-------------------------------------------------
function OnMilitaryClicked()
	
	Events.SerialEventGameMessagePopup( { Type = ButtonPopupTypes.BUTTONPOPUP_MILITARY_OVERVIEW } );

end
-------------------------------------------------
-------------------------------------------------
function OnGovernmentClicked()
	
	LuaEvents.UI_ShowGovernmentOverview()

end

-------------------------------------------------
-------------------------------------------------

Controls.CapInfo:RegisterCallback( Mouse.eLClick, OnGoldClicked );
Controls.CitiesInfo:RegisterCallback( Mouse.eLClick, OnGoldClicked );
Controls.PopInfo:RegisterCallback( Mouse.eLClick, OnGoldClicked );
-- Controls.FolInfo:RegisterCallback( Mouse.eLClick, OnFaithClicked );
Controls.MilInfo:RegisterCallback( Mouse.eLClick, OnMilitaryClicked );
Controls.TreInfo:RegisterCallback( Mouse.eLClick, OnGoldClicked );
Controls.ResInfo:RegisterCallback( Mouse.eLClick, OnTechClicked );


-------------------------------------------------
-- TOOLTIPS
-------------------------------------------------


-- Tooltip init
function DoInitTooltips()
	Controls.SciencePerTurn:SetToolTipCallback( ScienceTipHandler );
	Controls.GoldPerTurn:SetToolTipCallback( GoldTipHandler );
	Controls.HappinessString:SetToolTipCallback( HappinessTipHandler );
	Controls.GoldenAgeString:SetToolTipCallback( GoldenAgeTipHandler );
	Controls.CultureString:SetToolTipCallback( CultureTipHandler );
	Controls.TourismString:SetToolTipCallback( TourismTipHandler );
	Controls.FaithString:SetToolTipCallback( FaithTipHandler );
	Controls.ResourceString:SetToolTipCallback( ResourcesTipHandler );
	Controls.InternationalTradeRoutes:SetToolTipCallback( InternationalTradeRoutesTipHandler );
end

-- Science Tooltip
local tipControlTable = {};
TTManager:GetTypeControlTable( "TooltipTypeTopPanel", tipControlTable );
function ScienceTipHandler( control )

	local strText = "";
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_SCIENCE)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_SCIENCE_OFF_TOOLTIP");
	else
	
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];
		local pTeam = Teams[pPlayer:GetTeam()];
		local pCity = UI.GetHeadSelectedCity();
	
		local iSciencePerTurn = pPlayer:GetScience();
	
		if (pPlayer:IsAnarchy()) then
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_ANARCHY", pPlayer:GetAnarchyNumTurns());
			strText = strText .. "[NEWLINE][NEWLINE]";
		end
	
		-- Science
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE", iSciencePerTurn);
		
			if (pPlayer:GetNumCities() > 0) then
				strText = strText .. "[NEWLINE][NEWLINE]";
			end
		end
	
		local bFirstEntry = true;
	
		-- Science LOSS from Budget Deficits
		local iScienceFromBudgetDeficit = pPlayer:GetScienceFromBudgetDeficitTimes100();
		if (iScienceFromBudgetDeficit ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end

			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_BUDGET_DEFICIT", iScienceFromBudgetDeficit / 100);
			strText = strText .. "[NEWLINE]";
		end
	
		-- Science from Cities
		local iScienceFromCities = pPlayer:GetScienceFromCitiesTimes100(true);
		if (iScienceFromCities ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end

			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_CITIES", iScienceFromCities / 100);
		end
	
		-- Science from Trade Routes
		local iScienceFromTrade = pPlayer:GetScienceFromCitiesTimes100(false) - iScienceFromCities;
		if (iScienceFromTrade ~= 0) then
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end
			
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_ITR", iScienceFromTrade / 100);
		end
	
		-- Science from Other Players
		local iScienceFromOtherPlayers = pPlayer:GetScienceFromOtherPlayersTimes100();
		if (iScienceFromOtherPlayers ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end

			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_MINORS", iScienceFromOtherPlayers / 100);
		end
	
		-- Science from Happiness
		local iScienceFromHappiness = pPlayer:GetScienceFromHappinessTimes100();
		if (iScienceFromHappiness ~= 0) then
			
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end
	
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_HAPPINESS", iScienceFromHappiness / 100);
		end
	
		-- Science from Research Agreements
		local iScienceFromRAs = pPlayer:GetScienceFromResearchAgreementsTimes100();
		if (iScienceFromRAs ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				bFirstEntry = false;
			else
				strText = strText .. "[NEWLINE]";
			end
	
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_SCIENCE_FROM_RESEARCH_AGREEMENTS", iScienceFromRAs / 100);
		end
		
		-- Let people know that building more cities makes techs harder to get
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_TECH_CITY_COST", Game.GetNumCitiesTechCostMod());
		end
	end
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Gold Tooltip
function GoldTipHandler( control )

	local strText = "";
	local iPlayerID = Game.GetActivePlayer();
	local pPlayer = Players[iPlayerID];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pCity = UI.GetHeadSelectedCity();
	
	local iTotalGold = pPlayer:GetGold();

	local iGoldPerTurnFromOtherPlayers = pPlayer:GetGoldPerTurnFromDiplomacy();
	local iGoldPerTurnToOtherPlayers = 0;
	if (iGoldPerTurnFromOtherPlayers < 0) then
		iGoldPerTurnToOtherPlayers = -iGoldPerTurnFromOtherPlayers;
		iGoldPerTurnFromOtherPlayers = 0;
	end
	
	local iGoldPerTurnFromReligion = pPlayer:GetGoldPerTurnFromReligion();

	local fTradeRouteGold = (pPlayer:GetGoldFromCitiesTimes100() - pPlayer:GetGoldFromCitiesMinusTradeRoutesTimes100()) / 100;
	local fGoldPerTurnFromCities = pPlayer:GetGoldFromCitiesMinusTradeRoutesTimes100() / 100;
	local fCityConnectionGold = pPlayer:GetCityConnectionGoldTimes100() / 100;
	--local fInternationalTradeRouteGold = pPlayer:GetGoldPerTurnFromTradeRoutesTimes100() / 100;
	local fTraitGold = pPlayer:GetGoldPerTurnFromTraits();
	local fTotalIncome = fGoldPerTurnFromCities + iGoldPerTurnFromOtherPlayers + fCityConnectionGold + iGoldPerTurnFromReligion + fTradeRouteGold + fTraitGold;
	
	if (pPlayer:IsAnarchy()) then
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_ANARCHY", pPlayer:GetAnarchyNumTurns());
		strText = strText .. "[NEWLINE][NEWLINE]";
	end
	
	if (not OptionsManager.IsNoBasicHelp()) then
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_AVAILABLE_GOLD", iTotalGold);
		strText = strText .. "[NEWLINE][NEWLINE]";
	end
	
	strText = strText .. "[COLOR:150:255:150:255]";
	strText = strText .. "+" .. Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_INCOME", math.floor(fTotalIncome));
	strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_CITY_OUTPUT", fGoldPerTurnFromCities);
	strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_FROM_CITY_CONNECTIONS", math.floor(fCityConnectionGold));
	strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_FROM_ITR", math.floor(fTradeRouteGold));
	if (math.floor(fTraitGold) > 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_FROM_TRAITS", math.floor(fTraitGold));
	end
	if (iGoldPerTurnFromOtherPlayers > 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_FROM_OTHERS", iGoldPerTurnFromOtherPlayers);
	end
	if (iGoldPerTurnFromReligion > 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_FROM_RELIGION", iGoldPerTurnFromReligion);
	end
	strText = strText .. "[/COLOR]";
	
	local iUnitCost = pPlayer:CalculateUnitCost();
	local iUnitSupply = pPlayer:CalculateUnitSupply();
	local iBuildingMaintenance = pPlayer:GetBuildingGoldMaintenance();
	local iImprovementMaintenance = pPlayer:GetImprovementGoldMaintenance();
	local iTotalExpenses = iUnitCost + iUnitSupply + iBuildingMaintenance + iImprovementMaintenance + iGoldPerTurnToOtherPlayers;
	
	strText = strText .. "[NEWLINE]";
	strText = strText .. "[COLOR:255:150:150:255]";
	strText = strText .. "[NEWLINE]-" .. Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_EXPENSES", iTotalExpenses);
	if (iUnitCost ~= 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNIT_MAINT", iUnitCost);
	end
	if (iUnitSupply ~= 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_UNIT_SUPPLY", iUnitSupply);
	end
	if (iBuildingMaintenance ~= 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_BUILDING_MAINT", iBuildingMaintenance);
	end
	if (iImprovementMaintenance ~= 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_TILE_MAINT", iImprovementMaintenance);
	end
	if (iGoldPerTurnToOtherPlayers > 0) then
		strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLD_TO_OTHERS", iGoldPerTurnToOtherPlayers);
	end
	strText = strText .. "[/COLOR]";
	
	if (fTotalIncome + iTotalGold < 0) then
		strText = strText .. "[NEWLINE][COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_TP_LOSING_SCIENCE_FROM_DEFICIT") .. "[/COLOR]";
	end
	
	-- Basic explanation of Happiness
	if (not OptionsManager.IsNoBasicHelp()) then
		strText = strText .. "[NEWLINE][NEWLINE]";
		strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_GOLD_EXPLANATION");
	end
	
	--Controls.GoldPerTurn:SetToolTipString(strText);
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Happiness Tooltip
function HappinessTipHandler( control )

	local strText;
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_HAPPINESS_OFF_TOOLTIP");
	else
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];
		local pTeam = Teams[pPlayer:GetTeam()];
		local pCity = UI.GetHeadSelectedCity();
	
		local iHappiness = pPlayer:GetExcessHappiness();

		if (not pPlayer:IsEmpireUnhappy()) then
			strText = Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_HAPPINESS", iHappiness);
		elseif (pPlayer:IsEmpireVeryUnhappy()) then
			strText = Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_UNHAPPINESS", "[ICON_HAPPINESS_4]", -iHappiness);
		else
			strText = Locale.ConvertTextKey("TXT_KEY_TP_TOTAL_UNHAPPINESS", "[ICON_HAPPINESS_3]", -iHappiness);
		end
	
		local iPoliciesHappiness = pPlayer:GetHappinessFromPolicies();
		local iResourcesHappiness = pPlayer:GetHappinessFromResources();
		local iExtraLuxuryHappiness = pPlayer:GetExtraHappinessPerLuxury();
		local iCityHappiness = pPlayer:GetHappinessFromCities();
		local iBuildingHappiness = pPlayer:GetHappinessFromBuildings();
		local iTradeRouteHappiness = pPlayer:GetHappinessFromTradeRoutes();
		local iReligionHappiness = pPlayer:GetHappinessFromReligion();
		local iNaturalWonderHappiness = pPlayer:GetHappinessFromNaturalWonders();
		local iExtraHappinessPerCity = pPlayer:GetExtraHappinessPerCity() * pPlayer:GetNumCities();
		local iMinorCivHappiness = pPlayer:GetHappinessFromMinorCivs();
		local iLeagueHappiness = pPlayer:GetHappinessFromLeagues();
	
		local iHandicapHappiness = pPlayer:GetHappiness() - iPoliciesHappiness - iResourcesHappiness - iCityHappiness - iBuildingHappiness - iTradeRouteHappiness - iReligionHappiness - iNaturalWonderHappiness - iMinorCivHappiness - iExtraHappinessPerCity - iLeagueHappiness;
	
		if (pPlayer:IsEmpireVeryUnhappy()) then
		
			if (pPlayer:IsEmpireSuperUnhappy()) then
				strText = strText .. "[NEWLINE][NEWLINE]";
				strText = strText .. "[COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_TP_EMPIRE_SUPER_UNHAPPY") .. "[/COLOR]";
			end
		
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. "[COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_TP_EMPIRE_VERY_UNHAPPY") .. "[/COLOR]";
		elseif (pPlayer:IsEmpireUnhappy()) then
		
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. "[COLOR:255:60:60:255]" .. Locale.ConvertTextKey("TXT_KEY_TP_EMPIRE_UNHAPPY") .. "[/COLOR]";
		end
	
		local iTotalHappiness = iPoliciesHappiness + iResourcesHappiness + iCityHappiness + iBuildingHappiness + iMinorCivHappiness + iHandicapHappiness + iTradeRouteHappiness + iReligionHappiness + iNaturalWonderHappiness + iExtraHappinessPerCity + iLeagueHappiness;
	
		strText = strText .. "[NEWLINE][NEWLINE]";
		strText = strText .. "[COLOR:150:255:150:255]";
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_SOURCES", iTotalHappiness);
	
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_FROM_RESOURCES", iResourcesHappiness);
	
		-- Individual Resource Info
	
		local iBaseHappinessFromResources = 0;
		local iNumHappinessResources = 0;

		for resource in GameInfo.Resources() do
			local resourceID = resource.ID;
			local iHappiness = pPlayer:GetHappinessFromLuxury(resourceID);
			if (iHappiness > 0) then
				strText = strText .. "[NEWLINE]";
				strText = strText .. "          +" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_EACH_RESOURCE", iHappiness, resource.IconString, resource.Description);
				iNumHappinessResources = iNumHappinessResources + 1;
				iBaseHappinessFromResources = iBaseHappinessFromResources + iHappiness;
			end
		end
	
		-- Happiness from Luxury Variety
		local iHappinessFromExtraResources = pPlayer:GetHappinessFromResourceVariety();
		if (iHappinessFromExtraResources > 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "          +" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_RESOURCE_VARIETY", iHappinessFromExtraResources);
		end
	
		-- Extra Happiness from each Luxury
		if (iExtraLuxuryHappiness >= 1) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "          +" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_EXTRA_PER_RESOURCE", iExtraLuxuryHappiness, iNumHappinessResources);
		end
	
		-- Misc Happiness from Resources
		local iMiscHappiness = iResourcesHappiness - iBaseHappinessFromResources - iHappinessFromExtraResources - (iExtraLuxuryHappiness * iNumHappinessResources);
		if (iMiscHappiness > 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "          +" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_OTHER_SOURCES", iMiscHappiness);
		end
	
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_CITIES", iCityHappiness);
		if (iPoliciesHappiness >= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_POLICIES", iPoliciesHappiness);
		end
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_BUILDINGS", iBuildingHappiness);
		if (iTradeRouteHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_CONNECTED_CITIES", iTradeRouteHappiness);
		end
		if (iReligionHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_STATE_RELIGION", iReligionHappiness);
		end
		if (iNaturalWonderHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_NATURAL_WONDERS", iNaturalWonderHappiness);
		end
		if (iExtraHappinessPerCity ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_CITY_COUNT", iExtraHappinessPerCity);
		end
		if (iMinorCivHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_CITY_STATE_FRIENDSHIP", iMinorCivHappiness);
		end
		if (iLeagueHappiness ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_LEAGUES", iLeagueHappiness);
		end
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_DIFFICULTY_LEVEL", iHandicapHappiness);
		strText = strText .. "[/COLOR]";
	
		-- Unhappiness
		local iTotalUnhappiness = pPlayer:GetUnhappiness();
		local iUnhappinessFromUnits = Locale.ToNumber( pPlayer:GetUnhappinessFromUnits() / 100, "#.##" );
		local iUnhappinessFromCityCount = Locale.ToNumber( pPlayer:GetUnhappinessFromCityCount() / 100, "#.##" );
		local iUnhappinessFromCapturedCityCount = Locale.ToNumber( pPlayer:GetUnhappinessFromCapturedCityCount() / 100, "#.##" );
		
		local iUnhappinessFromPupetCities = pPlayer:GetUnhappinessFromPuppetCityPopulation();
		local unhappinessFromSpecialists = pPlayer:GetUnhappinessFromCitySpecialists();
		local unhappinessFromPop = pPlayer:GetUnhappinessFromCityPopulation() - unhappinessFromSpecialists - iUnhappinessFromPupetCities;
			
		local iUnhappinessFromPop = Locale.ToNumber( unhappinessFromPop / 100, "#.##" );
		local iUnhappinessFromOccupiedCities = Locale.ToNumber( pPlayer:GetUnhappinessFromOccupiedCities() / 100, "#.##" );
		local iUnhappinessPublicOpinion = pPlayer:GetUnhappinessFromPublicOpinion();
		
		strText = strText .. "[NEWLINE][NEWLINE]";
		strText = strText .. "[COLOR:255:150:150:255]";
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_TOTAL", iTotalUnhappiness);
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_CITY_COUNT", iUnhappinessFromCityCount);
		if (iUnhappinessFromCapturedCityCount ~= "0") then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_CAPTURED_CITY_COUNT", iUnhappinessFromCapturedCityCount);
		end
		strText = strText .. "[NEWLINE]";
		strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_POPULATION", iUnhappinessFromPop);
		
		if(iUnhappinessFromPupetCities > 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_PUPPET_CITIES", iUnhappinessFromPupetCities / 100);
		end
		
		if(unhappinessFromSpecialists > 0) then
			strText = strText .. "[NEWLINE]  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_SPECIALISTS", unhappinessFromSpecialists / 100);
		end
		
		if (iUnhappinessFromOccupiedCities ~= "0") then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_OCCUPIED_POPULATION", iUnhappinessFromOccupiedCities);
		end
		if (iUnhappinessFromUnits ~= "0") then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_UNITS", iUnhappinessFromUnits);
		end
		if (iPoliciesHappiness < 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_POLICIES", iPoliciesHappiness);
		end		
		if (iUnhappinessPublicOpinion > 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. "  [ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_TP_UNHAPPINESS_PUBLIC_OPINION", iUnhappinessPublicOpinion);
		end		
		strText = strText .. "[/COLOR]";
	
		-- Basic explanation of Happiness
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_HAPPINESS_EXPLANATION");
		end
	end
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Golden Age Tooltip
function GoldenAgeTipHandler( control )

	local strText;
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_HAPPINESS)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_HAPPINESS_OFF_TOOLTIP");
	else
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];
		local pTeam = Teams[pPlayer:GetTeam()];
		local pCity = UI.GetHeadSelectedCity();
	
		if (pPlayer:GetGoldenAgeTurns() > 0) then
			strText = Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_NOW", pPlayer:GetGoldenAgeTurns());
		else
			local iHappiness = pPlayer:GetExcessHappiness();

			strText = Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_PROGRESS", pPlayer:GetGoldenAgeProgressMeter(), pPlayer:GetGoldenAgeProgressThreshold());
			strText = strText .. "[NEWLINE]";
		
			if (iHappiness >= 0) then
				strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_ADDITION", iHappiness);
			else
				strText = strText .. "[COLOR_WARNING_TEXT]" .. Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_LOSS", -iHappiness) .. "[ENDCOLOR]";
			end
		end
	
		strText = strText .. "[NEWLINE][NEWLINE]";
		if (pPlayer:IsGoldenAgeCultureBonusDisabled()) then
			strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_EFFECT_NO_CULTURE");		
		else
			strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_GOLDEN_AGE_EFFECT");		
		end
		
		if (pPlayer:GetGoldenAgeTurns() > 0 and pPlayer:GetGoldenAgeTourismModifier() > 0) then
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText ..  Locale.ConvertTextKey("TXT_KEY_TP_CARNIVAL_EFFECT");			
		end
	end
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Culture Tooltip
function CultureTipHandler( control )

	local strText = "";
	
	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_POLICIES)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_POLICIES_OFF_TOOLTIP");
	else
	
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];
    
	    local iTurns;
		local iCultureNeeded = pPlayer:GetNextPolicyCost() - pPlayer:GetJONSCulture();
	    if (iCultureNeeded <= 0) then
			iTurns = 0;
		else
			if (pPlayer:GetTotalJONSCulturePerTurn() == 0) then
				iTurns = "?";
			else
				iTurns = iCultureNeeded / pPlayer:GetTotalJONSCulturePerTurn();
				iTurns = math.ceil(iTurns);
			end
	    end
	    
	    if (pPlayer:IsAnarchy()) then
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_ANARCHY", pPlayer:GetAnarchyNumTurns());
		end
	    
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_NEXT_POLICY_TURN_LABEL", iTurns);
	
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_ACCUMULATED", pPlayer:GetJONSCulture());
			strText = strText .. "[NEWLINE]";
		
			if (pPlayer:GetNextPolicyCost() > 0) then
				strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_NEXT_POLICY", pPlayer:GetNextPolicyCost());
			end
		end

		if (pPlayer:IsAnarchy()) then
			tipControlTable.TooltipLabel:SetText( strText );
			tipControlTable.TopPanelMouseover:SetHide(false);
			tipControlTable.TopPanelMouseover:DoAutoSize();
			return;
		end

		local bFirstEntry = true;
		
		-- Culture for Free
		local iCultureForFree = pPlayer:GetJONSCulturePerTurnForFree();
		if (iCultureForFree ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FOR_FREE", iCultureForFree);
		end
	
		-- Culture from Cities
		local iCultureFromCities = pPlayer:GetJONSCulturePerTurnFromCities();
		if (iCultureFromCities ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_CITIES", iCultureFromCities);
		end
	
		-- Culture from Excess Happiness
		local iCultureFromHappiness = pPlayer:GetJONSCulturePerTurnFromExcessHappiness();
		if (iCultureFromHappiness ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_HAPPINESS", iCultureFromHappiness);
		end
	
		-- Culture from Traits
		local iCultureFromTraits = pPlayer:GetJONSCulturePerTurnFromTraits();
		if (iCultureFromTraits ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_TRAITS", iCultureFromTraits);
		end
	
		-- Culture from Minor Civs
		local iCultureFromMinors = pPlayer:GetCulturePerTurnFromMinorCivs();
		if (iCultureFromMinors ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_MINORS", iCultureFromMinors);
		end

		-- Culture from Religion
		local iCultureFromReligion = pPlayer:GetCulturePerTurnFromReligion();
		if (iCultureFromReligion ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_RELIGION", iCultureFromReligion);
		end
		
		-- Culture from a bonus turns (League Project)
		local iCultureFromBonusTurns = pPlayer:GetCulturePerTurnFromBonusTurns();
		if (iCultureFromBonusTurns ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			local iBonusTurns = pPlayer:GetCultureBonusTurns();
			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_BONUS_TURNS", iCultureFromBonusTurns, iBonusTurns);
		end
		
		-- Culture from Golden Age
		local iCultureFromGoldenAge = pPlayer:GetTotalJONSCulturePerTurn() - iCultureForFree - iCultureFromCities - iCultureFromHappiness - iCultureFromMinors - iCultureFromReligion - iCultureFromTraits - iCultureFromBonusTurns;
		if (iCultureFromGoldenAge ~= 0) then
		
			-- Add separator for non-initial entries
			if (bFirstEntry) then
				strText = strText .. "[NEWLINE]";
				bFirstEntry = false;
			end

			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_FROM_GOLDEN_AGE", iCultureFromGoldenAge);
		end

		-- Let people know that building more cities makes policies harder to get
		if (not OptionsManager.IsNoBasicHelp()) then
			strText = strText .. "[NEWLINE][NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_CULTURE_CITY_COST", Game.GetNumCitiesPolicyCostMod());
		end
	end
	
	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Tourism Tooltip
function TourismTipHandler( control )

	local iPlayerID = Game.GetActivePlayer();
	local pPlayer = Players[iPlayerID];
	
	local iTotalGreatWorks = pPlayer:GetNumGreatWorks();
	local iTotalSlots = pPlayer:GetNumGreatWorkSlots();
	
	local strText1 = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_1", iTotalGreatWorks);
	local strText2 = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_2", (iTotalSlots - iTotalGreatWorks));
		
	local strText = strText1 .. "[NEWLINE]" .. strText2;
		
	local cultureVictory = GameInfo.Victories["VICTORY_CULTURAL"];
	if(cultureVictory ~= nil and PreGame.IsVictory(cultureVictory.ID)) then
	    local iNumInfluential = pPlayer:GetNumCivsInfluentialOn();
		local iNumToBeInfluential = pPlayer:GetNumCivsToBeInfluentialOn();
		local szText = Locale.ConvertTextKey("TXT_KEY_CO_VICTORY_INFLUENTIAL_OF", iNumInfluential, iNumToBeInfluential);

		local strText3 = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_TOURISM_TOOLTIP_3", szText);
		
		strText = strText .. "[NEWLINE][NEWLINE]" .. strText3;
	end	

	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- FaithTooltip
function FaithTipHandler( control )

	local strText = "";

	if (Game.IsOption(GameOptionTypes.GAMEOPTION_NO_RELIGION)) then
		strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_RELIGION_OFF_TOOLTIP");
	else
	
		local iPlayerID = Game.GetActivePlayer();
		local pPlayer = Players[iPlayerID];

	    if (pPlayer:IsAnarchy()) then
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_ANARCHY", pPlayer:GetAnarchyNumTurns());
			strText = strText .. "[NEWLINE]";
			strText = strText .. "[NEWLINE]";
		end
	    
		strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_ACCUMULATED", pPlayer:GetFaith());
		strText = strText .. "[NEWLINE]";
	
		-- Faith from Cities
		local iFaithFromCities = pPlayer:GetFaithPerTurnFromCities();
		if (iFaithFromCities ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_CITIES", iFaithFromCities);
		end
	
		-- Faith from Minor Civs
		local iFaithFromMinorCivs = pPlayer:GetFaithPerTurnFromMinorCivs();
		if (iFaithFromMinorCivs ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_MINORS", iFaithFromMinorCivs);
		end

		-- Faith from Religion
		local iFaithFromReligion = pPlayer:GetFaithPerTurnFromReligion();
		if (iFaithFromReligion ~= 0) then
			strText = strText .. "[NEWLINE]";
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_FROM_RELIGION", iFaithFromReligion);
		end
		
		if (iFaithFromCities ~= 0 or iFaithFromMinorCivs ~= 0 or iFaithFromReligion ~= 0) then
			strText = strText .. "[NEWLINE]";
		end
	
		strText = strText .. "[NEWLINE]";

		if (pPlayer:HasCreatedPantheon()) then
			if (Game.GetNumReligionsStillToFound() > 0 or pPlayer:HasCreatedReligion()) then
				if (pPlayer:GetCurrentEra() < GameInfo.Eras["ERA_INDUSTRIAL"].ID) then
					strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_NEXT_PROPHET", pPlayer:GetMinimumFaithNextGreatProphet());
					strText = strText .. "[NEWLINE]";
					strText = strText .. "[NEWLINE]";
				end
			end
		else
			if (pPlayer:CanCreatePantheon(false)) then
				strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_NEXT_PANTHEON", Game.GetMinimumFaithNextPantheon());
				strText = strText .. "[NEWLINE]";
			else
				strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_PANTHEONS_LOCKED");
				strText = strText .. "[NEWLINE]";
			end
			strText = strText .. "[NEWLINE]";
		end

		if (Game.GetNumReligionsStillToFound() < 0) then
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_RELIGIONS_LEFT", 0);
		else
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_RELIGIONS_LEFT", Game.GetNumReligionsStillToFound());
		end
		
		if (pPlayer:GetCurrentEra() >= GameInfo.Eras["ERA_INDUSTRIAL"].ID) then
		    local bAnyFound = false;
			strText = strText .. "[NEWLINE]";		
			strText = strText .. "[NEWLINE]";		
			strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_FAITH_NEXT_GREAT_PERSON", pPlayer:GetMinimumFaithNextGreatProphet());	
			
			local capital = pPlayer:GetCapitalCity();
			if(capital ~= nil) then	
				for info in GameInfo.Units{Special = "SPECIALUNIT_PEOPLE"} do
					local infoID = info.ID;
					local faithCost = capital:GetUnitFaithPurchaseCost(infoID, true);
					if(faithCost > 0 and pPlayer:IsCanPurchaseAnyCity(false, true, infoID, -1, YieldTypes.YIELD_FAITH)) then
						if (pPlayer:DoesUnitPassFaithPurchaseCheck(infoID)) then
							strText = strText .. "[NEWLINE]";
							strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey(info.Description);
							bAnyFound = true;
						end
					end
				end
			end
						
			if (not bAnyFound) then
				strText = strText .. "[NEWLINE]";
				strText = strText .. "[ICON_BULLET]" .. Locale.ConvertTextKey("TXT_KEY_RO_YR_NO_GREAT_PEOPLE");
			end
		end
	end

	tipControlTable.TooltipLabel:SetText( strText );
	tipControlTable.TopPanelMouseover:SetHide(false);
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- Resources Tooltip
function ResourcesTipHandler( control )

	local strText;
	local iPlayerID = Game.GetActivePlayer();
	local pPlayer = Players[iPlayerID];
	local pTeam = Teams[pPlayer:GetTeam()];
	local pCity = UI.GetHeadSelectedCity();
	
	strText = "";
	
	local pResource;
	local bShowResource;
	local bThisIsFirstResourceShown = true;
	local iNumAvailable;
	local iNumUsed;
	local iNumTotal;
	
	for pResource in GameInfo.Resources() do
		local iResourceLoop = pResource.ID;
		
		if (Game.GetResourceUsageType(iResourceLoop) == ResourceUsageTypes.RESOURCEUSAGE_STRATEGIC) then
			
			bShowResource = false;
			
			if (pTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechReveal])) then
				if (pTeam:GetTeamTechs():HasTech(GameInfoTypes[pResource.TechCityTrade])) then
					bShowResource = true;
				end
			end
			
			if (bShowResource) then
				iNumAvailable = pPlayer:GetNumResourceAvailable(iResourceLoop, true);
				iNumUsed = pPlayer:GetNumResourceUsed(iResourceLoop);
				iNumTotal = pPlayer:GetNumResourceTotal(iResourceLoop, true);
				
				-- Add newline to the front of all entries that AREN'T the first
				if (bThisIsFirstResourceShown) then
					strText = "";
					bThisIsFirstResourceShown = false;
				else
					strText = strText .. "[NEWLINE][NEWLINE]";
				end
				
				strText = strText .. iNumAvailable .. " " .. pResource.IconString .. " " .. Locale.ConvertTextKey(pResource.Description);
				
				-- Details
				if (iNumUsed ~= 0 or iNumTotal ~= 0) then
					strText = strText .. ": ";
					strText = strText .. Locale.ConvertTextKey("TXT_KEY_TP_RESOURCE_INFO", iNumTotal, iNumUsed);
				end
			end
		end
	end
	
	print(strText);
	if(strText ~= "") then
		tipControlTable.TopPanelMouseover:SetHide(false);
		tipControlTable.TooltipLabel:SetText( strText );
	else
		tipControlTable.TopPanelMouseover:SetHide(true);
	end
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
	
end

-- International Trade Route Tooltip
function InternationalTradeRoutesTipHandler( control )

	local iPlayerID = Game.GetActivePlayer();
	local pPlayer = Players[iPlayerID];
	
	local strTT = "";
	
	local iNumLandTradeUnitsAvail = pPlayer:GetNumAvailableTradeUnits(DomainTypes.DOMAIN_LAND);
	if (iNumLandTradeUnitsAvail > 0) then
		local iTradeUnitType = pPlayer:GetTradeUnitType(DomainTypes.DOMAIN_LAND);
		local strUnusedTradeUnitWarning = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES_TT_UNASSIGNED", iNumLandTradeUnitsAvail, GameInfo.Units[iTradeUnitType].Description);
		strTT = strTT .. strUnusedTradeUnitWarning;
	end
	
	local iNumSeaTradeUnitsAvail = pPlayer:GetNumAvailableTradeUnits(DomainTypes.DOMAIN_SEA);
	if (iNumSeaTradeUnitsAvail > 0) then
		local iTradeUnitType = pPlayer:GetTradeUnitType(DomainTypes.DOMAIN_SEA);
		local strUnusedTradeUnitWarning = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES_TT_UNASSIGNED", iNumLandTradeUnitsAvail, GameInfo.Units[iTradeUnitType].Description);	
		strTT = strTT .. strUnusedTradeUnitWarning;
	end
	
	if (strTT ~= "") then
		strTT = strTT .. "[NEWLINE]";
	end
	
	local iUsedTradeRoutes = pPlayer:GetNumInternationalTradeRoutesUsed();
	local iAvailableTradeRoutes = pPlayer:GetNumInternationalTradeRoutesAvailable();
	
	local strText = Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_INTERNATIONAL_TRADE_ROUTES_TT", iUsedTradeRoutes, iAvailableTradeRoutes);
	strTT = strTT .. strText;
	
	local strYourTradeRoutes = pPlayer:GetTradeYourRoutesTTString();
	if (strYourTradeRoutes ~= "") then
		strTT = strTT .. "[NEWLINE][NEWLINE]"
		strTT = strTT .. Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_ITR_ESTABLISHED_BY_PLAYER_TT");
		strTT = strTT .. "[NEWLINE]";
		strTT = strTT .. strYourTradeRoutes;
	end

	local strToYouTradeRoutes = pPlayer:GetTradeToYouRoutesTTString();
	if (strToYouTradeRoutes ~= "") then
		strTT = strTT .. "[NEWLINE][NEWLINE]"
		strTT = strTT .. Locale.ConvertTextKey("TXT_KEY_TOP_PANEL_ITR_ESTABLISHED_BY_OTHER_TT");
		strTT = strTT .. "[NEWLINE]";
		strTT = strTT .. strToYouTradeRoutes;
	end
	
	--print(strText);
	if(strText ~= "") then
		tipControlTable.TopPanelMouseover:SetHide(false);
		tipControlTable.TooltipLabel:SetText( strTT );
	else
		tipControlTable.TopPanelMouseover:SetHide(true);
	end
    
    -- Autosize tooltip
    tipControlTable.TopPanelMouseover:DoAutoSize();
end

-------------------------------------------------
-- On Top Panel mouseover exited
-------------------------------------------------
--function HelpClose()
	---- Hide the help text box
	--Controls.HelpTextBox:SetHide( true );
--end


-- Register Events
-- Events.SerialEventGameDataDirty.Add(OnTopPanelDirty);
-- Events.SerialEventTurnTimerDirty.Add(OnTopPanelDirty);
-- Events.SerialEventCityInfoDirty.Add(OnTopPanelDirty);

-- Update data at initialization
-- UpdateData();
-- DoInitTooltips();
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

Events.OpenInfoCorner(nil)
if ContextPtr:LookUpControl("/InGame/WorldView/InfoCorner") then
	ContextPtr:LookUpControl("/InGame/WorldView/InfoCorner"):SetHide(true)
end