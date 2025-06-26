local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- Entry point: Initializes all CollectorHelper modules
-- ============================================================================
function CollectorHelper:Init()
    self:InitMerchant()         -- Merchant frame and logic
    self:InitAHUI()             -- Auction House tracker
    self:InitLfrGossip()        -- LFR gossip hooks
    self:InitRecipeUI()         -- Recipe sync frame
    self:InitNews()             -- News/changelog frame

    self:InitOptionsPanel()     -- Config panel
    self:InitAutoSync()         -- Automatic recipe learning handler
end

-- ============================================================================
-- Automatically sync new recipe data when a new recipe is learned
-- ============================================================================
function CollectorHelper:InitAutoSync()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("NEW_RECIPE_LEARNED")

    frame:SetScript("OnEvent", function(_, _, recipeID)
        local info = C_TradeSkillUI.GetProfessionInfoByRecipeID(recipeID)
        if not (info and info.parentProfessionName) then return end

        local player = self.player
        local professionData = recipeCollected[player] and recipeCollected[player][info.parentProfessionName]
        if not professionData then return end

        professionData.recipes[recipeID] = true
        professionData.collected = (professionData.collected or 0) + 1
        professionData.lastSync = date("%Y-%m-%d %H:%M:%S")

        self:ShowRecipeUI(false)
    end)
end

-- ============================================================================
-- Setup merchant frame + recipe auto-show on merchant open
-- ============================================================================
function CollectorHelper:InitMerchant()
    self:InitMerchantUI()

    hooksecurefunc("MerchantFrame_Update", function() self:UpdateShop() end)
    MerchantNextPageButton:HookScript("OnClick", function() self:UpdateShop() end)
    MerchantPrevPageButton:HookScript("OnClick", function() self:UpdateShop() end)

    MerchantFrame:HookScript("OnShow", function()
        C_Timer.After(0.25, function() self:ShowRecipeUI(false) end)
    end)
end

-- ============================================================================
-- Hook into LFR-related gossip NPCs for automatic logic
-- ============================================================================
function CollectorHelper:InitLfrGossip()
    GossipFrame:HookScript("OnShow", function()
        C_Timer.After(0.25, function() self:GossipLfr() end)
    end)

    GossipFrame:HookScript("OnHide", function()
        self.db.lockDownData = {}
        self.gossipUpdate = false
    end)
end
