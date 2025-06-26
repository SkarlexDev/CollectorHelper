local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- Implemented logic inspired from CanIMogIt:
-- https://gitlab.com/toreltwiddler/CanIMogIt/-/blob/master/code.lua

--- @class CollectorHelper : AceAddon
--- @field DressUpModel DressUpModel
--- @field ITEM_SLOT_ENUM table<string, number[]>

-- Create a model frame to simulate equipping an item (used for sourceID fallback)
CollectorHelper.DressUpModel = CreateFrame('DressUpModel')
CollectorHelper.DressUpModel:SetUnit('player')

--- Returns a list of transmog slots for the given equip location
--- @param itemEquipLoc string
--- @return number[]|0
function CollectorHelper:getItemSlot(itemEquipLoc)
    return CollectorHelper.ITEM_SLOT_ENUM[itemEquipLoc] or 0
end

--- Retrieves the Transmog SourceID of an item from its link using C_TransmogCollection
--- Falls back to old method if API doesn't return valid info.
--- @param itemLink string
--- @return number|nil
function CollectorHelper:GetSourceID(itemLink)
    if itemLink == nil then return nil end
    local sourceID = select(2, C_TransmogCollection.GetItemInfo(itemLink))
    if sourceID then
        return sourceID
    end
    return self:RetailOldGetSourceID(itemLink)
end

--- Legacy method for retrieving source ID using DressUpModel API when normal API fails.
--- Uses slot info and simulates TryOn behavior to extract source ID.
--- @param itemLink string
--- @return number|nil
function CollectorHelper:RetailOldGetSourceID(itemLink)
    local itemID, _, _, slotName = C_Item.GetItemInfoInstant(itemLink)
    local slots = self:getItemSlot(slotName)
    local DressUpModel = self.DressUpModel

    if slots == nil or slots == false or C_Item.IsDressableItemByID(itemID) == false or slots == 0 then return end

    DressUpModel:SetUnit('player')
    DressUpModel:Undress()

    for _, slot in pairs(slots) do
        DressUpModel:TryOn(itemLink, slot)
        local transmogInfo = DressUpModel:GetItemTransmogInfo(slot)
        if transmogInfo and transmogInfo.appearanceID and transmogInfo.appearanceID ~= 0 then
            -- This appearanceID is actually the SourceID (Blizzard API inconsistency)
            local sourceID = transmogInfo.appearanceID
            if not self:IsSourceIDFromItemLink(sourceID, itemLink) then
                return -- Likely data not ready yet
            end
            return sourceID
        end
    end
    return nil
end

--- Validates if a given sourceID maps to the provided itemLink
--- @param sourceID number
--- @param itemLink string
--- @return boolean
function CollectorHelper:IsSourceIDFromItemLink(sourceID, itemLink)
    local sourceItemLink = select(6, C_TransmogCollection.GetAppearanceSourceInfo(sourceID))
    if not sourceItemLink then return false end
    return self:DoItemIDsMatch(sourceItemLink, itemLink)
end

--- Checks whether two item links refer to the same item ID
--- @param itemLinkA string
--- @param itemLinkB string
--- @return boolean
function CollectorHelper:DoItemIDsMatch(itemLinkA, itemLinkB)
    return self:GetItemID(itemLinkA) == self:GetItemID(itemLinkB)
end

--- Extracts the item ID from an itemLink
--- @param itemLink string
--- @return number|nil
function CollectorHelper:GetItemID(itemLink)
    return tonumber(itemLink:match("item:(%d+)"))
end
