local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- Equip handler: builds UI buttons to use or destroy a BoE item from the merchant
-- ============================================================================

--- Builds "Sell" and "Destroy" buttons for a merchant item, allowing the user to
--- quickly use or destroy the item directly from the merchant frame.
---
--- @param i number The merchant item index (1-based)
--- @param isRecipeOrCosmetic boolean True if the item is a recipe or cosmetic (buttons won't be shown in this case)
function CollectorHelper:MerchantEquipHandler(i, isRecipeOrCosmetic)
    if isRecipeOrCosmetic then return end

    -- Parent item button from merchant frame
    local itemFrame = _G["MerchantItem" .. i .. "ItemButton"]

    -- Create container for Sell/Destroy buttons
    local mActionFrame = CollectorHelper:FrameBuilder({
        frameName = "MerchantItem" .. i .. "ActionFrameBtn",
        parent = itemFrame,
        width = 110,
        height = 20,
        point = { pos = "BOTTOMRIGHT", x = 115, y = -10 }
    })
    mActionFrame:SetBackdropColor(0, 0, 0, 0)
    mActionFrame:SetBackdropBorderColor(0, 0, 0, 0)

    -- ============================================================================
    -- Sell Button
    -- ============================================================================

    --- Creates a "Sell" button to equip or use the matching item in bags.
    local aBtn = CollectorHelper:ButtonBuilder({
        buttonName = "MerchantItem" .. i .. "CHASBtn",
        parent = mActionFrame,
        text = "Sell",
        width = 45,
        height = 22,
        point = { pos = "BOTTOMLEFT", x = 0, y = 0 }
    })

    aBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            local index = tonumber(self:GetName():match("%d+"))
            local sourceId = CollectorHelper.db.merchantBoeIndex[index]
            local source = CollectorHelper:GetItemDetails(sourceId)
            local slots = CollectorHelper:getItemSlot(source.itemEquipLoc)

            -- Try to use the item if it's found in bags
            if slots ~= 0 then
                for bag = 0, NUM_BAG_SLOTS do
                    local numSlots = C_Container.GetContainerNumSlots(bag)
                    for slot = 1, numSlots do
                        local bagItem = C_Container.GetContainerItemInfo(bag, slot)
                        if bagItem and bagItem.itemID == sourceId then
                            C_Container.UseContainerItem(bag, slot)
                            return
                        end
                    end
                end
            end
        end
    end)

    -- ============================================================================
    -- Destroy Button
    -- ============================================================================

    --- Creates a "Destroy" button to remove the item from player's inventory.
    local aDBtn = CollectorHelper:ButtonBuilder({
        buttonName = "MerchantItem" .. i .. "CHADBtn",
        parent = mActionFrame,
        text = "Destroy",
        width = 50,
        height = 22,
        point = { pos = "BOTTOMRIGHT", x = -8, y = 0 }
    })

    aDBtn:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            local index = tonumber(self:GetName():match("%d+"))
            local sourceId = CollectorHelper.db.merchantBoeIndex[index]
            local source = CollectorHelper:GetItemDetails(sourceId)
            local slots = CollectorHelper:getItemSlot(source.itemEquipLoc)

            -- Try to delete the item if found in bags
            if slots ~= 0 then
                for bag = 0, NUM_BAG_SLOTS do
                    local numSlots = C_Container.GetContainerNumSlots(bag)
                    for slot = 1, numSlots do
                        local bagItem = C_Container.GetContainerItemInfo(bag, slot)
                        if bagItem and bagItem.itemID == sourceId then
                            ClearCursor()
                            C_Container.PickupContainerItem(bag, slot)
                            DeleteCursorItem()
                            return
                        end
                    end
                end
            end
        end
    end)
end
