local configWidth, configHeight = 320, 190
local width, height = 320, 190
local scale = 1

Events.MinimapTextureBroadcastEvent.Add(function(uiHandle, newWidth, newHeight)
	if newWidth ~= configWidth or newHeight ~= configHeight then
		configWidth = newWidth
		configHeight = newHeight
		width = newWidth
		height = newHeight
		Controls.MainGrid:SetSizeVal(width + 35, height + 102)
		scale = configWidth / width
	end
	Controls.Minimap:SetTextureHandle(uiHandle)
	Controls.Minimap:SetSizeVal(width, height)
end)
UI:RequestMinimapBroadcast()

Controls.Minimap:RegisterCallback(Mouse.eLClick, function(_, _, _, x, y)
	Events.MinimapClickedEvent(x / scale, y / scale)
end)

local function OnClose()
	UIManager:DequeuePopup(ContextPtr)
end
Controls.CloseButton:RegisterCallback(Mouse.eLClick, OnClose)

ContextPtr:SetInputHandler(function(uiMsg, wParam)
	if uiMsg == KeyEvents.KeyDown then
		if wParam == Keys.VK_ESCAPE then
			OnClose()
			return true
		elseif wParam == Keys.VK_RETURN then
			return true
		end
	end
end)

ContextPtr:SetShowHideHandler(function(isHidden, isInit)
	if not isInit then
		if isHidden then
			UI.decTurnTimerSemaphore()
		else
			UI.incTurnTimerSemaphore()
		end
	end
end)

LuaEvents.AdditionalInformationDropdownGatherEntries.Add(function(entries)
	table.insert(entries, {
		text = Locale.Lookup("TXT_KEY_JFD_MINIMAP_OVERVIEW"),
		call = function()
			UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
		end,
	})
end)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries()

local function ToggleMiniMapOverview()
	if ContextPtr:IsHidden() then
		UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
	else
		UIManager:DequeuePopup(ContextPtr)
	end
end
LuaEvents.JFD_UI_ShowBigMiniMapOverview.Add(ToggleMiniMapOverview)

UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
UIManager:DequeuePopup(ContextPtr)
