--[[
	API overrides from external addons that augment the data missing in the Classic API
]]
ShadowUF = select(2, ...)
ShadowUF.API = {}

local fallbackDebuffColor = {r = 0.80, g = 0.00, b = 0.00}
local debuffTypeColors = {
	none = DEBUFF_TYPE_NONE_COLOR,
	[""] = DEBUFF_TYPE_NONE_COLOR,
	Magic = DEBUFF_TYPE_MAGIC_COLOR,
	Curse = DEBUFF_TYPE_CURSE_COLOR,
	Disease = DEBUFF_TYPE_DISEASE_COLOR,
	Poison = DEBUFF_TYPE_POISON_COLOR,
	Bleed = DEBUFF_TYPE_BLEED_COLOR,
}

function ShadowUF.API.GetDebuffTypeColor(debuffType)
	local colors = DebuffTypeColor
	if( colors ) then
		return colors[debuffType] or colors.none or colors[""] or fallbackDebuffColor
	end

	return debuffTypeColors[debuffType] or debuffTypeColors.none or fallbackDebuffColor
end

-- Threat colors
function ShadowUF.API.GetThreatStatusColor(state)
	if( state == 3 ) then
		return 1, 0, 0
	elseif( state == 2 ) then
		return 1, 0.6, 0
	elseif( state == 1 ) then
		return 1, 1, 0.47
	else
		return 0.69, 0.69, 0.69
	end
end
