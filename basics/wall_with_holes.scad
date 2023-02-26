module wall_with_holes(size = [1, 1, 1], hole_width = 0.05, hole_distance = 0.1, hole_angle = 45) {
    v_hole_dist = hole_distance / 2;
    h_cnt = ceil(size.x / hole_distance);
    v_cnt = ceil(size.z / v_hole_dist);
    col_offsets = [- hole_distance / 2, 0];

    module holes() {
        for (row = [0: v_cnt]) {
            col_offset = col_offsets[row % 2];
            for (col = [0: h_cnt]) {
                translate([hole_distance * col + col_offset, 0, v_hole_dist * row])
                    rotate([0, hole_angle, 0])
                        cube([hole_width, size.y, hole_width]);
            }
        }
    }

    color("lightblue")
        difference() {
            cube([size.x, size.y, size.z]);
            //        holes();
        }
    translate([0, -1, 0])
        holes();
}


wall_with_holes([98, 10, 200], 5, 13, 35);
