local Embers = {}
ShadowUF:RegisterModule(Embers, "burningEmbersBar", ShadowUF.L["Burning Embers bar"], true, "WARLOCK", SPEC_WARLOCK_DESTRUCTION)

-- This is a local in ShardBar.lua so we can't access it right now
local MAX_POWER_PER_EMBER = MAX_POWER_PER_EMBER or 10

function Embers:OnEnable(frame)
	if( not frame.burningEmbersBar ) then
		frame.burningEmbersBar = CreateFrame("StatusBar", nil, frame)
		frame.burningEmbersBar:SetMinMaxValues(0, 1)
		frame.burningEmbersBar:SetValue(0)
		frame.burningEmbersBar.embers = {}
		
		for id=1, 4 do
			local ember = ShadowUF.Units:CreateBar(frame.burningEmbersBar)
			
			if( id > 1 ) then
				ember:SetPoint("TOPLEFT", frame.burningEmbersBar.embers[id - 1], "TOPRIGHT", 1, 0)
			else
				ember:SetPoint("TOPLEFT", frame.burningEmbersBar, "TOPLEFT", 0, 0)
			end
			
			frame.burningEmbersBar.embers[id] = ember
		end
	end
	
	frame:RegisterUnitEvent("UNIT_POWER_FREQUENT", self, "Update")
	frame:RegisterUnitEvent("UNIT_MAXPOWER", self, "UpdateBarBlocks")
	frame:RegisterUpdateFunc(self, "Update")
	frame:RegisterUpdateFunc(self, "UpdateBarBlocks")
end

function Embers:OnDisable(frame)
	frame:UnregisterAll(self)

	for id, ember in pairs(frame.burningEmbersBar.embers) do
		ember.background:Hide()
	end
end

function Embers:OnLayoutApplied(frame)
	if( not frame.visibility.burningEmbersBar ) then return end

	for id, ember in pairs(frame.burningEmbersBar.embers) do
		if( ShadowUF.db.profile.units[frame.unitType].burningEmbersBar.background ) then
			ember.background:Show()
		else
			ember.background:Hide()
		end
		
		ember.background:SetTexture(ShadowUF.Layout.mediaPath.statusbar)
		ember.background:SetHorizTile(false)
		ember:SetStatusBarTexture(ShadowUF.Layout.mediaPath.statusbar)
		ember:GetStatusBarTexture():SetHorizTile(false)
		ember:SetHeight(frame.burningEmbersBar:GetHeight())
		ember:SetMinMaxValues(0, MAX_POWER_PER_EMBER)
		ember:SetOrientation(ShadowUF.db.profile.units[frame.unitType].burningEmbersBar.vertical and "VERTICAL" or "HORIZONTAL")
		ember:SetReverseFill(ShadowUF.db.profile.units[frame.unitType].burningEmbersBar.reverse and true or false)
		ember.setColor = nil
	end

	self:UpdateBarBlocks(frame)
end

function Embers:UpdateBarBlocks(frame, event, unit, powerType)
	if( not frame.visibility.burningEmbersBar ) then return end
	if( event and powerType ~= "BURNING_EMBERS" ) then return end

	local max = UnitPowerMax("player", Enum.PowerType.BurningEmbers, true)
	max = floor(max / MAX_POWER_PER_EMBER)

	if( max == 0 or frame.burningEmbersBar.visibleBlocks == max ) then return end

	local blockWidth = (frame.burningEmbersBar:GetWidth() - (max - 1)) / max
	for id=1, max do
		local ember = frame.burningEmbersBar.embers[id]
		ember:SetWidth(blockWidth)

		if( ShadowUF.db.profile.units[frame.unitType].burningEmbersBar.background ) then
			ember.background:Show()
		end

		ember:Show()
	end

	for id=max+1, #(frame.burningEmbersBar.embers) do
		frame.burningEmbersBar.embers[id]:Hide()
	end

	frame.burningEmbersBar.visibleBlocks = max
end

function Embers:Update(frame, event, unit, powerType)
    if( event and powerType ~= "BURNING_EMBERS" ) then return end

    local power = UnitPower("player", Enum.PowerType.BurningEmbers, true)
    for id=1, frame.burningEmbersBar.visibleBlocks do
        local ember = frame.burningEmbersBar.embers[id]

        local value = math.min(power, MAX_POWER_PER_EMBER)
        ember:SetValue(value)

        local color
        if value == MAX_POWER_PER_EMBER then
            color = "FULLBURNINGEMBER"
        else
            color = "BURNINGEMBERS"
        end

        if ember.setColor ~= color then
            ember.setColor = color
            frame:SetBlockColor(
                ember,
                "burningEmbersBar",
                ShadowUF.db.profile.powerColors[color].r,
                ShadowUF.db.profile.powerColors[color].g,
                ShadowUF.db.profile.powerColors[color].b
            )
        end

        power = power - MAX_POWER_PER_EMBER
    end
end


