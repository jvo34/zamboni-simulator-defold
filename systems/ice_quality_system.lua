local M = {}

local function clamp(value, min_value, max_value)
    return math.max(min_value, math.min(value, max_value))
end

local function lerp(a, b, t)
    return a + ((b - a) * t)
end

local function point_inside_rounded_rink(x, y, rink)
    local half_w = rink.width * 0.5
    local half_h = rink.height * 0.5
    local radius = rink.corner_radius

    local local_x = x - rink.center_x
    local local_y = y - rink.center_y

    if math.abs(local_x) > half_w or math.abs(local_y) > half_h then
        return false
    end

    local inner_x = half_w - radius
    local inner_y = half_h - radius

    if math.abs(local_x) <= inner_x or math.abs(local_y) <= inner_y then
        return true
    end

    local corner_x = (local_x >= 0 and 1 or -1) * inner_x
    local corner_y = (local_y >= 0 and 1 or -1) * inner_y
    local dx = local_x - corner_x
    local dy = local_y - corner_y

    return (dx * dx) + (dy * dy) <= (radius * radius)
end

function M.create_grid(constants)
    local rink = constants.rink
    local grid = constants.ice_grid

    local target_tile_w = grid.tile_width
    local target_tile_h = grid.tile_height

    local left = rink.center_x - (rink.width * 0.5)
    local bottom = rink.center_y - (rink.height * 0.5)

    local cols = math.max(1, math.ceil(rink.width / target_tile_w))
    local rows = math.max(1, math.ceil(rink.height / target_tile_h))

    -- Use adaptive tile size so tiles cover the full rink extents with no leftover strips.
    local tile_w = rink.width / cols
    local tile_h = rink.height / rows

    local offset_x = left + (tile_w * 0.5)
    local offset_y = bottom + (tile_h * 0.5)

    local tiles = {}

    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local x = offset_x + (col * tile_w)
            local y = offset_y + (row * tile_h)

            if point_inside_rounded_rink(x, y, rink) then
                tiles[#tiles + 1] = {
                    row = row,
                    col = col,
                    x = x,
                    y = y,
                    width = tile_w,
                    height = tile_h,
                    quality = 0,
                }
            end
        end
    end

    return tiles
end

function M.set_tile_quality(tile, quality, constants)
    local max_quality = constants.tiles.max_quality
    tile.quality = clamp(quality, 0, max_quality)
end

function M.add_tile_quality(tile, amount, constants)
    M.set_tile_quality(tile, tile.quality + amount, constants)
end

function M.get_tile_blend(tile, constants)
    local max_quality = constants.tiles.max_quality
    if max_quality <= 0 then
        return 0
    end
    return clamp(tile.quality / max_quality, 0, 1)
end

function M.get_tile_color(tile, constants)
    local grid = constants.ice_grid
    local blend = M.get_tile_blend(tile, constants)
    local dirty = grid.dirty_color
    local clean = grid.clean_color

    local r = lerp(dirty[1], clean[1], blend)
    local g = lerp(dirty[2], clean[2], blend)
    local b = lerp(dirty[3], clean[3], blend)
    local a = lerp(dirty[4], clean[4], blend)

    local tint = tile.tint or 1.0
    return vmath.vector4(r * tint, g * tint, b * tint, a)
end

function M.count_dirty_tiles(tiles, constants)
    local threshold = constants.ice_grid.clean_threshold
    local dirty_count = 0

    for _, tile in ipairs(tiles) do
        if tile.quality < threshold then
            dirty_count = dirty_count + 1
        end
    end

    return dirty_count
end

function M.get_clean_percent(tiles, constants)
    if #tiles == 0 then
        return 100
    end

    local dirty_count = M.count_dirty_tiles(tiles, constants)
    local clean_count = #tiles - dirty_count
    return (clean_count / #tiles) * 100
end

local function quat_inverse_unit(q)
    return vmath.quat(-q.x, -q.y, -q.z, q.w)
end

function M.get_blade_center(zamboni_pos, zamboni_rot, constants)
    local blade = constants.ice_grid.blade
    local local_offset = vmath.vector3(blade.offset_x, blade.offset_y, 0)
    local rotated = vmath.rotate(zamboni_rot, local_offset)
    return vmath.vector3(zamboni_pos.x + rotated.x, zamboni_pos.y + rotated.y, 0)
end

local function get_cleaning_area(zamboni_pos, zamboni_rot, constants)
    local mode = constants.ice_grid.cleaning_mode or "rear_blade"

    if mode == "full_body" then
        local body_half_length = constants.vehicle.bounds_half_length or 0
        local body_half_width = constants.vehicle.bounds_half_width or 0
        local body_padding = constants.ice_grid.body_clean_padding or 0

        return {
            center = vmath.vector3(zamboni_pos.x, zamboni_pos.y, 0),
            half_length = body_half_length + body_padding,
            half_width = body_half_width + body_padding,
            rotation = zamboni_rot,
        }
    end

    local blade = constants.ice_grid.blade
    return {
        center = M.get_blade_center(zamboni_pos, zamboni_rot, constants),
        half_length = blade.half_length,
        half_width = blade.half_width,
        rotation = zamboni_rot,
    }
end

local function tile_overlaps_area(tile, area, inv_rot)
    local delta = vmath.vector3(tile.x - area.center.x, tile.y - area.center.y, 0)
    local local_pos = vmath.rotate(inv_rot, delta)

    local extent_x = area.half_length + (tile.width * 0.5)
    local extent_y = area.half_width + (tile.height * 0.5)
    return math.abs(local_pos.x) <= extent_x and math.abs(local_pos.y) <= extent_y
end

function M.clean_tiles_with_blade(tiles, zamboni_pos, zamboni_rot, constants)
    local area = get_cleaning_area(zamboni_pos, zamboni_rot, constants)
    local inv_rot = quat_inverse_unit(area.rotation)

    local cleaned_count = 0
    for _, tile in ipairs(tiles) do
        if tile.quality < constants.ice_grid.clean_threshold and tile_overlaps_area(tile, area, inv_rot) then
            M.set_tile_quality(tile, constants.tiles.max_quality, constants)
            cleaned_count = cleaned_count + 1
        end
    end

    return cleaned_count, area.center
end

return M
