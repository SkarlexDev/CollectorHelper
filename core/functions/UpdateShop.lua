local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
local COLORS = CollectorHelper.COLORS or {}

--- Updates the merchant shop UI and internal state, processing items, currencies, 
--- and auction house tracking data.
---
--- Collects merchant items info, determines item states, aggregates currency info, 
--- and updates UI elements accordingly.
function CollectorHelper:UpdateShop()
    local itemData = {}                  -- Holds currency quantities the player owns
    local size = GetMerchantNumItems() or MERCHANT_ITEMS_PER_PAGE
    local currencyMap = {}              -- Sum of currency costs per currency texture
    local currencyMapAH = {}            -- Auction House tracked items map (texture -> item name)
    local currencyLink = {}             -- Currency texture to item link mapping
    local initialItemIndexMap = {}      -- Maps merchant item index to item ID
    self.db.merchantBoeIndex = {}       -- Reset BoE merchant items index cache
    self.db.ahItems = {}                -- Reset Auction House tracked items list

    -- Update visibility and state of merchant items (hiding collected, etc.)
    CollectorHelper:MerchantItemHideHandler()

    -- Iterate over all merchant items to process cost and item state
    for i = 1, size do
        local itemIndex = i
        local itemId = GetMerchantItemID(itemIndex)
        if itemId ~= nil then
            local source = CollectorHelper:GetItemDetails(itemId)
            local shopItemState = CollectorHelper:CheckShopID(source)

            -- Only process items not already collected or owned
            if shopItemState == 0 then
                local currencyIndex = GetMerchantItemCostInfo(itemIndex)
                local itemsSources = 1 -- Placeholder for multiple sources if needed
                
                if currencyIndex == 0 then
                    -- Item costs gold
                    local data = C_MerchantFrame.GetItemInfo(itemIndex)
                    local price = data.price
                    if price == nil then
                        return -- Abort if price is unavailable
                    end
                    for _ = 1, itemsSources do
                        local itemTexture = "MoneyCurrency" -- Special texture for gold
                        if itemTexture then
                            currencyLink[itemTexture] = nil
                            -- Accumulate total gold cost
                            if currencyMap[itemTexture] then
                                currencyMap[itemTexture] = currencyMap[itemTexture] + price
                            else
                                currencyMap[itemTexture] = price
                            end

                            -- Format player's current money amount (gold, silver, copper)
                            local money = GetMoney()
                            local gold = floor(money / 1e4)
                            local silver = floor(money / 100 % 100)
                            local copper = money % 100
                            if gold > 0 then
                                money = money - (silver * 100) - copper
                            end

                            local multiplier = 1
                            if settings.housingDuplicateCount > 1 then
                                local isHousing = source.itemType == "Housing"
                                if isHousing then
                                    local housingInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(source.itemId, true)
                                    if housingInfo then
                                        local difSetting = settings.housingDuplicateCount - housingInfo.numStored
                                        if difSetting > 0 then
                                                multiplier = difSetting                                   
                                        end
                                    end
                                end
                            end                            
                            itemData[itemTexture] = money * multiplier
                        end
                    end
                else
                    -- Item costs one or more currencies/items (non-gold)
                    for y = 1, currencyIndex do
                        local itemTexture, itemValue, link = GetMerchantItemCostItem(itemIndex, y)
                        local isItemForAh = false
                        local itemName = ""
                        if link ~= nil and self.doAhTrack == true then
                            local itSrc = CollectorHelper:GetItemDetails(link)
                            isItemForAh = itSrc ~= nil and itSrc.bindType ~= nil and itSrc.bindType == 0
                            if itSrc ~= nil then
                                itemName = itSrc.name
                            end
                        end

                        for _ = 1, itemsSources do
                            if itemTexture then
                                -- Map texture to link once
                                if currencyLink[itemTexture] == nil then
                                    currencyLink[itemTexture] = link
                                end
                                -- Sum the total currency cost per texture
                                if currencyMap[itemTexture] then
                                    currencyMap[itemTexture] = currencyMap[itemTexture] + itemValue
                                else
                                    currencyMap[itemTexture] = itemValue
                                end

                                -- Get current player quantity of this currency or item
                                local ci = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
                                if ci ~= nil then
                                    itemData[itemTexture] = ci.quantity
                                else
                                    local count = C_Item.GetItemCount(link)
                                    itemData[itemTexture] = count
                                end

                                -- Track items that are bind-on-pickup for auction house usage
                                if isItemForAh then
                                    currencyMapAH[itemTexture] = itemName
                                end
                            end
                        end
                    end
                end
                initialItemIndexMap[itemIndex] = itemId
            end
        end
    end

    -- Reset force show flag (used elsewhere to temporarily show collected items)
    self.forceShowMerchant = false

    -- Prepare table for UI update with currency cost display info
    local costTable = {}

    local missingItem = false
    for itemTexture, totalValue in pairs(currencyMap) do
        local display = ""
        local haveCurencyVal = itemData[itemTexture]
        local isGold = itemTexture == "MoneyCurrency"
        local percentage = nil

        if isGold then
            display = display .. " " .. CollectorHelper:FormatGoldAmount(GetMoneyString(totalValue, true))
        else
            display = display .. "|T" .. itemTexture .. ":16|t " .. totalValue
        end

        if haveCurencyVal ~= nil then
            percentage = (haveCurencyVal / totalValue) * 100
            if percentage > 100 then
                percentage = 100
            end

            if isGold then
                haveCurencyVal = CollectorHelper:FormatGoldAmount(GetMoneyString(haveCurencyVal, true))
            end

            -- Add colored text for player's current currency amount
            display = display .. " - " .. CollectorHelper:TextCFormat(COLORS.green, haveCurencyVal)
        end

        table.insert(costTable, {
            display = display,
            linkItem = currencyLink[itemTexture],
            percentage = percentage
        })

        -- Auction House tracking for bind-on-pickup items
        local ahTrack = currencyMapAH[itemTexture]
        if ahTrack then
            local cost = totalValue
            if haveCurencyVal then
                cost = cost - haveCurencyVal
            end

            display = " |T" .. itemTexture .. ":16|t " .. " " .. ahTrack
            table.insert(self.db.ahItems, {
                display = display,
                linkItem = currencyLink[itemTexture],
                quantity = CollectorHelper:TextCFormat(COLORS.white, cost),
                clear = true
            })
        end
        missingItem = true
    end

    -- Auction house tracking flag reset
    self.doAhTrack = false

    -- Show or hide the merchant cost UI frame depending on whether there are costs
    if missingItem then
        self.merchantCost:Hide()
        self.mainScrollableContent.scrollFrame:Show()
        self.mainScrollableContent.UpdateRows(costTable)
    else
        self.merchantCost:Show()
        self.mainScrollableContent.scrollFrame:Hide()
        self.mainScrollableContent.UpdateRows(costTable)
    end

    -- Store and sort merchant item indices for internal usage
    local sortedItemIndices = {}
    for itemIndex in pairs(initialItemIndexMap) do
        table.insert(sortedItemIndices, itemIndex)
    end
    table.sort(sortedItemIndices)

    self.db.itemIndexMap = {}
    for _, itemIndex in ipairs(sortedItemIndices) do
        self.db.itemIndexMap[itemIndex] = initialItemIndexMap[itemIndex]
    end
end
