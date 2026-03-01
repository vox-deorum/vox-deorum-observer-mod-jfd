--==========================================================================================================================
-- INCLUDES
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
include("JFD_AIObserver_Utils.lua")
--==========================================================================================================================
-- GLOBALS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
local g_ConvertTextKey  = Locale.ConvertTextKey
local g_MapGetPlot		= Map.GetPlot
local g_MathCeil		= math.ceil
local g_MathFloor		= math.floor
local g_MathMax			= math.max
local g_MathMin			= math.min
				
local Players 			= Players
local HexToWorld 		= HexToWorld
local ToHexFromGrid 	= ToHexFromGrid
local Teams 			= Teams
--==========================================================================================================================
-- CORE FUNCTIONS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
--==========================================================================================================================
-- UI FUNCTIONS
--==========================================================================================================================
----------------------------------------------------------------------------------------------------------------------------
-- local opSupressNotifs = Game.GetCustomOption("GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS");
local opSupressNotifs = Game.IsOption("GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS");
-- local opSupressPopups = Game.GetCustomOption("GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS");
local opSupressPopups = Game.IsOption("GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS");
----------------------------------------------------------------------------------------------------------------------------
-- IGE
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- MINI MAP PANEL
----------------------------------------------------------------------------------------------------------------------------
--JFD_AIObserver_ChangeMapOptionsParent
local controlMapOptionsButton = ("/InGame/WorldView/MiniMapPanel/MapOptionsButton")
-- local function JFD_AIObserver_ChangeMapOptionsParent()	
	-- Controls.OverlayMapsButton:ChangeParent(ContextPtr:LookUpControl(controlMapOptionsButton))
-- end
-- Events.LoadScreenClose.Add(JFD_AIObserver_ChangeMapOptionsParent);
----------------------------------------------------------------------------------------------------------------------------
-- SUPPRESS NOTIFS
----------------------------------------------------------------------------------------------------------------------------
--JFD_AIObserver_NotificationAdded
function JFD_AIObserver_NotificationAdded(notification, notificationType)
	if( notificationType == NotificationTypes.NOTIFICATION_GOODY ) then
		LuaEvents.ClearNotification("AncientRuins")
	elseif( notificationType == ButtonPopupTypes.NOTIFICATION_CHOOSE_ARCHAEOLOGY ) then
		LuaEvents.ClearNotification("ChooseArchaeology")
	end
end
if opSupressNotifs then
	Events.NotificationAdded.Add(JFD_AIObserver_NotificationAdded);
end
----------------------------------------------------------------------------------------------------------------------------
-- SUPPRESS POPUPS
----------------------------------------------------------------------------------------------------------------------------
--JFD_AIObserver_SerialEventGameMessagePopup
function JFD_AIObserver_SerialEventGameMessagePopup( popupInfo )
	if( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_GOLDEN_AGE_REWARD ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/GoldenAgePopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_GREAT_PERSON_REWARD ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/GreatPersonRewardPopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_NEW_ERA ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/NewEraPopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_WHOS_WINNING ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/WhosWinningPopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_NATURAL_WONDER_REWARD ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/NaturalWonderPopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_BARBARIAN_CAMP_REWARD ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/BarbarianCampPopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_GOODY_HUT_REWARD ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/GoodyHutPopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_GREETING ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/CityStateGreetingPopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_TECH_AWARD ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/TechAwardPopup"));
	elseif( popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_WONDER_COMPLETED_ACTIVE_PLAYER ) then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/WonderPopup"));
	end
end
if opSupressPopups then
	Events.SerialEventGameMessagePopup.Add(JFD_AIObserver_SerialEventGameMessagePopup);
end
--==========================================================================================================================
--==========================================================================================================================
