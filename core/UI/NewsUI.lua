local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

function CollectorHelper:InitNews()
    -- Only proceed if version has changed
    if settings.version == self.db.version then return end

    settings.version = self.db.version

    if settings.autoShowNews then
        self:ShowNews()
    end

    self.db.settings = settings
end
