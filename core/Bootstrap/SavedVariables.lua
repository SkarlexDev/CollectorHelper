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
        local prof1, prof2, _, _, cooking, firstAid = GetProfessions()
        local profIndices = { prof1, prof2, cooking, firstAid }
        local profNames = {}
        local profIcons = {}

        for _, index in pairs(profIndices) do
            if index then
                local name, icon = GetProfessionInfo(index)
                if self:IsTrackedRecipeProfession(name) then
                    table.insert(profNames, name)
                    profIcons[name] = icon
                end
            end
        end

        local player = self:GetCurrentPlayerID()
        self.player = player
        local isFirstTime = recipeCollected[player] == nil
        recipeCollected[player] = recipeCollected[player] or {}

        for _, profName in ipairs(profNames) do
            if not recipeCollected[player][profName] then
                recipeCollected[player][profName] = {
                    collected = 0,
                    recipes = {},
                    lastSync = "never",
                    total = 0,
                    icon = profIcons[profName],
                }
            elseif not recipeCollected[player][profName].icon then
                recipeCollected[player][profName].icon = profIcons[profName]
            end
        end

        if self.dashboard then
            self:RefreshDashboardRecipeJournal()
            self:RefreshDashboardStats()
        end

        if isFirstTime then
            C_Timer.After(0.50, function()
                self:PromptFirstTimeSync()
            end)
        end
    end)
end

-- ========================================================================
-- Prompt First-Time Recipe Sync
-- ========================================================================
function CollectorHelper:PromptFirstTimeSync()
    self:Print("This character doesn't have any recipe data yet. Open the recipe journal from the dashboard to sync your professions.")
    self:ToggleDashboard("recipes")
end
