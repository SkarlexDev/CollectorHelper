# CollectorHelper
## 3.0.2
- Added a Support page with a copyable invite link to the CollectorHelper Discord.
- Added a Discord community badge to the project overview.

## 3.0.1
- Extracted the themed scrollbar into a reusable widget with a proportional thumb and synchronized mouse-wheel scrolling.
- Reused the modern themed scrollbar in the auction-house list for consistent scrolling across the addon.
- Improved virtualized list scroll-bound updates and scrollbar synchronization.
- Restored hover highlighting and active-page indicators in the dashboard navigation.
- Added LuaLS metadata for scrollable-list parameters and return values.

## 3.0.0
- Added a character-based recipe journal inside the collection dashboard.
- Moved addon preferences into the dashboard and added a configurable minimap button.
- Added a resizable dashboard with saved dimensions and a refreshed profession journal layout.
- Improved minimap button integration and added changelog browsing to the dashboard.
- Excluded Fishing and Archaeology from recipe tracking and fixed profession-sync UI updates.
- Added a collection dashboard with quick access and preferences.
- Reorganized the dashboard tabs and refreshed the interface with a compact dark-teal theme.
- Added modern scrollbars and updated the changelog and recipe journal layouts.
- Added an Overview reference for the current `/ch` shortcuts, including their actions and the planned refactoring of their legacy names and organization.
- `/ch help` lists commands, `/ch` or `/ch panel` opens the dashboard, `/ch dashboard` is an alias, `/ch options` opens Preferences, `/ch ah` opens the auction-house list, `/ch recipe` opens Recipe Journal, and `/ch news` opens the changelog.
- Consolidated recipe access in the main dashboard; `/ch recipe` opens the journal, with no separate recipe window or merchant recipe shortcut.
- Refreshed the merchant helper with the dashboard theme, a compact aligned header, and a cost list that adapts to Housing controls.
- Made the merchant panel collapsible into a compact tab beside the merchant tabs and moved the Housing toggle into the action row.
- Standardized the four merchant actions with matching icon-card sizes and spacing; narrowed the panel and brought it closer to the merchant frame.
- Removed the redundant currency heading, added hover feedback to currency rows, and clarified the all-collected message.
- Virtualized merchant and auction-house lists so only visible rows plus a small buffer need frames; improved scrollbar updates and shared frame utilities.
- Reorganized addon modules into feature-based folders.
- Reused scroll-list rows to reduce frame creation during refreshes.
- Cached item details and bag contents to reduce repeated inventory scans.
- Updated bundled libraries, including a checkbox fix for WoW 12.1.

## 2.7.0
- Game interface update.
- Fixed Housing support.

## 2.6.5
- Fixed a merchant update issue.

## 2.6.3
- Updated recipe database data.

## 2.6.2
- Extended support for multiple currency costs.

## 2.6.1
- Fixed duplicate purchase logic for Housing items.

## 2.6.0
- Added Housing support and duplicate purchases for Housing items.

## 2.5.5
- Updated bundled libraries.

## 2.5.4
- Applied a Lua hotfix.

## 2.5.3
- Fixed the recipe popup.

## 2.5.2
- Fixed an interface issue.

## 2.5.1
- Fixed profession syncing when learning a profession for the first time.

## 2.2.0
- Replaced deprecated functions.
- Added code optimizations.

## 2.1.1
- Updated patch versioning.
- Fixed a minor framework update issue.

## 2.1.0
- Added support for interface version 11.1.5.

## 2.0.9
- Added an option to hide merchant items when another source is already collected.
- Added the addon settings panel, accessible with `/ch options`.

## 2.0.8
- Added a recipe list view and a delete option.

## 2.0.7
- Updated the addon version.

## 2.0.6
- Fixed the merchant recipe-learning button on multi-page merchants.

## 2.0.5
- Added the addon settings panel, accessible with `/ch options`.

## 2.0.4
- Updated the merchant recipe-learning button.

## 2.0.3
- Added Zul'Gurub recipes.

## 2.0.2
- Added automatic recipe syncing when learning a recipe.

## 2.0.1
- Updated the main frame and scroll-row visuals.

## 2.0.0
- Added bundled libraries.
- Refactored the code structure.
- Optimized code and memory usage.
- Updated the main merchant UI.
- Added recipe syncing and recipe progress to the main frame.

## 1.7.2
- Stopped automatically opening recipe sync when vendor gossip opens.
- Added a recipe sync button to the merchant frame.

## 1.7.1
- Fixed a nil error when no primary profession is learned.

## 1.7.0
- Redesigned the recipe-check logic introduced in 1.6.0.
- Added recipe syncing for primary professions and Cooking, with total and collected recipe counts.
- Added the `/ch recipe` command.
- Noted that recipe checks may have issues; feedback can be reported in the CurseForge comments.

## 1.6.0
- Added character-based recipe support.
- Added recipe data through patch 11.0.7.

## 1.5.9
- Updated the interface.

## 1.5.8
- Updated the code.

## 1.5.7
- Updated the interface for a new patch.

## 1.5.6
- Fixed the cost frame.

## 1.5.5
- Fixed settings migration.
- Added an LFR completion mark.
- Added an option to disable news auto-show on updates.

## V1.5.3
- Fixed lfr check on history data from previous week

## 1.5.2
- Fixed the LFR check for history data from the previous week.

## V1.5.0
- Added Changelog frame
- Code optimisations
- Removed Equip button from boe items
- Added Destroy button to boe iteems
- Split functions into independent modules
- Updated command list & display
- Added LFR helper
    1. Display shorter name on lfr option
    2. Added tooltip with bosses in wing
    3. Added track killed/total
    4. Added color change for in proggress
    5. Added finished mark for lfr wing
    6. Added support up to Shadowlands

## V1.4.4
- Added sell button for boe merchant items (warband collect faster)

## V1.4.3
- The War Within patch 11.0 supported.

## V1.4.2
- Fixed buttons overlap on classic interface
- Shorter button names

## V1.4
- Dynamic Row Item Recycling in Scroll View (performance)
- Dynamic Scrollbar Visibility (ui look)
- Updated cost frame display with buttons like type and high-light onhover
- Added currency chat link on click
- Updated UI
- Changed buy all button for all pages
- Changed cost/page to total merchant cost
- Added AH window support for currency items that can be bought from AH
- Command support
- Added support for additional merchant layouts.
- Added support for merchant layouts displayed as a list.

## V1.3
- Code update
- Added toggle button for cost frame
- Updated cost frame with list of items + tooltips

## V1.2
- Added elvui skin helper
- Fixed transmog item source detection.
- Frame/buttons better handle
- Added BoE vendor items in bag with equip button from merchant item 
- Fixed equip button with skip confirmation
- Added addon logo texture

## V1.1
- Money frame hide added
- Pet filter added
- Fix Miscellaneous for some items
- Added required/current currency - percentage to collect display
- Added show/hide collected button from merchant
- Added handle for gold items
- Fixed money / alter currency both visible on merchant
- Fixed strange way api handles some items for transmog

## V1.0 
Initial Release
