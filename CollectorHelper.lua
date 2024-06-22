-- init
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

local merchantCostTitle = merchantFrameCost:CreateFontString(nil, "OVERLAY", "GameTooltipText")
merchantCostTitle:SetPoint("TOP",0,-8)
merchantCostTitle:SetText("\124cnYELLOW_FONT_COLOR:Currency Needed to Collect this page")


local marchantCost = merchantFrameCost:CreateFontString(nil, "OVERLAY", "GameTooltipText")
marchantCost:SetPoint("TOPLEFT",35,-40)

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
local function checkShopID(itemId,iTypo)
  -- Check if the id is nil
  if itemId == nil then 
    return false 
  end  
  -- Attempt to get the item set ID for transmog
  local itemSetId = C_Item.GetItemLearnTransmogSet(itemId)
  -- Check if item is Heirloom
  local isItemHeirloom = C_Heirloom.IsItemHeirloom(itemId)
  if iTypo == "Miscellaneous" then
    return checkMiscellaneousOwned(itemId)
  elseif itemSetId ~= nil then
    return setOwned(itemSetId)
  elseif isItemHeirloom then
    return C_Heirloom.PlayerHasHeirloom(itemId)
  else
    return C_TransmogCollection.PlayerHasTransmog(itemId)
  end
end


local function updateShop()
  -- great point to block addon if not settings.hideMerchant then return end
  local size = MERCHANT_ITEMS_PER_PAGE
  local currencyMap = {}
    for i = 1,size do
    local itemIndex = (MerchantFrame.page - 1) * size + i
    local itemId = GetMerchantItemID(itemIndex)
    if itemId ~= nil then
      local _,_,_,_,_,iTypo,_,_,_,_,_,_ = C_Item.GetItemInfo(itemId)
      if checkShopID(itemId,iTypo) then
        SetItemButtonSlotVertexColor(_G["MerchantItem"..i],0.4,0.4,0.4)
        _G["MerchantItem"..i.."ItemButton"]:Hide()
        _G["MerchantItem"..i.."Name"]:SetText("")
        _G["MerchantItem"..i.."AltCurrencyFrame"]:Hide()
      else
        local currencyIndex = GetMerchantItemCostInfo(itemIndex)
        for y = 1,currencyIndex do
          local itemTexture, itemValue, itemLink, currencyName = GetMerchantItemCostItem(itemIndex,y)
          if itemTexture then
            if currencyMap[itemTexture] then
              currencyMap[itemTexture] = currencyMap[itemTexture] + itemValue
            else
              currencyMap[itemTexture] = itemValue
            end
          end
        end
      end
    end
  end

  local cost = "";
  for itemTexture, totalValue in pairs(currencyMap) do
    cost = cost .. "|T"..itemTexture..":16|t "..totalValue.. "\n\n"
  end

  if cost == "" then
    cost = "\124cnPURE_GREEN_COLOR:You have everything on this page"
  end
  marchantCost:SetText(cost)
end


local CollectorHelper = CreateFrame("Frame")
CollectorHelper:RegisterEvent("ADDON_LOADED")
CollectorHelper:RegisterEvent("TRANSMOG_COLLECTION_SOURCE_ADDED")
CollectorHelper:RegisterEvent("GET_ITEM_INFO_RECEIVED")
CollectorHelper:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
CollectorHelper:SetScript("OnEvent",function(self,event,arg1,arg2,arg3)
  if event == "ADDON_LOADED" and arg1 =="CollectorHelper" then
    hooksecurefunc("MerchantFrame_Update",updateShop)
    MerchantNextPageButton:HookScript("OnClick",updateShop)
    MerchantPrevPageButton:HookScript("OnClick",updateShop)
  end
end)