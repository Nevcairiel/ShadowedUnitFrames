local Runes = {}

ShadowUF:RegisterModule(Runes, "runeBar", ShadowUF.L["Rune bar"], true, "DEATHKNIGHT")
ShadowUF.BlockTimers:Inject(Runes, "RUNE_TIMER")
ShadowUF.DynamicBlocks:Inject(Runes)

function Runes:OnEnable(frame)
	if( not frame.runeBar ) then
		frame.runeBar = CreateFrame("StatusBar", nil, frame)
		frame.runeBar:SetMinMaxValues(0, 1)
		frame.runeBar:SetValue(0)
		frame.runeBar.runes = {}
		frame.runeBar.blocks = frame.runeBar.runes

        for i = 1, 6 do
            local rune = ShadowUF.Units:CreateBar(frame.runeBar)
            rune.id = i

            if( i > 1 ) then
				rune:SetPoint("TOPLEFT", frame.runeBar.runes[i-1], "TOPRIGHT", 1, 0)
            else
                rune:SetPoint("TOPLEFT", frame.runeBar, "TOPLEFT", 0, 0)
            end

            frame.runeBar.runes[i] = rune
        end
	end

	frame:RegisterNormalEvent("RUNE_POWER_UPDATE", self, "UpdateUsable")
	frame:RegisterNormalEvent("RUNE_TYPE_UPDATE", self, "UpdateType")
	frame:RegisterUpdateFunc(self, "UpdateUsable")
end

function Runes:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Runes:OnLayoutApplied(frame)
	if( not frame.visibility.runeBar ) then return end

	local barWidth = (frame.runeBar:GetWidth() - 5) / 6
	for runeNumber, rune in pairs(frame.runeBar.runes) do
		if( ShadowUF.db.profile.units[frame.unitType].runeBar.background ) then
			rune.background:Show()
		else
			rune.background:Hide()
		end

		rune.background:SetTexture(ShadowUF.Layout.mediaPath.statusbar)
		rune.background:SetHorizTile(false)
		rune:SetStatusBarTexture(ShadowUF.Layout.mediaPath.statusbar)
		rune:GetStatusBarTexture():SetHorizTile(false)
		rune:SetWidth(barWidth)

		frame:SetBlockColor(rune, "runeBar", 0.5, 0.5, 0.5)
        self:UpdateType(frame, "RUNE_TYPE_UPDATE", runeNumber)
	end
end

local function runeMonitor(self, elapsed)
	local time = GetTime()
	self:SetValue(time)

	if( time >= self.endTime ) then
		self:SetValue(self.endTime)
		self:SetAlpha(1.0)
		self:SetScript("OnUpdate", nil)
		self.endTime = nil
	end

	if( self.fontString ) then
		self.fontString:UpdateTags()
	end
end

-- Updates the timers on runes
function Runes:UpdateUsable(frame, event, runeNumber, usable)
    local order = {1, 2, 5, 6, 3, 4}
	if( not runeNumber or not order[runeNumber] ) then
		return
	end

    local index = order[runeNumber]
	if( not index or not frame.runeBar.runes[index] ) then
		return
	end

	local rune = frame.runeBar.runes[index]

	local startTime, cooldown, cooled = GetRuneCooldown(runeNumber)
	-- Blizzard changed something with this API apparently and now it can be true/false/nil
	if( cooled == nil ) then return end

	if( not cooled ) then
		rune.endTime = startTime + cooldown
		rune:SetMinMaxValues(startTime, rune.endTime)
		rune:SetValue(GetTime())
		rune:SetAlpha(0.40)
		rune:SetScript("OnUpdate", runeMonitor)
	else
		rune:SetMinMaxValues(0, 1)
		rune:SetValue(1)
		rune:SetAlpha(1.0)
		rune:SetScript("OnUpdate", nil)
		rune.endTime = nil
	end

	if( rune.fontString ) then
		rune.fontString:UpdateTags()
	end

    self:UpdateType(frame, event, runeNumber)
end

-- Updates the color
function Runes:UpdateType(frame, event, runeNumber, ...)
	if( not runeNumber or not frame.runeBar.runes[runeNumber] ) then
		return
	end

	local rune = frame.runeBar.runes[runeNumber]

    -- Colorize by rune type
    local runeType = GetRuneType(runeNumber)
    -- RUNETYPE_BLOOD
    if(runeType == 1) then
        local color = ShadowUF.db.profile.powerColors.RUNES_BLOOD
        frame:SetBlockColor(rune, "runeBar", color.r, color.g, color.b)
    end
    -- RUNETYPE_CHROMATIC ("CHROMATIC" refers to Unholy runes)
    if(runeType == 2) then
        local color = ShadowUF.db.profile.powerColors.RUNES_UNHOLY
        frame:SetBlockColor(rune, "runeBar", color.r, color.g, color.b)
    end
    -- RUNETYPE_FROST
    if(runeType == 3) then
        local color = ShadowUF.db.profile.powerColors.RUNES_FROST
        frame:SetBlockColor(rune, "runeBar", color.r, color.g, color.b)
    end
    -- RUNETYPE_DEATH
    if(runeType == 4) then
        local color = ShadowUF.db.profile.powerColors.RUNES_DEATH
        frame:SetBlockColor(rune, "runeBar", color.r, color.g, color.b)
    end
end
