local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
local COLORS = CollectorHelper.COLORS or {}

function CollectorHelper:ShowNews()
    -- Create the news frame if it does not exist yet
    if not self.newsFrame then
        self.newsFrame = self:FrameBuilder({
            frameName = "CollectorHelper_News",
            parent = UIParent,
            width = 450,
            height = 450,
            point = { pos = "CENTER", x = 0, y = 0 },
            titleBuilder = {
                text = self:TextCFormat(COLORS.yellow, "CollectorHelper Changelog - News"),
                point = { pos = "TOP", x = 0, y = -8 }
            }
        })

        -- Checkbox to toggle auto-open news feature
        local checkbox = CreateFrame("CheckButton", nil, self.newsFrame, "InterfaceOptionsCheckButtonTemplate")
        checkbox:SetPoint("BOTTOMLEFT", 7, 7)
        checkbox.Text:SetText("Auto Open on New Changes")

        -- Load current setting for autoShowNews or default to false
        checkbox:SetChecked(settings.autoShowNews)

        -- Update setting on checkbox click and save
        checkbox:SetScript("OnClick", function()
            settings.autoShowNews = checkbox:GetChecked()
            self.db.settings = settings
            print(settings.autoShowNews and "Feature Enabled" or "Feature Disabled")
        end)

        -- Make the news frame draggable
        self.newsFrame:SetMovable(true)
        self.newsFrame:EnableMouse(true)
        self.newsFrame:RegisterForDrag("LeftButton")
        self.newsFrame:SetScript("OnDragStart", self.newsFrame.StartMoving)
        self.newsFrame:SetScript("OnDragStop", self.newsFrame.StopMovingOrSizing)

        -- Add a close button to hide the news frame
        self:ButtonBuilder({
            buttonName = "Collector_NewsCloseButton",
            parent = self.newsFrame,
            text = "Close",
            width = 100,
            height = 22,
            point = { pos = "BOTTOM", x = 0, y = 8 },
            onClickScript = function(_, button)
                if button == "LeftButton" then
                    self.newsFrame:Hide()
                end
            end
        })

        -- Add a small footer text credit
        self:FontBuilder({
            parent = self.newsFrame,
            text = self:TextCFormat(COLORS.yellow, "Made By Skarlex"),
            point = { pos = "BOTTOM", x = 150, y = 13 }
        })

        -- Create scroll frame for news content with standard Blizzard scroll template
        self.scrollFrame = CreateFrame("ScrollFrame", nil, self.newsFrame, "UIPanelScrollFrameTemplate")
        self.scrollFrame:SetPoint("TOPLEFT", self.newsFrame, "TOPLEFT", 10, -30)
        self.scrollFrame:SetPoint("BOTTOMRIGHT", self.newsFrame, "BOTTOMRIGHT", -30, 40)

        -- Create a content frame inside scroll frame where news lines are added
        self.contentFrame = self:FrameBuilder({
            frameName = "CollectorHelper_NewsContent",
            parent = self.scrollFrame,
            width = 430,
            height = 400,
            point = { pos = "CENTER", x = 0, y = 0 }
        })
        self.contentFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)

        self.scrollFrame:SetScrollChild(self.contentFrame)

        -- Populate the content frame with news versions and their messages
        local offset = -10
        for _, version in ipairs(self.db.news) do
            -- Version header (e.g., "v1.0.0")
            local versionText = self.contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            versionText:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 10, offset)
            versionText:SetWidth(400)
            versionText:SetJustifyH("LEFT")
            versionText:SetText(version[1])
            versionText:SetWordWrap(true)

            -- Fixed height decrement for spacing instead of relying on dynamic height
            offset = offset - 25

            -- List of changes/notes for this version
            for i = 2, #version do
                local newsText = self.contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                newsText:SetPoint("TOPLEFT", self.contentFrame, "TOPLEFT", 20, offset)
                newsText:SetWidth(400)
                newsText:SetJustifyH("LEFT")
                newsText:SetText(version[i])
                newsText:SetWordWrap(true)

                offset = offset - 18
            end

            -- Additional spacing between versions
            offset = offset - 10
        end

        -- Adjust content frame height to fit all news entries
        self.contentFrame:SetHeight(math.abs(offset))

        -- Refresh scroll child rectangle and reset scroll position to top
        self.scrollFrame:UpdateScrollChildRect()
        self.scrollFrame:SetVerticalScroll(0)

        -- Ensure scroll position is reset on showing the scroll frame
        self.scrollFrame:SetScript("OnShow", function(self)
            self:SetVerticalScroll(0)
        end)
    else
        -- If news frame already exists, just show it
        self.newsFrame:Show()
    end
end
