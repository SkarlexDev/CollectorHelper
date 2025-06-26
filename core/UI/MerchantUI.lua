local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
local COLORS = CollectorHelper.COLORS or {}

-- =========================================================================
-- Initializes the custom Merchant UI extension
-- =========================================================================
function CollectorHelper:InitMerchantUI()

    local width = 327
    local buttonHeight = 22
    local buttonWidth = 100

    self.merchantFrameCost = self:FrameBuilder({
        frameName = "CollectorHelper_Merchant",
        parent = MerchantFrame,
        width = 330,
        height = MerchantFrame:GetHeight(),
        point = { pos = "TOPRIGHT", x = 330, y = 0 },
    })

    local titleFrame = self:FrameBuilder({
        frameName = "CollectorHelper_MerchantTitle",
        parent = self.merchantFrameCost,
        width = width,
        height = 25,
        point = { pos = "TOP", x = 0, y = -2 },
        bgColorR = 0.1176, bgColorG = 0.1176, bgColorB = 0.1176, bgAlpha = 1,
    })

    self:FontBuilder({
        parent = titleFrame,
        text = self:TextCFormat(COLORS.yellow, "Currency Needed to Collect everything"),
        point = { pos = "CENTER", x = 0, y = 0 },
    })

    local contentFrame = self:FrameBuilder({
        frameName = "CollectorHelper_MerchantInner",
        parent = self.merchantFrameCost,
        width = width,
        height = 280,
        point = { pos = "TOP", x = 0, y = -27 },
        bgColorR = 0.1176, bgColorG = 0.1176, bgColorB = 0.1176, bgAlpha = 0.8,
    })

    self.merchantCost = self:FontBuilder({
        parent = contentFrame,
        text = self:TextCFormat(COLORS.green, "You have everything on this merchant"),
        point = { pos = "CENTER", x = 0, y = 80 },
    })

    self.mainScrollableContent = self:CreateScrollableContent({
        parent = contentFrame,
        width = 280,
        height = 260,
        xpos = 0,
        point = { pos = "CENTER", x = -11, y = 0 },
    })

    self.innerRecipeFrame = self:FrameBuilder({
        frameName = "CollectorHelper_MerchantInnerRecipe",
        parent = self.merchantFrameCost,
        width = width,
        height = 102,
        point = { pos = "TOP", x = 0, y = -307 },
        bgColorR = 0, bgColorG = 0, bgColorB = 0, bgAlpha = 0.251,
    })

    local buttonFrame = self:FrameBuilder({
        frameName = "CollectorHelper_MerchantInnerBtn0",
        parent = self.merchantFrameCost,
        width = width,
        height = 33,
        point = { pos = "TOP", x = 0, y = -409 },
        bgColorR = 0.1176, bgColorG = 0.1176, bgColorB = 0.1176, bgAlpha = 1,
    })

    -- Buy All Button
    self.buyAllButton = self:ButtonBuilder({
        buttonName = "Collector_MBuyButton",
        parent = buttonFrame,
        text = "Buy All",
        width = buttonWidth,
        height = buttonHeight,
        point = { pos = "BOTTOMLEFT", x = 8, y = 6 },
        onClickScript = function()
            for itemIndex in pairs(self.db.itemIndexMap) do
                if GetMerchantItemCostInfo(itemIndex) == 0 or CanAffordMerchantItem(itemIndex) then
                    BuyMerchantItem(itemIndex, 1)
                end
            end
        end,
    })

    -- Toggle Owned Button
    self.toggleShowOwned = self:ButtonBuilder({
        buttonName = "Collector_MSHButton",
        parent = buttonFrame,
        text = "Toggle owned",
        width = buttonWidth,
        height = buttonHeight,
        point = { pos = "BOTTOM", x = 0, y = 6 },
        onClickScript = function()
            settings.hideMerchantOwned = not settings.hideMerchantOwned
            self.forceShowMerchant = not settings.hideMerchantOwned
            self:UpdateShop()
        end,
    })

    -- AH Track Button
    self:ButtonBuilder({
        buttonName = "Collector_MAHListButton",
        parent = buttonFrame,
        text = "AH Track",
        width = buttonWidth,
        height = buttonHeight,
        point = { pos = "BOTTOMRIGHT", x = -8, y = 6 },
        onClickScript = function()
            self.doAhTrack = true
            self:UpdateShop()
            self.ahFrame:Show()
            self.ahScrollableContent.UpdateRows(self.db.ahItems)
        end,
    })

    -- Toggle Visibility of Cost Frame (State: saved in settings)
    if settings.showCostFrame == false then
        self.merchantFrameCost:Hide()
    end

    -- Toggle Buttons on Merchant Tab
    self:ButtonBuilder({
        buttonName = "Collector_MerchantToggle",
        parent = _G["MerchantFrameTab1"],
        text = "Toggle CH",
        width = 90,
        height = 25,
        point = { pos = "LEFT", x = 3, y = -28 },
        onClickScript = function()
            local isVisible = self.merchantFrameCost:IsShown()
            self.merchantFrameCost:SetShown(not isVisible)
            settings.showCostFrame = not isVisible
        end,
    })

    self:ButtonBuilder({
        buttonName = "Collector_MerchantSyncRecipe",
        parent = _G["MerchantFrameTab1"],
        text = "Sync Recipe",
        width = 90,
        height = 25,
        point = { pos = "LEFT", x = 93, y = -28 },
        onClickScript = function()
            self:ShowRecipeUI(true)
        end,
    })
end
