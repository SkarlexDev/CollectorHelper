
# CollectorHelper

Retail collection helper for merchants, recipes, transmog, raid-finder progress, and auction-house shopping lists.

## Code layout

- `CollectorHelper.lua` owns addon lifecycle and slash commands.
- `Init.xml` defines the ordered module load.
- `core/Bootstrap/` initializes saved data and settings.
- `core/Data/` contains collection catalogs and changelog data.
- `core/Shared/` contains helpers shared by multiple features.
- `core/Features/` groups merchant, auction house, recipe, LFR, and dashboard changelog code.
- `core/Features/Dashboard/` provides the main collection hub, preferences, and minimap button.
- `core/Features/Recipes/Dashboard.lua` renders the character-based recipe journal inside the dashboard.
- The minimap launcher uses LibDataBroker and LibDBIcon, following the Plater setup.
- `core/UI/` contains shared builders and reusable widgets.
- `Libs/` contains bundled Ace3, LibDataBroker, and LibDBIcon dependencies.

The TOC targets Retail interface versions `120100` and `120105`. Existing settings and recipe/LFR saved variables remain supported.

Use `/ch` to open the resizable dashboard, `/ch options` for dashboard preferences, `/ch recipe` for the character-based recipe journal, and `/ch news` for the integrated changelog. Dashboard size and minimap-button position are saved. Fishing and Archaeology are excluded from recipe tracking. The merchant's **Sync Recipe** shortcut opens the dashboard journal; there is no separate recipe window.

![4prime![afterlfr](https://github.com/user-attachments/assets/e243a84d-e0a8-465e-87bd-c72a4e146407)
](https://github.com/user-attachments/assets/033af33e-b0df-4f81-9e5a-d847e913144f)
![3prime](https://github.com/user-attachments/assets/98ae5f58-5ec4-4f5b-99cd-6c69d4ff8208)
![2prime](https://github.com/user-attachments/assets/6fcaf210-ecd2-4b1e-8a8d-4f1c6f129a28)
![1prime](https://github.com/user-attachments/assets/d78356e8-cbea-47e2-8daf-20a274d84f52)
![5prime](https://github.com/user-attachments/assets/585b54f4-00e3-4d97-9c18-63c954bee59d)
![changelfr](https://github.com/user-attachments/assets/576cb2f4-c3f6-4272-b137-dbe577082b31)
