local _, app = ...
local COLORS = app.COLORS
local cmds = {
  {
    "/ch help",
    "- Displays this help or command list." },
  {
    "/ch ah",
    "- Shows auction house shop list"
  },
  {
    "/ch news",
    "- Shows news/changelog frame"
  }
}

-- Slash command to toggle the AddOn
SLASH_COLLECTORHELPER1 = "/ch"
SlashCmdList["COLLECTORHELPER"] = function(msg, editBox)
  local showHelp = function()
    print("Displaying command list:")
    for _, cmd in ipairs(cmds) do
      print(app:textCFormat(COLORS.yellow, cmd[1]) .. cmd[2])
    end
  end
  local command, arg1 = strsplit(" ", msg)
  if command == "help" or command == "" then
    showHelp()
  elseif command == "ah" then
    app.ahFrame:Show()
  elseif command == "news" then
    app:ShowNews()
  else
    showHelp()
  end
end

-- ========================
-- Section: Addon RegisterEvent
-- ========================
local CollectorHelper = CreateFrame("Frame")
CollectorHelper:RegisterEvent("ADDON_LOADED")
CollectorHelper:SetScript("OnEvent", function(self, event, arg1, arg2, arg3)
  if event == "ADDON_LOADED" and arg1 == "CollectorHelper" then
    app:InitAddon()
  end
end)
