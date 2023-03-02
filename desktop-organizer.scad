include <libs/BOSL/constants.scad>
use <libs/BOSL/masks.scad>
use <basics/lattice_wall.scad>

wall = 4;
length = 95;
width = 88;
height = 83;

back_height = 58;
back_width = 18;
front_width = 22;

back_bevel = 6;
middle_bevel = 8;

incline_height = 42;
incline_angle = 45;

lattice_border = 7;
lattice_width = 4.6;
lattice_hole = 8.8;

cham = 1.2;

SIDE_X = [wall, 0, 0];
SIDE_Y = [0, wall, 0];
SIDE_Z = [0, 0, wall];

middle_y = width - wall - back_width - middle_bevel;
lattice_side_hole_w = width - back_width - 3 * wall - 2 * lattice_border;
lattice_side_hole_h = height - 3 * lattice_border;

function bevel_length(bevel) = bevel / cos(45);

module side_wall() {
    difference() {
        union() {
            difference() {
                basic_side_wall();
                chamfer_side_wall();
            }
            back_corner();
            middle_corner();
            back_shoulder();
            middle_shoulder();
        }
        correct_bevel_edges();
    }
    //    color("coral")
    //        translate([0, width - back_bevel, back_height])
    //            chamfer_mask(wall, cham, orient = ORIENT_X, center = false);
}

module basic_side_wall() {
    difference() {
        cube([wall, width - back_bevel, height]);
        translate([- 1, middle_y, back_height])
            cube([wall + 2, width, height]);
        front_incline_mask();
        side_wall_hole();
    }
    side_wall_lattice();
}

module front_incline_mask() {
    s = max(length, width, height);
    translate([- 1, 0, incline_height])
        rotate([incline_angle, 0, 0])
            cube(s + 2);
}

module side_wall_hole() {
    incl_start_h = incline_height - 2 * lattice_border - lattice_border / tan((90 + incline_angle) / 2);
    incl_end_w = (lattice_side_hole_h - incl_start_h) / tan(incline_angle);
    translate([- 1, lattice_border, 2 * lattice_border])
        rotate([90, 0, 90])
            linear_extrude(wall + 2) {
                polygon([
                        [0, 0], [lattice_side_hole_w, 0], [lattice_side_hole_w, lattice_side_hole_h],
                        [incl_end_w, lattice_side_hole_h], [0, incl_start_h]
                    ]);
            }
}

module side_wall_lattice() {
    difference() {
        translate([wall, lattice_border, 2 * lattice_border])
            rotate([0, 0, 90])
                lattice([lattice_side_hole_w, wall, lattice_side_hole_h], lattice_width, lattice_hole);
        front_incline_mask();
    }
}

module chamfer_side_wall() {
    both_side_of_wall() {
        chamfer_mask(incline_height, cham, orient = ORIENT_Z, center = false);
    }
    translate([0, 0, incline_height])
        rotate([- incline_angle, 0, 0])
            both_side_of_wall() {
                chamfer_mask(width, cham, orient = ORIENT_Z, center = false);
            }
    translate([0, 0, height])
        both_side_of_wall() {
            chamfer_mask(width, cham, orient = ORIENT_Y, center = false);
        }
    translate([0, middle_y, back_height])
        both_side_of_wall() {
            chamfer_mask(width, cham, orient = ORIENT_Y, center = false);
        }
}

module back_corner() {
    translate([0, width - back_bevel, 0])
        rotate([0, 0, - 45])
            difference() {
                back_length = bevel_length(back_bevel);
                cube([wall, back_length, back_height]);
                translate([0, 0, back_height])
                    both_side_of_wall() {
                        chamfer_mask(back_length, cham, orient = ORIENT_Y, center = false);
                    }
            }
}

module middle_corner() {
    translate([0, middle_y, 0])
        rotate([0, 0, - 45])
            difference() {
                middle_length = bevel_length(middle_bevel);
                cube([wall, middle_length, height]);
                translate([0, 0, height])
                    both_side_of_wall() {
                        chamfer_mask(middle_length, cham, orient = ORIENT_Y, center = false);
                    }
            }
}

module back_shoulder() {
    translate([back_bevel, width - wall, 0]) {
        difference() {
            cube([lattice_border, wall, back_height]);
            translate([0, 0, back_height])
                both_side_of_wall(SIDE_Y) {
                    chamfer_mask(lattice_border, cham, orient = ORIENT_X, center = false);
                }
        }
    }
}

module middle_shoulder() {
    translate([middle_bevel, middle_y + wall, 0]) {
        difference() {
            cube([lattice_border, wall, height]);
            translate([0, 0, height])
                both_side_of_wall(SIDE_Y) {
                    chamfer_mask(lattice_border, cham, orient = ORIENT_X, center = false);
                }
        }
    }
}

module correct_bevel_edges() {

}

module both_side_of_wall(v = SIDE_X) {
    children();
    translate(v)
        children();
}

module bottom() {
    difference() {
        cube([length, width, wall]);
        chamfer_mask(wall, cham, orient = ORIENT_Z, center = false);
        translate([length, 0, 0])
            chamfer_mask(wall, cham, orient = ORIENT_Z, center = false);
        translate([0, width, 0]) {
            chamfer_mask(wall, back_bevel, orient = ORIENT_Z, center = false);
            translate([length, 0, 0])
                chamfer_mask(wall, back_bevel, orient = ORIENT_Z, center = false);
        }
    }
}



bottom();
side_wall();
//translate([length, 0, 0])
//    mirror([1, 0, 0])
//        side_wall();

