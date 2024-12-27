local _, app = ...

app.COLLECTORHELPER_VERSION = "1.7.0"

local COLORS = app.COLORS

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
    app:initializeRecipesCollected()
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

function app:initializeRecipesCollected()
    C_Timer.After(0.25, function()
        local firstTime = false;
        -- Retrieve the profession indices and cooking profession
        local prof1index, prof2index, _, _, cooking = GetProfessions()

        -- Function to get profession info based on index
        local function getProfessionInfo(index)
            if index then
                return GetProfessionInfo(index)
            else
                return "" -- Return empty string if index is nil
            end
        end

        local prof1 = getProfessionInfo(prof1index)
        local prof2 = getProfessionInfo(prof2index)
        local cookingProf = getProfessionInfo(cooking)

        -- Get the player's name and realm
        local playerName = UnitName("player")
        local realm = GetNormalizedRealmName()
        local player = playerName .. "-" .. realm
        app.player = player -- Store the player's name with realm

        -- Initialize recipeCollected if it doesn't exist yet
        if not recipeCollected then
            recipeCollected = {}
        end

        -- Initialize the table for the player if it doesn't exist
        if not recipeCollected[player] then
            firstTime = true
            recipeCollected[player] = {}
        end

        local function initializeProfessionRecipes(profession)
            if not recipeCollected[player][profession] then
                recipeCollected[player][profession] = {
                    ["collected"] = 0, -- Initialize with 0 collected recipes
                    ["recipes"] = {},  -- Initialize with an empty table for recipes
                    ["lastSync"] = "never",
                    ["total"] = 0
                }
            end
        end
        initializeProfessionRecipes(prof1)
        initializeProfessionRecipes(prof2)
        initializeProfessionRecipes(cookingProf)
        if firstTime then
            C_Timer.After(0.50, function()
                print(app:textCFormat(COLORS.yellow, "CH:"),
                    "This character dont have any recipe data you may sync it now if you want, you may reopen the popup with /ch recipe command, its important to reload after first sync")
                app:ShowRecipeUI()
            end)
        end
    end)
end
