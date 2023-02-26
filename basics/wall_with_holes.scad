//module wall_with_holes(size = [1, 1, 1], hole_width = 0.05, lattice_width = 0.1, hole_angle = 45) {
//    h_hole_dist = (hole_width + lattice_width) / cos(90 - hole_angle);
//    v_hole_dist = lattice_width / 2;
//    h_cnt = ceil(size.x / h_hole_dist);
//    v_cnt = ceil(size.z / v_hole_dist);
//    col_offsets = [0, - h_hole_dist / 2, 0];
//
//    module holes() {
//        for (row = [0: v_cnt]) {
//            //            col_offset = col_offsets[row % 2];
//            col_offset = 0;
//            for (col = [0: h_cnt]) {
//                translate([h_hole_dist * col + col_offset, 0, v_hole_dist * row])
//                    rotate([0, hole_angle, 0])
//                        cube([hole_width, size.y, hole_width]);
//            }
//        }
//    }
//
//    color("lightgreen")
//        difference() {
//            cube([size.x, size.y, size.z]);
//            //        holes();
//        }
//    //    translate([0, - 1, 0])
//    //        holes();
//}

//wall_with_holes([98, 10, 200], 5, 7, 35);
//color("coral")
//    translate([0, - 0.5, 0])
//        rotate([0, 35, 0])
//            translate([- 60, 0, - 20])
//                for (i = [0: 10]) {
//                    translate([12 * i, 0, 0])
//                        cube([7, 4, 100]);
//                }
//
//color("coral")
//    translate([0, - 0.5, 0])
//        rotate([0, - 55, 0])
//            translate([- 24, 0, - 60])
//                for (i = [0: 10]) {
//                    translate([12 * i, 0, 0])
//                        cube([7, 4, 100]);
//                }

lattice();

module lattice() {
    wall = [100, 10, 200];
    lattice_w = 5;
    hole_w = 17;
    angle = 75;
    assert(0 <= angle && angle < 90, "angle between 0-90");
    x_offset = 5;
    cube([wall.x, wall.y, wall.z]);
    translate([0, - 0.1, 0])
        color("lightblue") {
            partial_lattice(angle, wall.x, wall.y, wall.z, lattice_w, hole_w, x_offset);
            translate([0, 0, wall.z])
                rotate([0, 90, 0])
                    partial_lattice(angle, wall.z, wall.y, wall.x, lattice_w, hole_w, x_offset);
        }
}

module partial_lattice(angle, length, width, height, lattice_width, lattice_distance, offset) {
    start_point = - lattice_width * sin(angle) + offset;
    lattice_length = length / cos(angle) + lattice_width * tan(angle);
    v_dist = (lattice_width + lattice_distance) / cos(angle);
    lattice_cnt = (height + length * tan(angle)) / v_dist;
    for (i = [0:lattice_cnt]) {
        translate([start_point, 0, i * v_dist])
            rotate([0, angle, 0])
                translate([- offset / cos(angle), 0, 0])
                    cube([lattice_length, width, lattice_width]);
    }
}
//translate([8.72, - 0.5, 0]) {
//    rotate([0, - 55, 0])
//        color("coral")
//            translate([0, 0, - 50])
//                cube([7, 4, 100]);
//    translate([20.92, 0, 0])
//        rotate([0, - 55, 0])
//            color("lightblue")
//                translate([0, 0, - 50])
//                    cube([7, 4, 100]);
//}