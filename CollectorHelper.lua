local itemIndexMap = {}
local forceShowMerchant = false
local merchantIndex = {}

SLASH_COLLECTORHELPER1 = "/ch"
SlashCmdList["COLLECTORHELPER"] = function()
  settings.hideMerchantOwned = not settings.hideMerchantOwned
  updateShop()
end

-- ========================
-- Section: Merchant Frame build
-- ========================
local merchantFrameCost = frameBuilder({
  frameName = "CollectorHelper_MerchantButton",
  parent = MerchantFrame,
  width = 280,
  height = MerchantFrame:GetHeight(),
  point = {
    pos = "TOPRIGHT",
    x = 280,
    y = 0,
  },
  titleBuilder = {
    text = textCFormat(COLORS.yellow, "Currency Needed to Collect this page"),
    point = {
      pos = "TOP",
      x = 0,
      y = -8,
    }
  }
})

-- cost details
local marchantCost = fontBuilder({
  parent = merchantFrameCost,
  text = "",
  point = {
    pos = "TOPLEFT",
    x = 35,
    y = -40,
  }
})

local m1s = buttonBuilder({
  buttonName = "Collector_MBuyButton",
  parent = merchantFrameCost,
  text = "Buy All Possible",
  width = 120,
  height = 22,
  point = {
    pos = "BOTTOMLEFT",
    x = 18,
    y = 8,
  }
})

m1s:HookScript("OnClick", function(self, button)
  if button == "LeftButton" then
    for itemIndex, itemId in pairs(itemIndexMap) do
      local costInfo = GetMerchantItemCostInfo(itemIndex)
      if costInfo == 0 or CanAffordMerchantItem(itemIndex) then
        BuyMerchantItem(itemIndex, 1)
      end
    end
  end
end)

local m2s = buttonBuilder({
  buttonName = "Collector_MSHButton",
  parent = merchantFrameCost,
  text = "Show/hide owned",
  width = 120,
  height = 22,
  point = {
    pos = "BOTTOMRIGHT",
    x = -18,
    y = 8,
  }
})

m2s:HookScript("OnClick", function(self, button)
  if button == "LeftButton" then
    settings.hideMerchantOwned = not settings.hideMerchantOwned
    if settings.hideMerchantOwned == false then
      forceShowMerchant = true
    end
    updateShop()
  end
end)


-- ========================
-- Section: Item owned logic
-- ========================
local function isToyItem(itemId)
  if C_ToyBox.GetToyInfo(itemId) then
    return true
  end
  return false
end

local function IsMountItem(itemId)
  if C_MountJournal.GetMountFromItem(itemId) then
    return true
  end
  return false
end

local function IsPetItem(itemId)
  if C_PetJournal.GetPetInfoByItemID(itemId) then
    return true
  end
  return false
end

-- check set owned
local function setOwned(itemSet)
  local ids = C_TransmogSets.GetAllSourceIDs(itemSet)
  for _, sourceID in ipairs(ids) do
    local info = C_TransmogCollection.GetSourceInfo(sourceID)
    if not info.isCollected then return false end
  end
  return true
end

-- check item owned from merchant
local function checkShopID(source)
  -- 0 false, 1 true, 2 ignore
  if source == nil or source.itemId == nil then
    return 0
  end

  local isToy = isToyItem(source.itemId)
  if isToy then
    return PlayerHasToy(source.itemId) and 1 or 0
  end

  local isMount = IsMountItem(source.itemId)
  if isMount then
    local mountID = C_MountJournal.GetMountFromItem(source.itemId)
    local playerKnowsMount = select(11, C_MountJournal.GetMountInfoByID(mountID))
    return playerKnowsMount and 1 or 0
  end

  local IsPet = IsPetItem(source.itemId)
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
    return setOwned(itemSetId) and 1 or 0
  elseif isItemHeirloom then
    return C_Heirloom.PlayerHasHeirloom(source.itemId) and 1 or 0
  else
    local itemAppearanceID, _ = C_TransmogCollection.GetItemInfo(source.itemId)
    if itemAppearanceID == nil then
      local sourceID = GetSourceID(source.link)
      if sourceID ~= nil then
        return C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID) and 1 or 0
      else
        return 2 -- ignore item
      end
    else
      local r = C_TransmogCollection.PlayerHasTransmog(source.itemId) and 1 or 0
      if r == 0 and source.bindType == 2 then
        if playerHasItemInBag(source.itemId) == true then
          return 10
        end
      end
      return r
    end
  end
end

function playerHasItemInBag(itemCheckId)
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

-- ========================
-- Section: Merchant items
-- ========================
function updateShop()
  local itemData = {}
  local size = MERCHANT_ITEMS_PER_PAGE
  local currencyMap = {}
  local initialItemIndexMap = {}
  merchantIndex = {}

  for i = 1, size do
    local itemIndex = (MerchantFrame.page - 1) * size + i
    local itemId = GetMerchantItemID(itemIndex)
    if itemId ~= nil then
      merchantIndex[i] = itemId
      local source = getItemDetails(itemId)
      local shopItemState = checkShopID(source)
      local equipBtn = _G["MerchantItem" .. i .. "EquipBtn"]
      if equipBtn ~= nil then
        equipBtn:Hide()
      end
      if shopItemState == 1 then
        if settings.hideMerchantOwned then
          SetItemButtonSlotVertexColor(_G["MerchantItem" .. i], 0.4, 0.4, 0.4)
          _G["MerchantItem" .. i .. "ItemButton"]:Hide()
          _G["MerchantItem" .. i .. "Name"]:SetText("")
          _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Hide()
          _G["MerchantItem" .. i .. "MoneyFrame"]:Hide()
        elseif forceShowMerchant == true then
          local currencyIndex = GetMerchantItemCostInfo(itemIndex)
          SetItemButtonSlotVertexColor(_G["MerchantItem" .. i], 1, 1, 1)
          _G["MerchantItem" .. i .. "ItemButton"]:Show()
          _G["MerchantItem" .. i .. "Name"]:SetText(source.name)
          if currencyIndex == 0 then
            _G["MerchantItem" .. i .. "MoneyFrame"]:Show()
          else
            _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Show()
          end
        end
      elseif shopItemState == 0 then
        local currencyIndex = GetMerchantItemCostInfo(itemIndex)
        if currencyIndex == 0 then
          -- is gold
          local _, _, price, _, _, _, _, _ = GetMerchantItemInfo(itemIndex)
          local itemTexture = "MoneyCurrency"
          if itemTexture then
            if currencyMap[itemTexture] then
              currencyMap[itemTexture] = currencyMap[itemTexture] + price
            else
              currencyMap[itemTexture] = price
            end
            local count = GetMoney()
            itemData[itemTexture] = count
          end
        else
          for y = 1, currencyIndex do
            local itemTexture, itemValue, link, _ = GetMerchantItemCostItem(itemIndex, y)
            if itemTexture then
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
            end
          end
        end
        initialItemIndexMap[itemIndex] = itemId
      elseif shopItemState == 10 then
        -- item is in bag should equip to learn
        _G["MerchantItem" .. i .. "Name"]:SetText("This item is in your bag")
        _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Hide()
        _G["MerchantItem" .. i .. "MoneyFrame"]:Hide()
        local eqBtn = _G["MerchantItem" .. i .. "EquipBtn"]
        if eqBtn == nil then
          merchantEquipHandler(i)
        else
          eqBtn:Show()
        end
      else
        -- (ignored items)
      end
    end
  end
  forceShowMerchant = false

  local cost = ""
  for itemTexture, totalValue in pairs(currencyMap) do
    local haveCurencyVal = itemData[itemTexture]
    local isGold = itemTexture == "MoneyCurrency"
    if isGold then
      cost = cost .. formatGoldAmount(GetMoneyString(totalValue, true))
    else
      cost = cost .. "|T" .. itemTexture .. ":16|t " .. totalValue
    end
    if haveCurencyVal ~= nil then
      local percentage = (haveCurencyVal / totalValue) * 100
      if percentage > 100 then
        percentage = 100
      end
      if isGold then
        haveCurencyVal = formatGoldAmount(GetMoneyString(haveCurencyVal, true))
      end
      cost = cost .. " - " ..
          textCFormat(COLORS.green, haveCurencyVal) .. " (" .. string.format("%.2f", percentage) .. "%)"
    end
    cost = cost .. "\n\n"
  end

  if cost == "" then
    cost = textCFormat(COLORS.green, "You have everything on this page")
  end
  marchantCost:SetText(cost)

  -- Create a sorted list of itemIndex keys
  local sortedItemIndices = {}
  for itemIndex in pairs(initialItemIndexMap) do
    table.insert(sortedItemIndices, itemIndex)
  end
  table.sort(sortedItemIndices)

  -- Create a new sorted map
  itemIndexMap = {}
  for _, itemIndex in ipairs(sortedItemIndices) do
    itemIndexMap[itemIndex] = initialItemIndexMap[itemIndex]
  end
end

-- Equip item from merchant frame
function merchantEquipHandler(i)
  local itemFrame = _G["MerchantItem" .. i .. "ItemButton"]
  local equipBtn = buttonBuilder({
    buttonName = "MerchantItem" .. i .. "EquipBtn",
    parent = itemFrame,
    text = "Equip",
    width = 60,
    height = 22,
    point = {
      pos = "BOTTOMRIGHT",
      x = 85,
      y = -4,
    }
  })
  equipBtn:HookScript("OnClick", function(self, button)
    if button == "LeftButton" then
      local index = tonumber(self:GetName():match("%d+"))
      local sourceId = merchantIndex[index]
      local source = getItemDetails(sourceId)
      local slots = getItemSlot(source.itemEquipLoc)
      if slots ~= 0 then
        local slotTarget = 0
        for _, slot in pairs(slots) do
          if slotTarget == 0 then slotTarget = slot end
        end
        C_Item.EquipItemByName(source.link, slotTarget)
        _G["StaticPopup1Button1"]:Click()
      end
    end
  end)
end

-- ========================
-- Section: Addon RegisterEvent
-- ========================
local CollectorHelper = CreateFrame("Frame")
CollectorHelper:RegisterEvent("ADDON_LOADED")
CollectorHelper:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
CollectorHelper:RegisterEvent("GET_ITEM_INFO_RECEIVED")
CollectorHelper:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
CollectorHelper:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
  if event == "ADDON_LOADED" and arg1 == "CollectorHelper" then
    if settings == nil then
      settings = settings or { hideMerchantOwned = true }
    end
    hooksecurefunc("MerchantFrame_Update", updateShop)
    MerchantNextPageButton:HookScript("OnClick", updateShop)
    MerchantPrevPageButton:HookScript("OnClick", updateShop)
  end
end)
