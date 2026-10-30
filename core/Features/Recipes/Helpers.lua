local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

function CollectorHelper:IsTrackedRecipeProfession(name)
    if not name then return false end
    local normalized = strlower(name)
    return normalized ~= "fishing"
        and normalized ~= "archaeology"
        and normalized ~= "archeology"
end

function CollectorHelper:SyncProfessionData(button, professionName)
    if not self:IsTrackedRecipeProfession(professionName) then
        return false
    end

    local player = self.player
    if not (player and recipeCollected[player] and professionName) then
        self:initializeRecipesCollected()
        return false
    end

    local professionData = recipeCollected[player][professionName]
    if not professionData then
        self:initializeRecipesCollected()
        return false
    end

    local recipeIDs = C_TradeSkillUI.GetAllRecipeIDs()
    if type(recipeIDs) ~= "table" then
        return false
    end

    local collected, total = 0, 0
    local now = date("%Y-%m-%d %H:%M:%S")
    professionData.recipes = {}
    professionData.icon = button.iconTexture or (button.icon and button.icon:GetTexture())

    for _, id in pairs(recipeIDs) do
        local info = C_TradeSkillUI.GetRecipeInfo(id)
        if info then
            professionData.recipes[info.recipeID] = info.learned or false
            if info.learned then collected = collected + 1 end
            total = total + 1
        end
    end

    professionData.collected = collected
    professionData.total = total
    professionData.lastSync = now

    if button.collectedText then
        if button.lastSyncText then
            button.collectedText:SetText("Collected: " .. collected .. " / " .. total)
            button.lastSyncText:SetText("Last Sync: " .. now)
        else
            button.collectedText:SetText(collected .. " / " .. total)
        end
    end
    return true
end
