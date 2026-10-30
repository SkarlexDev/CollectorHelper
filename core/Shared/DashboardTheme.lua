local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

CollectorHelper.DASHBOARD_COLORS = {
    background = { 0.035, 0.047, 0.071, 0.99 },
    panel = { 0.067, 0.086, 0.125, 0.98 },
    panelHover = { 0.102, 0.133, 0.184, 1 },
    panelRaised = { 0.086, 0.114, 0.161, 1 },
    accent = { 0.33, 0.78, 0.72, 1 },
    accentSoft = { 0.20, 0.45, 0.45, 1 },
    text = { 0.92, 0.95, 0.98, 1 },
    muted = { 0.61, 0.68, 0.77, 1 },
    border = { 0.16, 0.21, 0.29, 1 },
    green = { 0.26, 0.66, 0.51, 1 },
}

-- Adds a reusable, theme-matched scrollbar to a ScrollFrame without Blizzard's legacy template.
function CollectorHelper:CreateModernScrollBar(scrollFrame)
    scrollFrame:EnableMouseWheel(true)
    local track = CreateFrame("Frame", nil, scrollFrame)
    track:SetWidth(12)
    track:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, -4)
    track:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 4)

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
    slider:SetValue(0)
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")

    local thumb = slider:GetThumbTexture()
    thumb:SetSize(8, 28)
    thumb:SetColorTexture(unpack(self.DASHBOARD_COLORS.accentSoft))

    local function Update()
        local range = scrollFrame:GetVerticalScrollRange()
        local viewportHeight = math.max(scrollFrame:GetHeight(), 1)
        local contentHeight = viewportHeight + range
        local trackHeight = math.max(track:GetHeight(), 1)
        local thumbHeight = math.min(trackHeight, math.max(28, trackHeight * viewportHeight / contentHeight))

        slider:SetMinMaxValues(0, range)
        thumb:SetHeight(thumbHeight)
        slider:SetShown(range > 0)
        track:SetShown(range > 0)
        -- Slider value follows the ScrollFrame offset: zero at the top, max at the bottom.
        slider:SetValue(scrollFrame:GetVerticalScroll())
    end

    slider:SetScript("OnValueChanged", function(_, value)
        scrollFrame:SetVerticalScroll(value)
    end)
    slider:SetScript("OnEnter", function()
        thumb:SetColorTexture(unpack(self.DASHBOARD_COLORS.accent))
    end)
    slider:SetScript("OnLeave", function()
        thumb:SetColorTexture(unpack(self.DASHBOARD_COLORS.accentSoft))
    end)
    scrollFrame:SetScript("OnMouseWheel", function(_, delta)
        local range = scrollFrame:GetVerticalScrollRange()
        slider:SetValue(math.max(0, math.min(range,
            scrollFrame:GetVerticalScroll() - delta * 42)))
    end)
    scrollFrame:HookScript("OnSizeChanged", Update)
    scrollFrame:HookScript("OnVerticalScroll", Update)
    scrollFrame.UpdateModernScrollBar = Update
    Update()
    return slider
end
