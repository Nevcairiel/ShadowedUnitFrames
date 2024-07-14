local Range = {
	friendly = {
		["PRIEST"] = {
			(C_Spell.GetSpellInfo(17)), -- Power Word: Shield
			(C_Spell.GetSpellInfo(527)), -- Purify
		},
		["DRUID"] = {
			(C_Spell.GetSpellInfo(774)), -- Rejuvenation
			(C_Spell.GetSpellInfo(2782)), -- Remove Corruption
		},
		["PALADIN"] = C_Spell.GetSpellInfo(19750), -- Flash of Light
		["SHAMAN"] = C_Spell.GetSpellInfo(8004), -- Healing Surge
		["WARLOCK"] = C_Spell.GetSpellInfo(5697), -- Unending Breath
		--["DEATHKNIGHT"] = C_Spell.GetSpellInfo(47541), -- Death Coil
		["MONK"] = C_Spell.GetSpellInfo(115450), -- Detox
	},
	hostile = {
		["DEATHKNIGHT"] = {
			(C_Spell.GetSpellInfo(47541)), -- Death Coil
			(C_Spell.GetSpellInfo(49576)), -- Death Grip
		},
		["DEMONHUNTER"] = C_Spell.GetSpellInfo(185123), -- Throw Glaive
		["DRUID"] = C_Spell.GetSpellInfo(8921),  -- Moonfire
		["HUNTER"] = {
			(C_Spell.GetSpellInfo(193455)), -- Cobra Shot
			(C_Spell.GetSpellInfo(19434)), -- Aimed Short
			(C_Spell.GetSpellInfo(193265)), -- Hatchet Toss
		},
		["MAGE"] = {
			(C_Spell.GetSpellInfo(116)), -- Frostbolt
			(C_Spell.GetSpellInfo(30451)), -- Arcane Blast
			(C_Spell.GetSpellInfo(133)), -- Fireball
		},
		["MONK"] = C_Spell.GetSpellInfo(115546), -- Provoke
		["PALADIN"] = C_Spell.GetSpellInfo(62124), -- Hand of Reckoning
		["PRIEST"] = C_Spell.GetSpellInfo(585), -- Smite
		--["ROGUE"] = C_Spell.GetSpellInfo(1725), -- Distract
		["SHAMAN"] = C_Spell.GetSpellInfo(403), -- Lightning Bolt
		["WARLOCK"] = C_Spell.GetSpellInfo(686), -- Shadow Bolt
		["WARRIOR"] = C_Spell.GetSpellInfo(355), -- Taunt
	},
}

ShadowUF:RegisterModule(Range, "range", ShadowUF.L["Range indicator"])

local LSR = LibStub("SpellRange-1.0")

local playerClass = select(2, UnitClass("player"))
local rangeSpells = {}

local UnitPhaseReason_o = UnitPhaseReason
local UnitPhaseReason = function(unit)
	local phase = UnitPhaseReason_o(unit)
	if (phase == Enum.PhaseReason.WarMode or phase == Enum.PhaseReason.ChromieTime) and UnitIsVisible(unit) then
		return nil
	end
	return phase
end

local function checkRange(self)
	local frame = self.parent

	-- Check which spell to use
	local spell
	if( UnitCanAssist("player", frame.unit) ) then
		spell = rangeSpells.friendly
	elseif( UnitCanAttack("player", frame.unit) ) then
		spell = rangeSpells.hostile
	end

	if( not UnitIsConnected(frame.unit) or UnitPhaseReason(frame.unit) ) then
		frame:SetRangeAlpha(ShadowUF.db.profile.units[frame.unitType].range.oorAlpha)
	elseif( spell ) then
		frame:SetRangeAlpha(LSR.IsSpellInRange(spell, frame.unit) == 1 and ShadowUF.db.profile.units[frame.unitType].range.inAlpha or ShadowUF.db.profile.units[frame.unitType].range.oorAlpha)
	-- That didn't work, but they are grouped lets try the actual API for this, it's a bit flaky though and not that useful generally
	elseif( UnitInRaid(frame.unit) or UnitInParty(frame.unit) ) then
		frame:SetRangeAlpha(UnitInRange(frame.unit, "player") and ShadowUF.db.profile.units[frame.unitType].range.inAlpha or ShadowUF.db.profile.units[frame.unitType].range.oorAlpha)
	-- Nope, just show in range :(
	else
		frame:SetRangeAlpha(ShadowUF.db.profile.units[frame.unitType].range.inAlpha)
	end
end

local function isUsable(key)
	if key and not type(key) == "table" then
		local isUsable, _ = C_Spell.IsSpellUsable(key)
		return isUsable
	end
end

local function updateSpellCache(category)
	rangeSpells[category] = nil
	if( isUsable(ShadowUF.db.profile.range[category .. playerClass]) ) then
		rangeSpells[category] = ShadowUF.db.profile.range[category .. playerClass]

	elseif( isUsable(ShadowUF.db.profile.range[category .. "Alt" .. playerClass]) ) then
		rangeSpells[category] = ShadowUF.db.profile.range[category .. "Alt" .. playerClass]

	elseif( Range[category][playerClass] ) then
		if( type(Range[category][playerClass]) == "table" ) then
			for i = 1, #Range[category][playerClass] do
				local spell = Range[category][playerClass][i]
				if( type(spell) == "table") then
					if( isUsable(spell.spellID) ) then
						rangeSpells[category] = spell
						break
					end
				else
					if( isUsable(spell) ) then
						rangeSpells[category] = spell
						break
					end
				end
			end
		elseif( isUsable(Range[category][playerClass]) ) then
			rangeSpells[category] = Range[category][playerClass]
		end
	end
end

local function createTimer(frame)
	if( not frame.range.timer ) then
		frame.range.timer = C_Timer.NewTicker(0.5, checkRange)
		frame.range.timer.parent = frame
	end
end

local function cancelTimer(frame)
	if( frame.range and frame.range.timer ) then
		frame.range.timer:Cancel()
		frame.range.timer = nil
	end
end

function Range:ForceUpdate(frame)
	if( UnitIsUnit(frame.unit, "player") ) then
		frame:SetRangeAlpha(ShadowUF.db.profile.units[frame.unitType].range.inAlpha)
		cancelTimer(frame)
	else
		createTimer(frame)
		checkRange(frame.range.timer)
	end
end

function Range:OnEnable(frame)
	if( not frame.range ) then
		frame.range = CreateFrame("Frame", nil, frame)
	end

	frame:RegisterNormalEvent("PLAYER_SPECIALIZATION_CHANGED", self, "SpellChecks")
	frame:RegisterUpdateFunc(self, "ForceUpdate")

	createTimer(frame)
end

function Range:OnLayoutApplied(frame)
	self:SpellChecks(frame)
end

function Range:OnDisable(frame)
	frame:UnregisterAll(self)

	if( frame.range ) then
		cancelTimer(frame)
		frame:SetRangeAlpha(1.0)
	end
end


function Range:SpellChecks(frame)
	updateSpellCache("friendly")
	updateSpellCache("hostile")
	if( frame.range and ShadowUF.db.profile.units[frame.unitType].range.enabled ) then
		self:ForceUpdate(frame)
	end
end
