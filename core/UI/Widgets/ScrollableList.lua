local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local ROW_HEIGHT = 20
local ROW_GAP = 2
local ROW_SPACING = ROW_HEIGHT + ROW_GAP
local DEFAULT_ROW_COLOR = { 0.05, 0.05, 0.05, 0.95 }
local DEFAULT_HOVER_COLOR = { 0.5, 0.5, 0.5, 1 }
local DEFAULT_BUTTON_COLOR = { 0.102, 0.102, 0.102, 1 }
local DEFAULT_BORDER_COLOR = { 0, 0, 0, 1 }
local DEFAULT_ACCENT_COLOR = { 0.5, 0.5, 0.5, 1 }

---@class CollectorHelper.ScrollableContentPoint
---@field pos string
---@field x number
---@field y number

---@class CollectorHelper.ScrollableContentParams
---@field parent Frame
---@field point CollectorHelper.ScrollableContentPoint
---@field width number
---@field height number
---@field xwidth? number
---@field xpos? number
---@field bgFile? string
---@field edgeFile? string
---@field edgeSize? number
---@field modernScrollBar? boolean
---@field themeColors? table

---@class CollectorHelper.ScrollableContent
---@field scrollFrame ScrollFrame
---@field UpdateRows fun(data: table)

function CollectorHelper:CreateRow(index, item, data, params, scrollChild, updateRows)
    local themeColors = params.themeColors
    local rowColor = themeColors and themeColors.panelRaised or DEFAULT_ROW_COLOR
    local rowHoverColor = themeColors and themeColors.panelHover or DEFAULT_HOVER_COLOR
    local buttonColor = themeColors and themeColors.panel or DEFAULT_BUTTON_COLOR
    local borderColor = themeColors and themeColors.border or DEFAULT_BORDER_COLOR
    local accentColor = themeColors and themeColors.accent or DEFAULT_ACCENT_COLOR

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
    row:SetBackdropBorderColor(unpack(borderColor))

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
    button:SetBackdropBorderColor(unpack(borderColor))

    local currentItem, currentData, currentIndex
    local function setRowColor(red, green, blue, alpha)
        row:SetBackdropColor(red, green, blue, alpha)
    end

    button:SetScript("OnEnter", function()
        setRowColor(unpack(rowHoverColor))
        button:SetBackdropColor(unpack(rowHoverColor))
        button:SetBackdropBorderColor(unpack(accentColor))
    end)
    button:SetScript("OnLeave", function()
        setRowColor(unpack(rowColor))
        button:SetBackdropColor(unpack(buttonColor))
        button:SetBackdropBorderColor(unpack(borderColor))
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

    row.Reset = function(self)
        currentItem = nil
        currentData = nil
        currentIndex = nil
        label:SetText("")
        percentageText:SetText("")
        quantityText:SetText("")
        percentageButton:Hide()
        quantityButton:Hide()
        clearButton:Hide()
        setRowColor(unpack(rowColor))
        button:SetBackdropColor(unpack(buttonColor))
        button:SetBackdropBorderColor(unpack(borderColor))
        self:Hide()
    end

    row:UpdateItem(index, item, data)
    return row
end

---@param params CollectorHelper.ScrollableContentParams
---@return CollectorHelper.ScrollableContent
function CollectorHelper:CreateScrollableContent(params)
    assert(type(params) == "table", "CreateScrollableContent expects a parameter table")
    assert(params.parent, "CreateScrollableContent requires a parent frame")
    assert(params.point and params.point.pos, "CreateScrollableContent requires a point")
    assert(type(params.width) == "number" and params.width > 0, "CreateScrollableContent requires a positive width")
    assert(type(params.height) == "number" and params.height > 0, "CreateScrollableContent requires a positive height")

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
    local currentData = {}
    local lastFirstIndex
    local updateRows

    local function updateScrollBar()
        if params.modernScrollBar then
            scrollFrame:RequestModernScrollBarUpdate()
        elseif #currentData * ROW_SPACING + 10 > scrollFrame:GetHeight() then
            scrollFrame.ScrollBar:Show()
        else
            scrollFrame.ScrollBar:Hide()
        end
    end

    local function clampScrollPosition()
        local maxScroll = math.max(0, #currentData * ROW_SPACING - scrollFrame:GetHeight())
        local scrollOffset = math.max(0, math.min(scrollFrame:GetVerticalScroll(), maxScroll))
        if scrollFrame:GetVerticalScroll() ~= scrollOffset then
            scrollFrame:SetVerticalScroll(scrollOffset)
        end
    end

    local function renderVisibleRows(force)
        local firstIndex = math.max(1, math.floor(scrollFrame:GetVerticalScroll() / ROW_SPACING))
        if not force and firstIndex == lastFirstIndex then return end
        lastFirstIndex = firstIndex

        local dataCount = #currentData
        local visibleRowCount = math.min(
            dataCount,
            math.ceil(scrollFrame:GetHeight() / ROW_SPACING) + 2
        )
        for slot = 1, visibleRowCount do
            local itemIndex = firstIndex + slot - 1
            local item = currentData[itemIndex]
            local row = rows[slot]
            if not row then
                row = CollectorHelper:CreateRow(
                    itemIndex,
                    item,
                    currentData,
                    params,
                    scrollChild,
                    updateRows
                )
                rows[slot] = row
            elseif item then
                row:UpdateItem(itemIndex, item, currentData)
            else
                row:Reset()
            end
        end

        for slot = visibleRowCount + 1, #rows do
            rows[slot]:Reset()
        end
    end

    updateRows = function(data)
        assert(type(data) == "table", "UpdateRows expects a table")
        currentData = data

        local contentHeight = #data * ROW_SPACING
        scrollChild:SetHeight(math.max(contentHeight, 1))
        scrollFrame:UpdateScrollChildRect()
        clampScrollPosition()

        lastFirstIndex = nil
        renderVisibleRows(true)
        updateScrollBar()
    end

    scrollFrame:HookScript("OnVerticalScroll", function()
        renderVisibleRows(false)
    end)
    scrollFrame:HookScript("OnSizeChanged", function()
        clampScrollPosition()
        lastFirstIndex = nil
        renderVisibleRows(true)
        updateScrollBar()
    end)

    if params.modernScrollBar then
        self:CreateModernScrollBar(scrollFrame)
    end

    return {
        scrollFrame = scrollFrame,
        UpdateRows = updateRows,
    }
end
