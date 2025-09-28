if( not ShadowUF.ComboPoints ) then return end

local Combo = setmetatable({}, {__index = ShadowUF.ComboPoints})
ShadowUF:RegisterModule(Combo, "comboPoints", ShadowUF.L["Combo points"])
local cpConfig = {max = MAX_COMBO_POINTS, key = "comboPoints", colorKey = "COMBOPOINTS", powerType = Enum.PowerType.ComboPoints, eventType = "COMBO_POINTS", icon = "Interface\\AddOns\\ShadowedUnitFrames\\media\\textures\\combo"}

function Combo:OnEnable(frame)
	frame.comboPoints = frame.comboPoints or CreateFrame("Frame", nil, frame)
	frame.comboPoints.cpConfig = cpConfig
	cpConfig.max = UnitPowerMax("player", cpConfig.powerType)

	frame:RegisterNormalEvent("UNIT_POWER_UPDATE", self, "Update", "player")
	frame:RegisterNormalEvent("UNIT_POWER_FREQUENT", self, "Update", "player")
	frame:RegisterNormalEvent("UNIT_MAXPOWER", self, "UpdateBarBlocks", "player")

	frame:RegisterUpdateFunc(self, "Update")
	frame:RegisterUpdateFunc(self, "UpdateBarBlocks")
end

function Combo:GetComboPointType()
	return "comboPoints"
end

function Combo:GetPoints(unit)
	-- For Malygos dragons, they also self cast their CP on themselves, which is why we check CP on ourself
	if( UnitHasVehicleUI("player") and UnitHasVehiclePlayerFrameUI("player") ) then
		local points = GetComboPoints("vehicle", "target")
		if( points == 0 ) then
			points = GetComboPoints("vehicle", "vehicle")
		end

		return points
	else
		return UnitPower("player", cpConfig.powerType)
	end
end

local ParentUpdate = ShadowUF.ComboPoints.Update

function Combo:Update(frame, event, unit, powerType)
	-- Prevent recursion when arena frames are unloading
	if not frame or not frame.comboPoints or not frame.comboPoints.cpConfig then
		return
	end
	if( not event or ( unit == frame.unit or unit == frame.vehicleUnit or unit == "player" or unit == "vehicle" ) ) then
		ParentUpdate(self, frame, event, unit, powerType)
	end
end
