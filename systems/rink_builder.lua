local M = {}

local function v3(x, y)
    return vmath.vector3(x, y, 0)
end

local function color4(c)
    return vmath.vector4(c[1], c[2], c[3], c[4])
end

local function add_box(x, y, w, h, color, rotation)
    local node = gui.new_box_node(v3(x, y), v3(w, h, 0))
    gui.set_color(node, color4(color))
    if rotation then
        gui.set_rotation(node, vmath.quat_rotation_z(rotation))
    end
    return node
end

local function add_circle(x, y, diameter, color)
    local node = gui.new_pie_node(v3(x, y), v3(diameter, diameter, 0))
    gui.set_color(node, color4(color))
    return node
end

local function draw_rounded_rect(cx, cy, width, height, radius, color)
    add_box(cx, cy, width - (radius * 2), height, color)
    add_box(cx, cy, width, height - (radius * 2), color)

    local half_w = width * 0.5
    local half_h = height * 0.5

    add_circle(cx - half_w + radius, cy + half_h - radius, radius * 2, color)
    add_circle(cx + half_w - radius, cy + half_h - radius, radius * 2, color)
    add_circle(cx - half_w + radius, cy - half_h + radius, radius * 2, color)
    add_circle(cx + half_w - radius, cy - half_h + radius, radius * 2, color)
end

local function draw_circle_outline(cx, cy, radius, thickness, color, segments)
    local step = (math.pi * 2) / segments
    local segment_len = (math.pi * 2 * radius) / segments

    for i = 0, segments - 1 do
        local angle = i * step
        local x = cx + math.cos(angle) * radius
        local y = cy + math.sin(angle) * radius
        add_box(x, y, thickness, segment_len, color, angle)
    end
end

local function draw_arc_outline(cx, cy, radius, thickness, color, segments, start_angle, end_angle)
    local arc = end_angle - start_angle
    local step = arc / segments
    local segment_len = (math.abs(arc) * radius) / segments

    for i = 0, segments do
        local angle = start_angle + (i * step)
        local x = cx + math.cos(angle) * radius
        local y = cy + math.sin(angle) * radius
        add_box(x, y, thickness, segment_len, color, angle)
    end
end

local function draw_center_line(rink, markings, palette)
    add_box(rink.center_x, rink.center_y, markings.center_line_thickness, rink.height - 10, palette.center_red)

    if not markings.center_line_dashed then
        return
    end

    local top = rink.center_y + ((rink.height - 22) * 0.5)
    local bottom = rink.center_y - ((rink.height - 22) * 0.5)
    local y = top

    while y > bottom do
        add_box(rink.center_x, y - (markings.center_line_dash_length * 0.5), 2, markings.center_line_dash_length, palette.ice)
        y = y - markings.center_line_dash_length - markings.center_line_dash_gap
    end
end

local function draw_faceoff_hash_marks(cx, cy, radius, thickness, length, offset, spacing, color)
    local edge = radius + offset
    local x_sep = spacing

    add_box(cx - x_sep, cy + edge, thickness, length, color)
    add_box(cx + x_sep, cy + edge, thickness, length, color)
    add_box(cx - x_sep, cy - edge, thickness, length, color)
    add_box(cx + x_sep, cy - edge, thickness, length, color)
end

local function draw_faceoff_symbol(cx, cy, color)
    add_box(cx, cy, 14, 2, color)
    add_box(cx, cy, 2, 14, color)

    add_box(cx - 8, cy + 8, 7, 2, color)
    add_box(cx + 8, cy + 8, 7, 2, color)
    add_box(cx - 8, cy - 8, 7, 2, color)
    add_box(cx + 8, cy - 8, 7, 2, color)

    add_box(cx - 6, cy + 12, 2, 5, color)
    add_box(cx + 6, cy + 12, 2, 5, color)
    add_box(cx - 6, cy - 12, 2, 5, color)
    add_box(cx + 6, cy - 12, 2, 5, color)
end

local function draw_placeholder_net(goal_line_x, cy, is_left_side, markings, palette)
    local dir = is_left_side and -1 or 1
    local center_x = goal_line_x + (markings.net_depth * 0.5 * dir)

    add_box(center_x, cy, markings.net_depth, markings.net_width, palette.net_mesh)
    add_box(center_x, cy - (markings.net_width * 0.5), markings.net_depth, markings.net_post_thickness, palette.net_post)
    add_box(center_x, cy + (markings.net_width * 0.5), markings.net_depth, markings.net_post_thickness, palette.net_post)
    add_box(goal_line_x, cy, markings.net_post_thickness, markings.net_width, palette.net_post)
end

local function draw_crease(goal_line_x, cy, half_height, is_left_side, fill_color, outline_color, outline_thickness, ice_color)
    add_circle(goal_line_x, cy, half_height * 2, fill_color)

    if is_left_side then
        add_box(goal_line_x - (half_height * 0.5), cy, half_height, (half_height * 2) + 2, ice_color)
        add_box(goal_line_x, cy, outline_thickness, half_height * 2, outline_color)
        draw_arc_outline(goal_line_x, cy, half_height, outline_thickness, outline_color, 42, -math.pi * 0.5, math.pi * 0.5)
    else
        add_box(goal_line_x + (half_height * 0.5), cy, half_height, (half_height * 2) + 2, ice_color)
        add_box(goal_line_x, cy, outline_thickness, half_height * 2, outline_color)
        draw_arc_outline(goal_line_x, cy, half_height, outline_thickness, outline_color, 42, math.pi * 0.5, math.pi * 1.5)
    end
end

local function draw_trapezoid_markings(rink, markings, palette)
    local left_goal_x = rink.center_x - (rink.width * 0.5) + markings.goal_line_inset
    local right_goal_x = rink.center_x + (rink.width * 0.5) - markings.goal_line_inset
    local top_y = rink.center_y + (markings.trapezoid_inset * 0.5)
    local bottom_y = rink.center_y - (markings.trapezoid_inset * 0.5)

    add_box(left_goal_x - (markings.trapezoid_depth * 0.5), top_y + 10, markings.trapezoid_depth, 2, palette.center_red, -0.32)
    add_box(left_goal_x - (markings.trapezoid_depth * 0.5), bottom_y - 10, markings.trapezoid_depth, 2, palette.center_red, 0.32)
    add_box(right_goal_x + (markings.trapezoid_depth * 0.5), top_y + 10, markings.trapezoid_depth, 2, palette.center_red, 0.32)
    add_box(right_goal_x + (markings.trapezoid_depth * 0.5), bottom_y - 10, markings.trapezoid_depth, 2, palette.center_red, -0.32)
end

function M.build(constants)
    local rink = constants.rink
    local markings = constants.rink_markings
    local palette = constants.palette

    local screen_w = gui.get_width()
    local screen_h = gui.get_height()

    add_box(screen_w * 0.5, screen_h * 0.5, screen_w, screen_h, palette.outside)

    local board_w = rink.width + (markings.board_thickness * 2)
    local board_h = rink.height + (markings.board_thickness * 2)
    local board_r = rink.corner_radius + markings.board_thickness

    draw_rounded_rect(rink.center_x, rink.center_y, board_w, board_h, board_r, palette.boards)
    draw_rounded_rect(rink.center_x, rink.center_y, rink.width, rink.height, rink.corner_radius, palette.ice)

    draw_center_line(rink, markings, palette)

    add_box(rink.center_x - markings.blue_line_offset, rink.center_y, markings.blue_line_thickness, rink.height - 10, palette.blue)
    add_box(rink.center_x + markings.blue_line_offset, rink.center_y, markings.blue_line_thickness, rink.height - 10, palette.blue)

    draw_circle_outline(rink.center_x, rink.center_y, markings.center_circle_radius, 3, palette.blue, 72)
    add_circle(rink.center_x, rink.center_y, markings.center_dot_radius * 2, palette.blue)

    local zone_x = markings.zone_faceoff_x_offset
    local zone_y = markings.zone_faceoff_y_offset

    draw_circle_outline(rink.center_x - zone_x, rink.center_y + zone_y, markings.faceoff_circle_radius, 4, palette.red_markings, 72)
    draw_circle_outline(rink.center_x + zone_x, rink.center_y + zone_y, markings.faceoff_circle_radius, 4, palette.red_markings, 72)
    draw_circle_outline(rink.center_x - zone_x, rink.center_y - zone_y, markings.faceoff_circle_radius, 4, palette.red_markings, 72)
    draw_circle_outline(rink.center_x + zone_x, rink.center_y - zone_y, markings.faceoff_circle_radius, 4, palette.red_markings, 72)

    add_circle(rink.center_x - zone_x, rink.center_y + zone_y, markings.faceoff_dot_radius * 2, palette.red_markings)
    add_circle(rink.center_x + zone_x, rink.center_y + zone_y, markings.faceoff_dot_radius * 2, palette.red_markings)
    add_circle(rink.center_x - zone_x, rink.center_y - zone_y, markings.faceoff_dot_radius * 2, palette.red_markings)
    add_circle(rink.center_x + zone_x, rink.center_y - zone_y, markings.faceoff_dot_radius * 2, palette.red_markings)

    draw_faceoff_hash_marks(rink.center_x - zone_x, rink.center_y + zone_y, markings.faceoff_circle_radius, markings.faceoff_hash_thickness, markings.faceoff_hash_length, markings.faceoff_hash_offset, markings.faceoff_hash_vertical_spacing, palette.red_markings)
    draw_faceoff_hash_marks(rink.center_x + zone_x, rink.center_y + zone_y, markings.faceoff_circle_radius, markings.faceoff_hash_thickness, markings.faceoff_hash_length, markings.faceoff_hash_offset, markings.faceoff_hash_vertical_spacing, palette.red_markings)
    draw_faceoff_hash_marks(rink.center_x - zone_x, rink.center_y - zone_y, markings.faceoff_circle_radius, markings.faceoff_hash_thickness, markings.faceoff_hash_length, markings.faceoff_hash_offset, markings.faceoff_hash_vertical_spacing, palette.red_markings)
    draw_faceoff_hash_marks(rink.center_x + zone_x, rink.center_y - zone_y, markings.faceoff_circle_radius, markings.faceoff_hash_thickness, markings.faceoff_hash_length, markings.faceoff_hash_offset, markings.faceoff_hash_vertical_spacing, palette.red_markings)

    draw_faceoff_symbol(rink.center_x - zone_x, rink.center_y + zone_y, palette.red_markings)
    draw_faceoff_symbol(rink.center_x + zone_x, rink.center_y + zone_y, palette.red_markings)
    draw_faceoff_symbol(rink.center_x - zone_x, rink.center_y - zone_y, palette.red_markings)
    draw_faceoff_symbol(rink.center_x + zone_x, rink.center_y - zone_y, palette.red_markings)

    add_circle(rink.center_x - markings.neutral_dot_offset_x, rink.center_y + markings.neutral_dot_offset_y, markings.neutral_dot_radius * 2, palette.red_markings)
    add_circle(rink.center_x + markings.neutral_dot_offset_x, rink.center_y + markings.neutral_dot_offset_y, markings.neutral_dot_radius * 2, palette.red_markings)
    add_circle(rink.center_x - markings.neutral_dot_offset_x, rink.center_y - markings.neutral_dot_offset_y, markings.neutral_dot_radius * 2, palette.red_markings)
    add_circle(rink.center_x + markings.neutral_dot_offset_x, rink.center_y - markings.neutral_dot_offset_y, markings.neutral_dot_radius * 2, palette.red_markings)

    local left_goal_line_x = rink.center_x - (rink.width * 0.5) + markings.goal_line_inset
    local right_goal_line_x = rink.center_x + (rink.width * 0.5) - markings.goal_line_inset

    add_box(left_goal_line_x, rink.center_y, markings.goal_line_thickness, rink.height - 10, palette.center_red)
    add_box(right_goal_line_x, rink.center_y, markings.goal_line_thickness, rink.height - 10, palette.center_red)

    draw_placeholder_net(left_goal_line_x, rink.center_y, true, markings, palette)
    draw_placeholder_net(right_goal_line_x, rink.center_y, false, markings, palette)

    draw_crease(
        left_goal_line_x,
        rink.center_y,
        markings.crease_half_height,
        true,
        palette.crease_fill,
        palette.crease_outline,
        markings.crease_outline_thickness,
        palette.ice
    )

    draw_crease(
        right_goal_line_x,
        rink.center_y,
        markings.crease_half_height,
        false,
        palette.crease_fill,
        palette.crease_outline,
        markings.crease_outline_thickness,
        palette.ice
    )

    draw_trapezoid_markings(rink, markings, palette)
end

return M
