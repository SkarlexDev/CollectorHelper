local _, app = ...

app.units = {
    { threshold = 1e9, suffix = "B", format = "%.2f" }, -- Billions
    { threshold = 1e6, suffix = "M", format = "%.2f" }, -- Millions
    { threshold = 1e3, suffix = "K", format = "%.0f" }, -- Thousands
}

--- Formats a number according to predefined units.
--- @param val string @ The input string representing a number, which may contain commas.
--- @return string
function app:formatNumber(val)
    local n = tonumber(val)
    if not n then return val end
    for _, unit in ipairs(self.units) do
        if n >= unit.threshold then
            return string.format(unit.format .. unit.suffix, n / unit.threshold)
        end
    end
    return tostring(n)
end

--- Formats a gold amount found within a string.
--- @param text string @ The input string containing a gold amount to format.
--- @return string
function app:formatGoldAmount(text)
    local rn = text:match("(%d[%d,]*%d)")
    if not rn then
        return text
    end

    local ns = rn:gsub(",", "")
    local num = tonumber(ns)
    if not num then return text end

    local fm = self:formatNumber(num)
    local r = text:gsub(rn, fm)
    return r
end


--- Formats a string with color coding for World of Warcraft.
--- @param color string @ The color code to apply, typically in hexadecimal format (e.g., "ff0000" for red).
--- @param text string @ The text to format with the specified color.
--- @return string
function app:textCFormat(color, text)
    return "\124cn" .. color .. ":" .. text .. "\124r"
end

