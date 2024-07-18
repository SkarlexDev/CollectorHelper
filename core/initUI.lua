local _, app = ...

local COLORS = app.COLORS

-- ========================
-- Section: Merchant Frame build
-- ========================
local merchantFrameCost = app:frameBuilder({
    frameName = "CollectorHelper_Merchant",
    parent = MerchantFrame,
    width = 330,
    height = MerchantFrame:GetHeight(),
    point = {
        pos = "TOPRIGHT",
        x = 330,
        y = 0,
    },
    titleBuilder = {
        text = app:textCFormat(COLORS.yellow, "Currency Needed to Collect everything"),
        point = {
            pos = "TOP",
            x = 0,
            y = -8,
        }
    }
})
app.merchantFrameCost = merchantFrameCost

app.merchantCost = app:fontBuilder({
    parent = merchantFrameCost,
    text = app:textCFormat(COLORS.green, "You have everything on this merchant"),
    point = {
        pos = "CENTER",
        x = 0,
        y = 80,
    }
})

local buyAllButton = app:buttonBuilder({
    buttonName = "Collector_MBuyButton",
    parent = merchantFrameCost,
    text = "Buy All",
    width = 100,
    height = 22,
    point = {
        pos = "BOTTOMLEFT",
        x = 8,
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
app.buyAllButton = buyAllButton

local toggleShowOwned = app:buttonBuilder({
    buttonName = "Collector_MSHButton",
    parent = merchantFrameCost,
    text = "Toggle owned",
    width = 100,
    height = 22,
    point = {
        pos = "BOTTOM",
        x = 0,
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
app.toggleShowOwned = toggleShowOwned

local ahListButton = app:buttonBuilder({
    buttonName = "Collector_MAHListButton",
    parent = merchantFrameCost,
    text = "AH Track",
    width = 100,
    height = 22,
    point = {
        pos = "BOTTOMRIGHT",
        x = -8,
        y = 8,
    },
    onClickScript = function(self, button)
        if button == "LeftButton" then
            app.doAhTrack = true
            app:updateShop()
            app.ahFrame:Show()
            app.ahScrollableContent.UpdateRows(app.ahItems)
        end
    end
})
app.ahListButton = ahListButton

-- Scrollable content cost
app.mainScrollableContent = app:CreateScrollableContent({
    parent = merchantFrameCost,
    width = 280,
    height = 370,
    point = {
        pos = "TOPLEFT",
        x = 8,
        y = -37,
    }
})

-- ========================
-- Section: AH list
-- ========================

local ahFrame = app:frameBuilder({
    frameName = "CollectorHelper_MerchantSource_AH",
    parent = UIParent,
    width = 330,
    height = 400,
    point = {
        pos = "CENTER",
        x = 0,
        y = 0,
    },
    titleBuilder = {
        text = app:textCFormat(COLORS.yellow, "Collector Ah List"),
        point = {
            pos = "TOP",
            x = 0,
            y = -8,
        }
    }
})

-- Make the frame movable
ahFrame:SetMovable(true)
ahFrame:EnableMouse(true)
ahFrame:RegisterForDrag("LeftButton")
ahFrame:SetScript("OnDragStart", ahFrame.StartMoving)

ahFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

ahFrame:Hide()

-- Scrollable content for AH list
app.ahScrollableContent = app:CreateScrollableContent({
    parent = ahFrame,
    width = 280,
    height = 320,
    point = {
        pos = "TOPLEFT",
        x = 15,
        y = -37,
    }
})

-- Close button for AH frame
app:buttonBuilder({
    buttonName = "Collector_MAHCloseButton",
    parent = ahFrame,
    text = "Close",
    width = 100,
    height = 22,
    point = {
        pos = "BOTTOMRIGHT",
        x = -13,
        y = 8,
    },
    onClickScript = function(self, button)
        if button == "LeftButton" then
            app.ahFrame:Hide()
        end
    end
})

-- Clear list button for AH frame
app:buttonBuilder({
    buttonName = "Collector_MAHClearButton",
    parent = ahFrame,
    text = "Clear List",
    width = 100,
    height = 22,
    point = {
        pos = "BOTTOMLEFT",
        x = 13,
        y = 8,
    },
    onClickScript = function(self, button)
        if button == "LeftButton" then
            app.ahItems = {}
            app.ahScrollableContent.UpdateRows(app.ahItems)
        end
    end
})
app.ahFrame = ahFrame

-- ========================
-- Section: Other
-- ========================
app:buttonBuilder({
    buttonName = "Collector_MerchantToggle",
    parent = _G["MerchantFrameTab1"],
    text = "Toggle CH",
    width = 90,
    height = 25,
    point = {
        pos = "LEFT",
        x = 3,
        y = -28,
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
