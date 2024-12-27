local _, app = ...

-- Initialize variables and constants
local merchantBoeIndex = {}
local COLORS = app.COLORS
local isAdapted = false

-- Adapts the interface for ElvUI Shadow & Light edit (SLE)
function app:adaptSLE()
    local scrollFrame = _G['SLE_ListMerchantScrollFrame']
    local orgScript1 = scrollFrame:GetScript("OnVerticalScroll")

    local function OnVerticalScroll(self, offset)
        orgScript1(self, offset)
        app:updateShop()
    end

    scrollFrame:SetScript("OnVerticalScroll", OnVerticalScroll)

    local sleFrame = _G["SLE_ListMerchantFrame"]
    local orgScript2 = sleFrame:GetScript("OnEvent")

    local function OnEvent(self, event, ...)
        orgScript2(self, event, ...)
        C_Timer.After(0.25, function()
            app:updateShop()
        end)
        C_Timer.After(0.50, function()
            app:updateShop()
        end)
    end
    sleFrame:SetScript("OnEvent", OnEvent)

    -- search
    local search = _G["SLE_ListMerchantFrameSearch"]
    local s1 = search:GetScript("OnTextChanged")
    local s2 = search:GetScript("OnShow")
    local s3 = search:GetScript("OnEnterPressed")
    local s4 = search:GetScript("OnEscapePressed")
    local s5 = search:GetScript("OnEditFocusLost")
    local s6 = search:GetScript("OnEditFocusGained")

    local function s1s(self)
        s1(self)
        app:updateShop()
    end

    local function s2s(self)
        s2(self)
        app:updateShop()
    end

    local function s3s(self)
        s3(self)
        app:updateShop()
    end

    local function s4s(self)
        s4(self)
        app:updateShop()
    end

    local function s5s(self)
        s5(self)
        app:updateShop()
    end

    local function s6s(self)
        s6(self)
        app:updateShop()
    end

    search:SetScript("OnTextChanged", s1s)
    search:SetScript("OnShow", s2s)
    search:SetScript("OnEnterPressed", s3s)
    search:SetScript("OnEscapePressed", s4s)
    search:SetScript("OnEditFocusLost", s5s)
    search:SetScript("OnEditFocusGained", s6s)

    isAdapted = true
end

-- Handles hiding and adapting merchant items
function app:merchantItemHideHandler()
    local size = MERCHANT_ITEMS_PER_PAGE ---@type number

    local isSLE = _G["SLE_ListMerchantFrame"] ~= nil -- Check if SLE is active
    if isSLE then size = GetMerchantNumItems() or 1 end
    if isSLE and not isAdapted then app:adaptSLE() end

    for i = 1, size do
        local itemIndex = (MerchantFrame.page - 1) * size + i ---@type number
        if isSLE then
            itemIndex = i
        end
        local itemId = GetMerchantItemID(itemIndex) ---@type number|nil

        if itemId then
            merchantBoeIndex[i] = itemId
            local source = app:getItemDetails(itemId)
            local shopItemState = app:checkShopID(source)
            local equipBtn = _G["MerchantItem" .. i .. "ActionFrameBtn"] ---@type CH.Btn
            if equipBtn then
                equipBtn:Hide()
            end
            -- Handle different item states
            if shopItemState == 1 then
                if settings.hideMerchantOwned then
                    if not isSLE then
                        SetItemButtonSlotVertexColor(_G["MerchantItem" .. i], 0.4, 0.4, 0.4)
                        _G["MerchantItem" .. i .. "ItemButton"]:Hide()
                        _G["MerchantItem" .. i .. "Name"]:SetText("")
                        _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Hide()
                        _G["MerchantItem" .. i .. "MoneyFrame"]:Hide()
                    else
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
                elseif app.forceShowMerchant then
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
            elseif shopItemState == 10 or shopItemState == 11 then
                if not isSLE then
                    local isRecipe = shopItemState == 11
                    _G["MerchantItem" .. i .. "Name"]:SetText("This item is in your bag")
                    _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Hide()
                    _G["MerchantItem" .. i .. "MoneyFrame"]:Hide()
                    local eqBtn = _G["MerchantItem" .. i .. "ActionFrameBtn"]
                    if not eqBtn then
                        app:merchantEquipHandler(i, isRecipe)
                    else
                        eqBtn:Show()
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
        end
    end
    app.forceShowMerchant = false
end

-- Update the shop items in the merchant frame


function app:updateShop()
    local itemData = {}
    local size = GetMerchantNumItems() or MERCHANT_ITEMS_PER_PAGE
    local currencyMap = {}
    local currencyMapAH = {}
    local currencyLink = {}
    local initialItemIndexMap = {}
    merchantBoeIndex = {}
    app.ahItems = {} -- Reset auction house items

    app:merchantItemHideHandler()

    for i = 1, size do
        local itemIndex = i
        local itemId = GetMerchantItemID(itemIndex) ---@type number|nil
        if itemId ~= nil then
            local source = app:getItemDetails(itemId)
            local shopItemState = app:checkShopID(source)

            if shopItemState == 0 then
                local currencyIndex = GetMerchantItemCostInfo(itemIndex)
                local itemsSources = 1
                if currencyIndex == 0 then
                    -- is gold
                    local _, _, price, _, _, _, _, _ = GetMerchantItemInfo(itemIndex)
                    for _ = 1, itemsSources do
                        local itemTexture = "MoneyCurrency"
                        if itemTexture then
                            currencyLink[itemTexture] = nil
                            if currencyMap[itemTexture] then
                                currencyMap[itemTexture] = currencyMap[itemTexture] + price
                            else
                                currencyMap[itemTexture] = price
                            end
                            local money = GetMoney()
                            local gold = floor(money / 1e4)
                            local silver = floor(money / 100 % 100)
                            local copper = money % 100
                            if gold > 0 then
                                money = money - (silver * 100) - copper
                            end
                            itemData[itemTexture] = money
                        end
                    end
                else
                    for y = 1, currencyIndex do
                        local itemTexture, itemValue, link = GetMerchantItemCostItem(itemIndex, y)
                        local isItemForAh = false
                        local itemName = ""
                        if link ~= nil and app.doAhTrack == true then
                            local itSrc = app:getItemDetails(link)
                            isItemForAh = itSrc ~= nil and itSrc.bindType ~= nil and itSrc.bindType == 0
                            if itSrc ~= nil then
                                itemName = itSrc.name
                            end
                        end
                        for _ = 1, itemsSources do
                            if itemTexture then
                                if currencyLink[itemTexture] == nil then
                                    currencyLink[itemTexture] = link
                                end
                                if currencyMap[itemTexture] then
                                    currencyMap[itemTexture] = currencyMap[itemTexture] + itemValue
                                else
                                    currencyMap[itemTexture] = itemValue
                                end
                                local ci = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
                                if ci ~= nil then
                                    itemData[itemTexture] = ci.quantity
                                else
                                    local count = C_Item.GetItemCount(link)
                                    itemData[itemTexture] = count
                                end
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
    app.forceShowMerchant = false

    -- Process collected currency data
    local costTable = {}

    local missingItem = false
    for itemTexture, totalValue in pairs(currencyMap) do
        local display = ""
        local haveCurencyVal = itemData[itemTexture]
        local isGold = itemTexture == "MoneyCurrency"
        local percentage = nil
        if isGold then
            display = display .. " " .. app:formatGoldAmount(GetMoneyString(totalValue, true))
        else
            display = display .. "|T" .. itemTexture .. ":16|t " .. totalValue
        end
        if haveCurencyVal ~= nil then
            percentage = (haveCurencyVal / totalValue) * 100
            if percentage > 100 then
                percentage = 100
            end
            if isGold then
                haveCurencyVal = app:formatGoldAmount(GetMoneyString(haveCurencyVal, true))
            end
            display = display .. " - " ..
                app:textCFormat(COLORS.green, haveCurencyVal)
        end

        table.insert(costTable, {
            display = display,
            linkItem = currencyLink[itemTexture],
            percentage = percentage
        })

        local ahTrack = currencyMapAH[itemTexture]
        if ahTrack then
            local cost = totalValue
            if haveCurencyVal then
                cost = cost - haveCurencyVal
            end
            display = " |T" .. itemTexture .. ":16|t " .. " " .. ahTrack
            --for i = 1, 10, 1 do
            table.insert(app.ahItems, {
                display = display,
                linkItem = currencyLink[itemTexture],
                quantity = app:textCFormat(COLORS.white, cost),
                clear = true
            })
            --end
        end
        missingItem = true
    end

    app.doAhTrack = false

    -- Show or hide the merchant cost frame based on item availability
    if missingItem then
        app.merchantCost:Hide()
        app.mainScrollableContent.scrollFrame:Show()
        app.mainScrollableContent.UpdateRows(costTable)
    else
        app.merchantCost:Show()
        app.mainScrollableContent.scrollFrame:Hide()
        app.mainScrollableContent.UpdateRows(costTable)
    end

    -- Sort and store item indices
    local sortedItemIndices = {}
    for itemIndex in pairs(initialItemIndexMap) do
        table.insert(sortedItemIndices, itemIndex)
    end
    table.sort(sortedItemIndices)


    app.itemIndexMap = {}
    for _, itemIndex in ipairs(sortedItemIndices) do
        app.itemIndexMap[itemIndex] = initialItemIndexMap[itemIndex]
    end
end

-- ========================
-- Section: Additional merchant buttons
-- ========================
-- Equip item from merchant frame
function app:merchantEquipHandler(i, isRecipe)
    local itemFrame = _G["MerchantItem" .. i .. "ItemButton"]
    local mActionFrame = app:frameBuilder({
        frameName = "MerchantItem" .. i .. "ActionFrameBtn",
        parent = itemFrame,
        width = 110,
        height = 20,
        point = {
            pos = "BOTTOMRIGHT",
            x = 115,
            y = -10,
        }
    })
    mActionFrame:SetBackdropColor(0, 0, 0, 0)
    mActionFrame:SetBackdropBorderColor(0, 0, 0, 0)
    if isRecipe then
        local aBtn = app:buttonBuilder({
            buttonName = "MerchantItem" .. i .. "CHASBtn",
            parent = mActionFrame,
            text = "Info",
            width = 45,
            height = 22,
            point = {
                pos = "BOTTOMLEFT",
                x = 0,
                y = 0,
            }
        })
        aBtn:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                print(app:textCFormat(COLORS.yellow, "CH:"), "The recipe sync popup will also open if the merchant has any recipes. After learning a recipe, it will be synced to prevent it from appearing again with the merchant, you may reopen the popup with /ch recipe command")
            end
        end)

    else
        local aBtn = app:buttonBuilder({
            buttonName = "MerchantItem" .. i .. "CHASBtn",
            parent = mActionFrame,
            text = "Sell",
            width = 45,
            height = 22,
            point = {
                pos = "BOTTOMLEFT",
                x = 0,
                y = 0,
            }
        })

        aBtn:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                local index = tonumber(self:GetName():match("%d+"))
                local sourceId = merchantBoeIndex[index]
                local source = app:getItemDetails(sourceId)
                local slots = app:getItemSlot(source.itemEquipLoc)
                if slots ~= 0 then
                    -- Find the item in the bags and use it
                    for bag = 0, NUM_BAG_SLOTS do
                        for slot = 1, C_Container.GetContainerNumSlots(bag) do
                            local bagItem = C_Container.GetContainerItemInfo(bag, slot)
                            if bagItem ~= nil then
                                if bagItem.itemID == sourceId then
                                    C_Container.UseContainerItem(bag, slot)
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end)

        local aDBtn = app:buttonBuilder({
            buttonName = "MerchantItem" .. i .. "CHADBtn",
            parent = mActionFrame,
            text = "Destroy",
            width = 50,
            height = 22,
            point = {
                pos = "BOTTOMRIGHT",
                x = -8,
                y = 0,
            }
        })
        aDBtn:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                local index = tonumber(self:GetName():match("%d+"))
                local sourceId = merchantBoeIndex[index]
                local source = app:getItemDetails(sourceId)
                local slots = app:getItemSlot(source.itemEquipLoc)
                if slots ~= 0 then
                    -- Find the item in the bags and use it
                    for bag = 0, NUM_BAG_SLOTS do
                        for slot = 1, C_Container.GetContainerNumSlots(bag) do
                            local bagItem = C_Container.GetContainerItemInfo(bag, slot)
                            if bagItem ~= nil then
                                if bagItem.itemID == sourceId then
                                    --C_Container.UseContainerItem(bag, slot)
                                    ClearCursor()
                                    C_Container.PickupContainerItem(bag, slot)
                                    DeleteCursorItem()
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end
