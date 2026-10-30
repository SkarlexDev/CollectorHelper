local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local COLORS = {
    background = { 0.035, 0.045, 0.075, 0.98 },
    panel = { 0.075, 0.09, 0.13, 0.98 },
    panelHover = { 0.12, 0.15, 0.20, 1 },
    accent = { 0.78, 0.58, 0.25, 1 },
    text = { 0.94, 0.92, 0.85, 1 },
    muted = { 0.62, 0.67, 0.75, 1 },
    green = { 0.38, 0.78, 0.53, 1 },
}

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
    frame:SetBackdropBorderColor(0.18, 0.21, 0.28, 1)
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
    button:SetBackdropBorderColor(0.18, 0.21, 0.28, 1)
    button.label = CreateLabel(button, text, "GameFontNormal", { "CENTER", button, "CENTER", 0, 0 })
    button.label:SetTextColor(unpack(COLORS.text))
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
        { "TOPLEFT", parent, "TOPLEFT", 0, -58 })
    characterHeader:SetTextColor(unpack(COLORS.accent))

    local characterScroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    characterScroll:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -80)
    characterScroll:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
    characterScroll:SetWidth(168)

    local characterContent = CreateFrame("Frame", nil, characterScroll)
    characterContent:SetSize(148, 1)
    characterScroll:SetScrollChild(characterContent)

    local details = CreateFrame("Frame", nil, parent)
    details:SetPoint("TOPLEFT", parent, "TOPLEFT", 204, -58)
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

    local deleteButton = CreateButton(details, 108, 28, "Delete data")
    deleteButton:SetPoint("TOPRIGHT", details, "TOPRIGHT", 0, 2)
    deleteButton:SetScript("OnClick", function()
        if selectedCharacter then
            StaticPopup_Show("COLLECTORHELPER_DELETE_RECIPE_DATA", selectedCharacter, nil, selectedCharacter)
        end
    end)

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

        for index, characterName in ipairs(names) do
            local button = characterButtons[index]
            if not button then
                button = CreateButton(characterContent, 146, 36, "")
                characterButtons[index] = button
                button.label:ClearAllPoints()
                button.label:SetPoint("LEFT", button, "LEFT", 9, 0)
                button.label:SetJustifyH("LEFT")
                button:SetScript("OnClick", function(widget)
                    selectedCharacter = widget.characterName
                    self:RefreshDashboardRecipeJournal()
                end)
            end

            button.characterName = characterName
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT", characterContent, "TOPLEFT", 0, -(index - 1) * 42)
            button.label:SetText(characterName)
            button:SetBackdropColor(unpack(characterName == selectedCharacter and COLORS.panelHover or COLORS.panel))
            button:SetBackdropBorderColor(unpack(characterName == selectedCharacter and COLORS.accent or COLORS.background))
            button:Show()
        end

        for index = #names + 1, #characterButtons do
            characterButtons[index]:Hide()
        end
        characterContent:SetHeight(math.max(#names * 42, 1))
        if #names == 0 then
            selectedCharacter = nil
        end
    end

    local function GetCurrentProfessions()
        local first, second, _, _, cooking, firstAid = GetProfessions()
        local professions = {}
        local function AddProfession(professionIndex)
            if not professionIndex then return end
            local name, icon, _, _, _, _, tradeSkillID = GetProfessionInfo(professionIndex)
            if name then
                PROFESSION_ICONS[name] = icon
                professions[name] = { icon = icon, tradeSkillID = tradeSkillID }
            end
        end
        AddProfession(first)
        AddProfession(second)
        AddProfession(cooking)
        AddProfession(firstAid)
        return professions
    end

    local function CreateProfessionTile()
        local tile = CreatePanel(details, 1, 112)
        tile.icon = tile:CreateTexture(nil, "ARTWORK")
        tile.icon:SetSize(42, 42)
        tile.icon:SetPoint("TOPLEFT", tile, "TOPLEFT", 14, -16)

        tile.name = CreateLabel(tile, "", "GameFontNormal", { "TOPLEFT", tile, "TOPLEFT", 68, -20 })
        tile.name:SetTextColor(unpack(COLORS.text))
        tile.progress = CreateLabel(tile, "", "GameFontHighlightSmall", { "TOPLEFT", tile, "TOPLEFT", 68, -44 })
        tile.progress:SetTextColor(unpack(COLORS.muted))

        tile.sync = CreateButton(tile, 84, 28, "Sync")
        tile.sync:SetPoint("BOTTOMRIGHT", tile, "BOTTOMRIGHT", -12, 10)
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
        local professionNames = {}
        for professionName, data in pairs(characterData or {}) do
            if type(data) == "table" then
                professionNames[#professionNames + 1] = professionName
            end
        end
        table.sort(professionNames)

        local slotCount = math.max(2, #professionNames)
        local detailWidth = details:GetWidth()
        if detailWidth <= 0 then
            detailWidth = parent:GetWidth() - 216
        end
        local tileWidth = math.max(190, math.floor((detailWidth - 12) / 2))
        for index = 1, slotCount do
            local tile = EnsureProfessionTile(index)
            local column = (index - 1) % 2
            local row = math.floor((index - 1) / 2)
            tile:SetSize(tileWidth, 112)
            tile:ClearAllPoints()
            tile:SetPoint("TOPLEFT", details, "TOPLEFT", column * (tileWidth + 12), -62 - row * 124)

            local professionName = professionNames[index]
            local data = professionName and characterData[professionName]
            if data then
                local currentProfession = currentProfessions[professionName]
                tile.name:SetText(professionName)
                tile.progress:SetText(string.format("%d / %d recipes  |  %s",
                    tonumber(data.collected) or 0,
                    tonumber(data.total) or 0,
                    data.lastSync or "Not synced"))
                tile.icon:SetTexture(data.icon or (currentProfession and currentProfession.icon)
                    or PROFESSION_ICONS[professionName] or 134400)
                tile.placeholder:Hide()
                tile.placeholderText:Hide()
                tile.name:Show()
                tile.progress:Show()
                tile.icon:Show()
                tile.sync.professionName = professionName
                tile.sync.tradeSkillID = currentProfession and currentProfession.tradeSkillID
                tile.sync.iconTexture = currentProfession and currentProfession.icon or data.icon
                tile.sync:SetShown(tile.sync.tradeSkillID ~= nil)
            else
                tile.name:Hide()
                tile.progress:Hide()
                tile.icon:Hide()
                tile.sync:Hide()
                tile.placeholder:Show()
                tile.placeholderText:Show()
            end
            tile:Show()
        end

        for index = slotCount + 1, #professionTiles do
            professionTiles[index]:Hide()
        end
    end

    self.dashboardRecipeJournal = parent
    self:RefreshDashboardRecipeJournal()
    parent:SetScript("OnSizeChanged", function()
        self:RefreshDashboardRecipeJournal()
    end)
end
