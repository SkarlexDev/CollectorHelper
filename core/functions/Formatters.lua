local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- Format a number with K/M/B suffixes for readability
-- e.g. 1500 -> "1K", 2300000 -> "2.3M"
-- ============================================================================

--- Formats large numbers into readable strings with suffixes.
--- @param val number|string The number to format.
--- @return string Formatted number with suffix (e.g. "1.2K", "3.4M").
function CollectorHelper:FormatNumber(val)
    local n = tonumber(val)
    if not n then return val end
    for _, unit in ipairs(self.units) do
        if n >= unit.threshold then
            return string.format(unit.format .. unit.suffix, n / unit.threshold)
        end
    end
    return tostring(n)
end

-- ============================================================================
-- Format gold amount string by replacing numbers with formatted values
-- Example: "123456 Gold" => "123K Gold"
-- ============================================================================

--- Replaces gold amount in string with shortened version.
--- @param text string Text containing numeric gold value.
--- @return string Text with formatted gold number.
function CollectorHelper:FormatGoldAmount(text)
    local rn = text:match("(%d[%d,]*%d)")
    if not rn then return text end

    local ns = rn:gsub(",", "")
    local num = tonumber(ns)
    if not num then return text end

    local fm = self:FormatNumber(num)
    return text:gsub(rn, fm)
end

-- ============================================================================
-- Format text with WoW color escape codes
-- WoW expects: "|cnRRGGBB:text|r"
-- ============================================================================

--- Colors text using WoW color escape sequence.
--- @param color string Hex RGB code without "#" (e.g., "ff0000" for red).
--- @param text string Text to apply the color to.
--- @return string Colorized text with WoW formatting.
function CollectorHelper:TextCFormat(color, text)
    return "|cn" .. color .. ":" .. text .. "|r"
end
