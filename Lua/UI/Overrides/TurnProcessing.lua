-------------------------------------------------
-- Turn Processing Popup
-------------------------------------------------
include( "IconSupport" );
include( "SupportFunctions" );

-- VD: Debug logging — filter Lua.log for "[VD]"
local function VD_Log(...)
	print("[VD]", ...)
end

local ms_IsShowingMinorCiv = false;
------------------------------------------------------------
------------------------------------------------------------
local function GetPlayer(iPlayerID)
	if (iPlayerID < 0) then
		return nil;
	end

	if (Players[iPlayerID]:IsHuman()) then
		return nil;
	end;

	return Players[iPlayerID];
end

-------------------------------------------------
-- VD manual popup API
-------------------------------------------------
local function VD_ShowTurnProcessingPopup()
	if(PreGame.IsMultiplayerGame()) then
		-- Turn Queue UI (see ActionInfoPanel.lua) replaces the turn processing UI in multiplayer.  
		return false;
	end

	if( ContextPtr:IsHidden() ) then
		ContextPtr:SetHide( false );
		Controls.Anim:SetHide( true );
		ms_IsShowingMinorCiv = false;
	end

	if (Controls.Anim:IsHidden()) then
		Controls.Anim:SetHide( false );
		Controls.Anim:BranchResetAnimation();
	end

	return true;
end

local function VD_GetProcessingTitle(player, iPlayerID)
	local civType = player:GetCivilizationType();
	local civInfo = GameInfo.Civilizations[civType];
	local strCiv = Locale.ConvertTextKey(civInfo.ShortDescription);
	if(strCiv and #strCiv > 0) then
		return Locale.ConvertTextKey("TXT_KEY_PROCESSING_TURN_FOR", Locale.ConvertTextKey(strCiv));
	end
	return Locale.ConvertTextKey("TXT_KEY_PROCESSING_TURN_FOR", Locale.ConvertTextKey("TXT_KEY_MULTIPLAYER_DEFAULT_PLAYER_NAME", iPlayerID + 1));
end

local function VD_SetKnownPlayerDisplay(iPlayerID, titleText)
	Controls.CivIconBG:SetHide( false );
	Controls.CivIconShadow:SetHide( false );
	CivIconHookup(iPlayerID, 64, Controls.CivIcon, Controls.CivIconBG, Controls.CivIconShadow, false, true);
	ms_IsShowingMinorCiv = false;
	Controls.TurnProcessingTitle:SetText(titleText);
end

local function VD_SetUnmetPlayerDisplay(iPlayerID)
	Controls.TurnProcessingTitle:SetText(Locale.ConvertTextKey("TXT_KEY_PROCESSING_TURN_FOR_UNMET_PLAYER", iPlayerID + 1));
	Controls.CivIcon:SetTexture("CivSymbolsColor512.dds");
	Controls.CivIcon:SetTextureOffsetVal( 448 + 7, 128 + 7 );
	Controls.CivIcon:SetColor( Vector4( 1.0, 1.0, 1.0, 1.0 ) );
	Controls.CivIcon:SetHide( false );
	Controls.CivIconBG:SetHide( true );
	Controls.CivIconShadow:SetHide( true );
	ms_IsShowingMinorCiv = false;
end

local function VD_SetMinorDisplay(iPlayerID)
	Controls.CivIconBG:SetHide( false );
	Controls.CivIconShadow:SetHide( false );
	CivIconHookup(iPlayerID, 64, Controls.CivIcon, Controls.CivIconBG, Controls.CivIconShadow, false, true);
	ms_IsShowingMinorCiv = true;
	Controls.TurnProcessingTitle:SetText(Locale.ConvertTextKey("TXT_KEY_PROCESSING_MINOR_CIVS"));
end

local function VD_OnShowTurnProcessing(iPlayerID, titleText, displayMode)
	VD_Log("TurnProcessingEvent: player=" .. tostring(iPlayerID) .. " mode=" .. tostring(displayMode) .. " title=" .. tostring(titleText))

	local player = GetPlayer(iPlayerID);
	if (player == nil) then
		VD_Log("TurnProcessingIgnored: invalid player=" .. tostring(iPlayerID))
		return;
	end

	if (not player:IsTurnActive()) then
		VD_Log("TurnProcessingIgnored: inactive player=" .. tostring(iPlayerID))
		return;
	end

	if player:IsBarbarian() and Game.IsOption(GameOptionTypes.GAMEOPTION_NO_BARBARIANS) then
		VD_Log("TurnProcessingIgnored: barbarians disabled player=" .. tostring(iPlayerID))
		return;
	end

	if displayMode == "minor" and ms_IsShowingMinorCiv and not ContextPtr:IsHidden() then
		-- If we are already showing the Minor Civ processing, just exit. We don't show them individually because they are usually quick to process.
		VD_Log("TurnProcessingIgnored: already showing grouped minor civs")
		return;
	end

	if not VD_ShowTurnProcessingPopup() then
		VD_Log("TurnProcessingIgnored: popup unavailable")
		return;
	end

	if displayMode == "minor" then
		VD_SetMinorDisplay(iPlayerID)
	elseif displayMode == "unmet" then
		VD_SetUnmetPlayerDisplay(iPlayerID)
	else
		VD_SetKnownPlayerDisplay(iPlayerID, titleText or VD_GetProcessingTitle(player, iPlayerID))
	end

	VD_Log("TurnProcessingApplied: player=" .. tostring(iPlayerID) .. " mode=" .. tostring(displayMode) .. " finalTitle=" .. tostring(Controls.TurnProcessingTitle:GetText()))
end
LuaEvents.VD_ShowTurnProcessing.Add(VD_OnShowTurnProcessing)
-------------------------------------------------------------------------
-- OnPlayerTurnStart
-- Human player's turn, hide the UI
-------------------------------------------------------------------------
function OnPlayerTurnStart()
	if (not ContextPtr:IsHidden()) then
		Controls.Anim:Reverse();
		Controls.Anim:Play();
	end
end
Events.ActivePlayerTurnStart.Add( OnPlayerTurnStart );
Events.RemotePlayerTurnStart.Add( OnPlayerTurnStart );

-------------------------------------------------------------------------
-- Callback while the alpha animation is playing.
-- It will also be called once, when the animation stops.
function OnAlphaAnim()
	if (Controls.Anim:IsStopped() and Controls.Anim:GetAlpha() == 0.0) then
		Controls.Anim:SetHide( true );
		ContextPtr:SetHide( true );
		--print("Hiding TurnProcessing");
	end
end
Controls.Anim:RegisterAnimCallback( OnAlphaAnim );
