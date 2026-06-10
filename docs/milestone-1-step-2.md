# Milestone 1 - Step 2

## Goal
Render a recognizable hockey rink with placeholder geometry and realistic proportions, while keeping all dimensions and colors centralized in constants.

## What was added
- `systems/rink_builder.lua`
- `ui/rink.gui_script`
- expanded `config/game_constants.lua` with rink marking and palette values

## Defold editor setup
1. Create `ui/rink.gui`.
2. Set its script to `/ui/rink.gui_script`.
3. Open `main/main.collection`.
4. Add a game object named `rink_ui`.
5. Add a GUI component to `rink_ui` and assign `/ui/rink.gui`.
6. Make sure the same collection also has your `zamboni` object with `/player/zamboni_controller.script`.
7. Run the game.

## Expected visual result
- rounded-corner rink silhouette
- center red line
- two blue lines
- center faceoff circle
- four zone faceoff circles
- two goal creases

## Why this step exists
- It validates spatial gameplay feel before ice-quality logic.
- It keeps rink geometry data-driven in one constants file.
- It creates direct hooks for tile quality and target completion overlays in the next milestone.

## Tuning notes
All rink look-and-feel values can be tuned in `config/game_constants.lua`:
- `C.rink`
- `C.rink_markings`
- `C.palette`
