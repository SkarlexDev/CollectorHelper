-- ============================================================================
-- CollectorHelper Main Addon Initialization
-- ============================================================================

local CollectorHelper = LibStub("AceAddon-3.0"):NewAddon("CollectorHelper", "AceConsole-3.0", "AceEvent-3.0")

-- ============================================================================
-- Slash Command Help Table (/ch)
-- ============================================================================
CollectorHelper.SLASH_COMMANDS = {
    { cmd = "help", desc = "Lists the available /ch commands." },
    { cmd = "panel", desc = "Opens the main dashboard; this is also the default when you enter /ch without a command." },
    { cmd = "dashboard", desc = "Alias for /ch panel." },
    { cmd = "options", desc = "Opens Preferences in the dashboard." },
    { cmd = "ah", desc = "Opens the tracked auction-house item list." },
    { cmd = "recipe", desc = "Opens the character-based Recipe Journal." },
    { cmd = "news", desc = "Opens the dashboard changelog." },
}

-- ============================================================================
-- Addon Lifecycle: OnInitialize
-- ============================================================================
function CollectorHelper:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CollectorHelperDB", nil, true)
    self:RegisterChatCommand("ch", "HandleChatCommand")

    local version = C_AddOns.GetAddOnMetadata("CollectorHelper", "Version")
    self.version = version or "unknown"

    self:InitDB()
    self:InitSettings()
end

-- ============================================================================
-- Addon Lifecycle: OnEnable
-- ============================================================================
function CollectorHelper:OnEnable()
    self:Init()
end

-- ============================================================================
-- Addon Lifecycle: OnDisable
-- ============================================================================
function CollectorHelper:OnDisable()
    self:UnregisterEvent("NEW_RECIPE_LEARNED")
    self:UnregisterEvent("BAG_UPDATE_DELAYED")
end

-- ============================================================================
-- Slash Command Dispatcher
-- ============================================================================
--- Handles "/ch" commands.
-- @param input string Command input
function CollectorHelper:HandleChatCommand(input)
    local command = strlower(strtrim(strsplit(" ", input or "", 2)))

    if command == "" or command == "panel" or command == "dashboard" then
        self:ToggleDashboard()
    elseif command == "help" then
        self:ShowHelpCmd()
    elseif command == "ah" then
        self.ahFrame:Show()
    elseif command == "recipe" then
        self:ToggleDashboard("recipes")
    elseif command == "news" then
        self:ToggleDashboard("news")
    elseif command == "options" then
        self:ToggleDashboard("settings")
    else
        self:Print("Unknown command: " .. command)
        self:ShowHelpCmd()
    end
end

-- ============================================================================
-- Display Help for Slash Commands
-- ============================================================================
function CollectorHelper:ShowHelpCmd()
    self:Print("Available /ch commands:")
    for _, entry in ipairs(self.SLASH_COMMANDS) do
        self:Print(string.format("/ch %s - %s", entry.cmd, entry.desc))
    end
end

-- ============================================================================
-- Global Access
-- ============================================================================
_G.CollectorHelper = CollectorHelper
_G.OpenCollectorHelperDashboard = function()
    CollectorHelper:ToggleDashboard()
end
