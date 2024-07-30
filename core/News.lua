local _, app = ...
local COLORS = app.COLORS

local news = {
    {
        "## V1.5.0",
        "- Added Changelog frame",
        "- Code optimisations",
        "- Removed Equip button from boe items",
        "- Added Destroy button to boe items",
        "- Split functions into independent modules",
        "- Updated command list & display",
        "- Added LFR helper",
        "   1. Display shorter name on LFR option",
        "   2. Added tooltip with bosses in wing",
        "   3. Added track killed/total",
        "   4. Added color change for in progress",
        "   5. Added finished mark for LFR wing",
        "   6. Added support up to Shadowlands"
    },
    {
        "## V1.4.4",
        "- Added sell button for boe merchant items (warband collect faster)"
    },
    {
        "## V1.4.3",
        "- The War Within patch 11.0 supported."
    },
    {
        "## V1.4.2",
        "- Fixed buttons overlap on classic interface",
        "- Shorter button names"
    },
    {
        "## V1.4",
        "- Dynamic Row Item Recycling in Scroll View (performance)",
        "- Dynamic Scrollbar Visibility (UI look)",
        "- Updated cost frame display with buttons like type and highlight on hover",
        "- Added currency chat link on click",
        "- Updated UI",
        "- Changed buy all button for all pages",
        "- Changed cost/page to total merchant cost",
        "- Added AH window support for currency items that can be bought from AH",
        "- Command support",
        "- Support for ElvUI Shadow & Light default merchant view",
        "- Support for ElvUI Shadow & Light default merchant view as list"
    },
    {
        "## V1.3",
        "- Code update",
        "- Added toggle button for cost frame",
        "- Updated cost frame with list of items + tooltips"
    },
    {
        "## V1.2",
        "- Added ElvUI skin helper",
        "- Fixed transmog item sources from CanIMogIt solution",
        "- Frame/buttons better handle",
        "- Added BoE vendor items in bag with equip button from merchant item",
        "- Fixed equip button with skip confirmation",
        "- Added addon logo texture"
    },
    {
        "## V1.1",
        "- Money frame hide added",
        "- Pet filter added",
        "- Fix Miscellaneous for some items",
        "- Added required/current currency - percentage to collect display",
        "- Added show/hide collected button from merchant",
        "- Added handle for gold items",
        "- Fixed money / alter currency both visible on merchant",
        "- Fixed strange way API handles some items for transmog"
    },
    {
        "## V1.0",
        "Initial Release"
    }
}

function app:InitNews()
    if settings.version ~= app.COLLECTORHELPER_VERSION then
        settings.version = app.COLLECTORHELPER_VERSION
        if app.newsFrame == nil then
            local newsFrame = app:frameBuilder({
                frameName = "CollectorHelper_News",
                parent = UIParent,
                width = 450,
                height = 450,
                point = {
                    pos = "CENTER",
                    x = 0,
                    y = 0,
                },
                titleBuilder = {
                    text = app:textCFormat(COLORS.yellow, "CollectorHelper Changelog - News"),
                    point = {
                        pos = "TOP",
                        x = 0,
                        y = -8,
                    }
                }
            })

            app.newsFrame = newsFrame

            newsFrame:SetMovable(true)
            newsFrame:EnableMouse(true)
            newsFrame:RegisterForDrag("LeftButton")
            newsFrame:SetScript("OnDragStart", newsFrame.StartMoving)
            newsFrame:SetScript("OnDragStop", function(self)
                self:StopMovingOrSizing()
            end)

            -- Close button for AH frame
            app:buttonBuilder({
                buttonName = "Collector_NewsCloseButton",
                parent = newsFrame,
                text = "Close",
                width = 100,
                height = 22,
                point = {
                    pos = "BOTTOM",
                    x = 0,
                    y = 8,
                },
                onClickScript = function(self, button)
                    if button == "LeftButton" then
                        newsFrame:Hide()
                    end
                end
            })
            app:fontBuilder({
                parent = newsFrame,
                text = app:textCFormat(COLORS.yellow, "Made By Skarlex"),
                point = {
                    pos = "BOTTOM",
                    x = 150,
                    y = 13,
                }
            })

            -- Create a scroll frame
            local scrollFrame = CreateFrame("ScrollFrame", nil, newsFrame, "UIPanelScrollFrameTemplate")
            scrollFrame:SetPoint("TOPLEFT", newsFrame, "TOPLEFT", 10, -30)
            scrollFrame:SetPoint("BOTTOMRIGHT", newsFrame, "BOTTOMRIGHT", -30, 40)

            -- Create a content frame
            local contentFrame = app:frameBuilder({
                frameName = "CollectorHelper_NewsContent",
                parent = scrollFrame,
                width = 430,
                height = 400,
                point = {
                    pos = "CENTER",
                    x = 0,
                    y = 0,
                }
            })
            contentFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)
            scrollFrame:SetScrollChild(contentFrame)

            -- Populate the content frame with news
            local offset = -10
            for _, version in ipairs(news) do
                local versionText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                versionText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, offset)
                versionText:SetWidth(400)
                versionText:SetJustifyH("LEFT")
                versionText:SetText(version[1])
                offset = offset - versionText:GetHeight() - 10

                for i = 2, #version do
                    local newsText = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    newsText:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 20, offset)
                    newsText:SetWidth(400)
                    newsText:SetJustifyH("LEFT")
                    newsText:SetText(version[i])
                    offset = offset - newsText:GetHeight() - 5
                end
                offset = offset - 10
            end

            contentFrame:SetHeight(math.abs(offset))

            scrollFrame:UpdateScrollChildRect()
            scrollFrame:SetVerticalScroll(0)
            scrollFrame:SetScript("OnShow", function(self)
                self:SetVerticalScroll(0)
            end)
        else
            app.newsFrame:Show()
        end
    end
end
