local _, app = ...

local COLORS = app.COLORS
-- ========================
-- Section: Merchant Frame build
-- ========================
local merchantFrameCost = app:frameBuilder({
    frameName = "CollectorHelper_Merchant",
    parent = MerchantFrame,
    width = 280,
    height = MerchantFrame:GetHeight(),
    point = {
        pos = "TOPRIGHT",
        x = 280,
        y = 0,
    },
    titleBuilder = {
        text = app:textCFormat(COLORS.yellow, "Currency Needed to Collect this page"),
        point = {
            pos = "TOP",
            x = 0,
            y = -8,
        }
    }
})
app.merchantFrameCost = merchantFrameCost
app.marchantCost = app:fontBuilder({
    parent = merchantFrameCost,
    text = app:textCFormat(COLORS.green, "You have everything on this page"),
    point = {
        pos = "CENTER",
        x = 0,
        y = 80,
    }
})
app:buttonBuilder({
    buttonName = "Collector_MBuyButton",
    parent = merchantFrameCost,
    text = "Buy All Possible",
    width = 120,
    height = 22,
    point = {
        pos = "BOTTOMLEFT",
        x = 18,
        y = 8,
    },
    onClickScript = function(self, button)
        if button == "LeftButton" then
            for itemIndex, _ in pairs(app.itemIndexMap) do
                local costInfo = GetMerchantItemCostInfo(itemIndex)
                if costInfo == 0 or CanAffordMerchantItem(itemIndex) then
                    BuyMerchantItem(itemIndex, 1)
                end
            end
        end
    end
})
app:buttonBuilder({
    buttonName = "Collector_MSHButton",
    parent = merchantFrameCost,
    text = "Show/hide owned",
    width = 120,
    height = 22,
    point = {
        pos = "BOTTOMRIGHT",
        x = -18,
        y = 8,
    },
    onClickScript = function(self, button)
        if button == "LeftButton" then
            settings.hideMerchantOwned = not settings.hideMerchantOwned
            if settings.hideMerchantOwned == false then
                app.forceShowMerchant = true
            end
            app:updateShop()
        end
    end
})
-- scrollable content cost
app.mainScrollableContent = app:CreateScrollableContent(merchantFrameCost)

-- ========================
-- Section: Merchant Source frame
-- ========================
local merchantSourceItems = app:frameBuilder({
    frameName = "CollectorHelper_MerchantSource",
    parent = merchantFrameCost,
    width = 280,
    height = MerchantFrame:GetHeight(),
    point = {
        pos = "TOPLEFT",
        x = -280,
        y = 0,
    },
    titleBuilder = {
        text = app:textCFormat(COLORS.yellow, "Possible Rewards for this Token"),
        point = {
            pos = "TOP",
            x = 0,
            y = -8,
        }
    }
})

app.merchantSourceItems = merchantSourceItems
merchantSourceItems:Hide()

sourceDetails = app:fontBuilder({
    parent = merchantSourceItems,
    text = "",
    point = {
        pos = "TOPLEFT",
        x = 30,
        y = -40,
    }
})

app:buttonBuilder({
    buttonName = "Collector_MerchantSource_Close",
    parent = merchantSourceItems,
    text = "Close",
    width = 120,
    height = 22,
    point = {
        pos = "BOTTOM",
        x = 0,
        y = 8,
    },
    onClickScript = function(self, button)
        if button == "LeftButton" then
            merchantSourceItems:Hide()
            merchantFrameCost:SetPoint("TOPRIGHT", 280, 0)
        end
    end
})


-- ========================
-- Section: Other
-- ========================
app:buttonBuilder({
    buttonName = "Collector_MerchantToggle",
    parent = MerchantFrame,
    text = "Toggle CH",
    width = 120,
    height = 22,
    point = {
        pos = "BOTTOM",
        x = -100,
        y = 5,
    },
    onClickScript = function(self, button)
        if button == "LeftButton" then
            if settings.showCostFrame then
                merchantFrameCost:Hide()
            else
                merchantFrameCost:Show()
            end
            settings.showCostFrame = not settings.showCostFrame
        end
    end
})
