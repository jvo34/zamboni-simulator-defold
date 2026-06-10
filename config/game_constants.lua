local C = {}

C.rink = {
    width = 940,
    height = 460,
    corner_radius = 54,
    center_x = 640,
    center_y = 360,
}

C.rink_markings = {
    board_thickness = 8,
    board_inner_border = 0,
    center_line_thickness = 8,
    center_line_dashed = true,
    center_line_dash_length = 10,
    center_line_dash_gap = 10,
    blue_line_thickness = 6,
    blue_line_offset = 235,
    center_circle_radius = 44,
    center_dot_radius = 4,
    zone_faceoff_x_offset = 304,
    zone_faceoff_y_offset = 118,
    faceoff_circle_radius = 44,
    faceoff_dot_radius = 3,
    neutral_dot_radius = 9,
    neutral_dot_offset_x = 155,
    neutral_dot_offset_y = 88,
    goal_line_inset = 64,
    goal_line_thickness = 4,
    goal_line_height = 320,
    goal_crease_radius = 30,
    crease_depth = 22,
    crease_half_height = 28,
    crease_notch = 0,
    crease_outline_thickness = 3,
    faceoff_hash_thickness = 3,
    faceoff_hash_length = 10,
    faceoff_hash_offset = 7,
    faceoff_hash_vertical_spacing = 8,
    net_depth = 22,
    net_width = 34,
    net_height = 64,
    net_post_thickness = 3,
    net_mesh_spacing = 8,
    trapezoid_depth = 52,
    trapezoid_inset = 108,
    ice_texture_line_count = 0,
    ice_texture_line_thickness = 0,
    ice_texture_tilt_radians = 0.0,
}

C.palette = {
    outside = { 0.90, 0.90, 0.90, 1.0 },
    boards = { 0.12, 0.12, 0.12, 1.0 },
    board_trim = { 1.0, 1.0, 1.0, 1.0 },
    ice = { 0.95, 0.95, 0.95, 1.0 },
    ice_texture = { 0.95, 0.95, 0.95, 0.0 },
    center_red = { 0.93, 0.25, 0.25, 1.0 },
    red_markings = { 0.93, 0.25, 0.25, 1.0 },
    blue = { 0.18, 0.45, 0.83, 1.0 },
    crease_fill = { 0.84, 0.90, 1.0, 0.5 },
    crease_outline = { 0.18, 0.45, 0.83, 1.0 },
    net_post = { 0.93, 0.25, 0.25, 1.0 },
    net_mesh = { 0.98, 0.98, 0.98, 1.0 },
}

C.vehicle = {
    acceleration = 170,
    brake_accel = 220,
    coast_decel = 140,
    max_forward_speed = 120,
    max_reverse_speed = 55,
    turn_speed = 1.9,
    min_turn_speed = 12,
    low_speed_turn_ratio = 0.35,
    bounds_half_length = 42,
    bounds_half_width = 24,
    bounds_radius = 8,
    bounds_margin = 1,
    corner_escape_nudge = 1.6,
    impact_nudge = 0.35,
    wall_nudge = 0.75,
}

C.timer = {
    session_seconds = 180,
}

C.tiles = {
    width = 32,
    height = 32,
    max_quality = 100,
}

C.ice_grid = {
    tile_width = 16,
    tile_height = 16,
    tile_gap = 0,
    dirty_color = { 0.68, 0.68, 0.68, 0.52 },
    clean_color = { 0.95, 0.95, 0.95, 0.0 },
    clean_threshold = 100,
    cleaning_rate = 90,
    cleaning_mode = "full_body",
    body_clean_padding = -8,
    blade = {
        offset_x = -38,
        offset_y = 0,
        half_length = 8,
        half_width = 24,
    },
}

return C
