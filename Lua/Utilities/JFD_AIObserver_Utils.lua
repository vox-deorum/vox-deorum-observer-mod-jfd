-- Shared helpers used by the observer UI.

local function Game_IsModActive(modID)
	for _, mod in pairs(Modding.GetActivatedMods()) do
		if mod.ID == modID then
			return true
		end
	end
	return false
end

function Game_IsIGEActive()
	return Game_IsModActive("170c8ed1-b516-4fe2-b571-befeac39d220")
end

function Game.GetRound(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

local ideologySpiritID = GameInfoTypes["POLICY_BRANCH_JFD_SPIRIT"]
function Player_GetIdeology(player, notSpirit)
	local ideologyID = player:GetLateGamePolicyTree()
	if notSpirit or not ideologySpiritID then
		return ideologyID
	elseif player:IsPolicyBranchUnlocked(ideologySpiritID) then
		return ideologySpiritID
	end
	return ideologyID
end
