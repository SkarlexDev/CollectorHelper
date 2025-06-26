-- ============================================================================
-- CollectorHelper Main Addon Initialization
-- ============================================================================

local CollectorHelper = LibStub("AceAddon-3.0"):NewAddon("CollectorHelper", "AceConsole-3.0", "AceEvent-3.0")

-- ============================================================================
-- Slash Command Help Table (/ch)
-- ============================================================================
local commands = {
    { cmd = "help",    desc = "- Displays this help or command list." },
    { cmd = "options", desc = "- Opens config panel." },
    { cmd = "ah",      desc = "- Shows auction house shop list." },
    { cmd = "recipe",  desc = "- Shows recipe frame for sync." },
    { cmd = "news",    desc = "- Shows news/changelog frame." },
}

-- ============================================================================
-- Addon Lifecycle: OnInitialize
-- ============================================================================
function CollectorHelper:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("CollectorHelperDB", defaults, true)
    self:RegisterChatCommand("ch", "HandleChatCommand")

    local version = C_AddOns.GetAddOnMetadata("CollectorHelper", "Version")
    self.db.version = version

    self:InitDB()
    self:InitSettings()
end

-- ============================================================================
-- Addon Lifecycle: OnEnable
-- ============================================================================
function CollectorHelper:OnEnable()
    -- self:Print("OnEnable fired. Welcome! Version: " .. self.db.version)
    self:Init()
end

-- ============================================================================
-- Addon Lifecycle: OnDisable
-- ============================================================================
function CollectorHelper:OnDisable()
    -- self:Print("Addon Disabled!")
end

-- ============================================================================
-- Slash Command Dispatcher
-- ============================================================================
--- Handles "/ch" commands.
-- @param input string Command input
function CollectorHelper:HandleChatCommand(input)
    local command = strlower(strtrim(strsplit(" ", input or "", 2)))

    if command == "" or command == "help" then
        self:ShowHelpCmd()
    elseif command == "ah" then
        self.ahFrame:Show()
    elseif command == "recipe" then
        self:ShowRecipeUI(true)
    elseif command == "news" then
        self:ShowNews()
    elseif command == "options" then
        Settings.OpenToCategory(self.MainPanel)
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
    for _, entry in ipairs(commands) do
        self:Print(string.format("/ch %s %s", entry.cmd, entry.desc))
    end
end

-- ============================================================================
-- Global Access
-- ============================================================================
_G.CollectorHelper = CollectorHelper
