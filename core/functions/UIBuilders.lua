local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- Helper: Configure Frame/Object Size and Position
-- ============================================================================
--- Sets dimensions and anchor point of a frame or region.
-- @param obj UIObject
-- @param params table: { width?, height?, point? }
function CollectorHelper:ConfigureFrame(obj, params)
    if params.width then obj:SetWidth(params.width) end
    if params.height then obj:SetHeight(params.height) end

    local p = params.point
    if p then
        obj:SetPoint(p.pos or "CENTER", p.x or 0, p.y or 0)
    else
        obj:SetPoint("CENTER", 0, 0)
    end
end

-- ============================================================================
-- UI: FontString Builder
-- ============================================================================
--- Creates a FontString on the parent with text and optional position.
-- @param params table: { parent, text?, point?, width?, height? }
-- @return FontString
function CollectorHelper:FontBuilder(params)
    local fs = params.parent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    self:ConfigureFrame(fs, params)
    fs:SetText(params.text or "")
    return fs
end

-- ============================================================================
-- UI: Frame Builder
-- ============================================================================
--- Creates a frame with backdrop, optional title, and anchor settings.
-- @param params table
-- @return Frame
function CollectorHelper:FrameBuilder(params)
    local f = CreateFrame("Frame", params.frameName, params.parent, "BackdropTemplate")
    self:ConfigureFrame(f, params)

    f:SetBackdrop({
        bgFile = params.bgFile or "Interface\\Buttons\\WHITE8x8",
        edgeFile = params.edgeFile or "Interface\\Buttons\\WHITE8x8",
        tileEdge = false,
        edgeSize = params.edgeSize or 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    f:SetBackdropColor(params.bgColorR or 0.05, params.bgColorG or 0.05, params.bgColorB or 0.05, params.bgAlpha or 0.95)
    f:SetBackdropBorderColor(0, 0, 0, 1)

    if params.titleBuilder then
        self:FontBuilder({
            parent = f,
            text = params.titleBuilder.text,
            point = params.titleBuilder.point,
        })
    end

    return f
end

-- ============================================================================
-- Internal: Apply ElvUI Skin if Available
-- ============================================================================
local function ApplyElvUISkin(button)
    if not ElvUI or type(ElvUI) ~= "table" or not ElvUI[1] then return end
    pcall(function()
        local E, S = ElvUI[1], ElvUI[1]:GetModule("Skins")
        if E.private and E.private.skins and E.private.skins.blizzard and E.private.skins.blizzard.enable and E.private.skins.blizzard.merchant then
            S:HandleButton(button)
        end
    end)
end

-- ============================================================================
-- UI: Insecure Button Builder
-- ============================================================================
--- Builds an insecure action button (e.g., item use), optionally skinned by ElvUI.
-- @param params table
-- @return Button
function CollectorHelper:ButtonBuilderInsecure(params)
    local b = CreateFrame("Button", params.buttonName, params.parent,
        "UIPanelButtonTemplate, InsecureActionButtonTemplate")
    b:RegisterForClicks("AnyUp", "AnyDown")
    b:SetAttribute("type", "item")

    self:ConfigureFrame(b, params)
    b:SetText(params.text or "")
    ApplyElvUISkin(b)

    return b
end

-- ============================================================================
-- UI: Standard Button Builder
-- ============================================================================
--- Creates a standard button with optional ElvUI skin and click handler.
-- @param params table
-- @return Button
function CollectorHelper:ButtonBuilder(params)
    local b = CreateFrame("Button", params.buttonName, params.parent, "UIPanelButtonTemplate")
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:SetText(params.text or "")

    self:ConfigureFrame(b, params)
    ApplyElvUISkin(b)

    if params.onClickScript then
        b:HookScript("OnClick", params.onClickScript)
    end

    return b
end

-- ============================================================================
-- Create a UI row frame for display in scrollable lists
-- Handles backdrop, button, text, and optional item details like percentage, quantity, and clear button.
-- ============================================================================
function CollectorHelper:CreateRow(index, item, data, params, scrollChild, UpdateRows)
    local row = CreateFrame("Frame", nil, scrollChild, "BackdropTemplate")
    row:SetSize(params.width, 20)
    row:SetPoint("TOPLEFT", params.xpos or 10, -(index - 1) * 22)

    -- Backdrop for the row
    row:SetBackdrop({
        bgFile = params.bgFile or "Interface\\Buttons\\WHITE8x8",
        edgeFile = params.edgeFile or "Interface\\Buttons\\WHITE8x8",
        tileEdge = false,
        edgeSize = params.edgeSize or 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    row:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    row:SetBackdropBorderColor(0, 0, 0, 1)

    -- Main clickable button within the row
    local btnP = CreateFrame("Button", nil, row, "BackdropTemplate")
    btnP:SetSize(params.width, 20)
    btnP:SetPoint("CENTER")

    btnP:RegisterForClicks("LeftButtonDown", "RightButtonDown")

    btnP:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = false,
        tileSize = 1,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)

    -- Hover highlight
    btnP:SetScript("OnEnter", function() row:SetBackdropColor(0.5, 0.5, 0.5, 1) end)
    btnP:SetScript("OnLeave", function() row:SetBackdropColor(0.05, 0.05, 0.05, 0.95) end)

    -- Click handler (example: print item link on left click)
    btnP:HookScript("OnClick", function(_, button)
        if button == "LeftButton" and item.linkItem then
            self:Print(item.linkItem)
        end
    end)

    -- ElvUI skin support (optional)
    ApplyElvUISkin(btnP)

    -- Text label for item display name
    local rowText = btnP:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rowText:SetPoint("LEFT", 2, 0)
    rowText:SetJustifyH("LEFT")
    rowText:SetText(item.display)

    -- Optional percentage display
    if item.percentage then
        local percentBtn = CreateFrame("Button", nil, btnP)
        percentBtn:SetSize(50, 20)
        percentBtn:SetPoint("RIGHT", 0, 0)

        local percentage = percentBtn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        percentage:SetPoint("LEFT", 5, 0)
        percentage:SetText(string.format("%.2f%%", item.percentage))
    end

    -- Optional quantity display
    if item.quantity then
        local qtyBtn = CreateFrame("Button", nil, btnP)
        qtyBtn:SetSize(35, 20)
        qtyBtn:SetPoint("RIGHT", 0, 0)

        local quantity = qtyBtn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        quantity:SetPoint("LEFT", 5, 0)
        quantity:SetText(tostring(item.quantity))
    end

    -- Optional clear button (Alt+click removes the item from data and updates rows)
    if item.clear then
        local clearBtn = CreateFrame("Button", nil, btnP)
        clearBtn:SetSize(20, 20)
        clearBtn:SetPoint("LEFT", -20, 0)

        local clearTexture = clearBtn:CreateTexture(nil, "ARTWORK")
        clearTexture:SetPoint("CENTER")
        clearTexture:SetTexture("Interface\\Buttons\\UI-StopButton")
        clearTexture:SetSize(25, 25)

        clearBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        clearBtn:SetScript("OnClick", function(_, button)
            if button == "LeftButton" and IsAltKeyDown() then
                table.remove(data, index)
                UpdateRows(data)
            end
        end)

        clearBtn:SetScript("OnEnter", function()
            row:SetBackdropColor(0.5, 0.5, 0.5, 1)
            GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)
            GameTooltip:SetText("Remove this item from AH shop list", 1, 1, 1)
            GameTooltip:AddLine("Alt + Click to remove", nil, nil, nil, true)
            GameTooltip:Show()
        end)

        clearBtn:SetScript("OnLeave", function()
            row:SetBackdropColor(0.102, 0.102, 0.102, 1)
            GameTooltip:Hide()
        end)
    end

    return row
end

-- ============================================================================
-- Create scrollable frame content with automatic row management
-- ============================================================================
function CollectorHelper:CreateScrollableContent(params)
    local sf = CreateFrame("ScrollFrame", nil, params.parent, "UIPanelScrollFrameTemplate")
    sf:SetSize(params.xwidth or params.width, params.height)
    sf:SetPoint(params.point.pos, params.point.x, params.point.y)

    local sc = CreateFrame("Frame", nil, sf)
    sc:SetSize(params.xwidth or params.width, 1) -- Initial height
    sf:SetScrollChild(sc)

    local rows = {}

    local function updateScroll(data)
        local height = #data * 21
        sc:SetHeight(height)
        if height + 10 > sf:GetHeight() then
            sf.ScrollBar:Show()
        else
            sf.ScrollBar:Hide()
        end
    end

    local function UpdateRows(data)
        -- Hide and clear old rows
        for _, row in ipairs(rows) do
            row:Hide()
            row:SetParent(nil)
        end
        rows = {}

        -- Create new rows for each item
        for i, item in ipairs(data) do
            rows[i] = self:CreateRow(i, item, data, params, sc, UpdateRows)
        end

        updateScroll(data)
    end

    return {
        scrollFrame = sf,
        UpdateRows = UpdateRows
    }
end
