--[[
	API overrides from external addons that augment the data missing in the Classic API
]]
ShadowUF = select(2, ...)
ShadowUF.API = {}

-- 2.5.6 (patch 20506) compatibility: DebuffTypeColor was removed from the global
-- environment and replaced with individual DEBUFF_TYPE_*_COLOR constants.
-- Reconstruct the table so all modules (auras, health, highlight) that reference
-- DebuffTypeColor continue to work without modification.
-- Keys used by this addon:
--   .none / ["none"]  -- auras.lua fallback for unknown debuff type
--   [""]              -- highlight.lua fallback (DebuffTypeColor[""])
--   "Magic", "Curse", "Disease", "Poison" -- school types returned by UnitAura
if not DebuffTypeColor then
	DebuffTypeColor = {
		none    = DEBUFF_TYPE_NONE_COLOR    or { r = 0.80, g = 0.00, b = 0.00 },
		[""]    = DEBUFF_TYPE_NONE_COLOR    or { r = 0.80, g = 0.00, b = 0.00 },
		Magic   = DEBUFF_TYPE_MAGIC_COLOR   or { r = 0.20, g = 0.60, b = 1.00 },
		Curse   = DEBUFF_TYPE_CURSE_COLOR   or { r = 0.60, g = 0.00, b = 1.00 },
		Disease = DEBUFF_TYPE_DISEASE_COLOR or { r = 0.60, g = 0.40, b = 0.00 },
		Poison  = DEBUFF_TYPE_POISON_COLOR  or { r = 0.00, g = 0.60, b = 0.00 },
	}
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
