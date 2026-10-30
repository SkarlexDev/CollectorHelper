local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local MINIMAP_ICON_NAME = "CollectorHelper"
local MINIMAP_ICON_TEXTURE = "Interface\\AddOns\\CollectorHelper\\core\\Media\\Textures\\Logo"

function CollectorHelper:InitMinimapButton()
    local broker = LibStub("LibDataBroker-1.1")
    local minimapIcons = LibStub("LibDBIcon-1.0")
    local dataObject = broker:GetDataObjectByName(MINIMAP_ICON_NAME)

    if not dataObject then
        dataObject = broker:NewDataObject(MINIMAP_ICON_NAME, {
            type = "launcher",
            text = "CollectorHelper",
            icon = MINIMAP_ICON_TEXTURE,
            OnClick = function(_, mouseButton)
                if mouseButton == "RightButton" then
                    self:ToggleDashboard("settings")
                else
                    self:ToggleDashboard()
                end
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine("CollectorHelper")
                tooltip:AddLine("Click to open the collection dashboard.", 1, 1, 1)
                tooltip:AddLine("Right-click to open preferences.", 1, 1, 1)
            end,
        })
    end

    if not minimapIcons:IsRegistered(MINIMAP_ICON_NAME) then
        minimapIcons:Register(MINIMAP_ICON_NAME, dataObject, settings)
    end

    self.minimapDBIcon = minimapIcons
    self.minimapButton = minimapIcons:GetMinimapButton(MINIMAP_ICON_NAME)
    self:UpdateMinimapButtonVisibility()
end

function CollectorHelper:UpdateMinimapButtonVisibility()
    if not self.minimapDBIcon then return end

    settings.hide = settings.showMinimapButton == false
    if settings.hide then
        self.minimapDBIcon:Hide(MINIMAP_ICON_NAME)
    else
        self.minimapDBIcon:Show(MINIMAP_ICON_NAME)
    end
end
