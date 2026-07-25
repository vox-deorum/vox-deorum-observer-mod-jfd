local suppressNotifications = Game.IsOption("GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS")
local suppressPopups = Game.IsOption("GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS")

local function OnNotificationAdded(_, notificationType)
	if notificationType == NotificationTypes.NOTIFICATION_GOODY then
		LuaEvents.ClearNotification("AncientRuins")
	elseif notificationType == ButtonPopupTypes.NOTIFICATION_CHOOSE_ARCHAEOLOGY then
		LuaEvents.ClearNotification("ChooseArchaeology")
	end
end

if suppressNotifications then
	Events.NotificationAdded.Add(OnNotificationAdded)
end

local function OnGameMessagePopup(popupInfo)
	if popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_GOLDEN_AGE_REWARD then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/GoldenAgePopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_GREAT_PERSON_REWARD then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/GreatPersonRewardPopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_NEW_ERA then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/NewEraPopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_WHOS_WINNING then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/WhosWinningPopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_NATURAL_WONDER_REWARD then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/NaturalWonderPopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_BARBARIAN_CAMP_REWARD then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/BarbarianCampPopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_GOODY_HUT_REWARD then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/GoodyHutPopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_CITY_STATE_GREETING then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/CityStateGreetingPopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_TECH_AWARD then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/TechAwardPopup"))
	elseif popupInfo.Type == ButtonPopupTypes.BUTTONPOPUP_WONDER_COMPLETED_ACTIVE_PLAYER then
		UIManager:DequeuePopup(ContextPtr:LookUpControl("/InGame/WonderPopup"))
	end
end

if suppressPopups then
	Events.SerialEventGameMessagePopup.Add(OnGameMessagePopup)
end
