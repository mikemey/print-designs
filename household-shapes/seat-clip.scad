$fn = 1024;

seat_r = 180;
upper_w = 5.2;
lower_w = 4.2;
clip_h = 14;
clip_bottom_w = 2;
clip_side_w = 3;
clip_l = 50;
bevel = 1.4;

teeth_overlap = 0.5;
teeth_count = 5;

angle = 360 / (2 * seat_r * PI / clip_l);

translate([-seat_r + upper_w + clip_side_w, 0, clip_h])
rotate_extrude(angle = angle)
    translate([seat_r + clip_side_w, 0, 0])
        rotate([180, 0, - 90])
            clip_profile();

module clip_profile() {
    outer_x = clip_h;
    inner_x = clip_h - clip_bottom_w;
    outer_lower_y = lower_w + 2 * clip_side_w + teeth_overlap;
    outer_upper_y = upper_w + 2 * clip_side_w + teeth_overlap;

    outer_points = [[0, 0], [outer_x - bevel, 0], [outer_x, bevel], [outer_x, outer_lower_y - bevel], [outer_x - bevel, outer_lower_y], [0, outer_upper_y]];
    remaining_inner_points = [[inner_x, outer_lower_y - clip_side_w], [inner_x, clip_side_w], [0, clip_side_w]];

    teeth_step_x = inner_x / teeth_count;
    teeth_step_y = (upper_w - lower_w) / teeth_count;
    start_x = 0;
    start_y = outer_upper_y - clip_side_w;

    function teeth_top(i) = [start_x + i * teeth_step_x / 2, start_y - i * teeth_step_y / 2 - teeth_overlap];
    function teeth_end(i) = [start_x + i * teeth_step_x / 2, start_y - i * teeth_step_y / 2];

    teeth_start_points = [[0, outer_upper_y - clip_side_w]];
    teeth_points = [for (i = [1:teeth_count * 2]) if (i % 2 == 0) teeth_end(i) else teeth_top(i)];

    polygon(points = concat(outer_points, teeth_start_points, teeth_points, remaining_inner_points));
}

