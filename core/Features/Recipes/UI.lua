local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
local COLORS = CollectorHelper.COLORS or {}

-- ============================================================================
-- Initializes the Recipe Sync UI and profession buttons
-- ============================================================================
function CollectorHelper:InitRecipeUI()
    -- Main frame
    self.recipeFrame = self:FrameBuilder({
        frameName = "CollectorHelper_Recipes",
        parent = UIParent,
        width = 300,
        height = 400,
        point = { pos = "CENTER", x = 0, y = 0 },
        titleBuilder = {
            text = self:TextCFormat(COLORS.yellow, "CollectorHelper Recipe sync"),
            point = { pos = "TOP", x = 0, y = -8 },
        }
    })

    self.recipeFrame:SetMovable(true)
    self.recipeFrame:EnableMouse(true)
    self.recipeFrame:RegisterForDrag("LeftButton")
    self.recipeFrame:SetScript("OnDragStart", self.recipeFrame.StartMoving)
    self.recipeFrame:SetScript("OnDragStop", self.recipeFrame.StopMovingOrSizing)

    self:ButtonBuilder({
        buttonName = "Collector_RecipeCloseButton",
        parent = self.recipeFrame,
        text = "Close",
        width = 100,
        height = 22,
        point = { pos = "BOTTOM", x = 0, y = 8 },
        onClickScript = function(_, button)
            if button == "LeftButton" then
                self.recipeFrame:Hide()
            end
        end
    })

    -- ============================================================================
    -- Internal: Sync profession data after opening trade skill UI
    -- ============================================================================
    function self:SyncProfessionData(button, professionName)
        local player = self.player
        if not (player and recipeCollected[player] and professionName) then 
            self:initializeRecipesCollected()
            return 
        end

        local professionData = recipeCollected[player][professionName]
        if not professionData then 
            self:initializeRecipesCollected()
            return 
        end

        local collected, total = 0, 0
        local now = date("%Y-%m-%d %H:%M:%S")
        professionData.recipes = {}

        for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
            local info = C_TradeSkillUI.GetRecipeInfo(id)
            if info then
                professionData.recipes[info.recipeID] = info.learned or false
                if info.learned then collected = collected + 1 end
                total = total + 1
            end
        end

        professionData.collected = collected
        professionData.total = total
        professionData.lastSync = now

        if button.lastSyncText then
            button.collectedText:SetText("Collected: " .. collected .. " / " .. total)
            button.lastSyncText:SetText("Last Sync: " .. now)
        else
            button.collectedText:SetText(collected .. " / " .. total)
        end
    end

    -- ============================================================================
    -- Internal: Button factory
    -- ============================================================================
    local function generateProfButton(yOffset, xOffset, size, parent, showSync)
        local button = self:ButtonBuilder({
            buttonName = "Collector_ProfButton_" .. yOffset .. "_" .. xOffset,
            parent = parent,
            text = "",
            width = size,
            height = size,
            point = { pos = "CENTER", x = xOffset, y = yOffset },
            onClickScript = function(btn, click)
                if click == "LeftButton" and btn.tradeSkillID then
                    C_TradeSkillUI.OpenTradeSkill(btn.tradeSkillID)
                    C_Timer.After(0.25, function()
                        self:SyncProfessionData(btn, btn.name)
                    end)
                end
            end
        })

        -- Icon
        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetAllPoints(button)
        icon:SetTexture(132764)
        button.icon = icon

        -- Collected text
        local text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("TOP", button, "BOTTOM", 0, -2)
        text:SetText("No profession")
        button.collectedText = text

        -- Sync timestamp text
        if showSync then
            local syncText = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            syncText:SetPoint("TOP", text, "BOTTOM", 0, -2)
            button.lastSyncText = syncText
        end

        return button
    end

    -- ============================================================================
    -- Build and store buttons
    -- ============================================================================
    self.profButtons = {
        -- Main frame buttons
        generateProfButton(125, 0, 64, self.recipeFrame, true),
        generateProfButton(25, 0, 64, self.recipeFrame, true),
        generateProfButton(-75, 0, 64, self.recipeFrame, true),

        -- Merchant extension frame buttons
        generateProfButton(2, -110, 60, self.innerRecipeFrame, false),
        generateProfButton(2, 0, 60, self.innerRecipeFrame, false),
        generateProfButton(2, 100, 60, self.innerRecipeFrame, false),
    }

    self.recipeFrame:Hide()
end
