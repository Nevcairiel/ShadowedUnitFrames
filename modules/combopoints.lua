if( not ShadowUF.ComboPoints ) then return end

local Combo = setmetatable({}, {__index = ShadowUF.ComboPoints})
ShadowUF:RegisterModule(Combo, "comboPoints", ShadowUF.L["Combo points"])
local cpConfig = {max = MAX_COMBO_POINTS, key = "comboPoints", colorKey = "COMBOPOINTS", powerType = Enum.PowerType.ComboPoints, eventType = "COMBO_POINTS", icon = "Interface\\AddOns\\ShadowedUnitFrames\\media\\textures\\combo"}

function Combo:OnEnable(frame)
	frame.comboPoints = frame.comboPoints or CreateFrame("Frame", nil, frame)
	frame.comboPoints.cpConfig = CopyTable(cpConfig)

	frame:RegisterNormalEvent("UNIT_POWER_UPDATE", self, "Update", "player")
	frame:RegisterNormalEvent("UNIT_POWER_FREQUENT", self, "Update", "player")
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

function Combo:GetPoints(unit)
	-- For Malygos dragons, they also self cast their CP on themselves, which is why we check CP on ourself
	if( UnitHasVehicleUI("player") and UnitHasVehiclePlayerFrameUI("player") ) then
		local points = GetComboPoints("vehicle")
		if( points == 0 ) then
			points = GetComboPoints("vehicle", "vehicle")
		end

		return points
	else
		return UnitPower("player", cpConfig.powerType)
	end
end

function Combo:Update(frame, event, unit, powerType)
	if( not event or ( unit == frame.unit or unit == frame.vehicleUnit or unit == "player" or unit == "vehicle" ) ) then
		ShadowUF.ComboPoints.Update(self, frame, event, unit, powerType)
	end
end
