local _, app = ...

-- Formats the given gold amount string into a more readable format (K for thousands, M for millions)
--- @param val string
--- @return string
function app:formatGoldAmount(val)
    local commaSepNr = val:match("(%d[%d,]*%d)")
    if not commaSepNr then
        return val
    end
    local number = commaSepNr:gsub(",", "")
    local commaCount = select(2, commaSepNr:gsub(",", ""))
    local formattedGold
    if commaCount == 1 then
        -- Convert to thousands (K)
        formattedGold = string.format("%.0fK", tonumber(number) / 1000)
    elseif commaCount == 2 then
        -- Convert to millions (M)
        formattedGold = string.format("%.2fM", tonumber(number) / 1000000)
    else
        formattedGold = number
    end
    local result = val:gsub(commaSepNr, formattedGold)
    return result
end

-- Formats text with the specified color
--- @param color string
--- @param text string
--- @return string
function app:textCFormat(color, text)
    return "\124cn" .. color .. ":" .. text .. "\124r"
end

-- Retrieves item details based on item ID
---@param itemInfo number
---@return CH.ItemDetails
function app:getItemDetails(itemInfo)
    C_Item.RequestLoadItemDataByID(itemInfo)
    local itemName, itemLink, itemQuality, _, _, itemType, _, _, itemEquipLoc, _, _, _, _, bindType = C_Item.GetItemInfo(
    itemInfo)

    local result = {
        itemId = itemInfo,
        name = itemName,
        link = itemLink,
        itemType = itemType,
        itemEquipLoc = itemEquipLoc,
        bindType = bindType,
        itemQuality = itemQuality
    }
    return result
end

-- ========================
-- Section: Constructors
-- ========================

-- Creates a font string with specified parameters
---@param params CH.CustomFontConstructorOptions
---@return FontString
function app:fontBuilder(params)
    local result = params.parent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    result:SetPoint(params.point.pos, params.point.x, params.point.y)
    result:SetText(params.text)
    return result
end

-- Creates a frame with specified parameters
---@param params CH.CustomFrameConstructorOptions
---@return BackdropTemplate|Frame
function app:frameBuilder(params)
    local result = CreateFrame("Frame", params.frameName, params.parent, "BackdropTemplate")
    result:SetWidth(params.width)
    result:SetHeight(params.height)
    result:SetPoint(params.point.pos, params.point.x, params.point.y)

    result:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tileEdge = false,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    result:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    result:SetBackdropBorderColor(0, 0, 0, 1)

    -- Create frame title text
    if params.titleBuilder then
        app:fontBuilder({
            parent = result,
            text = params.titleBuilder.text,
            point = params.titleBuilder.point
        })
    end
    return result
end

-- Creates a button with specified parameters
---@param params CH.CustomButtonConstructorOptions
---@return Button|UIPanelButtonTemplate
function app:buttonBuilder(params)
    local result = CreateFrame("Button", params.buttonName, params.parent, "UIPanelButtonTemplate")
    result:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    result:SetText(params.text)
    result:SetWidth(params.width)
    result:SetHeight(params.height)
    result:SetPoint(params.point.pos, params.point.x, params.point.y)

    -- Skin for ElvUI
    pcall(function()
        local E = ElvUI[1]
        local S = E:GetModule("Skins")
        if E.private.skins.blizzard.enable and E.private.skins.blizzard.merchant then
            S:HandleButton(result)
        end
    end)

    if params.onClickScript then
        result:HookScript("OnClick", params.onClickScript)
    end

    return result
end

-- Creates a scrollable content frame with specified parameters
---@param params CH.CustomScrollBuilder
function app:CreateScrollableContent(params)
    local scrollFrame = CreateFrame("ScrollFrame", nil, params.parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(params.width, params.height)
    scrollFrame:SetPoint(params.point.pos, params.point.x, params.point.y)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(params.width, 1)
    scrollFrame:SetScrollChild(scrollChild)
    local UpdateRows
    local rows = {}

    -- Function to create a row in the scrollable content
    local function CreateRow(index, item, data)
        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetSize(params.width, 20)
        row:SetPoint("TOPLEFT", 10, -(index - 1) * 21)

        local btnP = CreateFrame("Button", nil, row)
        btnP:RegisterForClicks("LeftButtonDown", "RightButtonDown")
        btnP:SetWidth(params.width - 20)
        btnP:SetHeight(20)
        btnP:SetPoint("CENTER", 0, 0)

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
                    table.remove(data, index)  -- Remove item from data at index
                    UpdateRows(data)  -- Rebuild rows with updated data
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

    local function updateScroll(data)
        -- Adjust scrollChild height based on number of rows
        scrollChild:SetHeight(#data * 21) -- 25
        if scrollChild:GetHeight() + 10 > scrollFrame:GetHeight() then
            scrollFrame.ScrollBar:Show()
        else
            scrollFrame.ScrollBar:Hide()
        end
    end

    -- Function to update rows in the scrollable content
    UpdateRows = function(data)
        -- Clear existing rows
        for i, row in ipairs(rows) do
            row:Hide()
            row:SetParent(nil)
            row = nil
        end
        rows = {}

        -- Create new rows
        for i, item in ipairs(data) do
            rows[i] = CreateRow(i, item, data)
        end
        updateScroll(data)
    end

    -- Return the scrollable content and its update function
    return {
        scrollFrame = scrollFrame,
        UpdateRows = UpdateRows
    }
end

