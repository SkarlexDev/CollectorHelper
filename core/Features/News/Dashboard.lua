local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local COLORS = {
    panel = { 0.075, 0.09, 0.13, 0.98 },
    accent = { 0.78, 0.58, 0.25, 1 },
    text = { 0.94, 0.92, 0.85, 1 },
    muted = { 0.62, 0.67, 0.75, 1 },
}

local function CreateLabel(parent, text, font, point)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    label:SetPoint(point[1], point[2], point[3], point[4], point[5])
    label:SetText(text or "")
    return label
end

function CollectorHelper:InitDashboardNews(parent)
    parent:SetClipsChildren(true)

    local title = CreateLabel(parent, "WHAT'S NEW", "GameFontNormalLarge",
        { "TOPLEFT", parent, "TOPLEFT", 0, -4 })
    title:SetTextColor(unpack(COLORS.text))

    local subtitle = CreateLabel(parent, "Updates and improvements to Collector Helper.",
        "GameFontHighlight", { "TOPLEFT", title, "BOTTOMLEFT", 0, -7 })
    subtitle:SetTextColor(unpack(COLORS.muted))

    local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -48)
    scroll:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -36, 8)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)

    local cards = {}
    for versionIndex, versionData in ipairs(self.db.news or {}) do
        local notes = {}
        for noteIndex = 2, #versionData do
            notes[#notes + 1] = versionData[noteIndex]
        end

        local card = CreateFrame("Frame", nil, content, "BackdropTemplate")
        card:SetSize(1, 1)
        card:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        card:SetBackdropColor(unpack(COLORS.panel))
        card:SetBackdropBorderColor(unpack(versionIndex == 1 and COLORS.accent or COLORS.muted))

        local heading = CreateLabel(card, versionData[1], "GameFontNormalLarge",
            { "TOPLEFT", card, "TOPLEFT", 16, -14 })
        heading:SetTextColor(unpack(versionIndex == 1 and COLORS.accent or COLORS.text))

        local noteLabels = {}
        for noteIndex, note in ipairs(notes) do
            local label = CreateLabel(card, note, "GameFontHighlight",
                { "TOPLEFT", card, "TOPLEFT", 20, -48 })
            label:SetJustifyH("LEFT")
            label:SetWordWrap(true)
            noteLabels[#noteLabels + 1] = label
        end
        cards[#cards + 1] = { frame = card, heading = heading, notes = noteLabels }
    end

    local function RefreshLayout()
        local width = math.max(scroll:GetWidth() - 24, 1)
        content:SetWidth(width)
        local yOffset = 0
        for _, card in ipairs(cards) do
            local cardWidth = math.max(width - 8, 1)
            card.frame:SetWidth(cardWidth)
            card.frame:ClearAllPoints()
            card.frame:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -yOffset)
            card.heading:SetWidth(math.max(cardWidth - 32, 1))
            local noteOffset = 48
            for _, label in ipairs(card.notes) do
                label:SetWidth(math.max(cardWidth - 40, 1))
                label:ClearAllPoints()
                label:SetPoint("TOPLEFT", card.frame, "TOPLEFT", 20, -noteOffset)
                local labelHeight = math.max(label:GetStringHeight(), 18)
                noteOffset = noteOffset + labelHeight + 8
            end
            local cardHeight = noteOffset + 10
            card.frame:SetHeight(cardHeight)
            yOffset = yOffset + cardHeight + 12
        end
        content:SetHeight(math.max(yOffset, 1))
        scroll:UpdateScrollChildRect()
        scroll:SetVerticalScroll(0)
    end

    parent:SetScript("OnSizeChanged", RefreshLayout)
    self.RefreshDashboardNews = RefreshLayout
    RefreshLayout()
end
