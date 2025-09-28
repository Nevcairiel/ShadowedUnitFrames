local Combo = {isComboPoints = true}
ShadowUF.ComboPoints = Combo

-- Create combo point icons
local function createIcons(config, pointsFrame)
    local point, relativePoint, x, y
    local pointsConfig = pointsFrame.cpConfig

    if config.growth == "LEFT" then
        point, relativePoint = "BOTTOMRIGHT", "BOTTOMLEFT"
        x = config.spacing
    elseif config.growth == "UP" then
        point, relativePoint = "BOTTOMLEFT", "TOPLEFT"
        y = config.spacing
    elseif config.growth == "DOWN" then
        point, relativePoint = "TOPLEFT", "BOTTOMLEFT"
        y = config.spacing
    else
        point, relativePoint = "BOTTOMLEFT", "BOTTOMRIGHT"
        x = config.spacing
    end

    x = x or 0
    y = y or 0

    for id = 1, pointsConfig.max do
        pointsFrame.icons[id] = pointsFrame.icons[id] or pointsFrame:CreateTexture(nil, "OVERLAY")
        local texture = pointsFrame.icons[id]
        texture:SetTexture(pointsConfig.icon)
        texture:SetSize(config.size or 16, config.size or 16)

        if id > 1 then
            texture:ClearAllPoints()
            texture:SetPoint(point, pointsFrame.icons[id - 1], relativePoint, x, y)
        else
            texture:ClearAllPoints()
            texture:SetPoint("CENTER", pointsFrame, "CENTER", 0, 0)
        end
    end
end

-- Create combo point blocks (bar mode)
local function createBlocks(config, pointsFrame)
    local pointsConfig = pointsFrame.cpConfig
    if pointsConfig.max == 0 then return end
    pointsFrame.visibleBlocks = pointsConfig.max

    local blockWidth = (pointsFrame:GetWidth() - ((pointsConfig.max / (pointsConfig.grouping or 1)) - 1)) / pointsConfig.max
    for id = 1, pointsConfig.max do
        pointsFrame.blocks[id] = pointsFrame.blocks[id] or pointsFrame:CreateTexture(nil, "OVERLAY")
        local texture = pointsFrame.blocks[id]
        local color = ShadowUF.db.profile.powerColors[pointsConfig.colorKey or "COMBOPOINTS"]
        texture:SetVertexColor(color.r, color.g, color.b, color.a)
        texture:SetHorizTile(false)
        texture:SetTexture(ShadowUF.Layout.mediaPath.statusbar)
        texture:SetHeight(pointsFrame:GetHeight())
        texture:SetWidth(blockWidth)
        texture:ClearAllPoints()

        if not texture.background and config.background then
            texture.background = pointsFrame:CreateTexture(nil, "BORDER")
            texture.background:SetHeight(1)
            texture.background:SetWidth(1)
            texture.background:SetAllPoints(texture)
            texture.background:SetHorizTile(false)
            texture.background:SetVertexColor(color.r, color.g, color.b, ShadowUF.db.profile.bars.backgroundAlpha)
            texture.background:SetTexture(ShadowUF.Layout.mediaPath.statusbar)
        end

        if texture.background then
            texture.background:SetShown(config.background)
        end

        local offset = 1
        if pointsConfig.grouping and ((id - 1) % pointsConfig.grouping ~= 0) then
            offset = 0
        end

        if config.growth == "LEFT" then
            if id > 1 then
                texture:SetPoint("TOPRIGHT", pointsFrame.blocks[id - 1], "TOPLEFT", -offset, 0)
            else
                texture:SetPoint("TOPRIGHT", pointsFrame, "TOPRIGHT", 0, 0)
            end
        else
            if id > 1 then
                texture:SetPoint("TOPLEFT", pointsFrame.blocks[id - 1], "TOPRIGHT", offset, 0)
            else
                texture:SetPoint("TOPLEFT", pointsFrame, "TOPLEFT", 0, 0)
            end
        end
    end
end

-- Prevent recursion during layout
function Combo:OnLayoutApplied(frame, config)
    local key = self:GetComboPointType()
    local pointsFrame = frame[key]
    if not pointsFrame then return end

    if pointsFrame._inLayout then return end
    pointsFrame._inLayout = true

    pointsFrame:SetFrameLevel(frame.topFrameLevel + 1)

    local pointsConfig = pointsFrame.cpConfig
    config = config[key]

    if config and not config.isBar then
        ShadowUF.Layout:ToggleVisibility(pointsFrame, frame.visibility[key])
    end

    if not frame.visibility[key] then
        pointsFrame._inLayout = nil
        return
    end

    if pointsFrame.points then
        for _, texture in pairs(pointsFrame.points) do
            texture:Hide()
            texture:ClearAllPoints()
        end
    end

    if config.isBar then
        pointsFrame.blocks = pointsFrame.blocks or {}
        pointsFrame.points = pointsFrame.blocks
        createBlocks(config, pointsFrame)
    else
        pointsFrame.icons = pointsFrame.icons or {}
        pointsFrame.points = pointsFrame.icons
        createIcons(config, pointsFrame)

        if pointsFrame:GetWidth() ~= 0.1 or pointsFrame:GetHeight() ~= 0.1 then
            pointsFrame:SetSize(0.1, 0.1)
        end

        if not pointsFrame._anchored then
            ShadowUF.Layout:AnchorFrame(frame, pointsFrame, config)
            pointsFrame._anchored = true
        end
    end

    pointsFrame._inLayout = nil
end

function Combo:OnDisable(frame)
    frame:UnregisterAll(self)
end

-- Safe update for bar blocks
function Combo:UpdateBarBlocks(frame, event, unit, powerType)
    local key = self:GetComboPointType()
    local pointsFrame = frame[key]
    if not pointsFrame or not pointsFrame.cpConfig.eventType or not pointsFrame.blocks then return end
    if event and powerType ~= pointsFrame.cpConfig.eventType then return end

    local max = self.GetMaxPoints and self:GetMaxPoints() or UnitPowerMax("player", pointsFrame.cpConfig.powerType)
    -- Clamp to safe maximum of 5
    if max > 5 then max = 5 end
    if max == 0 or pointsFrame.visibleBlocks == max then return end

    if pointsFrame._updatingBlocks then return end
    pointsFrame._updatingBlocks = true

    pointsFrame.cpConfig.max = max

    if not ShadowUF.db.profile.units[frame.unitType][key].isBar then
        createIcons(ShadowUF.db.profile.units[frame.unitType][key], pointsFrame)
        pointsFrame.visibleBlocks = max
        pointsFrame._updatingBlocks = nil
        return
    else
        createBlocks(ShadowUF.db.profile.units[frame.unitType][key], pointsFrame)
        pointsFrame.visibleBlocks = max
    end

    local blockWidth = (pointsFrame:GetWidth() - (max - 1)) / max
    for id = 1, max do
        pointsFrame.blocks[id]:SetWidth(blockWidth)
        pointsFrame.blocks[id]:Show()
    end

    for id = max + 1, #pointsFrame.blocks do
        pointsFrame.blocks[id]:Hide()
    end

    pointsFrame._updatingBlocks = nil
end

-- Regular Update
function Combo:Update(frame, event, unit, powerType)
    local key = self:GetComboPointType()
    if event and frame[key].cpConfig.eventType and frame[key].cpConfig.eventType ~= powerType then return end

    local points = self:GetPoints(unit)

    if ShadowUF.db.profile.units[frame.unitType][key].isBar then
        ShadowUF.Layout:SetBarVisibility(frame, key, ShadowUF.db.profile.units[frame.unitType][key].showAlways or (points and points > 0))
    end

    for id, pointTexture in pairs(frame[key].points) do
        if id <= points then
            pointTexture:Show()
        else
            pointTexture:Hide()
        end
    end
end

-- Adjust block heights when frame changes
function Combo:OnLayoutWidgets(frame)
    local key = self:GetComboPointType()
    if not frame.visibility[key] or not ShadowUF.db.profile.units[frame.unitType][key].isBar or not frame[key].blocks then return end

    local height = frame[key]:GetHeight()
    for _, block in pairs(frame[key].blocks) do
        block:SetHeight(height)
    end
end
