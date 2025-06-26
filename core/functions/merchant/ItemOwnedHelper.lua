local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- ITEM CHECK METHODS
-- ============================================================================

--- Check if an item is already collected or owned by the player.
--- Return codes:
--- - 0 = not owned
--- - 1 = owned
--- - 2 = ignore
--- - 10 = owned in bag but not known (BoE)
--- - 11 = known recipe in bag
--- @param source table|nil Item source metadata (must contain itemId, itemType, link, bindType, etc.)
--- @return integer
function CollectorHelper:CheckShopID(source)
    if source == nil or source.itemId == nil then
        return 0
    end

    -- Toy
    local isToy = CollectorHelper:IsToyItem(source.itemId)
    if isToy then
        return PlayerHasToy(source.itemId) and 1 or 0
    end

    -- Mount
    local isMount = CollectorHelper:IsMountItem(source.itemId)
    if isMount then
        local mountID = C_MountJournal.GetMountFromItem(source.itemId)
        local playerKnowsMount = select(11, C_MountJournal.GetMountInfoByID(mountID))
        return playerKnowsMount and 1 or 0
    end

    -- Pet
    local isPet = CollectorHelper:IsPetItem(source.itemId)
    if isPet then
        local petName = C_PetJournal.GetPetInfoByItemID(source.itemId)
        if petName ~= nil then
            local _, petGUID = C_PetJournal.FindPetIDByName(petName)
            return petGUID ~= nil and 1 or 0
        end
    end

    -- Recipe
    local isRecipe = source.itemType == "Recipe"
    if isRecipe then
        if CollectorHelper:PlayerHasItemInBag(source.itemId) == true then
            return 11
        end
        local recipeId = CollectorHelper:SearchRecipe(source.itemId)
        if recipeId ~= nil then
            local player = self.player
            if player and recipeCollected[player] then
                local professionData = recipeCollected[player][self.pNameToCheck]
                if professionData ~= nil then
                    local pd = professionData["recipes"][recipeId]
                    return pd ~= nil and pd and 1 or 0
                end
                return 0
            end
        end
    end

    -- Transmog set or heirloom
    local itemSetId = C_Item.GetItemLearnTransmogSet(source.itemId)
    local isItemHeirloom = C_Heirloom.IsItemHeirloom(source.itemId)
    if itemSetId ~= nil then
        return CollectorHelper:SetOwned(itemSetId) and 1 or 0
    elseif isItemHeirloom then
        return C_Heirloom.PlayerHasHeirloom(source.itemId) and 1 or 0
    else
        local itemAppearanceID, _ = C_TransmogCollection.GetItemInfo(source.itemId)
        if itemAppearanceID == nil then
            local sourceID = CollectorHelper:GetSourceID(source.link)
            if sourceID ~= nil then
                return C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) and 1 or 0
            else
                return 2
            end
        elseif settings.softCollect then
            local sourceID = CollectorHelper:GetSourceID(source.link)
            if sourceID == nil then return 2 end
            local info = C_TransmogCollection.GetAppearanceInfoBySource(sourceID)
            if info == nil then return 2 end
            return info.sourceIsKnown and 1 or 0
        else
            local r = C_TransmogCollection.PlayerHasTransmog(source.itemId) and 1 or 0
            if r == 0 and source.bindType == 2 then
                if CollectorHelper:PlayerHasItemInBag(source.itemId) == true then
                    return 10
                end
            end
            return r
        end
    end
end

-- ============================================================================
-- RECIPE SEARCH
-- ============================================================================

--- Searches for the recipe ID from known professions and stores the profession name to check.
--- @param id number|string The recipe item ID
--- @return number|nil Returns the recipe ID or nil if not found
function CollectorHelper:SearchRecipe(id)
    local prof1index, prof2index, _, _, cooking = GetProfessions()

    local prof1 = prof1index and GetProfessionInfo(prof1index) or ""
    local prof2 = prof2index and GetProfessionInfo(prof2index) or ""
    local cookingProf = cooking and GetProfessionInfo(cooking) or ""

    local p1 = self.db.recipes[prof1] or {}
    local p2 = self.db.recipes[prof2] or {}
    local p3 = self.db.recipes[cookingProf] or {}

    local recipeItemId = tonumber(id)

    if p1[recipeItemId] then
        self.pNameToCheck = prof1
        return p1[recipeItemId]
    elseif p2[recipeItemId] then
        self.pNameToCheck = prof2
        return p2[recipeItemId]
    elseif p3[recipeItemId] then
        self.pNameToCheck = cookingProf
        return p3[recipeItemId]
    else
        self.pNameToCheck = ""
        return nil
    end
end

-- ============================================================================
-- BAG CHECK UTILITY
-- ============================================================================

--- Checks if the item is in the player's bag.
--- @param itemCheckId number The item ID to look for
--- @return boolean
function CollectorHelper:PlayerHasItemInBag(itemCheckId)
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if item ~= nil and item.itemID == itemCheckId then
                return true
            end
        end
    end
    return false
end

-- ============================================================================
-- TYPE CHECK HELPERS
-- ============================================================================

--- Check if the item is a toy
--- @param itemId number
--- @return boolean
function CollectorHelper:IsToyItem(itemId)
    return C_ToyBox.GetToyInfo(itemId) ~= nil
end

--- Check if the item is a mount
--- @param itemId number
--- @return boolean
function CollectorHelper:IsMountItem(itemId)
    return C_MountJournal.GetMountFromItem(itemId) ~= nil
end

--- Check if the item is a pet
--- @param itemId number
--- @return boolean
function CollectorHelper:IsPetItem(itemId)
    return C_PetJournal.GetPetInfoByItemID(itemId) ~= nil
end

-- ============================================================================
-- TRANSMOG SET OWNERSHIP CHECK
-- ============================================================================

--- Checks if the player owns all items in a transmog set.
--- @param itemSet number Transmog item set ID
--- @return boolean
function CollectorHelper:SetOwned(itemSet)
    local ids = C_TransmogSets.GetAllSourceIDs(itemSet)
    for _, sourceID in ipairs(ids) do
        local info = C_TransmogCollection.GetSourceInfo(sourceID)
        if not info.isCollected then
            return false
        end
    end
    return true
end
