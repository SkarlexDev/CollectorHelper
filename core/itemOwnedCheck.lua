local _, app = ...

local _, playerclass = UnitClass("player")
--local token_Armor = TOKEN_ARMOR

function app:checkShopID(source)
    -- 0 false, 1 true, 2 ignore
    if source == nil or source.itemId == nil then
        return 0
    end
    -- CHECKS START
    local isToy = app:isToyItem(source.itemId)
    if isToy then
        return PlayerHasToy(source.itemId) and 1 or 0
    end

    local isMount = app:IsMountItem(source.itemId)
    if isMount then
        local mountID = C_MountJournal.GetMountFromItem(source.itemId)
        local playerKnowsMount = select(11, C_MountJournal.GetMountInfoByID(mountID))
        return playerKnowsMount and 1 or 0
    end

    local IsPet = app:IsPetItem(source.itemId)
    if IsPet then
        local petName = C_PetJournal.GetPetInfoByItemID(source.itemId)
        if petName ~= nil then
            local _, petGUID = C_PetJournal.FindPetIDByName(petName)
            return petGUID ~= nil and 1 or 0
        end
    end

    local itemSetId = C_Item.GetItemLearnTransmogSet(source.itemId)
    local isItemHeirloom = C_Heirloom.IsItemHeirloom(source.itemId)
    if itemSetId ~= nil then
        return app:setOwned(itemSetId) and 1 or 0
    elseif isItemHeirloom then
        return C_Heirloom.PlayerHasHeirloom(source.itemId) and 1 or 0
    else
        local itemAppearanceID, _ = C_TransmogCollection.GetItemInfo(source.itemId)
        if itemAppearanceID == nil then
            local sourceID = app:GetSourceID(source.link)
            if sourceID ~= nil then
                return C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) and 1 or 0
            else
                --local itemToken = token_Armor[source.itemId]
                --if itemToken ~= nil then
                --return app:tokenSourcesOwned(source.itemId, itemToken)
                --end
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

-- Item is BoE check if already purchased and is in bags
function app:playerHasItemInBag(itemCheckId)
    -- check if item is in bag
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local item = C_Container.GetContainerItemInfo(bag, slot)
            if (item ~= nil and item.itemID == itemCheckId) then
                return true
            end
        end
    end
    return false
end

-- TOY CHECK
function app:isToyItem(itemId)
    if C_ToyBox.GetToyInfo(itemId) then
        return true
    end
    return false
end

-- MOUNT CHECK
function app:IsMountItem(itemId)
    if C_MountJournal.GetMountFromItem(itemId) then
        return true
    end
    return false
end

-- PET CHECK
function app:IsPetItem(itemId)
    if C_PetJournal.GetPetInfoByItemID(itemId) then
        return true
    end
    return false
end

-- SET CHECK
function app:setOwned(itemSet)
    local ids = C_TransmogSets.GetAllSourceIDs(itemSet)
    for _, sourceID in ipairs(ids) do
        local info = C_TransmogCollection.GetSourceInfo(sourceID)
        if not info.isCollected then return false end
    end
    return true
end

-- In work for next update
-- Token item that provides specific items class based
function app:tokenSourcesOwned(tokenId, itemToken)
    local function isItemValidForClass(classes)
        for _, class in pairs(classes) do
            if class == app.CLS.ANY then
                -- can be used by any class
                return true
            end
            if class == playerclass then
                return true
            end
        end
        return false
    end

    local count = 0
    local owned = 0
    app.merchantTokenMap[tokenId] = {}
    for itemId, classes in pairs(itemToken) do
        if (isItemValidForClass(classes)) then
            count = count + 1
            local isOwned = C_TransmogCollection.PlayerHasTransmog(itemId)
            if isOwned then
                owned = owned + 1
            end
            table.insert(app.merchantTokenMap[tokenId], { owned = isOwned, itemId = itemId })
        end
    end
    return (owned == count) and 1 or 15
end
