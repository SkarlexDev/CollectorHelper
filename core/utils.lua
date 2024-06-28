local validEquipLocs = VALID_INV_TYPE

function extensiveTypeisValid(itemEquipLoc)
    return validEquipLocs[itemEquipLoc] or false
end

-- gold format display
function formatGoldAmount(val)
    -- Find the comma-separated number
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

function textCFormat(color,text)
    return "\124cn"..color..":"..text.."\124r"
end


-- Constructors

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
    return result
end


