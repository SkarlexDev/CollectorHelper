local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
local COLORS = CollectorHelper.DASHBOARD_COLORS

local PANEL_WIDTH = 390
local HEADER_HEIGHT = 56
local BODY_BOTTOM_GAP_WITH_HOUSING = 134
local BODY_BOTTOM_GAP = 68

local function CreateBackdrop(parent, name, width, height, point, color)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetPoint(unpack(point))
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(unpack(color or COLORS.panel))
    frame:SetBackdropBorderColor(unpack(COLORS.border))
    return frame
end

local function CreateLabel(parent, text, font, point, color)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    label:SetPoint(unpack(point))
    label:SetText(text)
    if color then
        label:SetTextColor(unpack(color))
    end
    return label
end

local function CreateActionButton(parent, name, text, width, height, onClick, hoverEnabled)
    local button = CreateFrame("Button", name, parent, "BackdropTemplate")
    button:SetSize(width, height)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    button:SetBackdropColor(unpack(COLORS.panelRaised))
    button:SetBackdropBorderColor(unpack(COLORS.border))
    button.label = CreateLabel(button, text, "GameFontNormalSmall",
        { "CENTER", button, "CENTER", 0, 0 }, COLORS.text)
    if hoverEnabled ~= false then
        button:SetScript("OnEnter", function(widget)
            widget:SetBackdropColor(unpack(COLORS.panelHover))
            widget:SetBackdropBorderColor(unpack(COLORS.accent))
        end)
        button:SetScript("OnLeave", function(widget)
            widget:SetBackdropColor(unpack(COLORS.panelRaised))
            widget:SetBackdropBorderColor(unpack(COLORS.border))
        end)
    end
    button:SetScript("OnClick", onClick)
    return button
end

local function CreateActionCard(parent, name, text, iconPath, width, color, accent, onClick, iconIsAtlas)
    local button = CreateFrame("Button", name, parent, "BackdropTemplate")
    button:SetSize(width, 40)
    button:SetPoint("CENTER", parent, "CENTER")
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    button:SetBackdropColor(unpack(color))
    button:SetBackdropBorderColor(unpack(COLORS.border))

    local stripe = button:CreateTexture(nil, "ARTWORK")
    stripe:SetWidth(2)
    stripe:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -6)
    stripe:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 1, 6)
    stripe:SetColorTexture(unpack(accent))

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(16, 16)
    icon:SetPoint("LEFT", button, "LEFT", 7, 0)
    if iconIsAtlas then
        icon:SetAtlas(iconPath)
    else
        icon:SetTexture(iconPath)
    end

    local label = CreateLabel(button, text, "GameFontNormalSmall",
        { "LEFT", icon, "RIGHT", 5, 0 }, COLORS.text)
    label:SetWidth(width - 34)
    label:SetJustifyH("LEFT")
    button.label = label

    button:SetScript("OnEnter", function(widget)
        widget:SetBackdropColor(unpack(COLORS.panelHover))
        widget:SetBackdropBorderColor(unpack(COLORS.accent))
    end)
    button:SetScript("OnLeave", function(widget)
        widget:SetBackdropColor(unpack(color))
        widget:SetBackdropBorderColor(unpack(COLORS.border))
    end)
    button:SetScript("OnClick", onClick)
    return button
end

function CollectorHelper:UpdateMerchantPanelToggle()
    if not (self.merchantFrameCost and self.merchantCollapsedButton) then return end

    local isShown = settings.showCostFrame
    self.merchantFrameCost:SetShown(isShown)
    self.merchantCollapsedButton:SetShown(not isShown)
end

function CollectorHelper:SetMerchantPanelShown(isShown)
    settings.showCostFrame = isShown
    self.db.settings = settings
    self:UpdateMerchantPanelToggle()
end

function CollectorHelper:UpdateMerchantLayout()
    if not (self.mainScrollableContent and self.merchantFrameCost) then return end

    local bottomGap = settings.showHousingFrame
        and BODY_BOTTOM_GAP_WITH_HOUSING
        or BODY_BOTTOM_GAP
    local listTop = self.merchantHasCosts and -76 or -140
    self.costSummary:SetShown(not self.merchantHasCosts)
    self.costListPanel:ClearAllPoints()
    self.costListPanel:SetPoint("TOPLEFT", self.merchantFrameCost, "TOPLEFT", 12, listTop)
    self.costListPanel:SetPoint("BOTTOMRIGHT", self.merchantFrameCost, "BOTTOMRIGHT", -12, bottomGap)
    self.mainScrollableContent.scrollFrame:SetHeight(math.max(100, self.costListPanel:GetHeight() - 20))
end

function CollectorHelper:InitMerchantUI()
    local merchantFrame = MerchantFrame
    local baseLevel = merchantFrame:GetFrameLevel()

    self.merchantFrameCost = CreateBackdrop(
        merchantFrame,
        "CollectorHelper_Merchant",
        PANEL_WIDTH,
        1,
        { "TOPLEFT", merchantFrame, "TOPRIGHT", 8, 0 },
        COLORS.background
    )
    self.merchantFrameCost:SetPoint("BOTTOMLEFT", merchantFrame, "BOTTOMRIGHT", 8, 0)
    self.merchantFrameCost:SetFrameLevel(baseLevel + 2)

    self.merchantPanelHeader = CreateBackdrop(
        self.merchantFrameCost,
        "CollectorHelper_MerchantHeader",
        PANEL_WIDTH - 24,
        HEADER_HEIGHT,
        { "TOPLEFT", self.merchantFrameCost, "TOPLEFT", 12, -12 },
        COLORS.panel
    )
    self.merchantPanelHeader:SetFrameLevel(self.merchantFrameCost:GetFrameLevel() + 2)

    local logo = self.merchantPanelHeader:CreateTexture(nil, "ARTWORK")
    logo:SetSize(30, 30)
    logo:SetPoint("LEFT", self.merchantPanelHeader, "LEFT", 12, 0)
    logo:SetTexture("Interface\\AddOns\\CollectorHelper\\core\\Media\\Textures\\Logo")

    local merchantTitle = CreateLabel(self.merchantPanelHeader, "MERCHANT HELPER", "GameFontNormal",
        { "TOPLEFT", logo, "TOPRIGHT", 9, -4 }, COLORS.text)
    merchantTitle:SetWidth(150)
    merchantTitle:SetJustifyH("LEFT")
    local merchantSubtitle = CreateLabel(self.merchantPanelHeader, "COLLECTION TOOLS", "GameFontHighlightSmall",
        { "TOPLEFT", merchantTitle, "BOTTOMLEFT", 0, -3 }, COLORS.muted)
    merchantSubtitle:SetWidth(150)
    merchantSubtitle:SetJustifyH("LEFT")

    self.merchantCollapseButton = CreateActionButton(
        self.merchantPanelHeader,
        "Collector_MerchantToggle",
        "−",
        24,
        24,
        function()
            self:SetMerchantPanelShown(false)
        end
    )
    self.merchantCollapseButton:SetPoint("RIGHT", self.merchantPanelHeader, "RIGHT", -8, 0)

    self.merchantFrameCost:SetWidth(PANEL_WIDTH)

    local merchantTab = _G.MerchantFrameTab2 or _G.MerchantFrameTab1 or merchantFrame
    self.merchantCollapsedButton = CreateActionButton(
        merchantFrame,
        "Collector_MerchantCollapsedToggle",
        "CH  +",
        54,
        26,
        function()
            self:SetMerchantPanelShown(true)
        end
    )
    self.merchantCollapsedButton:SetPoint("LEFT", merchantTab, "RIGHT", 5, 0)
    self.merchantCollapsedButton:SetFrameLevel(baseLevel + 8)

    self.costSummary = CreateBackdrop(
        self.merchantFrameCost,
        "CollectorHelper_MerchantSummary",
        PANEL_WIDTH - 24,
        54,
        { "TOPLEFT", self.merchantFrameCost, "TOPLEFT", 12, -76 },
        COLORS.panelRaised
    )
    self.merchantCost = CreateLabel(self.costSummary, "All collected!",
        "GameFontNormal", { "LEFT", self.costSummary, "LEFT", 14, 0 }, COLORS.green)
    self.merchantCost:SetWidth(PANEL_WIDTH - 56)
    self.merchantCost:SetJustifyH("LEFT")
    self.merchantCost:SetWordWrap(false)

    self.housingFrame = CreateBackdrop(
        self.merchantFrameCost,
        "CollectorHelper_HousingFrame",
        PANEL_WIDTH - 24,
        58,
        { "BOTTOMLEFT", self.merchantFrameCost, "BOTTOMLEFT", 12, 64 },
        COLORS.panel
    )
    local housingDescription = CreateLabel(self.housingFrame, "Housing duplicates", "GameFontNormalSmall",
        { "LEFT", self.housingFrame, "LEFT", 12, 0 }, COLORS.text)
    housingDescription:SetWidth(112)
    housingDescription:SetJustifyH("LEFT")

    self.housingSlider = self:SliderBuilder({
        sliderName = "CollectorHelper_HousingSlider",
        parent = self.housingFrame,
        width = 168,
        height = 20,
        point = { pos = "RIGHT", x = -14, y = 0 },
        min = 1,
        max = 50,
        step = 1,
        value = settings.housingDuplicateCount or 1,
        label = "",
        valueDisplay = true,
        onValueChanged = function(_, value)
            settings.housingDuplicateCount = value
            self:UpdateShop()
        end,
    })

    self.costListPanel = CreateBackdrop(
        self.merchantFrameCost,
        "CollectorHelper_MerchantCostList",
        PANEL_WIDTH - 24,
        1,
        { "TOPLEFT", self.merchantFrameCost, "TOPLEFT", 12, -76 },
        COLORS.panel
    )
    self.costListPanel:SetPoint(
        "BOTTOMRIGHT",
        self.merchantFrameCost,
        "BOTTOMRIGHT",
        -12,
        settings.showHousingFrame and BODY_BOTTOM_GAP_WITH_HOUSING or BODY_BOTTOM_GAP
    )

    self.mainScrollableContent = self:CreateScrollableContent({
        parent = self.costListPanel,
        width = PANEL_WIDTH - 58,
        xwidth = PANEL_WIDTH - 46,
        height = 120,
        xpos = 0,
        point = { pos = "TOPLEFT", x = 10, y = -10 },
        themeColors = COLORS,
        modernScrollBar = true,
    })
    self.merchantFrameCost:HookScript("OnSizeChanged", function()
        self:UpdateMerchantLayout()
    end)

    local actionPanel = CreateFrame("Frame", "CollectorHelper_MerchantActions", self.merchantFrameCost)
    actionPanel:SetSize(PANEL_WIDTH - 24, 44)
    actionPanel:SetPoint("BOTTOMLEFT", self.merchantFrameCost, "BOTTOMLEFT", 12, 10)

    self.buyAllButton = CreateActionCard(
        actionPanel,
        "Collector_MBuyButton",
        "Buy all",
        "Interface\\Icons\\INV_Misc_Coin_01",
        88,
        COLORS.panel,
        COLORS.green,
        function()
            for itemIndex in pairs(self.db.itemIndexMap) do
                if GetMerchantItemCostInfo(itemIndex) == 0 or CanAffordMerchantItem(itemIndex) then
                    BuyMerchantItem(itemIndex, 1)
                end
            end
        end
    )
    self.buyAllButton:ClearAllPoints()
    self.buyAllButton:SetPoint("LEFT", actionPanel, "LEFT", 1, 0)

    self.toggleShowOwned = CreateActionCard(
        actionPanel,
        "Collector_MSHButton",
        "Hide owned",
        "Interface\\Icons\\INV_Misc_Bag_10",
        88,
        COLORS.panelRaised,
        COLORS.accent,
        function()
            settings.hideMerchantOwned = not settings.hideMerchantOwned
            self.forceShowMerchant = not settings.hideMerchantOwned
            self.toggleShowOwned.label:SetText(settings.hideMerchantOwned and "Show owned" or "Hide owned")
            self:UpdateShop()
        end
    )
    self.toggleShowOwned.label:SetText(settings.hideMerchantOwned and "Show owned" or "Hide owned")
    self.toggleShowOwned:ClearAllPoints()
    self.toggleShowOwned:SetPoint("LEFT", self.buyAllButton, "RIGHT", 4, 0)

    self.ahTrackButton = CreateActionCard(
        actionPanel,
        "Collector_MAHListButton",
        "AH track",
        "Interface\\Icons\\INV_Misc_Coin_02",
        88,
        COLORS.panel,
        COLORS.accentSoft,
        function()
            self.doAhTrack = true
            self:UpdateShop()
            self.ahFrame:Show()
            self.ahScrollableContent.UpdateRows(self.db.ahItems)
        end
    )
    self.ahTrackButton:ClearAllPoints()
    self.ahTrackButton:SetPoint("LEFT", self.toggleShowOwned, "RIGHT", 4, 0)

    self.housingButton = CreateActionCard(
        actionPanel,
        "CollectorHelper_HousingExpand",
        "Housing",
        "housing-dashboard-homestone-icon",
        88,
        COLORS.panelRaised,
        COLORS.accentSoft,
        function()
            settings.showHousingFrame = not settings.showHousingFrame
            self.db.settings = settings
            self.housingFrame:SetShown(settings.showHousingFrame)
            self:UpdateMerchantLayout()
        end,
        true
    )
    self.housingButton:ClearAllPoints()
    self.housingButton:SetPoint("LEFT", self.ahTrackButton, "RIGHT", 4, 0)

    if not settings.showHousingFrame then
        self.housingFrame:Hide()
    end
    if not settings.showCostFrame then
        self.merchantFrameCost:Hide()
    end

    self.merchantHasCosts = false
    self:UpdateMerchantPanelToggle()
    self:UpdateMerchantLayout()
end
