-- gold format display
function formatGoldAmount(val)
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

function textCFormat(color, text)
    return "\124cn" .. color .. ":" .. text .. "\124r"
end

function getItemDetails(itemInfo)
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
function fontBuilder(params)
    local result = params.parent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    result:SetPoint(params.point.pos, params.point.x, params.point.y)
    result:SetText(params.text)
    return result
end

---@param params CH.CustomFrameConstructorOptions
function frameBuilder(params)
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
        fontBuilder({
            parent = result,
            text = params.titleBuilder.text,
            point = params.titleBuilder.point
        })
    end
    return result
end

---@param params CH.CustomButtonConstructorOptions
function buttonBuilder(params)
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

    return result
end
