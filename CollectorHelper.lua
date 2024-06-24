local itemIndexMap = {}

-- temp
SLASH_COLLECTORHELPER1 = "/ch"
SlashCmdList["COLLECTORHELPER"] = function()
  settings.hideMerchantOwned = not settings.hideMerchantOwned
  updateShop()
end

-- init merchantFrame
local merchantFrameCost = CreateFrame("Frame", "CollectorHelper_MerchantButton", MerchantFrame, "BackdropTemplate")
merchantFrameCost:SetWidth(250)
merchantFrameCost:SetHeight(MerchantFrame:GetHeight())
merchantFrameCost:SetPoint("TOPRIGHT", 250, 0)

merchantFrameCost:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  tileEdge = false,
  edgeSize = 1,
  insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
merchantFrameCost:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
merchantFrameCost:SetBackdropBorderColor(0, 0, 0, 1)

-- frame title
local merchantCostTitle = merchantFrameCost:CreateFontString(nil, "OVERLAY", "GameTooltipText")
merchantCostTitle:SetPoint("TOP",0,-8)
merchantCostTitle:SetText("\124cnYELLOW_FONT_COLOR:Currency Needed to Collect this page")

-- frame details
local marchantCost = merchantFrameCost:CreateFontString(nil, "OVERLAY", "GameTooltipText")
marchantCost:SetPoint("TOPLEFT",35,-40)

-- frame interaction
local merchantBuyBtn = CreateFrame("Button", "Collector_MerchantButton", merchantFrameCost, "UIPanelButtonTemplate")
merchantBuyBtn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
merchantBuyBtn:SetText("Buy All Possible")
merchantBuyBtn:SetWidth(120)
merchantBuyBtn:SetHeight(22)
merchantBuyBtn:SetPoint("BOTTOMLEFT", 5, 8)

merchantBuyBtn:HookScript("OnClick", function(self, button)
  if button == "LeftButton" then
    for itemIndex, itemId in pairs(itemIndexMap) do
      --print("Item ID: " .. itemId .. " Item Index: " .. itemIndex)
      if CanAffordMerchantItem(itemIndex) then
        BuyMerchantItem(itemIndex, 1)
      end
    end
  end
end)

local m1s = CreateFrame("Button", "Collector_M1SButton", merchantFrameCost, "UIPanelButtonTemplate")
m1s:RegisterForClicks("LeftButtonUp", "RightButtonUp")
m1s:SetText("Show/hide owned")
m1s:SetWidth(120)
m1s:SetHeight(22)
m1s:SetPoint("BOTTOMRIGHT", -5, 8)

m1s:HookScript("OnClick", function(self, button)
  if button == "LeftButton" then
    settings.hideMerchantOwned = not settings.hideMerchantOwned
    updateShop()
  end
end)


-- addon logic
-- check Miscellaneous (toys/mounts)
local function checkMiscellaneousOwned(itemId)
  local isToy = C_ToyBox.GetToyInfo(itemId) ~= nil
  if isToy then 
    return PlayerHasToy(itemId)
  end

  local mountId = C_MountJournal.GetMountFromItem(itemId)
  if mountId ~= nil then
    local _,_,_,_,_,_,_,_,_,_,isCollected = C_MountJournal.GetMountInfoByID(mountId)
    return isCollected
  end
  return false
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
local function checkShopID(itemId, iTypo)
  -- 0 false, 1 true, 2 ignore
  -- Check if the id is nil
  if itemId == nil then
    return 0
  end

  local itemSetId = C_Item.GetItemLearnTransmogSet(itemId)
  local isItemHeirloom = C_Heirloom.IsItemHeirloom(itemId)

  if iTypo == "Miscellaneous" then
    return checkMiscellaneousOwned(itemId) and 1 or 0
  elseif itemSetId ~= nil then
    return setOwned(itemSetId) and 1 or 0
  elseif isItemHeirloom then
    return C_Heirloom.PlayerHasHeirloom(itemId) and 1 or 0
  else
    local itemAppearanceID, itemModifiedAppearanceID = C_TransmogCollection.GetItemInfo(itemId)
    if itemAppearanceID == nil then
      return 2  -- ignore item
    else
      return C_TransmogCollection.PlayerHasTransmog(itemId) and 1 or 0
    end
  end
end


function updateShop()
  local size = MERCHANT_ITEMS_PER_PAGE
  local currencyMap = {}
  local initialItemIndexMap = {}

  for i = 1, size do
    local itemIndex = (MerchantFrame.page - 1) * size + i
    local itemId = GetMerchantItemID(itemIndex)
    if itemId ~= nil then
      local name, _, _, _, _, iTypo, _, _, _, _, _, _ = C_Item.GetItemInfo(itemId)
      local shopItemState = checkShopID(itemId, iTypo)
      if shopItemState == 1 then
        if settings.hideMerchantOwned then
          SetItemButtonSlotVertexColor(_G["MerchantItem" .. i], 0.4, 0.4, 0.4)
          _G["MerchantItem" .. i .. "ItemButton"]:Hide()
          _G["MerchantItem" .. i .. "Name"]:SetText("")
          _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Hide()
        else
          SetItemButtonSlotVertexColor(_G["MerchantItem" .. i], 1, 1, 1)
          _G["MerchantItem" .. i .. "ItemButton"]:Show()
          _G["MerchantItem" .. i .. "Name"]:SetText(name)
          _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Show()
        end
      elseif shopItemState == 0 then
        local currencyIndex = GetMerchantItemCostInfo(itemIndex)
        for y = 1, currencyIndex do
          local itemTexture, itemValue,_,_ = GetMerchantItemCostItem(itemIndex, y)
          if itemTexture then
            if currencyMap[itemTexture] then
              currencyMap[itemTexture] = currencyMap[itemTexture] + itemValue
            else
              currencyMap[itemTexture] = itemValue
            end
          end
        end
        initialItemIndexMap[itemIndex] = itemId
      else
        -- (ignored items)
      end
    end
  end

  local cost = ""
  for itemTexture, totalValue in pairs(currencyMap) do
    cost = cost .. "|T" .. itemTexture .. ":16|t " .. totalValue .. "\n\n"
  end

  if cost == "" then
    cost = "\124cnPURE_GREEN_COLOR:You have everything on this page"
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