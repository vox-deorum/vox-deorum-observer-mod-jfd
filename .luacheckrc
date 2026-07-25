-- luacheck configuration for AI Observer Interface (Lua 5.1 / Civ5)
std = "lua51"
max_line_length = false  -- Civ5 mod files often have long lines
unused_args = false       -- JFD callbacks often receive args they don't use

-- Civ5 engine globals available in all Lua contexts
globals = {
    -- Game objects
    "Game", "Players", "Teams", "Map", "Locale",
    "GameInfo", "GameDefines", "GameOptionTypes",
    "PreGame",

    -- UI framework
    "UI", "UIManager", "ContextPtr", "Controls",
    "InstanceManager",

    -- Event systems
    "Events", "LuaEvents", "GameEvents",

    -- Engine utilities
    "Modding", "LuaTypes",
    "include",

    -- Civ5 input/mouse
    "Mouse", "KeyEvents", "Keys",

    -- Civ5 enum/type tables
    "GameInfoTypes", "NotificationTypes",
    "ButtonPopupTypes",

    -- Civ5 icon helpers
    "IconHookup", "CivIconHookup",

    -- Civ5 coordinate helpers
    "ToGridFromHex",

    -- VD globals (defined in VD_Observer_Utils.lua)
    "VD_Log",
    "VD_ResolveCityPlot",
    "VD_FindNearestCity",
    "VD_BuildEventInfo",
    "VD_BuildCombatDescription",
    "VD_GetGrandStrategy",
    "VD_FormatPopulation",
    "VD_GetGoldDisplay",
    "VD_GetThinkingTitle",
    "VD_GetTurnProcessingDisplayMode",
    "VD_ShowTurnProcessing",
    "VD_GetSessionResults",
    "VD_SetStatControl",
    "VD_ResizeEntryBox",
    "VD_ENTRY_BASE_HEIGHT",
    "VD_ENTRY_NO_RATIONALE_HEIGHT",

    -- JFD helpers retained by the observer
    "Game_IsIGEActive",
    "Player_GetIdeology",
}

