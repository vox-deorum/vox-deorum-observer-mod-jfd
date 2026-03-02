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
    "HexToWorld", "ToHexFromGrid",

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

-- Exclude backup/reference files not part of the active mod
exclude_files = {
    "Lua/UI/Bak/**",
    "Lua/UI/WC Stuff/**",
}
