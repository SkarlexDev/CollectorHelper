local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

local VERSION_PREFIX = "CollectorHelper"

local function ParseVersion(version)
    if type(version) ~= "string" or #version > 32 or not version:match("^[%d%.]+$") then
        return nil
    end

    local parts = {}
    for part in version:gmatch("[^.]+") do
        if #part > 6 then
            return nil
        end
        parts[#parts + 1] = tonumber(part)
    end

    if #parts == 0 or version:sub(1, 1) == "." or version:sub(-1) == "." or version:find("%.%.") then
        return nil
    end

    return parts
end

local function CompareVersions(left, right)
    local leftParts, rightParts = ParseVersion(left), ParseVersion(right)
    if not leftParts or not rightParts then
        return nil
    end

    for index = 1, math.max(#leftParts, #rightParts) do
        local leftPart, rightPart = leftParts[index] or 0, rightParts[index] or 0
        if leftPart ~= rightPart then
            return leftPart > rightPart and 1 or -1
        end
    end

    return 0
end

function CollectorHelper:InitVersionCheck()
    if not C_ChatInfo.RegisterAddonMessagePrefix(VERSION_PREFIX) then
        self:Print("Could not register the version-check chat prefix.")
        return
    end

    self.receivedOutOfDateMessage = nil
    self:RegisterEvent("CHAT_MSG_ADDON", "OnVersionCheckAddonMessage")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "ScheduleVersionCheck")
    self:ScheduleVersionCheck()
end

function CollectorHelper:ScheduleVersionCheck()
    if self.versionCheckScheduled then
        return
    end

    self.versionCheckScheduled = true
    C_Timer.After(10, function()
        self:BroadcastVersionCheck()
    end)
end

function CollectorHelper:BroadcastVersionCheck()
    local version = self.version
    if not ParseVersion(version) then
        return
    end

    if IsInRaid() then
        local distribution = not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)
            and "INSTANCE_CHAT" or "RAID"
        C_ChatInfo.SendAddonMessage(VERSION_PREFIX, version, distribution)
    elseif IsInGroup() then
        local distribution = not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
            and "INSTANCE_CHAT" or "PARTY"
        C_ChatInfo.SendAddonMessage(VERSION_PREFIX, version, distribution)
    end

    if IsInGuild() then
        C_ChatInfo.SendAddonMessage(VERSION_PREFIX, version, "GUILD")
    end
end

function CollectorHelper:OnVersionCheckAddonMessage(_, prefix, message, _, sender)
    if prefix ~= VERSION_PREFIX or type(message) ~= "string" or type(sender) ~= "string"
        or Ambiguate(sender, "none") == UnitName("player") then
        return
    end

    if CompareVersions(message, self.version) == 1 and not self.receivedOutOfDateMessage then
        self.receivedOutOfDateMessage = true
        self:NotifyNewerVersion()
    end
end

function CollectorHelper:NotifyNewerVersion()
    self:Print("CollectorHelper is out of date. You can download the newest version from CurseForge.")
end
