local itemIndexMap = {}
local forceShowMerchant = false


SLASH_COLLECTORHELPER1 = "/ch"
SlashCmdList["COLLECTORHELPER"] = function()
  settings.hideMerchantOwned = not settings.hideMerchantOwned
  updateShop()
end

-- init merchantFrame
local merchantFrameCost = frameBuilder({
  frameName = "CollectorHelper_MerchantButton",
  parent = MerchantFrame,
  width = 280,
  height = MerchantFrame:GetHeight(),
  point = {
    pos = "TOPRIGHT",
    x = 280,
    y = 0,
  }
})


-- frame title
local merchantCostTitle = merchantFrameCost:CreateFontString(nil, "OVERLAY", "GameTooltipText")
merchantCostTitle:SetPoint("TOP",0,-8)
merchantCostTitle:SetText(textCFormat(COLORS.yellow, "Currency Needed to Collect this page"))

-- frame details
local marchantCost = merchantFrameCost:CreateFontString(nil, "OVERLAY", "GameTooltipText")
marchantCost:SetPoint("TOPLEFT",35,-40)

local m1s = buttonBuilder({
  buttonName = "Collector_MBuyButton",
  parent = merchantFrameCost,
  text = "Buy All Possible",
  width = 120,
  height = 22,
  point = {
    pos = "BOTTOMLEFT",
    x = 20,
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
    x = -20,
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


-- addon logic
-- check Miscellaneous (toys/mounts/pets)
local function checkMiscellaneousOwned(itemId)
  local isToy = C_ToyBox.GetToyInfo(itemId) ~= nil
  if isToy then
    return PlayerHasToy(itemId) and 1 or 0
  end

  local mountId = C_MountJournal.GetMountFromItem(itemId)
  if mountId ~= nil then
    local _,_,_,_,_,_,_,_,_,_,isCollected = C_MountJournal.GetMountInfoByID(mountId)
    return isCollected and 1 or 0
  end

  local petName = C_PetJournal.GetPetInfoByItemID(itemId)
  if petName ~= nil then
    local _,petGUID = C_PetJournal.FindPetIDByName(petName)
    return petGUID ~= nil and 1 or 0
  end
  return 2 -- ignore
end

-- check set owned
local function setOwned(itemSet)
  local ids = C_TransmogSets.GetAllSourceIDs(itemSet)
  for _,sourceID in ipairs(ids) do
    local info = C_TransmogCollection.GetSourceInfo(sourceID)
    if not info.isCollected then return false end
  end
  return true
end


-- check item owned from merchant
local function checkShopID(itemId, itemType, itemEquipLoc)
  -- 0 false, 1 true, 2 ignore
  if itemId == nil then
    return 0
  end

  local itemSetId = C_Item.GetItemLearnTransmogSet(itemId)
  local isItemHeirloom = C_Heirloom.IsItemHeirloom(itemId)
  if (itemType == "Miscellaneous" or itemType == "Consumable") and itemSetId == nil then
    return checkMiscellaneousOwned(itemId)
  elseif itemSetId ~= nil then
    return setOwned(itemSetId) and 1 or 0
  elseif isItemHeirloom then
    return C_Heirloom.PlayerHasHeirloom(itemId) and 1 or 0
  else
    local itemAppearanceID,_ = C_TransmogCollection.GetItemInfo(itemId)
    if itemAppearanceID == nil then
      local isValid = extensiveTypeisValid(itemEquipLoc)
      if isValid == true then
        return C_TransmogCollection.PlayerHasTransmog(itemId) and 1 or 0
      else
        return 2  -- ignore item
      end
    else
      return C_TransmogCollection.PlayerHasTransmog(itemId) and 1 or 0
    end
  end
end

-- merchant logic
function updateShop()
  local itemData = {}
  local size = MERCHANT_ITEMS_PER_PAGE
  local currencyMap = {}
  local initialItemIndexMap = {}

  for i = 1, size do
    local itemIndex = (MerchantFrame.page - 1) * size + i
    local itemId = GetMerchantItemID(itemIndex)
    if itemId ~= nil then
      local name, _, _, _, _, itemType, _, _, itemEquipLoc, _, _, _ = C_Item.GetItemInfo(itemId)
      local shopItemState = checkShopID(itemId, itemType, itemEquipLoc)
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
          _G["MerchantItem" .. i .. "Name"]:SetText(name)
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
          local _,_,price,_,_,_,_,_ = GetMerchantItemInfo(itemIndex)
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
            local itemTexture, itemValue,link,_ = GetMerchantItemCostItem(itemIndex, y)
            if itemTexture then
              if currencyMap[itemTexture] then
                currencyMap[itemTexture] = currencyMap[itemTexture] + itemValue
              else
                currencyMap[itemTexture] = itemValue
              end
              local ci = C_CurrencyInfo.GetCurrencyInfoFromLink(link)
              if ci ~=nil then
                itemData[itemTexture] = ci.quantity
              else
                local count = C_Item.GetItemCount(link)
                itemData[itemTexture] = count
              end
            end
          end
        end
        initialItemIndexMap[itemIndex] = itemId
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
      cost = cost .. " - "..textCFormat(COLORS.green, haveCurencyVal).." (" .. string.format("%.2f", percentage) .. "%)"
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


local CollectorHelper = CreateFrame("Frame")
CollectorHelper:RegisterEvent("ADDON_LOADED")
CollectorHelper:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
CollectorHelper:RegisterEvent("GET_ITEM_INFO_RECEIVED")
CollectorHelper:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
CollectorHelper:SetScript("OnEvent",function(self,event,arg1,arg2,arg3)
  if event == "ADDON_LOADED" and arg1 =="CollectorHelper" then
    if settings == nil then
      settings = settings or {hideMerchantOwned = true}
    end
    hooksecurefunc("MerchantFrame_Update",updateShop)
    MerchantNextPageButton:HookScript("OnClick",updateShop)
    MerchantPrevPageButton:HookScript("OnClick",updateShop)
  end
end)