local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ========================================================================
-- Default Settings Table (Used for Initialization and Migration)
-- ========================================================================
local DEFAULT_SETTINGS = {
    hideMerchantOwned = true,
    showCostFrame = true,
    showMinimapButton = true,
    minimapPos = 220,
    dashboardWidth = 1120,
    dashboardHeight = 760,
    showHousingFrame = true,
    housingDuplicateCount = 1, -- default buy one
    softCollect = false,
    version = "0"
}

-- ========================================================================
-- Init All Saved Data
-- ========================================================================
--- Initializes SavedVariables and applies defaults where necessary.
function CollectorHelper:InitSettings()
    settings = settings or CopyTable(DEFAULT_SETTINGS)
    lfrCollected = lfrCollected or {}
    recipeCollected = recipeCollected or {}
    mainPanelViewed = mainPanelViewed or {}

    self:initializeSettings()
    for _, characterData in pairs(recipeCollected) do
        if type(characterData) == "table" then
            for professionName in pairs(characterData) do
                if not self:IsTrackedRecipeProfession(professionName) then
                    characterData[professionName] = nil
                end
            end
        end
    end
    self:initializeLfrCollected()
    self:initializeRecipesCollected()
end

-- ========================================================================
-- Settings Migration
-- ========================================================================
--- Ensures default keys exist in `settings`.
function CollectorHelper:initializeSettings()
    settings.autoShowNews = nil
    if settings.minimapPos == nil then
        settings.minimapPos = tonumber(settings.minimapPosition) or DEFAULT_SETTINGS.minimapPos
    end
    settings.minimapPosition = nil
    settings.hide = settings.showMinimapButton == false

    for key, defaultValue in pairs(DEFAULT_SETTINGS) do
        if settings[key] == nil then
            settings[key] = defaultValue
        end
    end
    settings.version = self.version or settings.version
    self.db.settings = settings
end

-- ========================================================================
-- Initialize LFR Collected Data
-- ========================================================================
--- Initializes the structure for Looking For Raid collected data.
function CollectorHelper:initializeLfrCollected()
    if not self.db or not self.db.lfrData then
        return
    end

    for raidId, raidData in pairs(self.db.lfrData) do
        lfrCollected[raidId] = lfrCollected[raidId] or { wings = {} }

        for wingId in pairs(raidData.wings or {}) do
            if lfrCollected[raidId].wings[wingId] == nil then
                lfrCollected[raidId].wings[wingId] = false
            end
        end
    end
end

-- ========================================================================
-- Player ID Helper
-- ========================================================================
--- @return string Full player ID (e.g., "Name-Realm")
function CollectorHelper:GetCurrentPlayerID()
    local name, realm = UnitName("player"), GetNormalizedRealmName()
    return name and realm and (name .. "-" .. realm) or "Unknown"
end

-- ========================================================================
-- Initialize Recipes Collected Data
-- ========================================================================
--- Initializes recipe collection structure for the current player.
function CollectorHelper:initializeRecipesCollected()
    C_Timer.After(0.25, function()
        local prof1, prof2, _, _, cooking = GetProfessions()
        local profIndices = {
            { index = prof1, category = "primary" },
            { index = prof2, category = "primary" },
            { index = cooking, category = "cooking" },
        }
        local profNames = {}
        local profIcons = {}
        local profCategories = {}

        for _, profession in ipairs(profIndices) do
            local index = profession.index
            if index then
                local name, icon = GetProfessionInfo(index)
                if self:IsTrackedRecipeProfession(name) then
                    table.insert(profNames, name)
                    profIcons[name] = icon
                    profCategories[name] = profession.category
                end
            end
        end

        local player = self:GetCurrentPlayerID()
        self.player = player
        if mainPanelViewed[player] == nil then
            mainPanelViewed[player] = false
        end
        recipeCollected[player] = recipeCollected[player] or {}
        local activeProfessions = {}
        for _, profName in ipairs(profNames) do
            activeProfessions[profName] = true
        end

        for professionName, professionData in pairs(recipeCollected[player]) do
            if type(professionData) == "table"
                and self:IsTrackedRecipeProfession(professionName)
                and not activeProfessions[professionName] then
                recipeCollected[player][professionName] = nil
            end
        end

        for _, profName in ipairs(profNames) do
            if not recipeCollected[player][profName] then
                recipeCollected[player][profName] = {
                    collected = 0,
                    recipes = {},
                    lastSync = "never",
                    total = 0,
                    icon = profIcons[profName],
                    isCooking = profCategories[profName] == "cooking",
                }
            else
                local professionData = recipeCollected[player][profName]
                professionData.icon = professionData.icon or profIcons[profName]
                professionData.isCooking = profCategories[profName] == "cooking"
            end
        end

        if self.dashboard then
            self:RefreshDashboardRecipeJournal()
            self:RefreshDashboardStats()
        end
        self:ShowDashboardForFirstVisit()
    end)
end
