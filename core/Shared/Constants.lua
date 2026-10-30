local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- =========================================================================
-- Global Data Storage
-- =========================================================================

--- Mapping of inventory types to their corresponding slot IDs used by the game.
--- These IDs are used when determining where an item would be equipped.
---@type table<string, number[]>
CollectorHelper.ITEM_SLOT_ENUM = {
    -- Armor
    INVTYPE_HEAD = { 1 },         -- Head slot
    INVTYPE_SHOULDER = { 3 },     -- Shoulder slot
    INVTYPE_BODY = { 4 },         -- Shirt slot
    INVTYPE_CHEST = { 5 },        -- Chest slot
    INVTYPE_ROBE = { 5 },         -- Robes (same slot as chest)
    INVTYPE_WAIST = { 6 },        -- Waist slot
    INVTYPE_LEGS = { 7 },         -- Legs slot
    INVTYPE_FEET = { 8 },         -- Feet slot
    INVTYPE_WRIST = { 9 },        -- Wrist slot
    INVTYPE_HAND = { 10 },        -- Hands slot
    INVTYPE_CLOAK = { 15 },       -- Back slot (cloak)
    INVTYPE_TABARD = { 19 },      -- Tabard slot

    -- Weapons
    INVTYPE_WEAPON = { 16, 17 },          -- 1H Weapon (Main or Off-hand)
    INVTYPE_SHIELD = { 17 },              -- Off-hand shield
    INVTYPE_RANGED = { 16 },              -- Legacy ranged slot
    INVTYPE_2HWEAPON = { 16 },            -- Two-handed weapon
    INVTYPE_WEAPONMAINHAND = { 16 },      -- Main-hand weapon
    INVTYPE_WEAPONOFFHAND = { 16 },       -- Off-hand weapon (can include off-hand items)
    INVTYPE_HOLDABLE = { 17 },            -- Off-hand frill (e.g., tomes)
    INVTYPE_THROWN = { 16 },              -- Thrown weapons
    INVTYPE_RANGEDRIGHT = { 16 }          -- Ranged weapons (bows, guns, crossbows)
}

--- Color identifiers used for text formatting in the addon.
--- These are mapped to Blizzard's global color constants (e.g., RED_FONT_COLOR).
---@type table<string, string>
CollectorHelper.COLORS = {
    green = "PURE_GREEN_COLOR",  -- Bright green
    red = "RED_FONT_COLOR",      -- Standard red
    yellow = "YELLOW_FONT_COLOR",-- Standard yellow
    white = "WHITE_FONT_COLOR"   -- Standard white
}

--- Suffix formatting for currency or numeric values.
--- Used to format large numbers with appropriate units (K/M/B).
---@type { threshold: number, suffix: string, format: string }[]
CollectorHelper.units = {
    { threshold = 1e9, suffix = "B", format = "%.2f" }, -- Billions (1,000,000,000+)
    { threshold = 1e6, suffix = "M", format = "%.2f" }, -- Millions (1,000,000+)
    { threshold = 1e3, suffix = "K", format = "%.0f" }  -- Thousands (1,000+)
}
