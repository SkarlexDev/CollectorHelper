local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local COLORS = CollectorHelper.DASHBOARD_COLORS
local TRACK_WIDTH = 12
local TRACK_INSET = 4
local THUMB_WIDTH = 8
local MIN_THUMB_HEIGHT = 28
local MOUSE_WHEEL_STEP = 42

local function Clamp(value, minimum, maximum)
    return math.max(minimum, math.min(value, maximum))
end

---@param scrollFrame ScrollFrame
---@return Slider
function CollectorHelper:CreateModernScrollBar(scrollFrame)
    assert(scrollFrame, "CreateModernScrollBar requires a scroll frame")

    scrollFrame:EnableMouseWheel(true)

    local track = CreateFrame("Frame", nil, scrollFrame)
    track:SetWidth(TRACK_WIDTH)
    track:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, -TRACK_INSET)
    track:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, TRACK_INSET)

    local trackTexture = track:CreateTexture(nil, "BACKGROUND")
    trackTexture:SetWidth(2)
    trackTexture:SetPoint("TOP", track, "TOP")
    trackTexture:SetPoint("BOTTOM", track, "BOTTOM")
    trackTexture:SetColorTexture(0.10, 0.13, 0.18, 0.85)

    local slider = CreateFrame("Slider", nil, track)
    slider:SetOrientation("VERTICAL")
    slider:SetPoint("TOPLEFT", track, "TOPLEFT", 2, 0)
    slider:SetPoint("BOTTOMRIGHT", track, "BOTTOMRIGHT", -2, 0)
    slider:SetMinMaxValues(0, 0)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(0)
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")

    local thumb = slider:GetThumbTexture()
    thumb:SetSize(THUMB_WIDTH, MIN_THUMB_HEIGHT)
    thumb:SetColorTexture(unpack(COLORS.accentSoft))

    local synchronizing = false
    local updatePending = false

    local function Update()
        local range = math.max(scrollFrame:GetVerticalScrollRange(), 0)
        local viewportHeight = math.max(scrollFrame:GetHeight(), 1)
        local contentHeight = viewportHeight + range
        local trackHeight = math.max(track:GetHeight(), 1)
        local thumbHeight = math.min(
            trackHeight,
            math.max(MIN_THUMB_HEIGHT, trackHeight * viewportHeight / contentHeight)
        )
        local currentOffset = scrollFrame:GetVerticalScroll()
        local scrollOffset = Clamp(currentOffset, 0, range)

        slider:SetMinMaxValues(0, range)
        thumb:SetHeight(thumbHeight)
        slider:SetShown(range > 0)
        track:SetShown(range > 0)

        if scrollOffset ~= currentOffset then
            scrollFrame:SetVerticalScroll(scrollOffset)
        end

        synchronizing = true
        slider:SetValue(scrollOffset)
        synchronizing = false
    end

    local function RequestUpdate()
        if updatePending then return end
        updatePending = true
        C_Timer.After(0, function()
            updatePending = false
            Update()
        end)
    end

    slider:SetScript("OnValueChanged", function(_, value)
        if not synchronizing then
            scrollFrame:SetVerticalScroll(value)
        end
    end)
    slider:SetScript("OnEnter", function()
        thumb:SetColorTexture(unpack(COLORS.accent))
    end)
    slider:SetScript("OnLeave", function()
        thumb:SetColorTexture(unpack(COLORS.accentSoft))
    end)
    scrollFrame:HookScript("OnMouseWheel", function(_, delta)
        local range = math.max(scrollFrame:GetVerticalScrollRange(), 0)
        local currentOffset = scrollFrame:GetVerticalScroll()
        local scrollOffset = Clamp(
            currentOffset - delta * MOUSE_WHEEL_STEP,
            0,
            range
        )
        if scrollOffset ~= currentOffset then
            scrollFrame:SetVerticalScroll(scrollOffset)
        end
    end)
    scrollFrame:HookScript("OnSizeChanged", RequestUpdate)
    scrollFrame:HookScript("OnVerticalScroll", RequestUpdate)
    scrollFrame:HookScript("OnShow", RequestUpdate)

    scrollFrame.UpdateModernScrollBar = Update
    scrollFrame.RequestModernScrollBarUpdate = RequestUpdate
    Update()
    return slider
end
