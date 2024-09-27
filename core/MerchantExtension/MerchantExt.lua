local _, app = ...

local COLORS = app.COLORS

-- Function to create a row in the scrollable content
local function CreateRow(index, item, data, params, scrollChild, UpdateRows)
    local row = CreateFrame("Frame", nil, scrollChild)
    row:SetSize(params.width, 20)
    row:SetPoint("TOPLEFT", 10, -(index - 1) * 21)

    -- Create button with BackdropTemplate
    local btnP = CreateFrame("Button", nil, row, "BackdropTemplate")
    btnP:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    btnP:SetWidth(params.width - 20)
    btnP:SetHeight(20)
    btnP:SetPoint("CENTER", 0, 0)

    -- Add a default backdrop to the button
    btnP:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)

    -- Skin for ElvUI
    pcall(function()
        local E = ElvUI[1]
        local S = E:GetModule("Skins")
        if E.private.skins.blizzard.enable and E.private.skins.blizzard.merchant then
            S:HandleButton(btnP)
        end
    end)

    local rowText = btnP:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rowText:SetJustifyH("LEFT")
    rowText:SetPoint("LEFT")
    rowText:SetText(item.display)

    -- Additional item details (percentage, quantity, clear button)
    if item.percentage then
        local btn = CreateFrame("Button", nil, btnP)
        btn:SetWidth(50)
        btn:SetHeight(20)
        btn:SetPoint("RIGHT", 0, 0)

        local percentage = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        percentage:SetPoint("LEFT")
        percentage:SetText(string.format("%.2f%%", item.percentage))

        btn:SetScript("OnEnter", function()
            btnP:SetBackdropColor(0.5, 0.5, 0.5, 1) -- Light gray highlight
            GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)
            GameTooltip:SetText(item.display, 1, 1, 1)
            if item.linkItem then
                GameTooltip:SetHyperlink(item.linkItem)
            else
                GameTooltip:AddLine(item.tooltip, nil, nil, nil, true)
            end
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function()
            btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)
            GameTooltip:Hide()
        end)
    end

    if item.quantity then
        local btn = CreateFrame("Button", nil, btnP)
        btn:SetWidth(35)
        btn:SetHeight(20)
        btn:SetPoint("RIGHT", 0, 0)

        local quantity = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        quantity:SetPoint("LEFT")
        quantity:SetText(item.quantity)

        btn:SetScript("OnEnter", function()
            btnP:SetBackdropColor(0.5, 0.5, 0.5, 1) -- Light gray highlight
            GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)
            GameTooltip:SetText(item.display, 1, 1, 1)
            if item.linkItem then
                GameTooltip:SetHyperlink(item.linkItem)
            else
                GameTooltip:AddLine(item.tooltip, nil, nil, nil, true)
            end
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function()
            btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)
            GameTooltip:Hide()
        end)
    end

    if item.clear then
        local btn = CreateFrame("Button", nil, btnP)
        btn:SetWidth(20)
        btn:SetHeight(20)
        btn:SetPoint("LEFT", -20, 0)

        local clear = btn:CreateTexture(nil, "ARTWORK")
        clear:SetPoint("CENTER")
        clear:SetTexture("interface\\buttons\\ui-stopbutton")
        clear:SetSize(25, 25)

        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        btn:HookScript("OnClick", function(self, button)
            if button == "LeftButton" and IsAltKeyDown() then
                table.remove(data, index) -- Remove item from data at index
                UpdateRows(data)          -- Rebuild rows with updated data
            end
        end)

        btn:SetScript("OnEnter", function()
            btnP:SetBackdropColor(0.5, 0.5, 0.5, 1) -- Light gray highlight
            GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)
            GameTooltip:SetText("Remove this item from AH shop list", 1, 1, 1)
            GameTooltip:AddLine("Alt + Click to remove", nil, nil, nil, true)
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function()
            btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)
            GameTooltip:Hide()
        end)
    end

    btnP:SetScript("OnEnter", function()
        btnP:SetBackdropColor(0.5, 0.5, 0.5, 1) -- Light gray highlight
        GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)

        GameTooltip:SetText(item.display, 1, 1, 1)
        if item.linkItem then
            GameTooltip:SetHyperlink(item.linkItem)
        else
            --GameTooltip:AddLine(item.display, nil, nil, nil, true)
        end
        GameTooltip:Show()
    end)

    btnP:HookScript("OnClick", function(_, button)
        if button == "LeftButton" then
            if item.linkItem then
                print(item.linkItem)
            end
        end
    end)

    btnP:SetScript("OnLeave", function()
        btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)
        GameTooltip:Hide()
    end)

    return row
end


function app:InitMerchantUI()
    -- Merchant frame extension
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

    -- Completed message font
    app.merchantCost = app:fontBuilder({
        parent = merchantFrameCost,
        text = app:textCFormat(COLORS.green, "You have everything on this merchant"),
        point = {
            pos = "CENTER",
            x = 0,
            y = 80,
        }
    })

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
    }, CreateRow)

    -- ========================
    -- Section: Merchant Action buttons
    -- ========================
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
        onClickScript = function(_, button)
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


    hooksecurefunc("MerchantFrame_Update", function() app:updateShop() end)
    MerchantNextPageButton:HookScript("OnClick", function() app:updateShop() end)
    MerchantPrevPageButton:HookScript("OnClick", function() app:updateShop() end)

    app:InitMerchantUIAH()
    if settings.showCostFrame == false then
        app.merchantFrameCost:Hide()
    end
end

function app:InitMerchantUIAH()
    local merchantFrameCost = app.merchantFrameCost

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

    -- Merchant frame AH extension
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
    },CreateRow)

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
        onClickScript = function(_, button)
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
        onClickScript = function(_, button)
            if button == "LeftButton" then
                app.ahItems = {}
                app.ahScrollableContent.UpdateRows(app.ahItems)
            end
        end
    })
    app.ahFrame = ahFrame
end
