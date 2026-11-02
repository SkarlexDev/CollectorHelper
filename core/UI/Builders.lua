local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

function CollectorHelper:ConfigureFrame(obj, params)
    if params.width ~= nil then obj:SetWidth(params.width) end
    if params.height ~= nil then obj:SetHeight(params.height) end

    obj:ClearAllPoints()
    if params.points then
        for _, point in ipairs(params.points) do
            obj:SetPoint(unpack(point))
        end
        return
    end

    local point = params.point
    if point then
        local position = point.pos or "CENTER"
        if point.relativeTo then
            obj:SetPoint(position, point.relativeTo, point.relativePoint or position, point.x or 0, point.y or 0)
        else
            obj:SetPoint(position, point.x or 0, point.y or 0)
        end
    else
        obj:SetPoint("CENTER", 0, 0)
    end
end

function CollectorHelper:FontBuilder(params)
    local fontString = params.parent:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    self:ConfigureFrame(fontString, params)
    fontString:SetText(params.text or "")
    return fontString
end

function CollectorHelper:FrameBuilder(params)
    local frame = CreateFrame("Frame", params.frameName, params.parent, "BackdropTemplate")
    self:ConfigureFrame(frame, params)

    frame:SetBackdrop({
        bgFile = params.bgFile or "Interface\\Buttons\\WHITE8x8",
        edgeFile = params.edgeFile or "Interface\\Buttons\\WHITE8x8",
        tileEdge = false,
        edgeSize = params.edgeSize or 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(params.bgColorR or 0.05, params.bgColorG or 0.05, params.bgColorB or 0.05, params.bgAlpha or 0.95)
    frame:SetBackdropBorderColor(0, 0, 0, 1)

    if params.titleBuilder then
        self:FontBuilder({
            parent = frame,
            text = params.titleBuilder.text,
            point = params.titleBuilder.point,
        })
    end

    return frame
end

function CollectorHelper:ApplyElvUISkin(button)
    if not ElvUI or type(ElvUI) ~= "table" or not ElvUI[1] then return end

    pcall(function()
        local engine = ElvUI[1]
        local skins = engine:GetModule("Skins")
        local merchantSkins = engine.private and engine.private.skins and engine.private.skins.blizzard
        if merchantSkins and merchantSkins.enable and merchantSkins.merchant then
            skins:HandleButton(button)
        end
    end)
end

function CollectorHelper:ButtonBuilder(params)
    local button = CreateFrame("Button", params.buttonName, params.parent, "UIPanelButtonTemplate")
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:SetText(params.text or "")

    self:ConfigureFrame(button, params)
    self:ApplyElvUISkin(button)

    if params.onClickScript then
        button:HookScript("OnClick", params.onClickScript)
    end

    return button
end

function CollectorHelper:SliderBuilder(params)
    local slider = CreateFrame("Slider", params.sliderName, params.parent, "OptionsSliderTemplate")
    self:ConfigureFrame(slider, params)

    local min = params.min or 1
    local max = params.max or 20
    local value = params.value or min

    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(params.step or 1)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(value)

    _G[slider:GetName() .. "Low"]:SetText(tostring(min))
    _G[slider:GetName() .. "High"]:SetText(tostring(max))
    _G[slider:GetName() .. "Text"]:SetText(params.label or "")

    local valueText
    if params.valueDisplay then
        valueText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        valueText:SetPoint("BOTTOM", slider, "BOTTOM", 0, -9)
        valueText:SetText(tostring(value))
    end

    slider:SetScript("OnValueChanged", function(self, newValue)
        newValue = math.floor(newValue + 0.5)

        if valueText then
            valueText:SetText(tostring(newValue))
        end

        if params.onValueChanged then
            params.onValueChanged(self, newValue)
        end
    end)

    return slider
end
