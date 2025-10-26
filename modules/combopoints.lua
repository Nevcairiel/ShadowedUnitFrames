if( not ShadowUF.ComboPoints ) then return end

local Combo = setmetatable({}, {__index = ShadowUF.ComboPoints})
ShadowUF:RegisterModule(Combo, "comboPoints", ShadowUF.L["Combo points"])
local cpConfig = {max = MAX_COMBO_POINTS, key = "comboPoints", colorKey = "COMBOPOINTS", powerType = Enum.PowerType.ComboPoints, eventType = "COMBO_POINTS", icon = "Interface\\AddOns\\ShadowedUnitFrames\\media\\textures\\combo"}

function Combo:OnEnable(frame)
	frame.comboPoints = frame.comboPoints or CreateFrame("Frame", nil, frame)
	frame.comboPoints.cpConfig = CopyTable(cpConfig)

	frame:RegisterNormalEvent("UNIT_POWER_UPDATE", self, "Update", "player")
	frame:RegisterNormalEvent("UNIT_POWER_FREQUENT", self, "Update", "player")
	frame:RegisterNormalEvent("PLAYER_TARGET_CHANGED", self, "Update", "player")
	frame:RegisterNormalEvent("UNIT_MAXPOWER", self, "UpdateBarBlocks", "player")

	frame:RegisterUpdateFunc(self, "Update")
	frame:RegisterUpdateFunc(self, "UpdateBarBlocks")
end

function Combo:GetComboPointType()
	return "comboPoints"
end

function Combo:GetMaxPoints()
	-- Warriors have Overpower which is flagged as a combo point and UnitPowerMax says 5.
	if( select(2, UnitClass("player")) == "WARRIOR" ) then
		return 1
	else
		return UnitPowerMax("player", cpConfig.powerType)
	end
end

function Combo:GetPoints(unit, frame)
	if frame.unit == "target" then
		return GetComboPoints("player", "target")
	else
		return UnitPower("player", cpConfig.powerType)
	end
end

function Combo:Update(frame, event, unit, powerType)
	if( not event or ( unit == frame.unit or unit == "player" ) ) then
		ShadowUF.ComboPoints.Update(self, frame, event, unit, powerType)
	elseif(event == "PLAYER_TARGET_CHANGED" and frame.unit == "target") then
		ShadowUF.ComboPoints.Update(self, frame, event, "player", cpConfig.powerType)
	end
end
