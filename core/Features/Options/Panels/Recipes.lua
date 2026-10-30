local CollectorHelper = LibStub("AceAddon-3.0"):GetAddon("CollectorHelper")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

-- Global Recipe Collection Data
recipeCollected = recipeCollected or {}

-- Search filter (default empty)
local searchFilter = ""

-- Create Options Table for Blizzard Addon Panel
function CollectorHelper:CreateRecipeOptions()
  local options = {
    type = "group",
    name = "Recipe Collection",
    childGroups = "tree",
    args = {
      instructions = {
        type = "description",
        name =
        "Please note that total recipe number will change depending on expansion proffession learn and a manual sync",
        fontSize = "medium",
        order = 1,
      },
      reloadButton = {
        type = "execute",
        name = "Reload Data",
        desc = "Refresh the display with the latest character data.",
        func = function() self:UpdateRecipeOptions() end,
        order = 1,
      },
      sync = {
        type = "execute",
        name = "Sync",
        desc = "Sync recipe character data.",
        func = function() self:ShowRecipeUI(true) end,
        order = 2,

      },
      searchBox = {
        type = "input",
        name = "Search Character",
        desc = "Type to filter results live.",
        order = 3,
        set = function(_, value)
          searchFilter = string.lower(value or "")
          self:UpdateRecipeOptions()
        end,
        get = function() return searchFilter end
      },
      characterList = {
        type = "group",
        name = "Characters",
        args = {},
        order = 3,
      }
    }
  }
  return options
end

-- Function to Update the Options Table Dynamically
function CollectorHelper:UpdateRecipeOptions()
  local options = self:CreateRecipeOptions() -- Reset Base Options
  local charArgs = options.args.characterList.args

  for charName, charData in pairs(recipeCollected) do
    local nameOnly, _ = strsplit("-", charName, 2)

    -- Apply live search filtering
    if searchFilter == "" or string.find(string.lower(nameOnly), searchFilter, 1, true) then
      charArgs[charName] = {
        type = "group",
        name = charName, -- Show full name (Character-Realm)
        inline = true,
        order = 10,
        args = {}
      }

      local index = 1
      for profession, data in pairs(charData) do
        if profession ~= "Cooking" and data.total > 0 then
          charArgs[charName].args["prof" .. index] = {
            type = "description",
            name = profession .. ": " .. data.collected .. " / " .. data.total,
            fontSize = "medium",
            order = index * 10
          }
          index = index + 1
        end
      end

      -- Add Cooking if it exists
      if charData["Cooking"] and charData["Cooking"].total > 0 then
        charArgs[charName].args["cooking"] = {
          type = "description",
          name = "Cooking: " .. charData["Cooking"].collected .. " / " .. charData["Cooking"].total,
          fontSize = "medium",
          order = 30
        }
      end

      -- Delete Button for Character
      charArgs[charName].args["delete"] = {
        type = "execute",
        name = "Delete Data",
        desc = "Remove this character's recipe data.",
        func = function()
          recipeCollected[charName] = nil
          self:UpdateRecipeOptions()
        end,
        confirm = true,
        confirmText = "Are you sure you want to delete this character's recipe data?",
        order = 50
      }
    end
  end

  -- Re-register Updated Options
  AceConfigRegistry:RegisterOptionsTable("CollectorHelperOptions_Recipe", options)
  AceConfigDialog:SelectGroup("CollectorHelperOptions_Recipe", "Characters")
end
