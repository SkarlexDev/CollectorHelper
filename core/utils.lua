local _, app = ...

-- gold format display
--- @param val string
--- @return string
function app:formatGoldAmount(val)
    local commaSepNr = val:match("(%d[%d,]*%d)")
    if not commaSepNr then
        return val
    end
    local number = commaSepNr:gsub(",", "")
    local commaCount = select(2, commaSepNr:gsub(",", ""))
    local formatedGold
    if commaCount == 1 then
        -- Convert to thousands (K)
        formatedGold = string.format("%.0fK", tonumber(number) / 1000)
    elseif commaCount == 2 then
        -- Convert to millions (M)
        formatedGold = string.format("%.2fM", tonumber(number) / 1000000)
    else
        formatedGold = number
    end
    local result = val:gsub(commaSepNr, formatedGold)
    return result
end

--- Formats text with the specified color
--- @param color string
--- @param text string 
--- @return string 
function app:textCFormat(color, text)
    return "\124cn" .. color .. ":" .. text .. "\124r"
end


---@param itemInfo number
---@return CH.ItemDetails
function app:getItemDetails(itemInfo)
    C_Item.RequestLoadItemDataByID(itemInfo)
    local itemName, itemLink, _, _, _, itemType, _, _, itemEquipLoc, _, _, _, _, bindType = C_Item.GetItemInfo(itemInfo)
    local result = {
        itemId = itemInfo,
        name = itemName,
        link = itemLink,
        itemType = itemType,
        itemEquipLoc = itemEquipLoc,
        bindType = bindType,
    }
    return result
end

-- ========================
-- Section: Constructors
-- ========================

---@param params CH.CustomFontConstructorOptions
---@return FontString
function app:fontBuilder(params)
    local result = params.parent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    result:SetPoint(params.point.pos, params.point.x, params.point.y)
    result:SetText(params.text)
    return result
end

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
    -- create frame title text
    if params.titleBuilder ~= nil then
        app:fontBuilder({
            parent = result,
            text = params.titleBuilder.text,
            point = params.titleBuilder.point
        })
    end
    return result
end

---@param params CH.CustomButtonConstructorOptions
---@return Button|UIPanelButtonTemplate
function app:buttonBuilder(params)
    local result = CreateFrame("Button", params.buttonName, params.parent, "UIPanelButtonTemplate")
    result:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    result:SetText(params.text)
    result:SetWidth(params.width)
    result:SetHeight(params.height)
    result:SetPoint(params.point.pos, params.point.x, params.point.y)

    -- Skin for ElvUI.
    pcall(function(result)
        local E = ElvUI[1]
        local S = E:GetModule("Skins")
        if E.private.skins.blizzard.enable and E.private.skins.blizzard.merchant then
            S:HandleButton(result)
        end
    end, result)
    if params.onClickScript then
        result:HookScript("OnClick", params.onClickScript)
    end

    return result
end



function app:CreateScrollableContent(parentFrame)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(250, 370)
    scrollFrame:SetPoint("TOPLEFT", 8, -37)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(250, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local rows = {}

    local function CreateRow(index, item)
        local row = CreateFrame("Frame", nil, scrollChild)
        row:SetSize(250, 20)
        row:SetPoint("TOPLEFT", 10, -(index - 1) * 25)

        local rowText = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rowText:SetPoint("LEFT")
        rowText:SetText(item.display)

        row:SetScript("OnEnter", function()
            GameTooltip:SetOwner(parentFrame, "ANCHOR_RIGHT", 0, -34)
            GameTooltip:SetText(item.display, 1, 1, 1)
            if item.linkItem ~= nil then
                GameTooltip:SetHyperlink(item.linkItem)
            else
                GameTooltip:AddLine(item.description, nil, nil, nil, true)
            end
            GameTooltip:Show()
        end)

        row:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)

        return row
    end

    local function UpdateRows(data)
        -- Clear existing rows
        for i, row in ipairs(rows) do
            row:Hide()
            rows[i] = nil
        end

        -- Create new rows
        for i, item in ipairs(data) do
            rows[i] = CreateRow(i, item)
        end

        -- Adjust scrollChild height based on number of rows
        scrollChild:SetHeight(#data * 25)
    end

    -- Return the scrollable content and its update function
    return {
        scrollFrame = scrollFrame,
        UpdateRows = UpdateRows
    }
end