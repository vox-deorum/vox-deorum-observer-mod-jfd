-------------------------------------------------
-- MiniMap Overview Popup
-------------------------------------------------
include( "IconSupport" );
include( "InstanceManager" );

-------------------------------------------------
-- Global Constants
-------------------------------------------------

local mapWidth, mapHeight = Map.GetGridSize()

-- local iCBRXWidth, iCBRXHeight = 180,94
-- local iMainGridCBRX, iMainGridCBRY = 1250,677
local configWidth, configHeight = 320,190
-- local g_width, g_height = 960,570
local g_width, g_height = 320,190
local multipleVal = 1

-- if mapWidth == iCBRXWidth and mapHeight == iCBRXHeight then
	-- g_width, g_height = 1280,760
	-- Controls.MainGrid:SetSizeVal(iMainGridCBRX+35, iMainGridCBRY+87)
-- end
----------------------------------------------------------------
----------------------------------------------------------------
Events.MinimapTextureBroadcastEvent.Add(
function( uiHandle, width, height )--, paddingX )
	if width ~= configWidth or height ~= configHeight then
		configWidth = width
		configHeight = height

		g_width, g_height = width, height
		Controls.MainGrid:SetSizeVal(g_width+35, g_height+102)
		
		multipleVal = configWidth/g_width
	end
	Controls.Minimap:SetTextureHandle( uiHandle );
	Controls.Minimap:SetSizeVal( g_width, g_height );
end)
UI:RequestMinimapBroadcast();

----------------------------------------------------------------
----------------------------------------------------------------
Controls.Minimap:RegisterCallback( Mouse.eLClick,
function( _, _, _, x, y )
	Events.MinimapClickedEvent( x/multipleVal, y/multipleVal );
end)
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
------------------------------------------------------------------------------
function RefreshMiniMapOverview()	
	
end
RefreshMiniMapOverview()	
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
function ShowHideHandler( bIsHide, bInitState )
    if( not bInitState ) then
        if( not bIsHide ) then
        	UI.incTurnTimerSemaphore();  
        	--Events.SerialEventGameMessagePopupShown(g_PopupInfo);
        	
           RefreshMiniMapOverview()
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
LuaEvents.AdditionalInformationDropdownGatherEntries.Add(function(entries)
	table.insert(entries, {
		text=Locale.Lookup("TXT_KEY_JFD_MINIMAP_OVERVIEW"),
		call=function()
			UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
		end,
	});
	-- table.insert(entries, {
		-- text=Locale.Lookup("Open Civilopedia"),
		-- call=function()
			-- Events.SearchForPediaEntry("");
		-- end,
	-- });
end);

-- Just in case :)
LuaEvents.RequestRefreshAdditionalInformationDropdownEntries();

function JFD_UI_ShowMiniMapOverview()
	if ContextPtr:IsHidden() then
		UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
	else
		UIManager:DequeuePopup(ContextPtr)
	end
end
LuaEvents.JFD_UI_ShowBigMiniMapOverview.Add(JFD_UI_ShowMiniMapOverview);


UIManager:QueuePopup(ContextPtr, PopupPriority.SocialPolicy)
UIManager:DequeuePopup(ContextPtr)
