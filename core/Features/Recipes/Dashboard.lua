local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local COLORS = CollectorHelper.DASHBOARD_COLORS

local PROFESSION_ICONS = {
    Alchemy = 136240,
    Blacksmithing = 136241,
    Cooking = 133971,
    Enchanting = 136244,
    Engineering = 136243,
    Herbalism = 136246,
    Inscription = 237171,
    Jewelcrafting = 134071,
    Leatherworking = 136247,
    Mining = 136248,
    Skinning = 134366,
    Tailoring = 136249,
}

local function CreateLabel(parent, text, font, point)
    local label = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    label:SetPoint(point[1], point[2], point[3], point[4], point[5])
    label:SetText(text or "")
    return label
end

local function CreatePanel(parent, width, height)
    local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    frame:SetSize(width, height)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(unpack(COLORS.panel))
    frame:SetBackdropBorderColor(unpack(COLORS.border))
    return frame
end

local function CreateButton(parent, width, height, text)
    local button = CreateFrame("Button", nil, parent, "BackdropTemplate")
    button:SetSize(width, height)
    button:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    button:SetBackdropColor(unpack(COLORS.panelHover))
    button:SetBackdropBorderColor(unpack(COLORS.border))
    button.label = CreateLabel(button, text, "GameFontNormal", { "CENTER", button, "CENTER", 0, 0 })
    button.label:SetTextColor(unpack(COLORS.text))
    button:SetScript("OnEnter", function(widget)
        widget:SetBackdropColor(unpack(COLORS.panelRaised))
        widget:SetBackdropBorderColor(unpack(COLORS.accentSoft))
    end)
    button:SetScript("OnLeave", function(widget)
        widget:SetBackdropColor(unpack(COLORS.panelHover))
        widget:SetBackdropBorderColor(unpack(COLORS.border))
    end)
    return button
end

function CollectorHelper:InitDashboardRecipeJournal(parent)
    local title = CreateLabel(parent, "RECIPE JOURNAL", "GameFontNormalLarge",
        { "TOPLEFT", parent, "TOPLEFT", 0, -4 })
    title:SetTextColor(unpack(COLORS.text))

    local subtitle = CreateLabel(parent, "Profession progress, organized by character.",
        "GameFontHighlight", { "TOPLEFT", title, "BOTTOMLEFT", 0, -7 })
    subtitle:SetTextColor(unpack(COLORS.muted))

    local characterHeader = CreateLabel(parent, "CHARACTERS", "GameFontNormal",
        { "TOPLEFT", parent, "TOPLEFT", 0, -50 })
    characterHeader:SetTextColor(unpack(COLORS.accent))

    local characterScroll = CreateFrame("ScrollFrame", nil, parent)
    characterScroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -72)
    characterScroll:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    characterScroll:SetWidth(184)

    local characterContent = CreateFrame("Frame", nil, characterScroll)
    characterContent:SetSize(164, 1)
    characterScroll:SetScrollChild(characterContent)
    self:CreateModernScrollBar(characterScroll)

    local details = CreateFrame("Frame", nil, parent)
    details:SetPoint("TOPLEFT", parent, "TOPLEFT", 196, -96)
    details:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -8, 0)

    local selectedCharacter
    local characterButtons = {}
    local professionTiles = {}

    local detailTitle = CreateLabel(details, "", "GameFontNormalLarge",
        { "TOPLEFT", details, "TOPLEFT", 0, 0 })
    detailTitle:SetTextColor(unpack(COLORS.text))
    local detailSubtitle = CreateLabel(details, "", "GameFontHighlightSmall",
        { "TOPLEFT", detailTitle, "BOTTOMLEFT", 0, -6 })
    detailSubtitle:SetTextColor(unpack(COLORS.muted))
    local primaryHeader = CreateLabel(details, "PRIMARY PROFESSIONS", "GameFontNormal",
        { "TOPLEFT", details, "TOPLEFT", 0, -58 })
    primaryHeader:SetTextColor(unpack(COLORS.accent))
    local cookingHeader = CreateLabel(details, "COOKING", "GameFontNormal",
        { "TOPLEFT", details, "TOPLEFT", 0, -278 })
    cookingHeader:SetTextColor(unpack(COLORS.accent))

    local deleteButton = CreateButton(details, 108, 28, "Delete data")
    deleteButton:SetPoint("TOPRIGHT", details, "TOPRIGHT", 0, 2)
    deleteButton.label:SetFontObject("GameFontHighlightSmall")
    deleteButton.label:SetTextColor(1, 0.58, 0.52)
    deleteButton:SetBackdropColor(unpack(COLORS.panel))
    deleteButton:SetScript("OnEnter", function(widget)
        widget:SetBackdropColor(0.25, 0.10, 0.12, 1)
        widget:SetBackdropBorderColor(0.78, 0.29, 0.30, 1)
        widget.label:SetTextColor(1, 0.76, 0.72)
    end)
    deleteButton:SetScript("OnLeave", function(widget)
        widget:SetBackdropColor(unpack(COLORS.panel))
        widget:SetBackdropBorderColor(unpack(COLORS.border))
        widget.label:SetTextColor(1, 0.58, 0.52)
    end)
    deleteButton:SetScript("OnClick", function()
        if selectedCharacter then
            StaticPopup_Show("COLLECTORHELPER_DELETE_RECIPE_DATA", selectedCharacter, nil, selectedCharacter)
        end
    end)

    -- Reuse character buttons and size them to wrapped names to avoid truncation.
    local function RefreshCharacters()
        local names = {}
        for characterName in pairs(recipeCollected or {}) do
            names[#names + 1] = characterName
        end
        table.sort(names)

        if not selectedCharacter or not recipeCollected[selectedCharacter] then
            selectedCharacter = self.player
            if not selectedCharacter or not recipeCollected[selectedCharacter] then
                selectedCharacter = names[1]
            end
        end

        local buttonWidth = characterContent:GetWidth() - 2
        local yOffset = 0
        for index, characterName in ipairs(names) do
            local button = characterButtons[index]
            if not button then
                button = CreateButton(characterContent, buttonWidth, 36, "")
                characterButtons[index] = button
                button.label:ClearAllPoints()
                button.label:SetPoint("LEFT", button, "LEFT", 9, 0)
                button.label:SetWidth(buttonWidth - 18)
                button.label:SetJustifyH("LEFT")
                button.label:SetWordWrap(true)
                button:SetScript("OnEnter", function(widget)
                    widget:SetBackdropColor(unpack(COLORS.panelRaised))
                    widget:SetBackdropBorderColor(unpack(COLORS.accentSoft))
                    widget.label:SetTextColor(unpack(COLORS.accent))
                end)
                button:SetScript("OnLeave", function(widget)
                    local selected = widget.characterName == selectedCharacter
                    widget:SetBackdropColor(unpack(selected and COLORS.panelHover or COLORS.panel))
                    widget:SetBackdropBorderColor(unpack(selected and COLORS.accent or COLORS.border))
                    widget.label:SetTextColor(unpack(selected and COLORS.text or COLORS.muted))
                end)
                button:SetScript("OnClick", function(widget)
                    selectedCharacter = widget.characterName
                    self:RefreshDashboardRecipeJournal()
                end)
            end

            button.characterName = characterName
            button:SetWidth(buttonWidth)
            button.label:SetWidth(buttonWidth - 18)
            button.label:SetText(characterName)
            button.label:SetTextColor(unpack(characterName == selectedCharacter and COLORS.text or COLORS.muted))
            local buttonHeight = math.max(36, button.label:GetStringHeight() + 12)
            button:SetHeight(buttonHeight)
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", characterContent, "TOPLEFT", 0, -yOffset)
            button:SetBackdropColor(unpack(characterName == selectedCharacter and COLORS.panelHover or COLORS.panel))
            button:SetBackdropBorderColor(unpack(characterName == selectedCharacter and COLORS.accent or COLORS.border))
            button:Show()
            yOffset = yOffset + buttonHeight + 6
        end

        for index = #names + 1, #characterButtons do
            characterButtons[index]:Hide()
        end
        characterContent:SetHeight(math.max(yOffset - 6, 1))
        characterScroll:UpdateScrollChildRect()
        characterScroll.UpdateModernScrollBar()
        if #names == 0 then
            selectedCharacter = nil
        end
    end

    local function GetCurrentProfessions()
        local first, second, _, _, cooking = GetProfessions()
        local professions = {}
        local function AddProfession(professionIndex, category)
            if not professionIndex then return end
            local name, icon, _, _, _, _, tradeSkillID = GetProfessionInfo(professionIndex)
            if name then
                PROFESSION_ICONS[name] = icon
                professions[name] = {
                    icon = icon,
                    tradeSkillID = tradeSkillID,
                    category = category,
                }
            end
        end
        AddProfession(first, "primary")
        AddProfession(second, "primary")
        AddProfession(cooking, "cooking")
        return professions
    end

    local function CreateProfessionTile()
        local tile = CreatePanel(details, 1, 92)
        tile.icon = tile:CreateTexture(nil, "ARTWORK")
        tile.icon:SetSize(48, 48)
        tile.icon:SetPoint("BOTTOMLEFT", tile, "BOTTOMLEFT", 14, 14)

        tile.name = CreateLabel(tile, "", "GameFontNormal", { "TOPLEFT", tile, "TOPLEFT", 76, -12 })
        tile.name:SetTextColor(unpack(COLORS.text))
        tile.progress = CreateLabel(tile, "", "GameFontNormal", { "TOPLEFT", tile, "TOPLEFT", 76, -34 })
        tile.progress:SetTextColor(unpack(COLORS.muted))
        tile.progress:SetJustifyH("LEFT")
        tile.lastSync = CreateLabel(tile, "", "GameFontHighlightSmall",
            { "TOPLEFT", tile, "TOPLEFT", 76, -56 })
        tile.lastSync:SetTextColor(unpack(COLORS.muted))
        tile.lastSync:SetJustifyH("LEFT")

        tile.progressBar = CreateFrame("StatusBar", nil, tile)
        tile.progressBar:SetHeight(4)
        tile.progressBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
        tile.progressBar:SetStatusBarColor(unpack(COLORS.accent))
        tile.progressBar:SetMinMaxValues(0, 1)
        tile.progressBar:SetValue(0)
        tile.progressBar:SetPoint("BOTTOMLEFT", tile, "BOTTOMLEFT", 76, 10)
        tile.progressBar.background = tile.progressBar:CreateTexture(nil, "BACKGROUND")
        tile.progressBar.background:SetAllPoints()
        tile.progressBar.background:SetColorTexture(unpack(COLORS.border))

        tile.sync = CreateButton(tile, 84, 28, "Sync")
        tile.sync:SetPoint("RIGHT", tile, "RIGHT", -14, 0)
        tile.sync:SetScript("OnEnter", function(button)
            if button.syncing then return end
            button:SetBackdropColor(unpack(COLORS.accentSoft))
            button:SetBackdropBorderColor(unpack(COLORS.accent))
            button.label:SetTextColor(unpack(COLORS.text))
        end)
        tile.sync:SetScript("OnLeave", function(button)
            if button.syncing and button.label:GetText() == "Synced" then
                button:SetBackdropColor(unpack(COLORS.green))
                return
            end
            button:SetBackdropColor(unpack(COLORS.panelHover))
            button:SetBackdropBorderColor(unpack(COLORS.border))
            button.label:SetTextColor(unpack(COLORS.text))
        end)
        tile.sync:SetScript("OnClick", function(button)
            if not button.tradeSkillID or button.syncing then return end

            button.syncing = true
            button.label:SetText("Syncing...")
            button:SetEnabled(false)
            C_TradeSkillUI.OpenTradeSkill(button.tradeSkillID)
            C_Timer.After(0.5, function()
                local synced = self:SyncProfessionData(button, button.professionName)
                if synced then
                    button.label:SetText("Synced")
                    button:SetBackdropColor(unpack(COLORS.green))
                else
                    button.label:SetText("Try again")
                end

                self:RefreshDashboardRecipeJournal()
                self:RefreshDashboardStats()
                C_Timer.After(1.5, function()
                    button.syncing = false
                    button:SetEnabled(true)
                    button.label:SetText("Sync")
                    button:SetBackdropColor(unpack(COLORS.panelHover))
                end)
            end)
        end)

        tile.placeholder = CreateLabel(tile, "+", "GameFontNormalHuge",
            { "CENTER", tile, "CENTER", 0, 8 })
        tile.placeholder:SetTextColor(unpack(COLORS.accent))
        tile.placeholderText = CreateLabel(tile, "Empty profession slot", "GameFontHighlightSmall",
            { "CENTER", tile, "CENTER", 0, -22 })
        tile.placeholderText:SetTextColor(unpack(COLORS.muted))
        return tile
    end

    local function EnsureProfessionTile(index)
        if not professionTiles[index] then
            professionTiles[index] = CreateProfessionTile()
        end
        return professionTiles[index]
    end

    if not StaticPopupDialogs.COLLECTORHELPER_DELETE_RECIPE_DATA then
        StaticPopupDialogs.COLLECTORHELPER_DELETE_RECIPE_DATA = {
            text = "Delete recipe data for %s?",
            button1 = YES,
            button2 = NO,
            OnAccept = function(_, characterName)
                if characterName == self.player then
                    recipeCollected[characterName] = nil
                    selectedCharacter = characterName
                    self:initializeRecipesCollected()
                    return
                end

                recipeCollected[characterName] = nil
                if selectedCharacter == characterName then
                    selectedCharacter = nil
                end
                self:RefreshDashboardRecipeJournal()
                self:RefreshDashboardStats()
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end

    -- Render two primary profession slots and one separate Cooking slot.
    function self:RefreshDashboardRecipeJournal()
        RefreshCharacters()
        local characterData = selectedCharacter and recipeCollected[selectedCharacter]
        detailTitle:SetText(selectedCharacter or "No character data yet")
        deleteButton:SetShown(characterData ~= nil)

        local isCurrentCharacter = selectedCharacter == self.player
        detailSubtitle:SetText(isCurrentCharacter
            and "Select a profession tile to sync its latest recipe progress."
            or "Saved profession progress for this character.")

        local currentProfessions = isCurrentCharacter and GetCurrentProfessions() or {}
        local primaryNames = {}
        local cookingName
        for professionName, data in pairs(characterData or {}) do
            local currentProfession = currentProfessions[professionName]
            if type(data) == "table" and (not isCurrentCharacter or currentProfession) then
                local isCooking = currentProfession and currentProfession.category == "cooking"
                    or data.isCooking == true
                    or strlower(professionName) == "cooking"
                    or data.icon == PROFESSION_ICONS.Cooking
                if isCooking then
                    cookingName = professionName
                else
                    primaryNames[#primaryNames + 1] = professionName
                end
            end
        end
        table.sort(primaryNames)

        local detailWidth = details:GetWidth()
        if detailWidth <= 0 then
            detailWidth = parent:GetWidth() - 208
        end
        local tileWidth = math.max(detailWidth, 190)
        -- Keep two primary slots and one cooking slot stable even when a profession is missing.
        local slots = {
            { professionName = primaryNames[1], placeholder = "Empty profession slot", y = -78 },
            { professionName = primaryNames[2], placeholder = "Empty profession slot", y = -178 },
            { professionName = cookingName, placeholder = "Empty cooking slot", y = -298 },
        }
        for index, slot in ipairs(slots) do
            local tile = EnsureProfessionTile(index)
            tile:SetSize(tileWidth, 92)
            local textWidth = math.max(tileWidth - 190, 1)
            tile.name:SetWidth(textWidth)
            tile.progress:SetWidth(textWidth)
            tile.lastSync:SetWidth(textWidth)
            tile.progressBar:SetWidth(textWidth)
            tile:ClearAllPoints()
            tile:SetPoint("TOPLEFT", details, "TOPLEFT", 0, slot.y)

            local professionName = slot.professionName
            local data = professionName and characterData[professionName]
            if data then
                local currentProfession = currentProfessions[professionName]
                data.isCooking = (currentProfession and currentProfession.category == "cooking")
                    or data.isCooking == true
                tile.name:SetText(professionName)
                local collected = tonumber(data.collected) or 0
                local total = tonumber(data.total) or 0
                tile.progress:SetText(string.format("%d / %d recipes learned", collected, total))
                tile.lastSync:SetText("Last synced: " .. (data.lastSync or "Not synced"))
                tile.progressBar:SetMinMaxValues(0, math.max(total, 1))
                tile.progressBar:SetValue(math.min(collected, total))
                tile.icon:SetTexture(data.icon or (currentProfession and currentProfession.icon)
                    or PROFESSION_ICONS[professionName] or 134400)
                tile.placeholder:Hide()
                tile.placeholderText:Hide()
                tile.name:Show()
                tile.progress:Show()
                tile.lastSync:Show()
                tile.icon:Show()
                tile.progressBar:Show()
                tile.sync.professionName = professionName
                tile.sync.tradeSkillID = currentProfession and currentProfession.tradeSkillID
                tile.sync.iconTexture = currentProfession and currentProfession.icon or data.icon
                tile.sync:SetShown(tile.sync.tradeSkillID ~= nil)
            else
                tile.name:Hide()
                tile.progress:Hide()
                tile.lastSync:Hide()
                tile.icon:Hide()
                tile.progressBar:Hide()
                tile.sync:Hide()
                tile.placeholder:Show()
                tile.placeholderText:SetText(slot.placeholder)
                tile.placeholderText:Show()
            end
            tile:Show()
        end

        for index = #slots + 1, #professionTiles do
            professionTiles[index]:Hide()
        end
    end

    function self:SelectCurrentDashboardRecipeCharacter()
        if self.player and recipeCollected[self.player] then
            selectedCharacter = self.player
        end
        self:RefreshDashboardRecipeJournal()
    end

    self.dashboardRecipeJournal = parent
    self:RefreshDashboardRecipeJournal()
    parent:SetScript("OnSizeChanged", function()
        self:RefreshDashboardRecipeJournal()
    end)
end
