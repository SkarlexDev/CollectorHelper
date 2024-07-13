local _, app = ...

local merchantIndex = {}
local sourceHidden = true
local COLORS = app.COLORS

SLASH_COLLECTORHELPER1 = "/ch"
SlashCmdList["COLLECTORHELPER"] = function()
  -- do nothing
end


-- ========================
-- Section: Merchant items
-- ========================
function app:updateShop()
  local itemData = {}
  local size = MERCHANT_ITEMS_PER_PAGE ---@type number
  local currencyMap = {}
  local currencyLink = {}
  local initialItemIndexMap = {}
  merchantIndex = {}        -- reset
  app.merchantTokenMap = {} -- reset

  for i = 1, size do
    local itemIndex = (MerchantFrame.page - 1) * size + i ---@type number
    local itemId = GetMerchantItemID(itemIndex) ---@type number|nil
    if itemId ~= nil then
      merchantIndex[i] = itemId
      local source = app:getItemDetails(itemId)
      local shopItemState = app:checkShopID(source)
      local equipBtn = _G["MerchantItem" .. i .. "EquipBtn"] ---@type CH.Btn
      local showSources = _G["MerchantItem" .. i .. "ShowSrcBtn"] ---@type CH.Btn
      if equipBtn ~= nil then
        equipBtn:Hide()
      end
      if showSources ~= nil then
        showSources:Hide()
      end
      if shopItemState == 1 then
        if settings.hideMerchantOwned then
          SetItemButtonSlotVertexColor(_G["MerchantItem" .. i], 0.4, 0.4, 0.4)
          _G["MerchantItem" .. i .. "ItemButton"]:Hide()
          _G["MerchantItem" .. i .. "Name"]:SetText("")
          _G["MerchantItem" .. i .. "AltCurrencyFrame"]:Hide()
          _G["MerchantItem" .. i .. "MoneyFrame"]:Hide()
        elseif app.forceShowMerchant == true then
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
      elseif shopItemState == 0 or shopItemState == 15 then
        local currencyIndex = GetMerchantItemCostInfo(itemIndex)
        local itemsSources = 1
        if shopItemState == 15 then -- TODO items with sources
          local notOwnedCount = 0
          for _, entry in ipairs(app.merchantTokenMap[source.itemId]) do
            if not entry.owned then
              notOwnedCount = notOwnedCount + 1
            end
          end
          local srcBtn = _G["MerchantItem" .. i .. "ShowSrcBtn"] ---@type CH.Btn
          if srcBtn == nil then
            handleSourceMerchantToken(i)
          else
            srcBtn:Show()
          end
          itemsSources = notOwnedCount
        end
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
              local count = GetMoney()
              itemData[itemTexture] = count
            end
          end
        else
          for y = 1, currencyIndex do
            local itemTexture, itemValue, link = GetMerchantItemCostItem(itemIndex, y)
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
        local eqBtn = _G["MerchantItem" .. i .. "EquipBtn"] ---@type CH.Btn
        if eqBtn == nil then
          app:merchantEquipHandler(i)
        else
          eqBtn:Show()
        end
      else
        -- (ignored items)
      end
    end
  end
  app.forceShowMerchant = false

  local costTable = {}

  local missingItem = false
  for itemTexture, totalValue in pairs(currencyMap) do
    local display = ""
    local description = ""
    local haveCurencyVal = itemData[itemTexture]
    local isGold = itemTexture == "MoneyCurrency"
    if isGold then
      display = display .. app:formatGoldAmount(GetMoneyString(totalValue, true))
    else
      display = display .. "|T" .. itemTexture .. ":16|t " .. totalValue
    end
    if haveCurencyVal ~= nil then
      local percentage = (haveCurencyVal / totalValue) * 100
      if percentage > 100 then
        percentage = 100
      end
      if isGold then
        haveCurencyVal = app:formatGoldAmount(GetMoneyString(haveCurencyVal, true))
      end
      display = display .. " - " ..
          app:textCFormat(COLORS.green, haveCurencyVal) .. " (" .. string.format("%.2f", percentage) .. "%)"
    end

    table.insert(costTable, {
      display = display,
      description = description,
      isGold = isGold,
      linkItem = currencyLink[itemTexture]
    })
    missingItem = true
  end

  if missingItem == true then
    app.marchantCost:Hide()
    app.mainScrollableContent.scrollFrame:Show()
    app.mainScrollableContent.UpdateRows(costTable)
  else
    app.marchantCost:Show()
    app.mainScrollableContent.scrollFrame:Hide()
    app.mainScrollableContent.UpdateRows(costTable)
  end
  -- Create a sorted list of itemIndex keys
  local sortedItemIndices = {}
  for itemIndex in pairs(initialItemIndexMap) do
    table.insert(sortedItemIndices, itemIndex)
  end
  table.sort(sortedItemIndices)

  -- Create a new sorted map
  app.itemIndexMap = {}
  for _, itemIndex in ipairs(sortedItemIndices) do
    app.itemIndexMap[itemIndex] = initialItemIndexMap[itemIndex]
  end
end

-- ========================
-- Section: Additional merchant buttons
-- ========================

-- Equip item from merchant frame
function app:merchantEquipHandler(i)
  local itemFrame = _G["MerchantItem" .. i .. "ItemButton"]
  local equipBtn = app:buttonBuilder({
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
      local source = app:getItemDetails(sourceId)
      local slots = app:getItemSlot(source.itemEquipLoc)
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

-- IN Work
-- Token display possible rewards class based
function handleSourceMerchantToken(i)
  local itemFrame = _G["MerchantItem" .. i]
  local equipBtn = app:buttonBuilder({
    buttonName = "MerchantItem" .. i .. "ShowSrcBtn",
    parent = itemFrame,
    text = "Source",
    width = 50,
    height = 22,
    point = {
      pos = "BOTTOMRIGHT",
      x = 0,
      y = 0,
    }
  })
  equipBtn:HookScript("OnClick", function(self, button)
    if button == "LeftButton" then
      local index = tonumber(self:GetName():match("%d+"))
      local sourceId = merchantIndex[index]
      local source = app:getItemDetails(sourceId)
      local tokenSrc = app.merchantTokenMap[source.itemId]
      -- print(tokenSrc)
      for _, item in pairs(tokenSrc) do
        -- owned = isOwned, itemId = itemId
        if (not item.owned) then
          local details = app:getItemDetails(item.itemId) ---@type CH.ItemDetails
          --print(details.link)
          --print(item.owned)
          --print(item.itemId)
          --local details = getItemDetails(item.itemId)
          --print(details)
          --print(details.itemLink)
          local t =
          "|cffa335ee|Hitem:159300::168639::::::59:103::35:7:6536:6578:1543:4786:6439:6470:6514::::|h[Kula's Butchering Wristwraps]|h|r"
          --sourceDetails:SetText(details.link)
          app:createUserFrame(details.link)
        end
      end
      app.merchantSourceItems:Show()
      app.merchantFrameCost:SetPoint("TOPRIGHT", 280 * 2, 0)
    end
  end)
end

function app:createUserFrame(t)
  local function createText(parent, w, h, x, y)
    local t = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    t:SetSize(w, h)
    t:SetPoint("TOPLEFT", x, y)
    t:SetJustifyH("LEFT")
    t:SetWordWrap(false)
    return t
  end

  local userFrame = CreateFrame("Frame", nil, app.merchantSourceItems, "BackdropTemplate")
  userFrame:SetClipsChildren(true)
  userFrame:SetSize(492 + 24, 24)
  userFrame:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8"
  })
  userFrame:SetBackdropColor(0, 0, 0)
  userFrame:SetPoint("TOPLEFT", 0, 0)
  --userFrame:SetText(t)
  local userName = createText(userFrame, 240, 26, 6, 1)
  userName:SetText(t)
end

function toogleSourceTab()
  if sourceHidden == true then
    app.merchantFrameCost:SetPoint("TOPRIGHT", 280, 0)
    app.merchantSourceItems:Hide()
    sourceHidden = false
  else
    app.merchantSourceItems:Show()
    app.merchantFrameCost:SetPoint("TOPRIGHT", 280 * 2, 0)
    sourceHidden = true
  end
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
  app:doSettings()
  if event == "ADDON_LOADED" and arg1 == "CollectorHelper" then
    hooksecurefunc("MerchantFrame_Update", function() app:updateShop() end)
    MerchantNextPageButton:HookScript("OnClick", function() app:updateShop() end)
    MerchantPrevPageButton:HookScript("OnClick", function() app:updateShop() end)
  end
end)


function app:doSettings()
  if settings == nil then
    settings = {
      hideMerchantOwned = true,
      showCostFrame = true,
    }
  end
  app:MigrateSettings()

  if settings.showCostFrame == false then
      app.merchantFrameCost:Hide()
  end
end


function app:MigrateSettings()
  -- Check if settings table exists and if migration is needed
  if settings.showCostFrame == nil then
      settings.showCostFrame = true
  end
end