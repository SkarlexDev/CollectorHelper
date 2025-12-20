local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
local COLORS = CollectorHelper.COLORS or {}

function CollectorHelper:UpdateShop()
    local itemData = {}
    local size = GetMerchantNumItems() or MERCHANT_ITEMS_PER_PAGE
    local currencyMap = {}
    local currencyMapAH = {}
    local currencyLink = {}
    local initialItemIndexMap = {}
    self.db.merchantBoeIndex = {}
    self.db.ahItems = {}

    CollectorHelper:MerchantItemHideHandler()

    local function AddCurrency(texture, value, link, isAhItem)
        if value == 0 then         
            return
        end
        if currencyMap[texture] then
            currencyMap[texture] = currencyMap[texture] + value
        else
            currencyMap[texture] = value
        end
        if link and currencyLink[texture] == nil then
            currencyLink[texture] = link
        end
        if link then
            local ci = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
            if ci then
                itemData[texture] = ci.quantity
            else
                itemData[texture] = C_Item.GetItemCount(link)
            end
        else
            itemData[texture] = GetMoney()
        end
        if isAhItem then
            currencyMapAH[texture] = currencyMapAH[texture] or link
        end
    end

    for i = 1, size do
        local itemIndex = i
        local itemId = GetMerchantItemID(itemIndex)
        if itemId then
            local source = CollectorHelper:GetItemDetails(itemId)
            local shopItemState = CollectorHelper:CheckShopID(source)
            if shopItemState == 0 then
                local itemsSources = 1
                local data = C_MerchantFrame.GetItemInfo(itemIndex)
                local price = data and data.price
                local multiplier = 1
                if settings.housingDuplicateCount > 1 and source.itemType == "Housing" then
                    local housingInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(source.itemId, true)
                    if housingInfo then
                        local difSetting = settings.housingDuplicateCount - housingInfo.numStored
                        if difSetting > 0 then
                            multiplier = difSetting
                        end
                    end
                end
                if price then                    
                    AddCurrency("MoneyCurrency", price * multiplier, nil, false)
                end

                local currencyIndex = GetMerchantItemCostInfo(itemIndex)
                for y = 1, currencyIndex do
                    local tex, val, link = GetMerchantItemCostItem(itemIndex, y)
                    local isAhItem = false
                    if link and self.doAhTrack then
                        local itSrc = CollectorHelper:GetItemDetails(link)
                        isAhItem = itSrc and itSrc.bindType == 0
                    end
                    AddCurrency(tex, val * multiplier, link, isAhItem)
                end

                initialItemIndexMap[itemIndex] = itemId
            end
        end
    end

    self.forceShowMerchant = false

    local costTable = {}
    local missingItem = false

    for tex, totalVal in pairs(currencyMap) do
        local display = ""
        local haveVal = itemData[tex]
        local isGold = tex == "MoneyCurrency"
        local perc = nil

        if isGold then
            display = " " .. CollectorHelper:FormatGoldAmount(GetMoneyString(totalVal, true))
        else
            display = "|T" .. tex .. ":16|t " .. totalVal
        end

        if haveVal then
            perc = (haveVal / totalVal) * 100
            if perc > 100 then perc = 100 end
            if isGold then
                haveVal = CollectorHelper:FormatGoldAmount(GetMoneyString(haveVal, true))
            end
            display = display .. " - " .. CollectorHelper:TextCFormat(COLORS.green, haveVal)
        end

        table.insert(costTable, { display = display, linkItem = currencyLink[tex], percentage = perc })

        local ahLink = currencyMapAH[tex]
        if ahLink then
            local costRemaining = totalVal
            if haveVal then costRemaining = costRemaining - haveVal end
            local ahDisplay = " |T" .. tex .. ":16|t " .. ahLink
            table.insert(self.db.ahItems, {
                display = ahDisplay,
                linkItem = currencyLink[tex],
                quantity = CollectorHelper:TextCFormat(COLORS.white, costRemaining),
                clear = true
            })
        end
        missingItem = true
    end

    self.doAhTrack = false

    if missingItem then
        self.merchantCost:Hide()
        self.mainScrollableContent.scrollFrame:Show()
        self.mainScrollableContent.UpdateRows(costTable)
    else
        self.merchantCost:Show()
        self.mainScrollableContent.scrollFrame:Hide()
        self.mainScrollableContent.UpdateRows(costTable)
    end

    local sortedIndices = {}
    for idx in pairs(initialItemIndexMap) do
        table.insert(sortedIndices, idx)
    end
    table.sort(sortedIndices)
    self.db.itemIndexMap = {}
    for _, idx in ipairs(sortedIndices) do
        self.db.itemIndexMap[idx] = initialItemIndexMap[idx]
    end
end
