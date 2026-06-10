# Milestone 1 - Step 1

## Goal
Get a drivable placeholder Zamboni working with vehicle-style controls and centralized tuning values.

## What was added
- `config/game_constants.lua`
- `player/zamboni_controller.script`
- `game/game_controller.script`
- `ui/hud.gui_script`

## Defold editor setup
1. Create `game.input_binding` in project root.
2. Add actions:
   - `throttle_forward`: W, Up
   - `throttle_reverse`: S, Down
   - `steer_left`: A, Left
   - `steer_right`: D, Right
3. Open `game.project` and set:
   - `bootstrap.main_collection` to `/main/main.collection`
   - `input_binding` to `/game.input_binding`
4. Create `main/main.collection`.
5. Add a game object named `zamboni` in the collection.
6. Add a script component to `zamboni` and assign `/player/zamboni_controller.script`.
7. Add a visible placeholder to `zamboni`:
   - easiest option: add a sprite component using any temporary texture asset you have
   - scale it into a rectangle to resemble a top-down vehicle
8. Add another game object named `game_controller` and attach `/game/game_controller.script`.
9. Run the game.

## Expected result
- W accelerates forward.
- S reverses.
- A and D steer while moving.
- Turning in reverse feels mirrored like a real vehicle.

## Why this step exists
- Vehicle movement is the main gameplay feel and should be validated first.
- Constants are centralized early to avoid magic numbers and simplify tuning.
- The code remains intentionally small so the next step can focus on rink visuals only.
