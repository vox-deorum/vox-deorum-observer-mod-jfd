-- VD_Observer_Utils.lua
-- Stateless helper functions extracted from TopPanel.lua for the vox-deorum
-- AI Observer Interface. All functions are global so they can be used by any
-- file that calls include("VD_Observer_Utils.lua").
--
-- These helpers depend ONLY on Civ5 engine globals (Players, Map, Game, etc.)
-- and their own arguments — they hold no mutable state.

-------------------------------------------------
-- Logging
-------------------------------------------------

-- Debug logging — filter Lua.log for "[VD]"
function VD_Log(...)
	print("[VD]", ...)
end

-------------------------------------------------
-- Plot / location helpers
-------------------------------------------------

-- Resolves a plot for a SerialEventCity* payload. Prefers lookup by cityID
-- (reliable for live cities); falls back to hexPos for destroyed cities.
function VD_ResolveCityPlot(hexPos, playerID, cityID)
	local pPlayer = Players and Players[playerID] or nil
	if pPlayer then
		local pCity = pPlayer:GetCityByID(cityID)
		if pCity then
			local plot = pCity:Plot()
			if plot then return plot end
		end
	end
	if hexPos and hexPos.x ~= nil and hexPos.y ~= nil then
		local gridX, gridY = ToGridFromHex(hexPos.x, hexPos.y)
		return Map.GetPlot(gridX, gridY)
	end
	return nil
end

-- Returns the name and hex distance of the nearest city on the map to `plot`.
-- Iterates all alive players' cities. Returns nil, nil if no cities exist.
function VD_FindNearestCity(plot)
	if plot == nil then return nil, nil end
	local plotX, plotY = plot:GetX(), plot:GetY()
	local bestName, bestDist = nil, math.huge
	for iPlayer = 0, GameDefines.MAX_CIV_PLAYERS - 1 do
		local pPlayer = Players[iPlayer]
		if pPlayer and pPlayer:IsAlive() then
			for pCity in pPlayer:Cities() do
				local dist = Map.PlotDistance(plotX, plotY, pCity:GetX(), pCity:GetY())
				if dist < bestDist then
					bestDist = dist
					bestName = pCity:GetName()
				end
			end
		end
	end
	if bestName then
		return bestName, bestDist
	end
	return nil, nil
end

-- Packages plot + event metadata into a table for VD_AnimationStarted emission.
function VD_BuildEventInfo(plot, eventType, description)
	local plotIndex = plot and plot:GetPlotIndex() or -1
	local plotX     = plot and plot:GetX() or -1
	local plotY     = plot and plot:GetY() or -1
	local nearestCity, nearestCityDist = VD_FindNearestCity(plot)
	return {
		eventType       = eventType or "",
		plotIndex       = plotIndex,
		plotX           = plotX,
		plotY           = plotY,
		nearestCity     = nearestCity or "unknown",
		nearestCityDist = nearestCityDist or -1,
		description     = description or "",
	}
end

-------------------------------------------------
-- Combat description
-------------------------------------------------

-- Returns a short unit-type name for a unit, or fallback if nil.
local function UnitLabel(pUnit, fallback)
	if not pUnit then return fallback or "unknown" end
	return Locale.ConvertTextKey(pUnit:GetNameKey())
end

-- Builds a rich human-readable combat description.
-- Parameters mirror RunCombatSim / EndCombatSim event args.
function VD_BuildCombatDescription(atkPlayerID, defPlayerID,
		atkUnit, defUnit,
		atkDmg, atkFinalDmg, atkMaxHP,
		defDmg, defFinalDmg, defMaxHP)
	local atkCiv = Players[atkPlayerID]:GetCivilizationShortDescription()
	local defCiv = Players[defPlayerID]:GetCivilizationShortDescription()
	local atkName = UnitLabel(atkUnit)
	local defName = UnitLabel(defUnit)

	-- Compute HP before and after
	local atkHPBefore = atkMaxHP - atkDmg
	local atkHPAfter  = atkMaxHP - atkFinalDmg
	local defHPBefore = defMaxHP - defDmg
	local defHPAfter  = defMaxHP - defFinalDmg

	-- Choose verb based on outcome
	local verb
	if defHPAfter <= 0 then
		verb = "kills"
	elseif atkHPAfter <= 0 then
		verb = "killed by"
	else
		verb = "attacks"
	end

	if verb == "killed by" then
		return atkCiv .. " " .. atkName
			.. " (" .. atkHPBefore .. "/" .. atkMaxHP .. " HP)"
			.. " killed by " .. defCiv .. " " .. defName
			.. " (" .. defHPBefore .. "->" .. defHPAfter .. "/" .. defMaxHP .. " HP)"
	end

	return atkCiv .. " " .. atkName
		.. " (" .. atkHPBefore .. "->" .. atkHPAfter .. "/" .. atkMaxHP .. " HP)"
		.. " " .. verb .. " " .. defCiv .. " " .. defName
		.. " (" .. defHPBefore .. "->" .. defHPAfter .. "/" .. defMaxHP .. " HP)"
end

-------------------------------------------------
-- Player display helpers
-------------------------------------------------

-- Returns icon, shortLabel, description for a player's grand strategy
function VD_GetGrandStrategy(pPlayer)
	if not pPlayer:GetCapitalCity() then
		return "[ICON_CAPITAL]", "-", "Undecided"
	end
	local iGS = pPlayer:GetGrandStrategy()
	if iGS == 0 then     return "[ICON_CULTURE]",    "Culture",    "Culture Victory"
	elseif iGS == 1 then return "[ICON_INFLUENCE]",   "Diplomacy",  "Diplomacy Victory"
	elseif iGS == 2 then return "[ICON_RESEARCH]",    "Science",    "Science Victory"
	elseif iGS == 3 then return "[ICON_WAR]",         "Conquest",   "Conquest Victory"
	else                  return "[ICON_CAPITAL]",     "-",          "Undecided"
	end
end

-- Returns formatted population string with "k" suffix for large values
function VD_FormatPopulation(pPlayer)
	local iPop = pPlayer:GetTotalPopulation()
	if iPop >= 1000 then
		return tostring(Game.GetRound(iPop / 1000)) .. "k"
	end
	return tostring(iPop)
end

-- Returns icon, rateText, tooltip for a player's gold/treasury display
function VD_GetGoldDisplay(pPlayer)
	local iGold = pPlayer:GetGold()
	local iGoldRate = pPlayer:CalculateGoldRate()
	local icon
	if iGold == 0 and iGoldRate < 0 then     icon = "[ICON_GOLD_EMP]"
	elseif iGoldRate == 0 then                icon = "[ICON_GOLD_NEU]"
	elseif iGoldRate < 0 then                 icon = "[ICON_GOLD_NEG]"
	else                                      icon = "[ICON_GOLD_POS]"
	end
	local rateText
	if iGoldRate >= 0 then
		rateText = Locale.ConvertTextKey("[COLOR_JFD_OVERLAY_YIELD_GOLD]+{1_Num}[ENDCOLOR]", iGoldRate)
	else
		rateText = Locale.ConvertTextKey("[COLOR_WARNING_TEXT]{1_Num}[ENDCOLOR]", iGoldRate)
	end
	local tooltip = Locale.ConvertTextKey("{1_Desc} Treasury: {2_Num} gold | Net: {3_Num}/turn", icon, iGold, iGoldRate)
	return icon, rateText, tooltip
end

function VD_GetThinkingTitle(aiLabel)
	if not aiLabel or aiLabel == "" then
		return "Thinking"
	end

	local modelLabel = aiLabel:match("^%s*([^/]+)") or aiLabel
	modelLabel = modelLabel:gsub("^%s+", ""):gsub("%s+$", "")
	if modelLabel == "" then
		modelLabel = aiLabel
	end
	return modelLabel .. " Is Still Thinking"
end

function VD_GetTurnProcessingDisplayMode(playerID)
	local pPlayer = Players[playerID]
	if not pPlayer then
		return nil
	end

	if pPlayer:IsBarbarian() then
		if Game.IsOption(GameOptionTypes.GAMEOPTION_NO_BARBARIANS) then
			return nil
		end
		return "known"
	end

	if pPlayer:IsMinorCiv() then
		return "minor"
	end

	local pLocalTeam = Teams[Players[Game.GetActivePlayer()]:GetTeam()]
	if pLocalTeam:IsHasMet(pPlayer:GetTeam()) then
		return "known"
	end

	return "unmet"
end

function VD_ShowTurnProcessing(playerID, titleText)
	local displayMode = VD_GetTurnProcessingDisplayMode(playerID)
	if displayMode then
		LuaEvents.VD_ShowTurnProcessing(playerID, titleText, displayMode)
	end
	return displayMode
end

-------------------------------------------------
-- UI control helpers
-------------------------------------------------

-- Sets an icon+value stat control pair with shared tooltip
function VD_SetStatControl(iconCtrl, infoCtrl, iconStr, valueStr, tooltip)
	if iconStr then iconCtrl:SetText(iconStr) end
	iconCtrl:SetToolTipString(tooltip)
	infoCtrl:SetText(valueStr)
	infoCtrl:SetToolTipString(tooltip)
end

-- Constants for popup entry dynamic height
VD_ENTRY_BASE_HEIGHT = 67         -- rationale label Y offset (58) + 4px padding + 5px breathing room
VD_ENTRY_NO_RATIONALE_HEIGHT = 63 -- header + stats rows only + 5px breathing room

-- Resizes a popup entry box and its background anim grids to a given height
function VD_ResizeEntryBox(controlTable, height)
	controlTable.PlayerEntryBox:SetSizeY(height)
	controlTable.PlayerEntryAnimGrid:SetSizeY(height - 3)
	local animH = height
	controlTable.PlayerEntryAnim:SetSizeY(animH)
	controlTable.PlayerEntryAnimGrid2:SetSizeY(animH)
	controlTable.PlayerEntryAnimGridGA:SetSizeY(animH)
	controlTable.PlayerEntryAnimGridDA:SetSizeY(animH)
	controlTable.PlayerEntryAnimGridNA:SetSizeY(animH)
end
