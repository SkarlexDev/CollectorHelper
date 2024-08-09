local _, app = ...

app.COLLECTORHELPER_VERSION = "1.5.5"

-- ========================
-- Section: Addon init
-- ========================
function app:InitAddon()
    app:InitSettings()
    app:InitUI()
end

function app:InitUI()
    -- Merchant extension module
    app:InitMerchantUI()
    -- ========================
    -- Section: Other
    -- ========================
    app:InitNews()

    if app.merchantFrameCost ~= nil then
        app:buttonBuilder({
            buttonName = "Collector_MerchantToggle",
            parent = _G["MerchantFrameTab1"],
            text = "Toggle CH",
            width = 90,
            height = 25,
            point = {
                pos = "LEFT",
                x = 3,
                y = -28,
            },
            onClickScript = function(_, button)
                if button == "LeftButton" then
                    if settings.showCostFrame then
                        app.merchantFrameCost:Hide()
                    else
                        app.merchantFrameCost:Show()
                    end
                    settings.showCostFrame = not settings.showCostFrame
                end
            end
        })
    end
end

-- ========================
-- Section: Init settings
-- ========================
function app:InitSettings()
    if settings == nil then
        settings = {
            hideMerchantOwned = true,
            showCostFrame = true,
            version = "0"
        }
    end
    app:MigrateSettings()
    app:initializeLfrCollected()
end

-- ========================
-- Section: Migrate
-- ========================
function app:MigrateSettings()
    if settings.showCostFrame == nil then
        settings.showCostFrame = true
    end
    if settings.version == nil then
        settings.version = "0"
    end
    if settings.autoShowNews == nil then
        settings.autoShowNews = true
    end
end

function app:initializeLfrCollected()
    if not lfrCollected then
        lfrCollected = {}
    end
    for raidId, raidData in pairs(app.lfrData) do
        if not lfrCollected[raidId] then
            lfrCollected[raidId] = { wings = {} }
        end
        for wingId, _ in pairs(raidData.wings) do
            if lfrCollected[raidId].wings[wingId] == nil then
                lfrCollected[raidId].wings[wingId] = false
            end
        end
    end
end
