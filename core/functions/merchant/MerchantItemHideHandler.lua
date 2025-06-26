local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- Handles hiding and adapting merchant items in both default and SLE interfaces
-- ============================================================================

--- Processes all merchant items and hides, shows, or adapts them
--- based on collection status, settings, and interface mode (default or SLE).
function CollectorHelper:MerchantItemHideHandler()
    local size = MERCHANT_ITEMS_PER_PAGE

    -- Determine if ElvUI SLE merchant frame is in use
    local isSLE = _G["SLE_ListMerchantFrame"] ~= nil
    if isSLE then
        size = GetMerchantNumItems() or 1
    end

    -- Hook SLE merchant interface if not already done
    if isSLE and not self.isElvuiSLE then
        CollectorHelper:AdaptSLE()
    end

    for i = 1, size do
        local itemIndex = (MerchantFrame.page - 1) * size + i
        if isSLE then
            itemIndex = i
        end

        local itemId = GetMerchantItemID(itemIndex)
        if itemId then
            -- Cache merchant item ID by index for later actions (equip/destroy)
            self.db.merchantBoeIndex[i] = itemId

            local source = CollectorHelper:GetItemDetails(itemId)
            local shopItemState = CollectorHelper:CheckShopID(source)

            -- Hide existing equip buttons if already present
            local equipBtn = _G["MerchantItem" .. i .. "ActionFrameBtn"]
            if equipBtn then
                equipBtn:Hide()
            end

            -- ============================================================================
            -- CASE 1: Item already collected
            -- ============================================================================
            if shopItemState == 1 then
                if settings.hideMerchantOwned then
                    if not isSLE then
                        -- Default Blizzard merchant UI
                        SetItemButtonSlotVertexColor(_G["MerchantItem" .. i], 0.4, 0.4, 0.4)
                        _G["MerchantItem" .. i .. "ItemButton"]:Hide()
                        _G["MerchantItem" .. i .. "Name"]:SetText("")
                        _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Hide()
                        _G["MerchantItem" .. i .. "MoneyFrame"]:Hide()
                    else
                        -- SLE interface — hide matching buttons by comparing item IDs
                        for jk = 1, 10 do
                            local sleBtn = _G["SLE_ListMerchantFrame_Button" .. jk]
                            if sleBtn and sleBtn.link then
                                C_Item.RequestLoadItemDataByID(sleBtn.link)
                                local itId = C_Item.GetItemInfoInstant(sleBtn.link)
                                if itId == itemId then
                                    sleBtn:Hide()
                                end
                            end
                        end
                    end
                elseif self.forceShowMerchant then
                    -- Force show merchant item even if owned
                    if not isSLE then
                        local currencyIndex = GetMerchantItemCostInfo(itemIndex)
                        SetItemButtonSlotVertexColor(_G["MerchantItem" .. i], 1, 1, 1)
                        _G["MerchantItem" .. i .. "ItemButton"]:Show()
                        _G["MerchantItem" .. i .. "Name"]:SetText(source.name)
                        if currencyIndex == 0 then
                            _G["MerchantItem" .. i .. "MoneyFrame"]:Show()
                        else
                            _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Show()
                        end
                    else
                        for jk = 1, 10 do
                            local sleBtn = _G["SLE_ListMerchantFrame_Button" .. jk]
                            if sleBtn and sleBtn.link then
                                C_Item.RequestLoadItemDataByID(sleBtn.link)
                                local itId = C_Item.GetItemInfoInstant(sleBtn.link)
                                if itId == itemId then
                                    sleBtn:Show()
                                end
                            end
                        end
                    end
                end

            -- ============================================================================
            -- CASE 2: Item is in player bag and could be equipped/sold
            -- shopItemState == 10 → Owned BoE, 11 → Recipe, 12 → Cosmetic (currently disabled)
            -- ============================================================================
            elseif shopItemState == 10 or shopItemState == 11 or shopItemState == 12 then
                local isRecipeOrCosmetic = shopItemState == 11 or shopItemState == 12

                if not isSLE then
                    -- Update Blizzard UI with bag hint and equip buttons
                    _G["MerchantItem" .. i .. "Name"]:SetText("This item is in your bag")
                    _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Hide()
                    _G["MerchantItem" .. i .. "MoneyFrame"]:Hide()

                    local eqBtn = _G["MerchantItem" .. i .. "ActionFrameBtn"]
                    if not eqBtn then
                        CollectorHelper:MerchantEquipHandler(i, isRecipeOrCosmetic)
                    else
                        eqBtn:Show()
                    end
                else
                    -- Update SLE buttons visibility for bag item
                    for jk = 1, 10 do
                        local sleBtn = _G["SLE_ListMerchantFrame_Button" .. jk]
                        if sleBtn and sleBtn.link then
                            C_Item.RequestLoadItemDataByID(sleBtn.link)
                            local itId = C_Item.GetItemInfoInstant(sleBtn.link)
                            if itId == itemId then
                                sleBtn:Show()
                            end
                        end
                    end
                end
            end
        end
    end

    -- Reset force-show flag for future interactions
    self.forceShowMerchant = false
end
