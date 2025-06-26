local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
-- ============================================================================
-- Auction House quick search helper
-- ============================================================================
function CollectorHelper:AuctionHouseHelper(item)
    if AuctionHouseFrame and AuctionHouseFrame.CommoditiesBuyFrame and AuctionHouseFrame.CommoditiesBuyFrame.BackButton then
        AuctionHouseFrame.CommoditiesBuyFrame.BackButton:Click()
    end

    local query = {
        searchString = item.item.name,
        sorts = {
            { sortOrder = Enum.AuctionHouseSortOrder.Price, reverseSort = false },
            { sortOrder = Enum.AuctionHouseSortOrder.Name, reverseSort = false },
        },
        filters = {
            Enum.AuctionHouseFilter.PoorQuality,
            Enum.AuctionHouseFilter.CommonQuality,
            Enum.AuctionHouseFilter.UncommonQuality,
            Enum.AuctionHouseFilter.RareQuality,
            Enum.AuctionHouseFilter.EpicQuality,
        },
    }
    C_AuctionHouse.SendBrowseQuery(query)
end