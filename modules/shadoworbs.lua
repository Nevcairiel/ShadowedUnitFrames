if( not ShadowUF.ComboPoints ) then return end
local ShadowOrbs = setmetatable({}, {__index = ShadowUF.ComboPoints})
ShadowUF:RegisterModule(ShadowOrbs, "shadowOrbs", ShadowUF.L["Shadow Orbs"], nil, "PRIEST", SPEC_PRIEST_SHADOW, SHADOW_ORBS_SHOW_LEVEL)
local shadowConfig = {max = 3, key = "shadowOrbs", colorKey = "SHADOWORBS", powerType = Enum.PowerType.ShadowOrbs, eventType = "SHADOW_ORBS", icon = "Interface\\AddOns\\ShadowedUnitFrames\\media\\textures\\shard"}

function ShadowOrbs:OnEnable(frame)
	frame.shadowOrbs = frame.shadowOrbs or CreateFrame("Frame", nil, frame)
	frame.shadowOrbs.cpConfig = shadowConfig
	frame.comboPointType = shadowConfig.key

	frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "UpdateBarBlocks")
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", self, "Update")

	frame:RegisterUpdateFunc(self, "Update")
	frame:RegisterUpdateFunc(self, "UpdateBarBlocks")

	shadowConfig.max = UnitPowerMax("player", shadowConfig.powerType)
end

function ShadowOrbs:OnLayoutApplied(frame, config)
	ShadowUF.ComboPoints.OnLayoutApplied(self, frame, config)
	self:UpdateBarBlocks(frame)
end

 function ShadowOrbs:GetComboPointType()
	 return "shadowOrbs"
 end

function ShadowOrbs:GetPoints(unit)
	return UnitPower("player", shadowConfig.powerType)
end
