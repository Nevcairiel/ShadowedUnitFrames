local Indicators = {list = {"status", "pvp", "leader", "resurrect", "masterLoot", "raidTarget", "ready", "role", "class", "phase", "happiness" }}

ShadowUF:RegisterModule(Indicators, "indicators", ShadowUF.L["Indicators"])

function Indicators:UpdateClass(frame)
	if( not frame.indicators.class or not frame.indicators.class.enabled ) then return end

	local class = frame:UnitClassToken()
	if( UnitIsPlayer(frame.unit) and class ) then
		local coords = CLASS_ICON_TCOORDS[class]
		frame.indicators.class:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
		frame.indicators.class:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
		frame.indicators.class:Show()
	else
		frame.indicators.class:Hide()
	end
end

function Indicators:UpdatePhase(frame)
    if( not frame.indicators.phase or not frame.indicators.phase.enabled ) then return end

    if( UnitIsConnected(frame.unit) and not UnitInPhase(frame.unit) ) then
	    frame.indicators.phase:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
	    frame.indicators.phase:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
        frame.indicators.phase:Show()
    else
        frame.indicators.phase:Hide()
    end
end

function Indicators:UpdateResurrect(frame)
    if( not frame.indicators.resurrect or not frame.indicators.resurrect.enabled ) then return end

    if( UnitHasIncomingResurrection(frame.unit) ) then
        frame.indicators.resurrect:Show()
    else
        frame.indicators.resurrect:Hide()
    end
end

function Indicators:UpdateMasterLoot(frame)
	if( not frame.indicators.masterLoot or not frame.indicators.masterLoot.enabled ) then return end

	local lootType, partyID, raidID = GetLootMethod()
	if( lootType ~= "master" ) then
		frame.indicators.masterLoot:Hide()
	elseif( ( partyID and partyID == 0 and UnitIsUnit(frame.unit, "player") ) or ( partyID and partyID > 0 and UnitIsUnit(frame.unit, ShadowUF.partyUnits[partyID]) ) or ( raidID and raidID > 0 and UnitIsUnit(frame.unit, ShadowUF.raidUnits[raidID]) ) ) then
		frame.indicators.masterLoot:Show()
	else
		frame.indicators.masterLoot:Hide()
	end
end

function Indicators:UpdateRaidTarget(frame)
	if( not frame.indicators.raidTarget or not frame.indicators.raidTarget.enabled ) then return end

	if( UnitExists(frame.unit) and GetRaidTargetIndex(frame.unit) ) then
		SetRaidTargetIconTexture(frame.indicators.raidTarget, GetRaidTargetIndex(frame.unit))
		frame.indicators.raidTarget:Show()
	else
		frame.indicators.raidTarget:Hide()
	end
end

function Indicators:UpdateRole(frame, event)
	if( not frame.indicators.role or not frame.indicators.role.enabled ) then return end

	if( not UnitInRaid(frame.unit) and not UnitInParty(frame.unit) ) then
		frame.indicators.role:Hide()
	elseif( GetPartyAssignment("MAINTANK", frame.unit) ) then
		frame.indicators.role:SetTexture("Interface\\GroupFrame\\UI-Group-MainTankIcon")
		frame.indicators.role:Show()
	elseif( GetPartyAssignment("MAINASSIST", frame.unit) ) then
		frame.indicators.role:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon")
		frame.indicators.role:Show()
	else
		frame.indicators.role:Hide()
	end
end

function Indicators:UpdateLeader(frame)
	if( not frame.indicators.leader or not frame.indicators.leader.enabled ) then return end

	if( UnitIsGroupLeader(frame.unit) ) then
		frame.indicators.leader:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
		frame.indicators.leader:SetTexCoord(0, 1, 0, 1)
		frame.indicators.leader:Show()

	elseif( UnitIsGroupAssistant(frame.unit) or ( UnitInRaid(frame.unit) and IsEveryoneAssistant() ) ) then
		frame.indicators.leader:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
		frame.indicators.leader:SetTexCoord(0, 1, 0, 1)
		frame.indicators.leader:Show()
	else
		frame.indicators.leader:Hide()
	end
end

function Indicators:GroupRosterUpdate(frame)
	self:UpdateMasterLoot(frame)
	self:UpdateRole(frame)
	self:UpdateLeader(frame)
end

function Indicators:UpdatePVPFlag(frame)
	if( not frame.indicators.pvp or not frame.indicators.pvp.enabled ) then return end

	local faction = UnitFactionGroup(frame.unit)
	if( UnitIsPVPFreeForAll(frame.unit) ) then
		frame.indicators.pvp:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		frame.indicators.pvp:SetTexCoord(0,1,0,1)
		frame.indicators.pvp:Show()
	elseif( faction and faction ~= "Neutral" and UnitIsPVP(frame.unit) ) then
		frame.indicators.pvp:SetTexture(string.format("Interface\\TargetingFrame\\UI-PVP-%s", faction))
		frame.indicators.pvp:SetTexCoord(0,1,0,1)
		frame.indicators.pvp:Show()
	else
		frame.indicators.pvp:Hide()
	end
end

-- Non-player units do not give events when they enter or leave combat, so polling is necessary
local function combatMonitor(self, elapsed)
	self.timeElapsed = self.timeElapsed + elapsed
	if( self.timeElapsed < 1 ) then return end
	self.timeElapsed = self.timeElapsed - 1

	if( UnitAffectingCombat(self.parent.unit) ) then
		self.status:Show()
	else
		self.status:Hide()
	end
end

-- It looks like the combat check for players is a bit buggy when they are in a vehicle, so swap it to also check polling
function Indicators:CheckVehicle(frame)
	frame.indicators.timeElapsed = 0
	frame.indicators:SetScript("OnUpdate", frame.inVehicle and combatMonitor or nil)
end

function Indicators:UpdateStatus(frame)
	if( not frame.indicators.status or not frame.indicators.status.enabled ) then return end

	if( UnitAffectingCombat(frame.unitOwner) ) then
		frame.indicators.status:SetTexCoord(0.50, 1.0, 0.0, 0.49)
		frame.indicators.status:Show()
	elseif( frame.unitRealType == "player" and IsResting() ) then
		frame.indicators.status:SetTexCoord(0.0, 0.50, 0.0, 0.421875)
		frame.indicators.status:Show()
	else
		frame.indicators.status:Hide()
	end
end

-- Ready check fading once the check complete
local function fadeReadyStatus(self, elapsed)
	self.timeLeft = self.timeLeft - elapsed
	self.ready:SetAlpha(self.timeLeft / self.startTime)

	if( self.timeLeft <= 0 ) then
		self:SetScript("OnUpdate", nil)

		self.ready.status = nil
		self.ready:Hide()
	end
end

local FADEOUT_TIME = 6
function Indicators:UpdateReadyCheck(frame, event)
	if( not frame.indicators.ready or not frame.indicators.ready.enabled ) then return end

	-- We're done, and should fade it out if it's shown
	if( event == "READY_CHECK_FINISHED" ) then
		if( not frame.indicators.ready:IsShown() ) then return end

		-- Create the central timer frame if ones not already made
		if( not self.fadeTimer ) then
			self.fadeTimer = CreateFrame("Frame", nil)
			self.fadeTimer.fadeList = {}
			self.fadeTimer:Hide()
			self.fadeTimer:SetScript("OnUpdate", function(f, elapsed)
				local hasTimer
				for fadeFrame, timeLeft in pairs(f.fadeList) do
					hasTimer = true

					f.fadeList[fadeFrame] = timeLeft - elapsed
					fadeFrame:SetAlpha(f.fadeList[fadeFrame] / FADEOUT_TIME)

					if( f.fadeList[fadeFrame] <= 0 ) then
						f.fadeList[fadeFrame] = nil
						fadeFrame:Hide()
					end
				end

				if( not hasTimer ) then f:Hide() end
			end)
		end

		-- Start the timer
		self.fadeTimer.fadeList[frame.indicators.ready] = FADEOUT_TIME
		self.fadeTimer:Show()

		-- Player never responded so they are AFK
		if( frame.indicators.ready.status == "waiting" ) then
			frame.indicators.ready:SetTexture("Interface\\RaidFrame\\ReadyCheck-NotReady")
		end
		return
	end

	-- Have a state change in ready status
	local status = GetReadyCheckStatus(frame.unit)
	if( not status ) then
		frame.indicators.ready.status = nil
		frame.indicators.ready:Hide()
		return
	end

	if( status == "ready" ) then
		frame.indicators.ready:SetTexture(READY_CHECK_READY_TEXTURE)
	elseif( status == "notready" ) then
		frame.indicators.ready:SetTexture(READY_CHECK_NOT_READY_TEXTURE)
	elseif( status == "waiting" ) then
		frame.indicators.ready:SetTexture(READY_CHECK_WAITING_TEXTURE)
	end

	frame.indicators:SetScript("OnUpdate", nil)
	frame.indicators.ready.status = status
	frame.indicators.ready:SetAlpha(1.0)
	frame.indicators.ready:Show()
end

function Indicators:UpdateHappiness(frame)
	if( not frame.indicators.happiness or not frame.indicators.happiness.enabled ) then return end

	local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
	local hasPetUI, isHunterPet = HasPetUI()
	if ( not happiness or not isHunterPet ) then
		frame.indicators.happiness:Hide()
		return
	end

	if ( happiness == 1 ) then
		frame.indicators.happiness:SetTexCoord(0.375, 0.5625, 0, 0.359375)
	elseif ( happiness == 2 ) then
		frame.indicators.happiness:SetTexCoord(0.1875, 0.375, 0, 0.359375)
	elseif ( happiness == 3 ) then
		frame.indicators.happiness:SetTexCoord(0, 0.1875, 0, 0.359375)
	end
	frame.indicators.happiness:Show()
end

function Indicators:OnEnable(frame)
	-- Forces the indicators to be above the bars/portraits/etc
	if( not frame.indicators ) then
		frame.indicators = CreateFrame("Frame", nil, frame)
		frame.indicators:SetFrameLevel(frame.topFrameLevel + 2)
	end

	-- Now lets enable all the indicators
	local config = ShadowUF.db.profile.units[frame.unitType]
	if( config.indicators.status and config.indicators.status.enabled ) then
		frame:RegisterUpdateFunc(self, "UpdateStatus")
		frame.indicators.status = frame.indicators.status or frame.indicators:CreateTexture(nil, "OVERLAY")
		frame.indicators.status:SetTexture("Interface\\CharacterFrame\\UI-StateIcon")
		frame.indicators.timeElapsed = 0
		frame.indicators.parent = frame

		if( frame.unitType == "player" ) then
			frame:RegisterUpdateFunc(self, "CheckVehicle")
			frame:RegisterNormalEvent("PLAYER_REGEN_ENABLED", self, "UpdateStatus")
			frame:RegisterNormalEvent("PLAYER_REGEN_DISABLED", self, "UpdateStatus")
			frame:RegisterNormalEvent("PLAYER_UPDATE_RESTING", self, "UpdateStatus")
			frame:RegisterNormalEvent("UPDATE_FACTION", self, "UpdateStatus")
		else
			frame.indicators.status:SetTexCoord(0.50, 1.0, 0.0, 0.49)
			frame.indicators:SetScript("OnUpdate", combatMonitor)
		end
	elseif( frame.indicators.status ) then
		frame.indicators:SetScript("OnUpdate", nil)
	end

	if( config.indicators.phase and config.indicators.phase.enabled ) then
		-- Player phase changes do not generate a phase change event. This seems to be the best
		-- TODO: what event does fire here? frame:RegisterNormalEvent("UPDATE_WORLD_STATES", self, "UpdatePhase")
        frame:RegisterUpdateFunc(self, "UpdatePhase")
        frame.indicators.phase = frame.indicators.phase or frame.indicators:CreateTexture(nil, "OVERLAY")
    end

	if( config.indicators.resurrect and config.indicators.resurrect.enabled ) then
	    frame:RegisterNormalEvent("INCOMING_RESURRECT_CHANGED", self, "UpdateResurrect")
	    frame:RegisterNormalEvent("UNIT_OTHER_PARTY_CHANGED", self, "UpdateResurrect")
	    frame:RegisterUpdateFunc(self, "UpdateResurrect")

	    frame.indicators.resurrect = frame.indicators.resurrect or frame.indicators:CreateTexture(nil, "OVERLAY")
	    frame.indicators.resurrect:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
	end

	if( config.indicators.pvp and config.indicators.pvp.enabled ) then
		frame:RegisterUnitEvent("PLAYER_FLAGS_CHANGED", self, "UpdatePVPFlag")
		frame:RegisterUnitEvent("UNIT_FACTION", self, "UpdatePVPFlag")
		frame:RegisterUpdateFunc(self, "UpdatePVPFlag")

		frame.indicators.pvp = frame.indicators.pvp or frame.indicators:CreateTexture(nil, "OVERLAY")
	end

	if( config.indicators.class and config.indicators.class.enabled ) then
		frame:RegisterUpdateFunc(self, "UpdateClass")
		frame.indicators.class = frame.indicators.class or frame.indicators:CreateTexture(nil, "OVERLAY")
	end

	if( config.indicators.leader and config.indicators.leader.enabled ) then
		frame:RegisterNormalEvent("PARTY_LEADER_CHANGED", self, "UpdateLeader")
		frame:RegisterUpdateFunc(self, "UpdateLeader")

		frame.indicators.leader = frame.indicators.leader or frame.indicators:CreateTexture(nil, "OVERLAY")
	end

	if( config.indicators.masterLoot and config.indicators.masterLoot.enabled ) then
		frame:RegisterNormalEvent("PARTY_LOOT_METHOD_CHANGED", self, "UpdateMasterLoot")
		frame:RegisterUpdateFunc(self, "UpdateMasterLoot")

		frame.indicators.masterLoot = frame.indicators.masterLoot or frame.indicators:CreateTexture(nil, "OVERLAY")
		frame.indicators.masterLoot:SetTexture("Interface\\GroupFrame\\UI-Group-MasterLooter")
	end

	if( config.indicators.role and config.indicators.role.enabled ) then
		frame:RegisterUpdateFunc(self, "UpdateRole")

		frame.indicators.role = frame.indicators.role or frame.indicators:CreateTexture(nil, "OVERLAY")
		frame.indicators.role:SetTexture("Interface\\GroupFrame\\UI-Group-MainAssistIcon")
	end

	if( config.indicators.raidTarget and config.indicators.raidTarget.enabled ) then
		frame:RegisterNormalEvent("RAID_TARGET_UPDATE", self, "UpdateRaidTarget")
		frame:RegisterUpdateFunc(self, "UpdateRaidTarget")

		frame.indicators.raidTarget = frame.indicators.raidTarget or frame.indicators:CreateTexture(nil, "OVERLAY")
		frame.indicators.raidTarget:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
	end

	if( config.indicators.ready and config.indicators.ready.enabled ) then
		frame:RegisterNormalEvent("READY_CHECK", self, "UpdateReadyCheck")
		frame:RegisterNormalEvent("READY_CHECK_CONFIRM", self, "UpdateReadyCheck")
		frame:RegisterNormalEvent("READY_CHECK_FINISHED", self, "UpdateReadyCheck")
		frame:RegisterUpdateFunc(self, "UpdateReadyCheck")

		frame.indicators.ready = frame.indicators.ready or frame.indicators:CreateTexture(nil, "OVERLAY")
	end

	if( config.indicators.happiness and config.indicators.happiness.enabled ) then
		frame:RegisterUnitEvent("UNIT_HAPPINESS", self, "UpdateHappiness")
		frame:RegisterUpdateFunc(self, "UpdateHappiness")

		frame.indicators.happiness = frame.indicators.happiness or frame.indicators:CreateTexture(nil, "OVERLAY")
		frame.indicators.happiness:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
	end

	-- As they all share the function, register it as long as one is active
	if( frame.indicators.leader or frame.indicators.masterLoot or frame.indicators.role ) then
		frame:RegisterNormalEvent("GROUP_ROSTER_UPDATE", self, "GroupRosterUpdate")
	end
end

function Indicators:OnDisable(frame)
	frame:UnregisterAll(self)

	for _, key in pairs(self.list) do
		if( frame.indicators[key] ) then
			frame.indicators[key].enabled = nil
			frame.indicators[key]:Hide()
		end
	end
end

function Indicators:OnLayoutApplied(frame, config)
	if( frame.visibility.indicators ) then
		self:OnDisable(frame)
		self:OnEnable(frame)

		for _, key in pairs(self.list) do
			local indicator = frame.indicators[key]
			if( indicator and config.indicators[key] and config.indicators[key].enabled and config.indicators[key].size ) then
				indicator.enabled = true
				indicator:SetHeight(config.indicators[key].size)
				indicator:SetWidth(config.indicators[key].size)
				ShadowUF.Layout:AnchorFrame(frame, indicator, config.indicators[key])
			elseif( indicator ) then
				indicator.enabled = nil
				indicator:Hide()
			end
		end

		-- Disable the polling
		if( config.indicators.status and not config.indicators.status.enabled and frame.indicators.status ) then
			frame.indicators:SetScript("OnUpdate", nil)
		end
	end
end
