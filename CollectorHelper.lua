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


local function isReal(frame) return frame ~= nil and frame:IsShown() end

local function updateShop()
  -- great point to block addon if not settings.hideMerchant then return end
  local size = 10
  if isReal(MerchantItem11) then
    while isReal(_G["MerchantItem"..(size + 1)]) do size = size + 1 end
  end
  for i = 1,size do
    local itemId = GetMerchantItemID((MerchantFrame.page - 1) * size + i)
    if itemId ~= nil then
      local _,_,_,_,_,iTypo,_,_,_,_,_,_ = C_Item.GetItemInfo(itemId) 
      -- Get All ids from merchant
      --print(C_Item.GetItemLearnTransmogSet(itemId))
      --print(itemId)      
      if checkShopID(itemId,iTypo) then
        SetItemButtonSlotVertexColor(_G["MerchantItem"..i],0.4,0.4,0.4)
        _G["MerchantItem"..i.."ItemButton"]:Hide()
        _G["MerchantItem"..i.."Name"]:SetText("")      
        _G["MerchantItem"..i.."AltCurrencyFrame"]:Hide()
      end
    end
  end
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