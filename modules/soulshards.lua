if( not ShadowUF.ComboPoints ) then return end
if select(4, GetBuildInfo()) < 40400 then return end

local Souls = setmetatable({}, {__index = ShadowUF.ComboPoints})
ShadowUF:RegisterModule(Souls, "soulShards", ShadowUF.L["Soul Shards"], nil, "WARLOCK")
local soulsConfig = {max = 3, key = "soulShards", colorKey = "SOULSHARDS", powerType = Enum.PowerType.SoulShards, eventType = "SOUL_SHARDS", icon = "Interface\\AddOns\\ShadowedUnitFrames\\media\\textures\\shard"}

function Souls:OnEnable(frame)
	frame.soulShards = frame.soulShards or CreateFrame("Frame", nil, frame)
	frame.soulShards.cpConfig = soulsConfig
	frame.comboPointType = soulsConfig.key

	frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "UpdateBarBlocks")
	frame:RegisterUnitEvent("UNIT_DISPLAYPOWER", self, "Update")

	frame:RegisterUpdateFunc(self, "Update")
	frame:RegisterUpdateFunc(self, "UpdateBarBlocks")

	soulsConfig.max = UnitPowerMax("player", soulsConfig.powerType)
end

function Souls:OnLayoutApplied(frame, config)
	ShadowUF.ComboPoints.OnLayoutApplied(self, frame, config)
	self:UpdateBarBlocks(frame)
end

function Souls:GetComboPointType()
	return "soulShards"
end

function Souls:GetPoints(unit)
	return UnitPower("player", soulsConfig.powerType)
end
