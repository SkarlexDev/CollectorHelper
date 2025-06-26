local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ========================================================================
-- Default Settings Table (Used for Initialization and Migration)
-- ========================================================================
local DEFAULT_SETTINGS = {
    hideMerchantOwned = true,
    showCostFrame = true,
    autoShowNews = true,
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
    self:initializeLfrCollected()
    self:initializeRecipesCollected()
end

-- ========================================================================
-- Settings Migration
-- ========================================================================
--- Ensures default keys exist in `settings`.
function CollectorHelper:initializeSettings()
    for key, defaultValue in pairs(DEFAULT_SETTINGS) do
        if settings[key] == nil then
            settings[key] = defaultValue
        end
    end
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
        local profIndices = { GetProfessions() }
        local profNames = {}

        for _, index in ipairs(profIndices) do
            local name = index and GetProfessionInfo(index)
            if name then table.insert(profNames, name) end
        end

        local player = self:GetCurrentPlayerID()
        self.player = player

        recipeCollected[player] = recipeCollected[player] or {}
        local isFirstTime = next(recipeCollected[player]) == nil

        for _, profName in ipairs(profNames) do
            if not recipeCollected[player][profName] then
                recipeCollected[player][profName] = {
                    collected = 0,
                    recipes = {},
                    lastSync = "never",
                    total = 0
                }
            end
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
    self:Print("This character doesn't have any recipe data. You may sync it now if you want. You can reopen the popup with /ch recipe command. It's important to reload after the first sync.")
    self:ShowRecipeUI(true)
end
