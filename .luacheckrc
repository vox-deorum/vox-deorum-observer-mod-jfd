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

    -- Database
    "DB",

    -- UI framework
    "UIManager", "ContextPtr", "Controls",
    "InstanceManager", "TTManager",

    -- Event systems
    "Events", "LuaEvents",

    -- Engine utilities
    "Modding",
    "include",
    "Player",   -- Civ5 Player API table (used for method-existence checks)
    "Path",     -- Civ5 file path utility

    -- Civ5 input/mouse
    "Mouse", "KeyEvents", "Keys",

    -- Civ5 enum/type tables
    "GameInfoTypes", "NotificationTypes", "YieldTypes", "Type",
    "ButtonPopupTypes",

    -- Civ5 icon helpers
    "IconHookup", "CivIconHookup", "SimpleCivIconHookup",

    -- Civ5 coordinate helpers
    "HexToWorld", "ToHexFromGrid", "ToGridFromHex",

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
    "VD_SetStatControl",
    "VD_ResizeEntryBox",
    "VD_ENTRY_BASE_HEIGHT",
    "VD_ENTRY_NO_RATIONALE_HEIGHT",

    -- JFD mod globals (defined across multiple files)
    "JFD_Log",
    "JFD_GetPlayerRank",
    "JFD_AIObserver_NotificationAdded",
    "JFD_AIObserver_TurnBegin",
    "JFD_AIObserver_PopulateDefaultLeaderNames",
    "JFD_AIObserver_PopulateLeaderFlavours",
    "JFD_GetNumResearchAgreements",
    "Game_IsModActive",
    "Player_GetIdeology",
    "getStackTrace",
}

