local _, app = ...

local COLORS = app.COLORS

-- Function to create a row in the scrollable content
local function CreateRow(index, item, data, params, scrollChild, UpdateRows)
    local row = CreateFrame("Frame", nil, scrollChild)
    row:SetSize(params.width, 20)
    row:SetPoint("TOPLEFT", 10, -(index - 1) * 21)

    -- Create button with BackdropTemplate
    local btnP = CreateFrame("Button", nil, row, "BackdropTemplate")
    btnP:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    btnP:SetWidth(params.width - 20)
    btnP:SetHeight(20)
    btnP:SetPoint("CENTER", 0, 0)

    -- Add a default backdrop to the button
    btnP:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)

    -- Skin for ElvUI
    pcall(function()
        local E = ElvUI[1]
        local S = E:GetModule("Skins")
        if E.private.skins.blizzard.enable and E.private.skins.blizzard.merchant then
            S:HandleButton(btnP)
        end
    end)

    local rowText = btnP:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rowText:SetJustifyH("LEFT")
    rowText:SetPoint("LEFT")
    rowText:SetText(item.display)

    -- Additional item details (percentage, quantity, clear button)
    if item.percentage then
        local btn = CreateFrame("Button", nil, btnP)
        btn:SetWidth(50)
        btn:SetHeight(20)
        btn:SetPoint("RIGHT", 0, 0)

        local percentage = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        percentage:SetPoint("LEFT")
        percentage:SetText(string.format("%.2f%%", item.percentage))

        btn:SetScript("OnEnter", function()
            btnP:SetBackdropColor(0.5, 0.5, 0.5, 1) -- Light gray highlight
            GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)
            GameTooltip:SetText(item.display, 1, 1, 1)
            if item.linkItem then
                GameTooltip:SetHyperlink(item.linkItem)
            else
                GameTooltip:AddLine(item.tooltip, nil, nil, nil, true)
            end
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function()
            btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)
            GameTooltip:Hide()
        end)
    end

    if item.quantity then
        local btn = CreateFrame("Button", nil, btnP)
        btn:SetWidth(35)
        btn:SetHeight(20)
        btn:SetPoint("RIGHT", 0, 0)

        local quantity = btn:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        quantity:SetPoint("LEFT")
        quantity:SetText(item.quantity)

        btn:SetScript("OnEnter", function()
            btnP:SetBackdropColor(0.5, 0.5, 0.5, 1) -- Light gray highlight
            GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)
            GameTooltip:SetText(item.display, 1, 1, 1)
            if item.linkItem then
                GameTooltip:SetHyperlink(item.linkItem)
            else
                GameTooltip:AddLine(item.tooltip, nil, nil, nil, true)
            end
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function()
            btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)
            GameTooltip:Hide()
        end)
    end

    if item.clear then
        local btn = CreateFrame("Button", nil, btnP)
        btn:SetWidth(20)
        btn:SetHeight(20)
        btn:SetPoint("LEFT", -20, 0)

        local clear = btn:CreateTexture(nil, "ARTWORK")
        clear:SetPoint("CENTER")
        clear:SetTexture("interface\\buttons\\ui-stopbutton")
        clear:SetSize(25, 25)

        btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")

        btn:HookScript("OnClick", function(self, button)
            if button == "LeftButton" and IsAltKeyDown() then
                table.remove(data, index) -- Remove item from data at index
                UpdateRows(data)          -- Rebuild rows with updated data
            end
        end)

        btn:SetScript("OnEnter", function()
            btnP:SetBackdropColor(0.5, 0.5, 0.5, 1) -- Light gray highlight
            GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)
            GameTooltip:SetText("Remove this item from AH shop list", 1, 1, 1)
            GameTooltip:AddLine("Alt + Click to remove", nil, nil, nil, true)
            GameTooltip:Show()
        end)

        btn:SetScript("OnLeave", function()
            btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)
            GameTooltip:Hide()
        end)
    end

    btnP:SetScript("OnEnter", function()
        btnP:SetBackdropColor(0.5, 0.5, 0.5, 1) -- Light gray highlight
        GameTooltip:SetOwner(params.parent, "ANCHOR_RIGHT", 0, -34)

        GameTooltip:SetText(item.display, 1, 1, 1)
        if item.linkItem then
            GameTooltip:SetHyperlink(item.linkItem)
        else
            --GameTooltip:AddLine(item.display, nil, nil, nil, true)
        end
        GameTooltip:Show()
    end)

    btnP:HookScript("OnClick", function(_, button)
        if button == "LeftButton" then
            if item.linkItem then
                print(item.linkItem)
            end
        end
    end)

    btnP:SetScript("OnLeave", function()
        btnP:SetBackdropColor(0.102, 0.102, 0.102, 1)
        GameTooltip:Hide()
    end)

    return row
end


function app:InitMerchantUI()
    -- Merchant frame extension
    local merchantFrameCost = app:frameBuilder({
        frameName = "CollectorHelper_Merchant",
        parent = MerchantFrame,
        width = 330,
        height = MerchantFrame:GetHeight(),
        point = {
            pos = "TOPRIGHT",
            x = 330,
            y = 0,
        },
        titleBuilder = {
            text = app:textCFormat(COLORS.yellow, "Currency Needed to Collect everything"),
            point = {
                pos = "TOP",
                x = 0,
                y = -8,
            }
        }
    })
    app.merchantFrameCost = merchantFrameCost

    -- Completed message font
    app.merchantCost = app:fontBuilder({
        parent = merchantFrameCost,
        text = app:textCFormat(COLORS.green, "You have everything on this merchant"),
        point = {
            pos = "CENTER",
            x = 0,
            y = 80,
        }
    })

    -- Scrollable content cost
    app.mainScrollableContent = app:CreateScrollableContent({
        parent = merchantFrameCost,
        width = 280,
        height = 370,
        point = {
            pos = "TOPLEFT",
            x = 8,
            y = -37,
        }
    }, CreateRow)

    -- ========================
    -- Section: Merchant Action buttons
    -- ========================
    local buyAllButton = app:buttonBuilder({
        buttonName = "Collector_MBuyButton",
        parent = merchantFrameCost,
        text = "Buy All",
        width = 100,
        height = 22,
        point = {
            pos = "BOTTOMLEFT",
            x = 8,
            y = 8,
        },
        onClickScript = function(self, button)
            if button == "LeftButton" then
                for itemIndex, _ in pairs(app.itemIndexMap) do
                    local costInfo = GetMerchantItemCostInfo(itemIndex)
                    if costInfo == 0 or CanAffordMerchantItem(itemIndex) then
                        BuyMerchantItem(itemIndex, 1)
                    end
                end
            end
        end
    })
    app.buyAllButton = buyAllButton

    local toggleShowOwned = app:buttonBuilder({
        buttonName = "Collector_MSHButton",
        parent = merchantFrameCost,
        text = "Toggle owned",
        width = 100,
        height = 22,
        point = {
            pos = "BOTTOM",
            x = 0,
            y = 8,
        },
        onClickScript = function(_, button)
            if button == "LeftButton" then
                settings.hideMerchantOwned = not settings.hideMerchantOwned
                if settings.hideMerchantOwned == false then
                    app.forceShowMerchant = true
                end
                app:updateShop()
            end
        end
    })
    app.toggleShowOwned = toggleShowOwned


    hooksecurefunc("MerchantFrame_Update", function() app:updateShop() end)
    MerchantNextPageButton:HookScript("OnClick", function() app:updateShop() end)
    MerchantPrevPageButton:HookScript("OnClick", function() app:updateShop() end)

    app:InitMerchantUIAH()
    if settings.showCostFrame == false then
        app.merchantFrameCost:Hide()
    end
end

function app:InitMerchantUIAH()
    local merchantFrameCost = app.merchantFrameCost

    local ahListButton = app:buttonBuilder({
        buttonName = "Collector_MAHListButton",
        parent = merchantFrameCost,
        text = "AH Track",
        width = 100,
        height = 22,
        point = {
            pos = "BOTTOMRIGHT",
            x = -8,
            y = 8,
        },
        onClickScript = function(self, button)
            if button == "LeftButton" then
                app.doAhTrack = true
                app:updateShop()
                app.ahFrame:Show()
                app.ahScrollableContent.UpdateRows(app.ahItems)
            end
        end
    })
    app.ahListButton = ahListButton

    -- Merchant frame AH extension
    local ahFrame = app:frameBuilder({
        frameName = "CollectorHelper_MerchantSource_AH",
        parent = UIParent,
        width = 330,
        height = 400,
        point = {
            pos = "CENTER",
            x = 0,
            y = 0,
        },
        titleBuilder = {
            text = app:textCFormat(COLORS.yellow, "Collector Ah List"),
            point = {
                pos = "TOP",
                x = 0,
                y = -8,
            }
        }
    })

    -- Make the frame movable
    ahFrame:SetMovable(true)
    ahFrame:EnableMouse(true)
    ahFrame:RegisterForDrag("LeftButton")
    ahFrame:SetScript("OnDragStart", ahFrame.StartMoving)

    ahFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    ahFrame:Hide()

    -- Scrollable content for AH list
    app.ahScrollableContent = app:CreateScrollableContent({
        parent = ahFrame,
        width = 280,
        height = 320,
        point = {
            pos = "TOPLEFT",
            x = 15,
            y = -37,
        }
    }, CreateRow)

    -- Close button for AH frame
    app:buttonBuilder({
        buttonName = "Collector_MAHCloseButton",
        parent = ahFrame,
        text = "Close",
        width = 100,
        height = 22,
        point = {
            pos = "BOTTOMRIGHT",
            x = -13,
            y = 8,
        },
        onClickScript = function(_, button)
            if button == "LeftButton" then
                app.ahFrame:Hide()
            end
        end
    })

    -- Clear list button for AH frame
    app:buttonBuilder({
        buttonName = "Collector_MAHClearButton",
        parent = ahFrame,
        text = "Clear List",
        width = 100,
        height = 22,
        point = {
            pos = "BOTTOMLEFT",
            x = 13,
            y = 8,
        },
        onClickScript = function(_, button)
            if button == "LeftButton" then
                app.ahItems = {}
                app.ahScrollableContent.UpdateRows(app.ahItems)
            end
        end
    })
    app.ahFrame = ahFrame
end

function app:ShowRecipeUI()
    -- Nested function to update all profession buttons dynamically
    local function updateButtons(buttons)
        -- Retrieve current professions
        local prof1index, prof2index, _, _, cooking = GetProfessions()

        -- A table of profession indexes and corresponding buttons
        local professionData = {
            { prof1index, buttons[1] },
            { prof2index, buttons[2] },
            { cooking,    buttons[3] },
        }

        -- Loop over each profession and update the corresponding button
        for _, data in ipairs(professionData) do
            local profIndex, button = unpack(data)
            if profIndex then
                local name, iconTexture, _, _, _, _, tradeSkillID = GetProfessionInfo(profIndex)

                -- Update the icon texture and tradeSkillID
                if iconTexture then
                    button.icon:SetTexture(iconTexture) -- Set the profession icon
                    button.tradeSkillID = tradeSkillID  -- Dynamically set tradeSkillID
                    button.name = name                  -- Store the profession name in the button
                else
                    button.icon:SetTexture(132764)
                    button.tradeSkillID = nil           -- Clear tradeSkillID
                end

                -- Fetch the collected and lastSync data for the profession from recipeCollected[app.player]
                local player = app.player
                if player and recipeCollected[player] ~= nil then
                    local professionData = recipeCollected[player][name] -- Use the profession name here
                    if professionData then
                        local collected = professionData["collected"] or 0
                        local lastSync = professionData["lastSync"] or "Not available"
                        local totalRecipes = professionData["total"] or 0
                        -- Update the text under the button
                        button.collectedText:SetText("Collected: " .. collected .. " / " .. totalRecipes)
                        button.lastSyncText:SetText("Last Sync: " .. lastSync)
                    end
                end
            end
        end
    end

    -- Create the frame if it doesn't exist
    if app.recipeFrame == nil then
        local recipeFrame = app:frameBuilder({
            frameName = "CollectorHelper_Recipes",
            parent = UIParent,
            width = 300,
            height = 400,
            point = {
                pos = "CENTER",
                x = 0,
                y = 0,
            },
            titleBuilder = {
                text = app:textCFormat(COLORS.yellow, "CollectorHelper Recipe sync"),
                point = {
                    pos = "TOP",
                    x = 0,
                    y = -8,
                }
            }
        })
        app.recipeFrame = recipeFrame

        -- Make the frame draggable
        recipeFrame:SetMovable(true)
        recipeFrame:EnableMouse(true)
        recipeFrame:RegisterForDrag("LeftButton")
        recipeFrame:SetScript("OnDragStart", recipeFrame.StartMoving)
        recipeFrame:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
        end)

        -- Add a close button
        app:buttonBuilder({
            buttonName = "Collector_RecipeCloseButton",
            parent = recipeFrame,
            text = "Close",
            width = 100,
            height = 22,
            point = {
                pos = "BOTTOM",
                x = 0,
                y = 8,
            },
            onClickScript = function(self, button)
                if button == "LeftButton" then
                    recipeFrame:Hide()
                end
            end
        })

        -- Function to generate profession buttons
        local function generateProfButton(yOffset)
            local button = app:buttonBuilder({
                buttonName = "Collector_ProfButton_" .. yOffset,
                parent = recipeFrame,
                text = "",
                width = 64,
                height = 64,
                point = {
                    pos = "Center",
                    x = 0,
                    y = yOffset,
                },
                onClickScript = function(self, button)
                    if button == "LeftButton" then
                        if self.tradeSkillID then
                            --print("Opening TradeSkill ID:", self.tradeSkillID)
                            C_TradeSkillUI.OpenTradeSkill(self.tradeSkillID)
                        else
                            --print("No TradeSkillID set for this button.")
                        end

                        C_Timer.After(0.25, function()
                            -- Now, populate the recipes for this profession
                            local player = app.player
                            local professionName = self.name -- Get the profession name (e.g., Jewelcrafting)
                            if player and recipeCollected[player] ~= nil and professionName then
                                local professionData = recipeCollected[player][professionName]
                                if professionData then
                                    -- Loop through all recipe IDs and update the profession data
                                    local collectedRecipes = 0
                                    local totalRecipes = 0
                                    local currentTime = date("%Y-%m-%d %H:%M:%S") -- Get current time for lastSync

                                    -- Reset the recipes table and count valid ones
                                    professionData["recipes"] = {} -- Reset the recipes data

                                    for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
                                        local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
                                        if recipeInfo then
                                            -- Store the recipe ID and its learned status (true/false)
                                            if recipeInfo.learned then
                                                professionData["recipes"][recipeInfo.recipeID] = true
                                                collectedRecipes = collectedRecipes + 1
                                            else
                                                professionData["recipes"][recipeInfo.recipeID] = false
                                            end
                                            totalRecipes = totalRecipes + 1
                                        end
                                    end

                                    -- Update the profession's collected count and lastSync timestamp
                                    professionData["collected"] = collectedRecipes
                                    professionData["total"] = totalRecipes
                                    professionData["lastSync"] = currentTime

                                    -- Update the button text dynamically
                                    self.collectedText:SetText("Collected: " .. collectedRecipes .. " / " .. totalRecipes)
                                    self.lastSyncText:SetText("Last Sync: " .. currentTime)
                                end
                            end
                        end)
                    end
                end
            })

            local texture = button:CreateTexture(nil, "ARTWORK")
            texture:SetAllPoints(button)
            texture:SetTexture(132764)
            button.icon = texture -- Store the texture as a property of the button

            -- Create the text for "Collected" and "Last Sync"
            local collectedText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            collectedText:SetPoint("TOP", button, "BOTTOM", 0, -2)
            collectedText:SetText("No profession")
            button.collectedText = collectedText

            local lastSyncText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            lastSyncText:SetPoint("TOP", collectedText, "BOTTOM", 0, -2)
            button.lastSyncText = lastSyncText

            return button
        end

        -- Create and store buttons
        app.profButtons = {
            generateProfButton(125),
            generateProfButton(25),
            generateProfButton(-75),
        }

        -- Update the buttons dynamically
        updateButtons(app.profButtons)
    else
        -- Show the frame if it already exists
        app.recipeFrame:Show()

        -- Update the buttons to reflect current profession data
        if app.profButtons then
            updateButtons(app.profButtons)
        end
    end
end
