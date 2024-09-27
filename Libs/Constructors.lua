local _, app = ...

--- Utility function to configure frame/object dimensions and position.
--- @param obj UIObject
--- @param params table
function app:configureFrame(obj, params)
    if params.width then obj:SetWidth(params.width) end
    if params.height then obj:SetHeight(params.height) end
    obj:SetPoint(params.point.pos or "CENTER", params.point.x or 0, params.point.y or 0)
end

--- Creates and configures a FontString.
--- @param params table
--- @return FontString
function app:fontBuilder(params)
    local fs = params.parent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    self:configureFrame(fs, params)
    fs:SetText(params.text or "")
    return fs
end

--- Creates and configures a Frame with a backdrop and optional title.
--- @param params table
--- @return Frame|BackdropTemplate
function app:frameBuilder(params)
    local f = CreateFrame("Frame", params.frameName, params.parent, "BackdropTemplate")

    self:configureFrame(f, params)

    -- Set backdrop properties with defaults
    f:SetBackdrop({
        bgFile = params.bgFile or "Interface\\Buttons\\WHITE8x8",
        edgeFile = params.edgeFile or "Interface\\Buttons\\WHITE8x8",
        tileEdge = false,
        edgeSize = params.edgeSize or 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    f:SetBackdropColor(params.bgColorR or 0.05, params.bgColorG or 0.05, params.bgColorB or 0.05, params.bgAlpha or 0.95)
    f:SetBackdropBorderColor(0, 0, 0, 1)

    if params.titleBuilder then
        self:fontBuilder({
            parent = f,
            text = params.titleBuilder.text,
            point = params.titleBuilder.point
        })
    end

    return f
end

--- Creates and configures a Button with optional ElvUI skinning.
--- @param params table
--- @return Button|UIPanelButtonTemplate
function app:buttonBuilder(params)
    local b = CreateFrame("Button", params.buttonName, params.parent, "UIPanelButtonTemplate")
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    b:SetText(params.text or "")
    self:configureFrame(b, params)

    -- Optional ElvUI skinning
    if ElvUI then
        pcall(function()
            local E, S = ElvUI[1], ElvUI[1]:GetModule("Skins")
            if E.private.skins.blizzard.enable and E.private.skins.blizzard.merchant then
                S:HandleButton(b)
            end
        end)
    end

    -- Attach OnClick script if provided
    if params.onClickScript then
        b:HookScript("OnClick", params.onClickScript)
    end

    return b
end