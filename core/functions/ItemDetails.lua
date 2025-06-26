local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- Retrieve item details by ItemID, request data if not loaded yet
-- @param itemID number Item identifier
-- @return table|nil Table with item details or nil if not available
--    Fields:
--      itemId number - Item ID
--      name string|nil - Item name
--      link string|nil - Item link
--      itemType string|nil - Item type (e.g., "Armor", "Weapon")
--      itemSubType string|nil - Item subtype (e.g., "Plate", "Sword")
--      itemEquipLoc string|nil - Equip location (e.g., "INVTYPE_HEAD")
--      bindType number|nil - Bind type (e.g., 1=Bind on Pickup)
--      itemQuality number|nil - Quality of the item
-- ============================================================================

function CollectorHelper:GetItemDetails(itemID)
    C_Item.RequestLoadItemDataByID(itemID)
    local name, link, quality, _, _, itemType, itemSubType, _, equipLoc, _, _, _, _, bindType = C_Item.GetItemInfo(itemID)
    if name == nil then
        return nil
    end
    return {
        itemId = itemID,
        name = name,
        link = link,
        itemType = itemType,
        itemSubType = itemSubType,
        itemEquipLoc = equipLoc,
        bindType = bindType,
        itemQuality = quality
    }
end
