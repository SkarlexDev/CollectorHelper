local _, app = ...

-- Check if the given item is owned by the player based on its type (toy, mount, pet, heirloom, etc.)
function app:checkShopID(source)
    -- Return 0 for false, 1 for true, 2 for ignore
    if source == nil or source.itemId == nil then
        return 0
    end

    -- Check if the item is a toy and if the player already has it
    local isToy = app:isToyItem(source.itemId)
    if isToy then
        return PlayerHasToy(source.itemId) and 1 or 0
    end

    -- Check if the item is a mount and if the player already knows it
    local isMount = app:IsMountItem(source.itemId)
    if isMount then
        local mountID = C_MountJournal.GetMountFromItem(source.itemId)
        local playerKnowsMount = select(11, C_MountJournal.GetMountInfoByID(mountID))
        return playerKnowsMount and 1 or 0
    end

    -- Check if the item is a pet and if the player already has it
    local isPet = app:IsPetItem(source.itemId)
    if isPet then
        local petName = C_PetJournal.GetPetInfoByItemID(source.itemId)
        if petName ~= nil then
            local _, petGUID = C_PetJournal.FindPetIDByName(petName)
            return petGUID ~= nil and 1 or 0
        end
    end

    -- Check if the item is part of a transmog set or an heirloom and if the player owns it
    local itemSetId = C_Item.GetItemLearnTransmogSet(source.itemId)
    local isItemHeirloom = C_Heirloom.IsItemHeirloom(source.itemId)
    if itemSetId ~= nil then
        return app:setOwned(itemSetId) and 1 or 0
    elseif isItemHeirloom then
        return C_Heirloom.PlayerHasHeirloom(source.itemId) and 1 or 0
    else
        -- Check if the item is part of the player's transmog collection
        local itemAppearanceID, _ = C_TransmogCollection.GetItemInfo(source.itemId)
        if itemAppearanceID == nil then
            local sourceID = app:GetSourceID(source.link)
            if sourceID ~= nil then
                return C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) and 1 or 0
            else
                return 2 -- ignore item
            end
        else
            local r = C_TransmogCollection.PlayerHasTransmog(source.itemId) and 1 or 0
            if r == 0 and source.bindType == 2 then
                if app:playerHasItemInBag(source.itemId) == true then
                    return 10
                end
            end
            return r
        end
    end
end

-- Check if the item is in the player's bags
function app:playerHasItemInBag(itemCheckId)
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

-- Check if the item is a toy
function app:isToyItem(itemId)
    return C_ToyBox.GetToyInfo(itemId) ~= nil
end

-- Check if the item is a mount
function app:IsMountItem(itemId)
    return C_MountJournal.GetMountFromItem(itemId) ~= nil
end

-- Check if the item is a pet
function app:IsPetItem(itemId)
    return C_PetJournal.GetPetInfoByItemID(itemId) ~= nil
end

-- Check if all items in the transmog set are owned by the player
function app:setOwned(itemSet)
    local ids = C_TransmogSets.GetAllSourceIDs(itemSet)
    for _, sourceID in ipairs(ids) do
        local info = C_TransmogCollection.GetSourceInfo(sourceID)
        if not info.isCollected then return false end
    end
    return true
end
