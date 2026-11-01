local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")

-- ============================================================================
-- Initialize News/Changelog Data
-- ============================================================================

--- Represents a changelog entry with version and changes.
---@class ChangelogEntry
---@field [1] string Version (e.g., "## 2.1.1")
---@field [2] string First change description; later array entries are additional notes.

--- Adds user-facing release notes shown on the dashboard's What's New page.
function CollectorHelper:InitNewsData()
    self.db.news = {
        {
            "## 3.0.1",
            "- Extracted the themed scrollbar into a reusable widget with a proportional thumb and synchronized mouse-wheel scrolling.",
            "- Reused the modern themed scrollbar in the auction-house list for consistent scrolling across the addon.",
            "- Improved virtualized list scroll-bound updates and scrollbar synchronization.",
            "- Restored hover highlighting and active-page indicators in the dashboard navigation.",
            "- Added LuaLS metadata for scrollable-list parameters and return values.",
        },
        {
            "## 3.0.0",
            "- Added a character-based recipe journal inside the collection dashboard.",
            "- Moved addon preferences into the dashboard and added a configurable minimap button.",
            "- Added a resizable dashboard with saved dimensions and a refreshed profession journal layout.",
            "- Improved minimap button integration and added changelog browsing to the dashboard.",
            "- Excluded Fishing and Archaeology from recipe tracking and fixed profession-sync UI updates.",
            "- Added a collection dashboard with quick access and preferences.",
            "- Reorganized the dashboard tabs and refreshed the interface with a compact dark-teal theme.",
            "- Added modern scrollbars and updated the changelog and recipe journal layouts.",
            "- Recipe Journal now separates two primary professions from the optional Cooking slot and keeps long character names readable.",
            "- Added clear hover feedback for characters and recipe actions, including a distinct delete style.",
            "- Recipe data for a forgotten profession is removed immediately; deleting the current character's data resets learned professions to 0/0.",
            "- Reorganized addon modules into feature-based folders.",
            "- Reused scroll-list rows to reduce frame creation during refreshes.",
            "- Cached item details and bag contents to reduce repeated inventory scans.",
            "- Updated bundled libraries, including a checkbox fix for WoW 12.1.",
            "- Added an Overview reference explaining what the current /ch shortcuts do; their legacy names and organization are planned for refactoring in a future update.",
            "- Consolidated Recipe Journal in the main dashboard; /ch recipe opens the journal, with no separate recipe window or merchant recipe shortcut.",
            "- Refreshed the merchant helper with the dashboard theme, a compact aligned header, and a cost list that adapts to Housing controls.",
            "- The merchant panel now collapses into a compact tab beside the merchant tabs, with the Housing toggle in the action row.",
            "- Standardized all four merchant action cards with matching sizes and spacing; narrowed the panel and brought it closer to the merchant frame.",
            "- Removed the separate currency heading, added currency-row hover feedback, and clarified the completion message.",
            "- Virtualized merchant and auction-house lists to reuse only visible rows plus a small buffer; improved scrollbar updates and shared frame utilities.",
        },
        {
            "##2.7.0",
            "- Game interface update",
            "- Fix housing"
        },
        {
            "##2.6.5",
            "- Minor fix for merchant update"
        },
        {
            "##2.6.3",
            "- Updated recipe db data",
        },
        {
            "##2.6.2",
            "- Multiple currency cost extend",
        },
        {
            "##2.6.1",
            "- Fixed housing duplicate buy logic",
        },
        {
            "##2.6.0",
            "-Added housing support & duplicate buy for housing items",
        },
        {
            "##2.5.5",
            "-ACE3 Updates"
        },
        {
            "##2.5.4",
            "-Lua hotfix"
        },
        {
            "##2.5.3",
            "-Recipe popup Fix"
        },
        {
            "##2.5.2",
            "-Interface Fix"
        },
        {
            "##2.5.1",
            "-Hotfixed recipe sync profession on first time learn"
        },
        {
            "## 2.2.0",
            "Deprecated functions changed",
            "Code optimizations & more",
        },
        {
            "## 2.1.1",
            "- Patch versioning",
            "- Minor framework update bug fix",
        },
        {
            "## 2.1.0",
            "- Added support interface for 11.1.5"
        },
        {
            "##2.0.9",
            "- Added soft collect option to hide owned items from merchant if other source is already collected",
            "- Added addon panel see '/ch options' command"
        },
        {
            "##2.0.8",
            "- Added recipes list view & delete option"
        },
        {
            "##2.0.7",
            "- Version update"
        },
        {
            "##2.0.6",
            "- Fixed recipe learn merchant button for multiple pages"
        },
        {
            "##2.0.5",
            "- Added addon panel see '/ch options' command"
        },
        {
            "## 2.0.4",
            "- Updated merchant learn button for recipes"
        },
        {
            "## 2.0.3",
            "- Added Zul'Grurub recipes"
        },
        {
            "## 2.0.2",
            "- Added auto sync recipe on learn"
        },
        {
            "## 2.0.1",
            "- Main frame & scroll rows visual update"
        },
        {
            "## 2.0.0",
            "- Added ace3 lib.",
            "- Refactored code structure.",
            "- Code & memory optimisations",
            "- Updated merchant main UI",
            "- Added recipe sync & display on main frame",
        },
        {
            "## 1.7.2",
            "- Removed the automatic opening of recipe sync when vendor gossip is opened.",
            "- Added a Sync Recipe button to the merchant frame."
        },
        {
            "## 1.7.1",
            "Fixed nil error when primary profession not learned"
        },
        {
            "## 1.7.0",
            "- Redesigned the initial recipe check logic has been added in 1.6.0",
            "- Added recipe sync for primary professions and cooking, along with the display of total recipes and collected ones.",
            "- Added /ch recipe command",
            "- There may be issues with the recipe check.",
            "- Any issues or suggestions can be added in the CurseForge addon comment section."
        },
        {
            "## 1.6.0",
            "- Added support for recipes character based",
            "- Added recipes db until < 11.0.7"
        },
        {
            "## V1.5.9",
            "- Interface update"
        },
        {
            "## V1.5.8",
            "- Code update"
        },
        {
            "## V1.5.7",
            "- Interface update for new patch"
        },
        {
            "## V1.5.6",
            "- Fixed frame cost"
        },
        {
            "## V1.5.5",
            "- Fixed settings migration",
            "- Added lfr completion mark",
            "- Added option to block news autoshow on changes"
        },
        {
            "## V1.5.2",
            "- Fixed lfr check on history data from previous week"
        },
        {
            "## V1.5.0",
            "- Added Changelog frame",
            "- Code optimisations",
            "- Removed Equip button from boe items",
            "- Added Destroy button to boe items",
            "- Split functions into independent modules",
            "- Updated command list & display",
            "- Added LFR helper",
            "   1. Display shorter name on LFR option",
            "   2. Added tooltip with bosses in wing",
            "   3. Added track killed/total",
            "   4. Added color change for in progress",
            "   5. Added finished mark for LFR wing",
            "   6. Added support up to Shadowlands"
        },
        {
            "## V1.4.4",
            "- Added sell button for boe merchant items (warband collect faster)"
        },
        {
            "## V1.4.3",
            "- The War Within patch 11.0 supported."
        },
        {
            "## V1.4.2",
            "- Fixed buttons overlap on classic interface",
            "- Shorter button names"
        },
        {
            "## V1.4",
            "- Dynamic Row Item Recycling in Scroll View (performance)",
            "- Dynamic Scrollbar Visibility (UI look)",
            "- Updated cost frame display with buttons like type and highlight on hover",
            "- Added currency chat link on click",
            "- Updated UI",
            "- Changed buy all button for all pages",
            "- Changed cost/page to total merchant cost",
            "- Added AH window support for currency items that can be bought from AH",
            "- Command support",
            "- Added support for additional merchant layouts.",
            "- Added support for merchant layouts displayed as a list."
        },
        {
            "## V1.3",
            "- Code update",
            "- Added toggle button for cost frame",
            "- Updated cost frame with list of items + tooltips"
        },
        {
            "## V1.2",
            "- Added merchant skin compatibility.",
            "- Fixed transmog item source detection.",
            "- Frame/buttons better handle",
            "- Added BoE vendor items in bag with equip button from merchant item",
            "- Fixed equip button with skip confirmation",
            "- Added addon logo texture"
        },
        {
            "## V1.1",
            "- Money frame hide added",
            "- Pet filter added",
            "- Fix Miscellaneous for some items",
            "- Added required/current currency - percentage to collect display",
            "- Added show/hide collected button from merchant",
            "- Added handle for gold items",
            "- Fixed money / alter currency both visible on merchant",
            "- Fixed strange way API handles some items for transmog"
        },
        {
            "## V1.0",
            "Initial Release"
        }
    }
end
