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
    local sleButtonsByItemID
    if isSLE then
        size = GetMerchantNumItems() or 1
        sleButtonsByItemID = {}
        for buttonIndex = 1, 10 do
            local button = _G["SLE_ListMerchantFrame_Button" .. buttonIndex]
            local itemID = button and button.link and C_Item.GetItemInfoInstant(button.link)
            if itemID then
                local buttons = sleButtonsByItemID[itemID]
                if not buttons then
                    buttons = {}
                    sleButtonsByItemID[itemID] = buttons
                end
                buttons[#buttons + 1] = button
            end
        end
    end

    local function SetSLEItemShown(itemID, shown)
        local buttons = sleButtonsByItemID[itemID]
        if buttons then
            for _, button in ipairs(buttons) do
                button:SetShown(shown)
            end
        end
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
                        SetSLEItemShown(itemId, false)
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
                        SetSLEItemShown(itemId, true)
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
                    SetSLEItemShown(itemId, true)
                end
            end
        end
    end

    -- Reset force-show flag for future interactions
    self.forceShowMerchant = false
end
