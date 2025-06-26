local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function CollectorHelper:InitOptionsPanel()
    AceConfigRegistry:RegisterOptionsTable("CollectorHelperOptions", self:CreateGeneralOptions())
    AceConfigRegistry:RegisterOptionsTable("CollectorHelperOptions_Recipe", self:CreateRecipeOptions())

    local _, mainCategoryID = AceConfigDialog:AddToBlizOptions("CollectorHelperOptions", "CollectorHelper")
    AceConfigDialog:AddToBlizOptions("CollectorHelperOptions_Recipe", "Recipes", "CollectorHelper")
    self.MainPanel = mainCategoryID

    C_Timer.After(1.25, function()
        self:UpdateRecipeOptions()
    end)
end