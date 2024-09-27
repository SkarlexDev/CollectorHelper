local _, app = ...

-- Retrieves item details based on item ID
---@param itemInfo number
---@return App.ItemDetails
function app:getItemDetails(itemInfo)
    C_Item.RequestLoadItemDataByID(itemInfo)
    local name, link, quality, _, _, type, _, _, equipLoc, _, _, _, _, bindType = C_Item.GetItemInfo(itemInfo)

    return {
        itemId = itemInfo,
        name = name,
        link = link,
        itemType = type,
        itemEquipLoc = equipLoc,
        bindType = bindType,
        itemQuality = quality
    }
end

-- Creates a scrollable content frame with specified parameters
---@param params App.CustomScrollBuilder
---@param CreateRow ScriptObject
function app:CreateScrollableContent(params, CreateRow)
    local sf = CreateFrame("ScrollFrame", nil, params.parent, "UIPanelScrollFrameTemplate")
    sf:SetSize(params.width, params.height)
    sf:SetPoint(params.point.pos, params.point.x, params.point.y)

    local sc = CreateFrame("Frame", nil, sf)
    sc:SetSize(params.width, 1)
    sf:SetScrollChild(sc)

    local rows = {}

    local function updateScroll(data)
        sc:SetHeight(#data * 21) -- Adjust scroll height based on rows
        if sc:GetHeight() + 10 > sf:GetHeight() then
            sf.ScrollBar:Show()
        else
            sf.ScrollBar:Hide()
        end
    end

    -- Function to update rows in the scrollable content
    local function UpdateRows(data)
        -- Clear existing rows
        for _, row in ipairs(rows) do
            row:Hide()
            row:SetParent(nil)
            row = nil
        end
        rows = {}

        -- Create new rows
        for i, item in ipairs(data) do
            rows[i] = CreateRow(i, item, data, params, sc, UpdateRows)
        end
        updateScroll(data)
    end

    -- Return the scrollable content and its update function
    return {
        scrollFrame = sf,
        UpdateRows = UpdateRows
    }
end
