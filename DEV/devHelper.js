/*

Dev data for new recipes

-- As of 12.09.2025 -> 12.0.0
-- https://www.wowhead.com/items/finder
-- https://www.wowhead.com/items/recipes/alchemy?filter=161:92:82;1:1:2;0:0:100000
-- filter live-only:on?filter=161:92;1:1;0:0
-- ?filter=161:92:82;1:1:2;0:0:100000
-- wowhead fetcher

*/

async function fetchData() {
  const resultMap = {};

  // Step 1: Get all links from the list
  const links = document.querySelectorAll('tr.listview-row a.listview-cleartext');

  for (let link of links) {
    const itemUrl = link.href;
    
    // Step 2: Extract item ID from the URL
    const itemId = itemUrl.match(/item=(\d+)/)?.[1];
    if (!itemId) continue;

    // Step 3: Open the item's page and get the content
    const itemPage = await fetch(itemUrl);
    const itemText = await itemPage.text();

    // Step 4: Parse the content and find the first spell link
    const parser = new DOMParser();
    const doc = parser.parseFromString(itemText, 'text/html');
    const spellLink = doc.querySelector('a[href*="/spell="]'); // Only take the first one

    // Initialize itemId entry if not already present
    resultMap[itemId] = resultMap[itemId] || null;

    if (spellLink) {
      // Step 5: Extract spell ID from the first spell link
      const spellId = spellLink.href.match(/spell=(\d+)/)?.[1];
      if (spellId) {
        // Step 6: Store the mapping in the result map
        resultMap[itemId] = spellId;
      }
    }
  }

  // Convert resultMap to Lua table format
  let luaResult = '';
  for (let [itemId, spellId] of Object.entries(resultMap)) {
    luaResult += `  [${itemId}] = ${spellId ? spellId : 'null'},\n`;
  }

  console.log(luaResult); // Final mapping of itemId -> spellId in Lua table format
}

fetchData();
