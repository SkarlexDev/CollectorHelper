-- ========================
-- Section: debug ids
-- ========================
local function debugLockdown()
    for i = 1, GetNumSavedInstances() do
        local name, lockoutId, reset, difficultyId, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId =
            GetSavedInstanceInfo(i)
        if (isRaid and (difficultyId == 7 or difficultyId == 17)) then
            print(name)
            print(numEncounters)
            print(instanceId)
            print("---------------")
            for j = 1, numEncounters do
                local bossName, _, killed = GetSavedInstanceEncounterInfo(i, j)
                print(bossName)
                print(killed)
                print(j)
            end
        end
    end
end

local function debugGossip()
    local function getOptionID(self)
        print("clicked on " .. self:GetData().info.gossipOptionID)
    end

    local childs = { GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren() }
    for k, child in ipairs(childs) do
        local data = child.GetData and child:GetData()
        if data and data.info and data.info.gossipOptionID then
            if not child.hookedGossipExtraction then
                child:HookScript("OnClick", getOptionID)
                child.hookedGossipExtraction = true
            end
        end
    end
end