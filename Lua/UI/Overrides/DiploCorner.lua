include("SupportFunctions")

local chatInstances = {}
local chatTeam = -1
local chatPlayer = -1
local localPlayer = Game.GetActivePlayer()
local localTeam = Players[localPlayer]:GetTeam()
local alternateBackground = false

local function OnChat(fromPlayer, toPlayer, message, targetType)
	local entry = {}
	ContextPtr:BuildInstanceForControl("ChatEntry", entry, Controls.ChatStack)

	table.insert(chatInstances, entry)
	if #chatInstances > 100 then
		Controls.ChatStack:ReleaseChild(chatInstances[1].Box)
		table.remove(chatInstances, 1)
	end

	TruncateString(entry.String, 200, Players[fromPlayer]:GetNickName())
	local fromName = entry.String:GetText()

	if targetType == ChatTargetTypes.CHATTARGET_TEAM then
		entry.String:SetColorByName("Green_Chat")
		entry.String:SetText(fromName .. ": " .. message)
	elseif targetType == ChatTargetTypes.CHATTARGET_PLAYER then
		local toName
		if toPlayer == localPlayer then
			toName = Locale.ConvertTextKey("TXT_KEY_YOU")
		else
			TruncateString(entry.String, 200, Players[toPlayer]:GetNickName())
			toName = Locale.ConvertTextKey("TXT_KEY_DIPLO_TO_PLAYER", entry.String:GetText())
		end
		entry.String:SetText(fromName .. " (" .. toName .. "): " .. message)
		entry.String:SetColorByName("Magenta_Chat")
	elseif fromPlayer == localPlayer then
		entry.String:SetColorByName("Gray_Chat")
		entry.String:SetText(fromName .. ": " .. message)
	else
		entry.String:SetText(fromName .. ": " .. message)
	end

	entry.Box:SetSizeY(entry.String:GetSizeY() + 8)
	entry.Box:ReprocessAnchoring()
	if alternateBackground then
		entry.Box:SetColorChannel(3, 0.4)
	end
	alternateBackground = not alternateBackground

	Events.AudioPlay2DSound("AS2D_IF_MP_CHAT_DING")
	Controls.ChatStack:CalculateSize()
	Controls.ChatScroll:CalculateInternalSize()
	Controls.ChatScroll:SetScrollValue(1)
end
Events.GameMessageChat.Add(OnChat)

local function SendChat(message)
	if string.len(message) > 0 then
		Network.SendChat(message, chatTeam, chatPlayer)
	end
	Controls.ChatEntry:ClearString()
end
Controls.ChatEntry:RegisterCallback(SendChat)

local function OnChatTarget(teamID, playerID)
	chatTeam = teamID
	chatPlayer = playerID

	if teamID ~= -1 then
		TruncateString(Controls.LengthTest, Controls.ChatPull:GetSizeX(), Locale.ConvertTextKey("TXT_KEY_DIPLO_TO_TEAM"))
		Controls.ChatPull:GetButton():SetText(Controls.LengthTest:GetText())
	elseif playerID ~= -1 then
		TruncateString(Controls.LengthTest, Controls.ChatPull:GetSizeX(),
			Locale.ConvertTextKey("TXT_KEY_DIPLO_TO_PLAYER", Players[playerID]:GetNickName()))
		Controls.ChatPull:GetButton():SetText(Controls.LengthTest:GetText())
	else
		Controls.ChatPull:GetButton():LocalizeAndSetText("TXT_KEY_DIPLO_TO_ALL")
	end
end
Controls.ChatPull:RegisterSelectionCallback(OnChatTarget)

local function PopulateChatPull()
	Controls.ChatPull:ClearEntries()

	local entry = {}
	Controls.ChatPull:BuildEntry("InstanceOne", entry)
	entry.Button:SetVoids(-1, -1)
	entry.Button:GetTextControl():LocalizeAndSetText("TXT_KEY_DIPLO_TO_ALL")

	local teamMembers = 0
	for playerID = 0, GameDefines.MAX_PLAYERS do
		local player = Players[playerID]
		if playerID ~= localPlayer and player and player:IsHuman() and player:GetTeam() == localTeam then
			teamMembers = teamMembers + 1
		end
	end

	if teamMembers > 0 then
		entry = {}
		Controls.ChatPull:BuildEntry("InstanceOne", entry)
		entry.Button:SetVoids(localTeam, -1)
		entry.Button:GetTextControl():LocalizeAndSetText("TXT_KEY_DIPLO_TO_TEAM")
	end

	for playerID = 0, GameDefines.MAX_PLAYERS do
		local player = Players[playerID]
		if playerID ~= localPlayer and player and player:IsHuman() then
			entry = {}
			Controls.ChatPull:BuildEntry("InstanceOne", entry)
			entry.Button:SetVoids(-1, playerID)
			TruncateString(entry.Button:GetTextControl(), Controls.ChatPull:GetSizeX() - 20,
				Locale.ConvertTextKey("TXT_KEY_DIPLO_TO_PLAYER", player:GetNickName()))
		end
	end

	Controls.ChatPull:GetButton():LocalizeAndSetText("TXT_KEY_DIPLO_TO_ALL")
	Controls.ChatPull:CalculateInternals()
end
Events.MultiplayerGamePlayerUpdated.Add(PopulateChatPull)

ContextPtr:SetInputHandler(function(uiMsg, wParam)
	if not Controls.ChatPanel:IsHidden() and uiMsg == KeyEvents.KeyUp and wParam == Keys.VK_TAB then
		Controls.ChatEntry:TakeFocus()
		return true
	end
end)

Events.GameplaySetActivePlayer.Add(function()
	localPlayer = Game.GetActivePlayer()
	localTeam = Players[localPlayer]:GetTeam()
	PopulateChatPull()
end)

if Game.IsGameMultiPlayer() then
	PopulateChatPull()
	if not Game.IsHotSeat() then
		Controls.ChatPanel:SetHide(false)
		LuaEvents.ChatShow(true)
	end
end
