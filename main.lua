local addonName, addonData = ...

local EVENT_PLAYER_ENTERING_WORLD = 'PLAYER_ENTERING_WORLD'
local EVENT_PLAYER_FLAGS_CHANGED = 'PLAYER_FLAGS_CHANGED'
local EVENT_PLAYER_REGEN_ENABLED = 'PLAYER_REGEN_ENABLED'
local EVENT_CHAT_MSG_BG_SYSTEM_NEUTRAL = 'CHAT_MSG_BG_SYSTEM_NEUTRAL'
local EVENT_CHAT_MSG_BG_SYSTEM_ALLIANCE = 'CHAT_MSG_BG_SYSTEM_ALLIANCE'
local EVENT_CHAT_MSG_BG_SYSTEM_HORDE = 'CHAT_MSG_BG_SYSTEM_HORDE'

local UNIT_ID_PLAYER = 'player'
local FACTION_GROUP_HORDE = 'Horde'
local FACTION_GROUP_ALLIANCE = 'Alliance'

local MACRO_TARGET_EFC_NAME = 'EFC!'
local MACRO_TARGET_EFC_ICON = 132150
local MACRO_TARGET_EFC_BODY_FORMAT = '/target %s\n'

local L = addonData.L

local MSG_BATTLE_FOR_WSG_1MIN = L.MSG_BATTLE_FOR_WSG_1MIN
local MSG_ALLIANCE_WINS = L.MSG_ALLIANCE_WINS
local MSG_HORDE_WINS = L.MSG_HORDE_WINS
local MSG_PATTERN_ALLIANCE_FLAG_PICKED = L.MSG_PATTERN_ALLIANCE_FLAG_PICKED
local MSG_PATTERN_ALLIANCE_FLAG_DROPPED = L.MSG_PATTERN_ALLIANCE_FLAG_DROPPED
local MSG_PATTERN_ALLIANCE_FLAG_CAPTURED = L.MSG_PATTERN_ALLIANCE_FLAG_CAPTURED
local MSG_PATTERN_HORDE_FLAG_PICKED = L.MSG_PATTERN_HORDE_FLAG_PICKED
local MSG_PATTERN_HORDE_FLAG_DROPPED = L.MSG_PATTERN_HORDE_FLAG_DROPPED
local MSG_PATTERN_HORDE_FLAG_CAPTURED = L.MSG_PATTERN_HORDE_FLAG_CAPTURED

local STATE = {}
STATE.efcName = nil
STATE.efcNameInMacro = nil
STATE.eventsFrame = CreateFrame('Frame')
STATE.optionsFrame = CreateFrame('Frame', 'TargetEFCOptions', InterfaceOptionsFramePanelContainer)
STATE.efcFrame = CreateFrame('Frame', 'TargetEFCFrame', UIParent)

STATE.efcFrame:EnableMouse(true)
STATE.efcFrame:SetMovable(true)
STATE.efcFrame:SetUserPlaced(true)
STATE.efcFrame:RegisterForDrag('LeftButton')
STATE.efcFrame:SetScript('OnDragStart', STATE.efcFrame.StartMoving)
STATE.efcFrame:SetScript('OnDragStop', STATE.efcFrame.StopMovingOrSizing)
STATE.efcFrame:SetSize(200, 24)
STATE.efcFrame:SetBackdrop({
	bgFile = 'Interface/BUTTONS/WHITE8X8',
})
STATE.efcFrame:SetBackdropColor(0, 0, 0, 0.5)
STATE.efcFrame:SetPoint('CENTER', 650, -100)
STATE.efcFrame.text = STATE.efcFrame:CreateFontString(nil, 'ARTWORK')
STATE.efcFrame.text:SetFontObject(GameFontNormal)
STATE.efcFrame.text:SetPoint('CENTER', 0, 0)
STATE.efcFrame.text:SetText('EFC: ' .. tostring(nil))
STATE.efcFrame:Hide()

local showEFCFrame = function(show)
	if show then
		if TARGET_EFC_ADDON_DISABLED then
			return
		end

		STATE.efcFrame:Show()
	else
		STATE.efcFrame:Hide()
	end
end

local updateEFCFrameByState = function()
	if STATE.efcName ~= nil then
		showEFCFrame(true)
	end

	if STATE.efcNameInMacro == STATE.efcName then
		STATE.efcFrame:SetBackdropColor(0, 0, 0, 0.5)
	else
		STATE.efcFrame:SetBackdropColor(0.3, 0, 0, 0.5)
	end
end

local updateTargetEFCMacro = function()
	if not InCombatLockdown() then
		if GetMacroIndexByName(MACRO_TARGET_EFC_NAME) == 0 then
			CreateMacro(MACRO_TARGET_EFC_NAME, MACRO_TARGET_EFC_ICON, format(MACRO_TARGET_EFC_BODY_FORMAT, tostring(STATE.efcName)), nil)
		else
			EditMacro(MACRO_TARGET_EFC_NAME, MACRO_TARGET_EFC_NAME, MACRO_TARGET_EFC_ICON, format(MACRO_TARGET_EFC_BODY_FORMAT, tostring(STATE.efcName)), 1, nil)
		end

		STATE.efcNameInMacro = STATE.efcName
	end

	updateEFCFrameByState()
end

local updateEFCName = function(efcName)
	STATE.efcName = efcName
	STATE.efcFrame.text:SetText('EFC: ' .. tostring(STATE.efcName))

	updateTargetEFCMacro()
end

STATE.eventsFrame:RegisterEvent(EVENT_PLAYER_ENTERING_WORLD)
STATE.eventsFrame:RegisterEvent(EVENT_PLAYER_FLAGS_CHANGED)
STATE.eventsFrame:RegisterEvent(EVENT_PLAYER_REGEN_ENABLED)
STATE.eventsFrame:RegisterEvent(EVENT_CHAT_MSG_BG_SYSTEM_NEUTRAL)
STATE.eventsFrame:RegisterEvent(EVENT_CHAT_MSG_BG_SYSTEM_ALLIANCE)
STATE.eventsFrame:RegisterEvent(EVENT_CHAT_MSG_BG_SYSTEM_HORDE)
STATE.eventsFrame:SetScript('OnEvent', function(self, event, message)
	if event == EVENT_PLAYER_ENTERING_WORLD then
		updateTargetEFCMacro()
	elseif event == EVENT_PLAYER_FLAGS_CHANGED then
		if UnitIsAFK(UNIT_ID_PLAYER) then
			updateEFCName(nil)
			showEFCFrame(false)
		end
	elseif event == EVENT_PLAYER_REGEN_ENABLED then
		updateTargetEFCMacro()
	elseif event == EVENT_CHAT_MSG_BG_SYSTEM_NEUTRAL then
		if message == MSG_BATTLE_FOR_WSG_1MIN then
			showEFCFrame(true)
		end
  elseif event == EVENT_CHAT_MSG_BG_SYSTEM_HORDE then
		local match = ''
		
		if message == MSG_HORDE_WINS then
			showEFCFrame(false)
			return
		end

		if UnitFactionGroup(UNIT_ID_PLAYER) == FACTION_GROUP_HORDE then
			match = string.match(message, MSG_PATTERN_HORDE_FLAG_DROPPED)
			if match ~= nil then
				updateEFCName(nil)
				return
			end
		else
			match = string.match(message, MSG_PATTERN_ALLIANCE_FLAG_PICKED)
			if match ~= nil then
				updateEFCName(match)
				return
			end
			
			match = string.match(message, MSG_PATTERN_ALLIANCE_FLAG_CAPTURED)
			if match ~= nil then
				updateEFCName(nil)
				return
			end
		end
  elseif event == EVENT_CHAT_MSG_BG_SYSTEM_ALLIANCE then
		local match = ''
		
		if message == MSG_ALLIANCE_WINS then
			showEFCFrame(false)
			return
		end

		if UnitFactionGroup(UNIT_ID_PLAYER) == FACTION_GROUP_ALLIANCE then
			match = string.match(message, MSG_PATTERN_ALLIANCE_FLAG_DROPPED)
			if match ~= nil then
				updateEFCName(nil)
				return
			end
		else
			match = string.match(message, MSG_PATTERN_HORDE_FLAG_PICKED)
			if match ~= nil then
				updateEFCName(match)
				return
			end
			
			match = string.match(message, MSG_PATTERN_HORDE_FLAG_CAPTURED)
			if match ~= nil then
				updateEFCName(nil)
				return
			end
		end
  end
end)

STATE.optionsFrame.name = GetAddOnMetadata(addonName, 'Title')
STATE.optionsFrame:SetScript('OnShow', function(frame)
	if TARGET_EFC_ADDON_DISABLED == nil then
		TARGET_EFC_ADDON_DISABLED = false
	end

	local title = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', 16, -16)
	title:SetText(frame.name)

	local subtitle = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	subtitle:SetHeight(35)
	subtitle:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
	subtitle:SetPoint('RIGHT', frame, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH('LEFT')
	subtitle:SetJustifyV('TOP')
	subtitle:SetText(format('by %s', GetAddOnMetadata(addonName, 'Author')))
	
	local disabled = CreateFrame('CheckButton', 'TargetEFCDisabledCheckbox', frame, 'ChatConfigCheckButtonTemplate')
	disabled:SetPoint('TOPLEFT', subtitle, 'BOTTOMLEFT', 0, -15)
	disabled:SetChecked(TARGET_EFC_ADDON_DISABLED)
	disabled:SetScript('OnClick', function()
		TARGET_EFC_ADDON_DISABLED = not TARGET_EFC_ADDON_DISABLED

		disabled:SetChecked(TARGET_EFC_ADDON_DISABLED)
	end)

	getglobal(disabled:GetName() .. 'Text'):SetText('Disabled')
end)

InterfaceOptions_AddCategory(STATE.optionsFrame)
