local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local ROW_HEIGHT = 20
local ROW_SPACING = 22

function CollectorHelper:CreateRow(index, item, data, params, scrollChild, updateRows)
    local themeColors = params.themeColors
    local rowColor = themeColors and themeColors.panelRaised or { 0.05, 0.05, 0.05, 0.95 }
    local rowHoverColor = themeColors and themeColors.panelHover or { 0.5, 0.5, 0.5, 1 }
    local buttonColor = themeColors and themeColors.panel or { 0.102, 0.102, 0.102, 1 }

    local row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
    row:SetSize(params.width, ROW_HEIGHT)

    row:SetBackdrop({
        bgFile = params.bgFile or "Interface\\Buttons\\WHITE8x8",
        edgeFile = params.edgeFile or "Interface\\Buttons\\WHITE8x8",
        tileEdge = false,
        edgeSize = params.edgeSize or 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    row:SetBackdropColor(unpack(rowColor))
    row:SetBackdropBorderColor(unpack(themeColors and themeColors.border or { 0, 0, 0, 1 }))

    local button = CreateFrame("Button", nil, row, "BackdropTemplate")
    button:SetSize(params.width, ROW_HEIGHT)
    button:SetPoint("CENTER")
    button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    button:SetBackdrop({
        bgFile = themeColors and "Interface\\Buttons\\WHITE8x8"
            or "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = themeColors and "Interface\\Buttons\\WHITE8x8"
            or "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = false,
        tileSize = 1,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    button:SetBackdropColor(unpack(buttonColor))
    button:SetBackdropBorderColor(unpack(themeColors and themeColors.border or { 0, 0, 0, 1 }))

    local currentItem, currentData, currentIndex
    local function setRowColor(red, green, blue, alpha)
        row:SetBackdropColor(red, green, blue, alpha)
    end

    button:SetScript("OnEnter", function()
        setRowColor(unpack(rowHoverColor))
        button:SetBackdropColor(unpack(rowHoverColor))
        button:SetBackdropBorderColor(unpack(themeColors and themeColors.accent or { 0.5, 0.5, 0.5, 1 }))
    end)
    button:SetScript("OnLeave", function()
        setRowColor(unpack(rowColor))
        button:SetBackdropColor(unpack(buttonColor))
        button:SetBackdropBorderColor(unpack(themeColors and themeColors.border or { 0, 0, 0, 1 }))
    end)
    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" and currentItem and currentItem.linkItem then
            CollectorHelper:Print(currentItem.linkItem)
        end
    end)
    if not themeColors then
        CollectorHelper:ApplyElvUISkin(button)
    end

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", 2, 0)
    label:SetJustifyH("LEFT")
    if themeColors then
        label:SetTextColor(unpack(themeColors.text))
    end

    local percentageButton = CreateFrame("Button", nil, button)
    percentageButton:SetSize(50, ROW_HEIGHT)
    percentageButton:SetPoint("RIGHT", 0, 0)
    percentageButton:EnableMouse(false)
    local percentageText = percentageButton:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    percentageText:SetPoint("LEFT", 5, 0)
    if themeColors then
        percentageText:SetTextColor(unpack(themeColors.text))
    end

    local quantityButton = CreateFrame("Button", nil, button)
    quantityButton:SetSize(35, ROW_HEIGHT)
    quantityButton:SetPoint("RIGHT", 0, 0)
    quantityButton:EnableMouse(false)
    local quantityText = quantityButton:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    quantityText:SetPoint("LEFT", 5, 0)
    if themeColors then
        quantityText:SetTextColor(unpack(themeColors.text))
    end

    local clearButton = CreateFrame("Button", nil, button)
    clearButton:SetSize(20, ROW_HEIGHT)
    clearButton:SetPoint("LEFT", -20, 0)
    clearButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    local clearTexture = clearButton:CreateTexture(nil, "ARTWORK")
    clearTexture:SetPoint("CENTER")
    clearTexture:SetTexture("Interface\\Buttons\\UI-StopButton")
    clearTexture:SetSize(25, 25)
    clearButton:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" and IsAltKeyDown() and currentData and currentIndex then
            table.remove(currentData, currentIndex)
            updateRows(currentData)
        end
    end)
    clearButton:SetScript("OnEnter", function()
        setRowColor(unpack(rowHoverColor))
        GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)
        GameTooltip:SetText("Remove this item from AH shop list", 1, 1, 1)
        GameTooltip:AddLine("Alt + Click to remove", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    clearButton:SetScript("OnLeave", function()
        setRowColor(unpack(rowColor))
        GameTooltip:Hide()
    end)

    row.UpdateItem = function(self, rowIndex, rowItem, rowData)
        currentItem = rowItem
        currentData = rowData
        currentIndex = rowIndex

        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", params.xpos or 10, -(rowIndex - 1) * ROW_SPACING)
        label:SetText(rowItem.display or "")

        if rowItem.percentage ~= nil then
            percentageText:SetText(string.format("%.2f%%", rowItem.percentage))
            percentageButton:Show()
        else
            percentageButton:Hide()
        end

        if rowItem.quantity ~= nil then
            quantityText:SetText(tostring(rowItem.quantity))
            quantityButton:Show()
        else
            quantityButton:Hide()
        end

        clearButton:SetShown(rowItem.clear == true)
        self:Show()
    end

    row:UpdateItem(index, item, data)
    return row
end

function CollectorHelper:CreateScrollableContent(params)
    local scrollFrame
    if params.modernScrollBar then
        scrollFrame = CreateFrame("ScrollFrame", nil, params.parent)
    else
        scrollFrame = CreateFrame("ScrollFrame", nil, params.parent, "UIPanelScrollFrameTemplate")
    end
    local width = params.xwidth or params.width
    scrollFrame:SetSize(width, params.height)
    scrollFrame:SetPoint(params.point.pos, params.point.x, params.point.y)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(width, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local rows = {}

    local function updateRows(data)
        for index = 1, #data do
            local row = rows[index]
            if not row then
                row = CollectorHelper:CreateRow(index, data[index], data, params, scrollChild, updateRows)
                rows[index] = row
            else
                row:UpdateItem(index, data[index], data)
            end
        end

        for index = #data + 1, #rows do
            rows[index]:Hide()
        end

        local height = #data * ROW_SPACING
        scrollChild:SetHeight(math.max(height, 1))
        if params.modernScrollBar then
            scrollFrame.UpdateModernScrollBar()
            C_Timer.After(0, function()
                if scrollFrame.UpdateModernScrollBar then
                    scrollFrame.UpdateModernScrollBar()
                end
            end)
        else
            if height + 10 > scrollFrame:GetHeight() then
                scrollFrame.ScrollBar:Show()
            else
                scrollFrame.ScrollBar:Hide()
            end
        end
    end

    if params.modernScrollBar then
        self:CreateModernScrollBar(scrollFrame)
    end

    return {
        scrollFrame = scrollFrame,
        UpdateRows = updateRows,
    }
end
