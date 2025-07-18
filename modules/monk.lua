local Monk = {}
ShadowUF:RegisterModule(Monk, "monkBar", ShadowUF.L["Monk mana bar"], true, "MONK", SPEC_MONK_MISTWEAVER)

function Monk:OnEnable(frame)
	frame.monkBar = frame.monkBar or ShadowUF.Units:CreateBar(frame)

	frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "Update")

	frame:RegisterUpdateFunc(self, "Update")
end

function Monk:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Monk:OnLayoutApplied(frame)
	if( frame.visibility.monkBar ) then
		local color = ShadowUF.db.profile.powerColors.MANA
		frame:SetBarColor("monkBar", color.r, color.g, color.b)
	end
end

function Monk:Update(frame, event, unit, powerType)
	if( powerType ~= "MANA" ) then return end
	frame.monkBar:SetMinMaxValues(0, UnitPowerMax(frame.unit, SPELL_POWER_MANA))
	frame.monkBar:SetValue(UnitIsDeadOrGhost(frame.unit) and 0 or not UnitIsConnected(frame.unit) and 0 or UnitPower(frame.unit, SPELL_POWER_MANA))
end
