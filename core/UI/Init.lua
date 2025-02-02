local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

function CollectorHelper:Init()
    self:InitMerchant()
    self:InitAHUI()
    self:InitLfrGossip()
    self:InitRecipeUI()
    self:InitNews()
end

-- ============================================================================
-- Merchant init
-- ============================================================================
function CollectorHelper:InitMerchant()
    self:InitMerchantUI()

    hooksecurefunc("MerchantFrame_Update", function() self:updateShop() end)
    MerchantNextPageButton:HookScript("OnClick", function() self:updateShop() end)
    MerchantPrevPageButton:HookScript("OnClick", function() self:updateShop() end)

    MerchantFrame:HookScript("OnShow", function()
        C_Timer.After(0.25, function()
            self:ShowRecipeUI(false)
        end)
    end)
end

-- ============================================================================
-- Lfr npc gossipUpdate
-- ============================================================================
function CollectorHelper:InitLfrGossip()
    GossipFrame:HookScript("OnShow", function()
        C_Timer.After(0.25, function()
            self:GossipLfr()
        end)
    end)

    GossipFrame:HookScript("OnHide", function()
        self.db.lockDownData = {}
        self.gossipUpdate = false
    end)
end