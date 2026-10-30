local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- Adapts the interface for ElvUI Shadow & Light edit (SLE)
-- This method hooks into the SLE merchant UI to ensure `UpdateShop()` is called
-- on scroll, events, and text input changes, ensuring shop data stays current.
-- ============================================================================

--- Hooks ElvUI SLE merchant scroll and input events to refresh shop state
function CollectorHelper:AdaptSLE()
    -- Get the scroll frame used by SLE and preserve the original scroll script
    local scrollFrame = _G['SLE_ListMerchantScrollFrame']
    local orgScript1 = scrollFrame:GetScript("OnVerticalScroll")

    --- Called when the merchant scroll frame is scrolled
    --- @param self Frame
    --- @param offset number
    local function OnVerticalScroll(self, offset)
        orgScript1(self, offset)  -- Call original handler
        CollectorHelper:UpdateShop()  -- Trigger shop data refresh
    end

    scrollFrame:SetScript("OnVerticalScroll", OnVerticalScroll)

    -- Get the main SLE frame and hook into its OnEvent script
    local sleFrame = _G["SLE_ListMerchantFrame"]
    local orgScript2 = sleFrame:GetScript("OnEvent")

    --- Called when the SLE merchant frame receives an event
    --- @param self Frame
    --- @param event string
    --- @param ... any
    local function OnEvent(self, event, ...)
        orgScript2(self, event, ...)  -- Call original handler

        -- Delay to allow UI state to stabilize before updating shop view
        C_Timer.After(0.25, function()
            CollectorHelper:UpdateShop()
        end)
        C_Timer.After(0.50, function()
            CollectorHelper:UpdateShop()
        end)
    end

    sleFrame:SetScript("OnEvent", OnEvent)

    -- Get the SLE search input box and hook multiple common events
    local search = _G["SLE_ListMerchantFrameSearch"]

    --- @type string[]
    local events = {
        "OnTextChanged",
        "OnShow",
        "OnEnterPressed",
        "OnEscapePressed",
        "OnEditFocusLost",
        "OnEditFocusGained"
    }

    -- Hook each input event to call UpdateShop for dynamic search refresh
    for _, event in ipairs(events) do
        search:HookScript(event, function()
            CollectorHelper:UpdateShop()
        end)
    end

    -- Mark SLE integration as active to prevent re-hooking
    self.isElvuiSLE = true
end
