local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

--- Show or update the Recipe UI frame and profession buttons.
-- @param doShowFrame boolean Whether to show the recipeFrame if true.
function CollectorHelper:ShowRecipeUI(doShowFrame)
    -- Cache current player and their collected recipe data for efficiency.
    local player = self.player
    local recipeData = player and recipeCollected[player]

    --- Update the profession buttons dynamically with current profession info and collected recipes.
    -- @param buttons table Array of button frames representing professions.
    local function updateButtons(buttons)
        -- Get current profession indices for primary professions and cooking.
        local prof1index, prof2index, _, _, cooking = GetProfessions()

        -- Map profession indices to buttons; duplicates for showing twice as needed.
        local professionData = {
            { prof1index, buttons[1] },
            { prof2index, buttons[2] },
            { cooking,    buttons[3] },
            { prof1index, buttons[4] },
            { prof2index, buttons[5] },
            { cooking,    buttons[6] },
        }

        -- Loop through each profession-button pair to update the button UI.
        for _, data in ipairs(professionData) do
            local profIndex, button = unpack(data)
            if profIndex and button then
                -- Fetch profession details such as name, icon, and tradeSkillID.
                local name, iconTexture, _, _, _, _, tradeSkillID = GetProfessionInfo(profIndex)

                if iconTexture then
                    -- Update button icon texture and store tradeSkillID and name.
                    button.icon:SetTexture(iconTexture)
                    button.tradeSkillID = tradeSkillID
                    button.name = name
                else
                    -- Use a fallback icon if no icon is available.
                    button.icon:SetTexture(132764) -- fallback icon ID
                    button.tradeSkillID = nil
                    button.name = nil
                end

                -- If collected recipe data exists for the player and profession, update text.
                if recipeData and recipeData[name] then
                    local collected = recipeData[name]["collected"] or 0
                    local lastSync = recipeData[name]["lastSync"] or "Not available"
                    local totalRecipes = recipeData[name]["total"] or 0

                    if button.lastSyncText then
                        -- If the button has a lastSyncText UI element, show detailed info.
                        button.collectedText:SetText("Collected: " .. collected .. " / " .. totalRecipes)
                        button.lastSyncText:SetText("Last Sync: " .. lastSync)
                    else
                        -- Otherwise show simpler collected/total info only.
                        button.collectedText:SetText(collected .. " / " .. totalRecipes)
                    end
                end
            end
        end
    end

    -- Show the recipeFrame UI if requested and frame exists.
    if doShowFrame and self.recipeFrame then
        self.recipeFrame:Show()
    end

    -- Update profession buttons if they exist.
    if self.profButtons then
        updateButtons(self.profButtons)
    end
end
