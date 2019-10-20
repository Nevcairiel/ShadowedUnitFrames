local IncHeal = {}
ShadowUF:RegisterModule(IncHeal, "incHeal", ShadowUF.L["Incoming heals"])

function IncHeal:OnEnable(frame)
	frame.incHeal = frame.incHeal or ShadowUF.Units:CreateBar(frame)

	frame:RegisterUnitEvent("UNIT_MAXHEALTH", self, "UpdateFrame")
	frame:RegisterUnitEvent("UNIT_HEALTH", self, "UpdateFrame")
	frame:RegisterUnitEvent("UNIT_HEALTH_FREQUENT", self, "UpdateFrame")

	frame:RegisterUpdateFunc(self, "UpdateFrame")
end

function IncHeal:OnDisable(frame)
	frame:UnregisterAll(self)
	frame.incHeal:Hide()
end

function IncHeal:OnLayoutApplied(frame)
	if( not frame.visibility.incHeal or not frame.visibility.healthBar ) then return end

	-- Since we're hiding, reset state
	local bar = frame.incHeal
	bar.total = nil

	bar:SetSize(frame.healthBar:GetSize())
	bar:SetStatusBarTexture(ShadowUF.Layout.mediaPath.statusbar)
	bar:SetStatusBarColor(ShadowUF.db.profile.healthColors.inc.r, ShadowUF.db.profile.healthColors.inc.g, ShadowUF.db.profile.healthColors.inc.b, ShadowUF.db.profile.bars.alpha)
	bar:GetStatusBarTexture():SetHorizTile(false)
	bar:SetOrientation(frame.healthBar:GetOrientation())
	bar:SetReverseFill(frame.healthBar:GetReverseFill())
	bar:Hide()

	local cap = ShadowUF.db.profile.units[frame.unitType].incHeal.cap or 1.30

	-- When we can cheat and put the incoming bar right behind the health bar, we can efficiently show the incoming heal bar
	-- if the main bar has a transparency set, then we need a more complicated method to stop the health bar from being darker with incoming heals up
	if( ( ShadowUF.db.profile.units[frame.unitType].healthBar.invert and ShadowUF.db.profile.bars.backgroundAlpha == 0 ) or ( not ShadowUF.db.profile.units[frame.unitType].healthBar.invert and ShadowUF.db.profile.bars.alpha == 1 ) ) then
		bar.simple = true
		bar:SetFrameLevel(frame.topFrameLevel - 2)

		if( bar:GetOrientation() == "HORIZONTAL" ) then
			bar:SetWidth(frame.healthBar:GetWidth() * cap)
		else
			bar:SetHeight(frame.healthBar:GetHeight() * cap)
		end

		bar:ClearAllPoints()

		local point = bar:GetReverseFill() and "RIGHT" or "LEFT"
		bar:SetPoint("TOP" .. point, frame.healthBar)
		bar:SetPoint("BOTTOM" .. point, frame.healthBar)
	else
		bar.simple = nil
		bar:SetFrameLevel(frame.topFrameLevel + 1)
		bar:SetWidth(1)
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(1)
		bar:ClearAllPoints()

		bar.orientation = bar:GetOrientation()
		bar.reverseFill = bar:GetReverseFill()

		if( bar.orientation == "HORIZONTAL" ) then
			bar.healthSize = frame.healthBar:GetWidth()
			bar.positionPoint = bar.reverseFill and "TOPRIGHT" or "TOPLEFT"
			bar.positionRelative = bar.reverseFill and "BOTTOMRIGHT" or "BOTTOMLEFT"
		else
			bar.healthSize = frame.healthBar:GetHeight()
			bar.positionPoint = bar.reverseFill and "TOPLEFT" or "BOTTOMLEFT"
			bar.positionRelative = bar.reverseFill and "TOPRIGHT" or "BOTTOMRIGHT"
		end

		bar.positionMod = bar.reverseFill and -1 or 1
		bar.maxSize = bar.healthSize * cap
	end
end

function IncHeal:PositionBar(frame, incAmount)
	local bar = frame.incHeal
	local health = UnitHealth(frame.unit)
	local maxHealth = UnitHealthMax(frame.unit)

	if( incAmount <= 0 or health <= 0 or maxHealth <= 0 ) then
		bar.total = nil
		bar:Hide()
		return
	end

	if( not bar.total ) then bar:Show() end
	bar.total = incAmount

	-- When the primary bar has an alpha of 100%, we can cheat and do incoming heals easily. Otherwise we need to do it a more complex way to keep it looking good
	if( bar.simple ) then
		bar.total = health + incAmount
		bar:SetMinMaxValues(0, maxHealth * (ShadowUF.db.profile.units[frame.unitType].incHeal.cap or 1.30))
		bar:SetValue(bar.total)
	else
		local healthSize = bar.healthSize * (health / maxHealth)
		local incSize = bar.healthSize * (incAmount / maxHealth)

		if( (healthSize + incSize) > bar.maxSize ) then
			incSize = bar.maxSize - healthSize
		end

		if( bar.orientation == "HORIZONTAL" ) then
			bar:SetWidth(incSize)
			bar:SetPoint(bar.positionPoint, frame.healthBar, bar.positionMod * healthSize, 0)
			bar:SetPoint(bar.positionRelative, frame.healthBar, bar.positionMod * healthSize, 0)
		else
			bar:SetHeight(incSize)
			bar:SetPoint(bar.positionPoint, frame.healthBar, 0, bar.positionMod * healthSize)
			bar:SetPoint(bar.positionRelative, frame.healthBar, 0, bar.positionMod * healthSize)
		end
	end
end

function IncHeal:UpdateFrame(frame)
	self:PositionBar(frame, 0)
end
