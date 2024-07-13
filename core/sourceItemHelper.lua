local _, app = ...
-- implemented from CanIMogIt
-- https://gitlab.com/toreltwiddler/CanIMogIt/-/blob/master/code.lua

function app:getItemSlot(itemEquipLoc)
    return app.ITEM_SLOT_ENUM[itemEquipLoc] or 0
end

local DressUpModel = CreateFrame('DressUpModel')
DressUpModel:SetUnit('player')

function app:GetSourceID(itemLink)
    if itemLink == nil then return nil end
    local sourceID = select(2, C_TransmogCollection.GetItemInfo(itemLink))
    if sourceID then
        return sourceID
    end
    return app:RetailOldGetSourceID(itemLink)
end

function app:RetailOldGetSourceID(itemLink)
    -- Some items don't have the C_TransmogCollection.GetItemInfo data,
    -- so use the old way to find the sourceID (using the DressUpModel).
    local itemID, _, _, slotName = C_Item.GetItemInfoInstant(itemLink)
    local slots = app:getItemSlot(slotName)

    if slots == nil or slots == false or C_Item.IsDressableItemByID(itemID) == false or slots == 0 then return end

    DressUpModel:SetUnit('player')
    DressUpModel:Undress()
    for i, slot in pairs(slots) do
        DressUpModel:TryOn(itemLink, slot)
        local transmogInfo = DressUpModel:GetItemTransmogInfo(slot)
        if transmogInfo and
            transmogInfo.appearanceID ~= nil and
            transmogInfo.appearanceID ~= 0 then
            -- Yes, that's right, we are setting `appearanceID` to the `sourceID`. Blizzard messed
            -- up the DressUpModel functions, so _they_ don't even know what they do anymore.
            -- The `appearanceID` field from `DressUpModel:GetItemTransmogInfo` is actually its
            -- source ID, not it's appearance ID.
            local sourceID = transmogInfo.appearanceID
            if not app:IsSourceIDFromItemLink(sourceID, itemLink) then
                -- This likely means that the game hasn't finished loading things
                -- yet, so let's wait until we get good data before caching it.
                return
            end
            return sourceID
        end
    end
    return nil
end

function app:IsSourceIDFromItemLink(sourceID, itemLink)
    -- Returns whether the source ID given matches the itemLink.
    local sourceItemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID))
    if not sourceItemLink then return false end
    return app:DoItemIDsMatch(sourceItemLink, itemLink)
end

function app:DoItemIDsMatch(itemLinkA, itemLinkB)
    return app:GetItemID(itemLinkA) == app:GetItemID(itemLinkB)
end

function app:GetItemID(itemLink)
    return tonumber(itemLink:match("item:(%d+)"))
end

