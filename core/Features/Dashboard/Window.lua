local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local PANEL_WIDTH = 1120
local PANEL_HEIGHT = 760
local MIN_PANEL_WIDTH = 920
local MIN_PANEL_HEIGHT = 620
local SIDEBAR_WIDTH = 190

local COLORS = {
    background = { 0.035, 0.045, 0.075, 0.98 },
    panel = { 0.075, 0.09, 0.13, 0.98 },
    panelHover = { 0.12, 0.15, 0.20, 1 },
    accent = { 0.78, 0.58, 0.25, 1 },
    text = { 0.94, 0.92, 0.85, 1 },
    muted = { 0.62, 0.67, 0.75, 1 },
    green = { 0.38, 0.78, 0.53, 1 },
}

local NAVIGATION = {
    { id = "overview", label = "Overview", icon = "Interface\\Icons\\INV_Misc_Book_09" },
    { id = "tools", label = "Collection tools", icon = "Interface\\Icons\\INV_Misc_Bag_10" },
    { id = "settings", label = "Preferences", icon = "Interface\\Icons\\Trade_Engineering" },
    { id = "recipes", label = "Recipe journal", icon = "Interface\\Icons\\INV_Misc_Book_09" },
    { id = "news", label = "What's new", icon = "Interface\\Icons\\INV_Misc_Note_01" },
}

local function CreateBackdrop(parent, name, width, height, point, color)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetPoint(point[1], point[2], point[3], point[4], point[5])
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(unpack(color or COLORS.panel))
    frame:SetBackdropBorderColor(0.18, 0.21, 0.28, 1)
    return frame
end

local function CreateLabel(parent, text, font, point, color)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    label:SetPoint(point[1], point[2], point[3], point[4], point[5])
    label:SetText(text)
    if color then
        label:SetTextColor(unpack(color))
    end
    return label
end

function CollectorHelper:InitDashboard()
    if self.dashboard then return end

    local frame = CreateBackdrop(
        UIParent,
        "CollectorHelperDashboard",
        math.min(1600, math.max(MIN_PANEL_WIDTH, tonumber(settings.dashboardWidth) or PANEL_WIDTH)),
        math.min(1200, math.max(MIN_PANEL_HEIGHT, tonumber(settings.dashboardHeight) or PANEL_HEIGHT)),
        { "CENTER", UIParent, "CENTER", 0, 0 },
        COLORS.background
    )
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(MIN_PANEL_WIDTH, MIN_PANEL_HEIGHT, 1600, 1200)
    frame:EnableMouse(true)
    frame:SetScript("OnMouseDown", function(widget, button)
        if button == "LeftButton" then widget:StartMoving() end
    end)
    frame:SetScript("OnMouseUp", function(widget)
        widget:StopMovingOrSizing()
    end)
    frame:Hide()
    self.dashboard = frame

    local resizeGrip = CreateFrame("Button", nil, frame)
    resizeGrip:SetSize(18, 18)
    resizeGrip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 4)
    resizeGrip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizeGrip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizeGrip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizeGrip:SetScript("OnMouseDown", function()
        frame:StartSizing("BOTTOMRIGHT")
    end)
    resizeGrip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        settings.dashboardWidth = math.floor(frame:GetWidth() + 0.5)
        settings.dashboardHeight = math.floor(frame:GetHeight() + 0.5)
    end)

    local header = CreateFrame("Frame", nil, frame)
    header:SetPoint("TOPLEFT", 14, -12)
    header:SetPoint("TOPRIGHT", -14, -12)
    header:SetHeight(66)
    header:EnableMouse(true)
    header:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then frame:StartMoving() end
    end)
    header:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
    end)

    local logo = header:CreateTexture(nil, "ARTWORK")
    logo:SetSize(54, 54)
    logo:SetPoint("LEFT", 4, 0)
    logo:SetTexture("Interface\\AddOns\\CollectorHelper\\core\\Media\\Textures\\Logo")

    CreateLabel(header, "COLLECTOR HELPER", "GameFontNormalLarge", { "TOPLEFT", logo, "TOPRIGHT", 12, -3 }, COLORS.text)
    CreateLabel(header, "COLLECTION DASHBOARD  |cffffd27a3.0|r", "GameFontHighlightSmall",
        { "TOPLEFT", logo, "TOPRIGHT", 12, -26 }, COLORS.muted)

    local closeButton = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", 3, 3)
    closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    local accent = CreateBackdrop(frame, nil, 1, 2, { "TOPLEFT", frame, "TOPLEFT", 14, -82 }, COLORS.accent)
    accent:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -14, -82)
    accent:SetBackdropBorderColor(0, 0, 0, 0)

    local sidebar = CreateBackdrop(frame, nil, SIDEBAR_WIDTH, 1,
        { "TOPLEFT", frame, "TOPLEFT", 14, -91 }, COLORS.panel)
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 14, 14)
    local pageContainer = CreateFrame("Frame", nil, frame)
    pageContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", SIDEBAR_WIDTH + 32, -98)
    pageContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, -20)
    local contentWidth = math.max(670, frame:GetWidth() - SIDEBAR_WIDTH - 52)

    local pages = {}
    local navigationButtons = {}
    for index, entry in ipairs(NAVIGATION) do
        local pageID = entry.id
        local button = CreateFrame("Button", nil, sidebar, "BackdropTemplate")
        button:SetSize(SIDEBAR_WIDTH - 20, 42)
        button:SetPoint("TOPLEFT", 10, -14 - (index - 1) * 50)
        button:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        button:SetBackdropColor(unpack(COLORS.background))
        button:SetBackdropBorderColor(0.18, 0.21, 0.28, 1)

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetSize(24, 24)
        icon:SetPoint("LEFT", 10, 0)
        icon:SetTexture(entry.icon)
        CreateLabel(button, entry.label, "GameFontNormal", { "LEFT", icon, "RIGHT", 9, 0 }, COLORS.text)

        button:SetScript("OnEnter", function(widget)
            widget:SetBackdropColor(unpack(COLORS.panelHover))
        end)
        button:SetScript("OnLeave", function(widget)
            local color = self.dashboardActivePage == pageID and COLORS.panelHover or COLORS.background
            widget:SetBackdropColor(unpack(color))
        end)
        button:SetScript("OnClick", function()
            self:ShowDashboardPage(pageID)
        end)

        navigationButtons[pageID] = button
    end

    local footer = CreateLabel(sidebar, "A little more room\nfor your next collection.", "GameFontHighlightSmall",
        { "BOTTOMLEFT", sidebar, "BOTTOMLEFT", 14, 16 }, COLORS.muted)
    footer:SetJustifyH("LEFT")

    local function CreatePage(pageID)
        local page = CreateFrame("Frame", nil, pageContainer)
        page:SetAllPoints()
        page:Hide()
        pages[pageID] = page
        return page
    end

    local function CreateCard(parent, x, y, width, height, iconPath, title, description, onClick)
        local card = CreateFrame("Button", nil, parent, "BackdropTemplate")
        card:SetSize(width, height)
        card:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        card:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        card:SetBackdropColor(unpack(COLORS.panel))
        card:SetBackdropBorderColor(0.18, 0.21, 0.28, 1)

        local icon = card:CreateTexture(nil, "ARTWORK")
        icon:SetSize(34, 34)
        icon:SetPoint("LEFT", 13, 0)
        icon:SetTexture(iconPath)

        local titleText = CreateLabel(card, title, "GameFontNormal", { "TOPLEFT", icon, "TOPRIGHT", 11, -17 }, COLORS.text)
        titleText:SetWidth(width - 72)
        titleText:SetJustifyH("LEFT")
        local descriptionText = CreateLabel(card, description, "GameFontHighlightSmall",
            { "TOPLEFT", titleText, "BOTTOMLEFT", 0, -5 }, COLORS.muted)
        descriptionText:SetWidth(width - 72)
        descriptionText:SetJustifyH("LEFT")
        descriptionText:SetWordWrap(true)

        card:SetScript("OnEnter", function(widget)
            widget:SetBackdropColor(unpack(COLORS.panelHover))
            widget:SetBackdropBorderColor(unpack(COLORS.accent))
        end)
        card:SetScript("OnLeave", function(widget)
            widget:SetBackdropColor(unpack(COLORS.panel))
            widget:SetBackdropBorderColor(0.18, 0.21, 0.28, 1)
        end)
        card:SetScript("OnClick", onClick)
        card.titleText = titleText
        card.descriptionText = descriptionText
        return card
    end

    local statCards = {}
    local function CreateStatCard(parent, index, title, value, detail)
        local width = (contentWidth - 20) / 3
        local card = CreateBackdrop(parent, nil, width, 78,
            { "TOPLEFT", parent, "TOPLEFT", (index - 1) * (width + 10), -128 }, COLORS.panel)
        CreateLabel(card, title, "GameFontHighlightSmall",
            { "TOPLEFT", card, "TOPLEFT", 13, -11 }, COLORS.muted)
        local valueText = CreateLabel(card, value, "GameFontNormalLarge",
            { "TOPLEFT", card, "TOPLEFT", 13, -29 }, COLORS.text)
        local detailText = CreateLabel(card, detail, "GameFontHighlightSmall",
            { "BOTTOMLEFT", card, "BOTTOMLEFT", 13, 9 }, COLORS.accent)
        detailText:SetWidth(width - 26)
        statCards[index] = { frame = card, detail = detailText }
        return valueText
    end

    local overview = CreatePage("overview")
    local hero = CreateBackdrop(overview, nil, contentWidth, 104,
        { "TOPLEFT", overview, "TOPLEFT", 0, 0 }, COLORS.panel)
    local heroStripe = CreateBackdrop(hero, nil, 3, 70,
        { "LEFT", hero, "LEFT", 0, 0 }, COLORS.accent)
    heroStripe:SetBackdropBorderColor(0, 0, 0, 0)
    CreateLabel(hero, "Your collection, one stop at a time.", "GameFontNormalLarge",
        { "TOPLEFT", hero, "TOPLEFT", 20, -23 }, COLORS.text)
    local playerName = UnitName("player") or "Collector"
    CreateLabel(hero, "Welcome back, " .. playerName .. ". Pick up where your next collection begins.",
        "GameFontHighlight", { "TOPLEFT", hero, "TOPLEFT", 20, -52 }, COLORS.muted)

    self.dashboardStats = {
        recipes = CreateStatCard(overview, 1, "RECIPES LEARNED", "0", "Across all characters"),
        auction = CreateStatCard(overview, 2, "AH WATCH LIST", "0", "Items to find on the auction house"),
        raids = CreateStatCard(overview, 3, "LFR WINGS TRACKED", "0", "Wings marked as collected"),
    }

    CreateLabel(overview, "QUICK ACCESS", "GameFontNormal", { "TOPLEFT", overview, "TOPLEFT", 0, -228 }, COLORS.accent)
    local overviewCards = {}
    local overviewCardWidth = (contentWidth - 14) / 2
    overviewCards[1] = CreateCard(overview, 0, -250, overviewCardWidth, 86, "Interface\\Icons\\INV_Misc_Book_09",
        "Recipe journal", "Sync professions and browse character progress.",
        function()
            self:ShowDashboardPage("recipes")
        end)
    overviewCards[2] = CreateCard(overview, overviewCardWidth + 14, -250, overviewCardWidth, 86, "Interface\\Icons\\INV_Misc_Coin_01",
        "Auction house list", "Review the items you still need to buy.",
        function()
            frame:Hide()
            self.ahFrame:Show()
        end)
    overviewCards[3] = CreateCard(overview, 0, -348, overviewCardWidth, 86, "Interface\\Icons\\INV_Misc_Note_01",
        "Latest changes", "See what is new in CollectorHelper.",
        function()
            self:ShowDashboardPage("news")
        end)
    overviewCards[4] = CreateCard(overview, overviewCardWidth + 14, -348, overviewCardWidth, 86, "Interface\\Icons\\Trade_Engineering",
        "Fine-tune your setup", "Adjust collection and merchant preferences.",
        function() self:ShowDashboardPage("settings") end)

    local recipes = CreatePage("recipes")
    self:InitDashboardRecipeJournal(recipes)

    local news = CreatePage("news")
    self:InitDashboardNews(news)

    local tools = CreatePage("tools")
    CreateLabel(tools, "COLLECTION TOOLS", "GameFontNormalLarge", { "TOPLEFT", tools, "TOPLEFT", 0, -4 }, COLORS.text)
    CreateLabel(tools, "Choose a tool. Your existing collection data stays right where it is.",
        "GameFontHighlight", { "TOPLEFT", tools, "TOPLEFT", 0, -30 }, COLORS.muted)

    local toolCards = {
        { "Interface\\Icons\\INV_Misc_Book_09", "Recipe journal", "Sync professions and compare character progress.", function() self:ShowDashboardPage("recipes") end },
        { "Interface\\Icons\\INV_Misc_Coin_01", "Auction house list", "Review tracked vendor items and their quantities.", function() frame:Hide(); self.ahFrame:Show() end },
        { "Interface\\Icons\\INV_Misc_Note_01", "Changelog", "Read the latest addon updates.", function() self:ShowDashboardPage("news") end },
        { "Interface\\Icons\\Merchant_Enter", "Merchant helper", "Open a merchant to see ownership and costs.", function()
            if MerchantFrame and MerchantFrame:IsShown() then
                frame:Hide()
                self:UpdateShop()
            else
                self:Print("Visit a merchant to use the merchant collection tools.")
            end
        end },
        { "Interface\\Icons\\INV_Misc_GroupLooking", "LFR progress", "Your wing markers appear beside supported raid gossip options.", function()
            frame:Hide()
            if GossipFrame and GossipFrame:IsShown() then
                self:GossipLfr()
            else
                self:Print("Speak with a supported raid NPC to view and update LFR wing progress.")
            end
        end },
        { "Interface\\Icons\\Trade_Engineering", "Preferences", "Adjust your collection, merchant, and minimap options.", function() self:ShowDashboardPage("settings") end },
    }

    local toolCardFrames = {}
    local toolCardWidth = (contentWidth - 14) / 2
    for index, card in ipairs(toolCards) do
        local column = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        toolCardFrames[index] = CreateCard(tools, column * (toolCardWidth + 14),
            -72 - row * 104, toolCardWidth, 90, card[1], card[2], card[3], card[4])
    end

    local preferences = CreatePage("settings")
    CreateLabel(preferences, "YOUR COLLECTION, YOUR RULES", "GameFontNormalLarge",
        { "TOPLEFT", preferences, "TOPLEFT", 0, -4 }, COLORS.text)
    CreateLabel(preferences, "Quick switches for the options you change most.",
        "GameFontHighlight", { "TOPLEFT", preferences, "TOPLEFT", 0, -30 }, COLORS.muted)

    local switches = {
        { "hideMerchantOwned", "Hide collected items", "Keep already-owned items out of merchant lists." },
        { "softCollect", "Soft collection", "Treat appearances collected from other sources as complete." },
        { "showCostFrame", "Merchant cost panel", "Show the collection cost panel at merchants." },
        { "showMinimapButton", "Minimap button", "Show the CollectorHelper button around your minimap." },
    }
    local settingRefreshers = {}
    local settingRows = {}

    for index, setting in ipairs(switches) do
        local settingKey = setting[1]
        local settingTitle = setting[2]
        local settingDescription = setting[3]
        local row = CreateBackdrop(preferences, nil, contentWidth, 64,
            { "TOPLEFT", preferences, "TOPLEFT", 0, -72 - (index - 1) * 74 }, COLORS.panel)
        settingRows[#settingRows + 1] = row
        CreateLabel(row, settingTitle, "GameFontNormal",
            { "TOPLEFT", row, "TOPLEFT", 16, -16 }, COLORS.text)
        CreateLabel(row, settingDescription, "GameFontHighlightSmall",
            { "TOPLEFT", row, "TOPLEFT", 16, -39 }, COLORS.muted)

        local toggle = CreateFrame("Button", nil, row, "BackdropTemplate")
        toggle:SetSize(104, 32)
        toggle:SetPoint("RIGHT", row, "RIGHT", -14, 0)
        toggle:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
        toggle:SetBackdropBorderColor(0.18, 0.21, 0.28, 1)

        local toggleLabel = CreateLabel(toggle, "", "GameFontNormal",
            { "CENTER", toggle, "CENTER", 0, 0 }, COLORS.text)
        local function RefreshToggle()
            local enabled = settings[settingKey] == true
            toggle:SetBackdropColor(unpack(enabled and COLORS.green or COLORS.panelHover))
            toggleLabel:SetText(enabled and "ENABLED" or "DISABLED")
        end
        settingRefreshers[#settingRefreshers + 1] = RefreshToggle
        toggle:SetScript("OnClick", function()
            settings[settingKey] = not settings[settingKey]
            self.db.settings = settings
            RefreshToggle()
            if settingKey == "showCostFrame" and self.merchantFrameCost then
                self.merchantFrameCost:SetShown(settings.showCostFrame)
            end
            if settingKey == "showMinimapButton" then
                self:UpdateMinimapButtonVisibility()
            end
            if (settingKey == "hideMerchantOwned" or settingKey == "softCollect")
                and MerchantFrame and MerchantFrame:IsShown() then
                self:UpdateShop()
            end
        end)
        toggle:SetScript("OnEnter", function()
            toggle:SetBackdropBorderColor(unpack(COLORS.accent))
        end)
        toggle:SetScript("OnLeave", function()
            toggle:SetBackdropBorderColor(0.18, 0.21, 0.28, 1)
        end)
        RefreshToggle()
    end

    self.dashboardPages = pages
    self.dashboardNavigation = navigationButtons
    self.dashboardSettingRefreshers = settingRefreshers
    local function RefreshResponsiveLayout()
        contentWidth = math.max(670, pageContainer:GetWidth())
        if pageContainer:GetWidth() <= 0 then
            contentWidth = math.max(670, frame:GetWidth() - SIDEBAR_WIDTH - 52)
        end
        hero:SetWidth(contentWidth)

        local statWidth = (contentWidth - 20) / 3
        for index, card in ipairs(statCards) do
            card.frame:SetWidth(statWidth)
            card.frame:ClearAllPoints()
            card.frame:SetPoint("TOPLEFT", overview, "TOPLEFT", (index - 1) * (statWidth + 10), -128)
            card.detail:SetWidth(statWidth - 26)
        end

        local cardWidth = (contentWidth - 14) / 2
        for index, card in ipairs(overviewCards) do
            local column = (index - 1) % 2
            local row = math.floor((index - 1) / 2)
            card:SetWidth(cardWidth)
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", overview, "TOPLEFT", column * (cardWidth + 14), -250 - row * 98)
            card.titleText:SetWidth(cardWidth - 72)
            card.descriptionText:SetWidth(cardWidth - 72)
        end

        for index, card in ipairs(toolCardFrames) do
            local column = (index - 1) % 2
            local row = math.floor((index - 1) / 2)
            card:SetWidth(cardWidth)
            card:ClearAllPoints()
            card:SetPoint("TOPLEFT", tools, "TOPLEFT", column * (cardWidth + 14), -72 - row * 104)
            card.titleText:SetWidth(cardWidth - 72)
            card.descriptionText:SetWidth(cardWidth - 72)
        end

        for _, row in ipairs(settingRows) do
            row:SetWidth(contentWidth)
        end
    end
    frame:SetScript("OnSizeChanged", function(_, width, height)
        settings.dashboardWidth = math.floor(width + 0.5)
        settings.dashboardHeight = math.floor(height + 0.5)
        RefreshResponsiveLayout()
    end)
    RefreshResponsiveLayout()
    self:ShowDashboardPage("overview")
    self:RefreshDashboardStats()
end

function CollectorHelper:RefreshDashboardStats()
    if not self.dashboardStats then return end

    local recipeCount = 0
    for _, characterData in pairs(recipeCollected or {}) do
        for _, professionData in pairs(characterData) do
            if type(professionData) == "table" then
                recipeCount = recipeCount + (tonumber(professionData.collected) or 0)
            end
        end
    end

    local markedWings = 0
    for _, raidData in pairs(lfrCollected or {}) do
        for _, isCollected in pairs(raidData.wings or {}) do
            if isCollected then markedWings = markedWings + 1 end
        end
    end

    self.dashboardStats.recipes:SetText(tostring(recipeCount))
    self.dashboardStats.auction:SetText(tostring(#self.db.ahItems))
    self.dashboardStats.raids:SetText(tostring(markedWings))
end

function CollectorHelper:ShowDashboardPage(pageID)
    if not self.dashboardPages or not self.dashboardPages[pageID] then return end

    self.dashboardActivePage = pageID
    for id, page in pairs(self.dashboardPages) do
        page:SetShown(id == pageID)
    end

    for id, button in pairs(self.dashboardNavigation) do
        button:SetBackdropColor(unpack(id == pageID and COLORS.panelHover or COLORS.background))
        button:SetBackdropBorderColor(unpack(id == pageID and COLORS.accent or COLORS.panel))
    end

    if pageID == "settings" then
        for _, refresh in ipairs(self.dashboardSettingRefreshers) do
            refresh()
        end
    elseif pageID == "recipes" then
        self:RefreshDashboardRecipeJournal()
    elseif pageID == "news" and self.RefreshDashboardNews then
        self:RefreshDashboardNews()
    end
end

function CollectorHelper:ToggleDashboard(pageID)
    if not self.dashboard then return end

    if pageID then
        self:ShowDashboardPage(pageID)
        self.dashboard:Show()
        self:RefreshDashboardStats()
    else
        self.dashboard:SetShown(not self.dashboard:IsShown())
        if self.dashboard:IsShown() then
            self:RefreshDashboardStats()
        end
    end
end
