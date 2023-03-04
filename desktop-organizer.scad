include <libs/BOSL/constants.scad>
use <libs/BOSL/masks.scad>
use <libs/BOSL/shapes.scad>
use <basics/lattice_wall.scad>

wall = 4;
length = 95;
width = 88;
height = 83;

back_height = 58;
back_width = 18;
front_width = 22;

cham = 1.1;
back_bevel = 6;
middle_bevel = 8;

incline_height = 42;
incline_angle = 45;
bevel_angle = 45;

lattice_border = 7;
lattice_width = 4.6;
lattice_hole = 8.8;

middle_shoulder_length = 12;
back_shoulder_length = 10;

back_hole_height = 25;
back_hole_upper_len = 50;
back_hole_lower_len = 35;

SIDE_X = [wall, 0, 0];
SIDE_Y = [0, wall, 0];

middle_y = width - wall - back_width - middle_bevel;

function bevel_length(bevel) = bevel / cos(bevel_angle);

module both_side_of_wall(v = SIDE_X) {
    children();
    translate(v)
        children();
}

module front_incline_mask() {
    s = max(length, width, height);
    translate([- 1, 0, incline_height])
        rotate([incline_angle, 0, 0])
            cube(s + 2);
}

module bevel_mask(len, c = cham, orient = ORIENT_X) {
    chamfer_mask(len, c, orient = orient, center = false);
}

module side_wall() {
    lattice_side_hole_w = width - back_width - 3 * wall - 2 * lattice_border;
    lattice_side_hole_h = height - 3 * lattice_border;

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
        correct_wall_corner_bevels();
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

    module side_wall_hole() {
        incl_start_h = incline_height - 2 * lattice_border - lattice_border / tan((90 + incline_angle) / 2);
        incl_end_w = (lattice_side_hole_h - incl_start_h) / tan(incline_angle);
        translate([- 1, lattice_border, 2 * lattice_border])
            rotate([90, 0, 90])
                linear_extrude(wall + 2)
                    polygon([
                            [0, 0], [lattice_side_hole_w, 0], [lattice_side_hole_w, lattice_side_hole_h],
                            [incl_end_w, lattice_side_hole_h], [0, incl_start_h]
                        ]);
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
            bevel_mask(incline_height, orient = ORIENT_Z);
        }
        translate([0, 0, incline_height])
            rotate([- incline_angle, 0, 0])
                both_side_of_wall() {
                    bevel_mask(width, orient = ORIENT_Z);
                }
        translate([0, 0, height])
            both_side_of_wall() {
                bevel_mask(width, orient = ORIENT_Y);
            }
        translate([0, middle_y, back_height])
            both_side_of_wall() {
                bevel_mask(width, orient = ORIENT_Y);
            }
    }

    module back_corner() {
        translate([0, width - back_bevel, 0])
            rotate([0, 0, - bevel_angle])
                difference() {
                    back_length = bevel_length(back_bevel);
                    cube([wall, back_length, back_height]);
                    translate([0, 0, back_height])
                        both_side_of_wall() {
                            bevel_mask(back_length, orient = ORIENT_Y);
                        }
                }
    }

    module middle_corner() {
        translate([0, middle_y, 0]) {
            rotate([0, 0, - bevel_angle])
                difference() {
                    middle_length = bevel_length(middle_bevel);
                    cube([wall, middle_length, height]);
                    translate([0, 0, height])
                        both_side_of_wall() {
                            bevel_mask(middle_length, orient = ORIENT_Y);
                        }
                }
            linear_extrude(back_height)
                polygon([[cham, cham], [middle_bevel, middle_bevel], [cham, middle_bevel]]);
        }
    }

    module back_shoulder() {
        translate([back_bevel, width - wall, 0]) {
            difference() {
                cube([back_shoulder_length, wall, back_height]);
                translate([0, 0, back_height])
                    both_side_of_wall(SIDE_Y) {
                        bevel_mask(back_shoulder_length);
                    }
            }
        }
    }

    module middle_shoulder() {
        translate([middle_bevel, middle_y + wall, 0]) {
            difference() {
                cube([middle_shoulder_length, wall, height]);
                translate([0, 0, height])
                    both_side_of_wall(SIDE_Y) {
                        bevel_mask(middle_shoulder_length);
                    }
            }
        }
    }

    module correct_wall_corner_bevels() {
        offset = wall / 2;
        module bevel_correction() {
            translate([0, - offset, 0])
                bevel_mask(wall, orient = ORIENT_Y);
            rotate([0, 0, - bevel_angle])
                bevel_mask(wall, orient = ORIENT_Y);

        }
        translate([0, middle_y, height])
            bevel_correction();
        translate([middle_bevel, middle_y + middle_bevel, height])
            rotate([0, 0, - bevel_angle])
                bevel_correction();
        translate([0, width - back_bevel, back_height])
            bevel_correction();
        translate([back_bevel, width, back_height])
            rotate([0, 0, - bevel_angle])
                bevel_correction();

    }
}

module bottom() {
    difference() {
        cube([length, width, wall]);
        bevel_mask(wall, orient = ORIENT_Z);
        translate([length, 0, 0])
            bevel_mask(wall, orient = ORIENT_Z);
        translate([0, width, 0]) {
            bevel_mask(wall, back_bevel, orient = ORIENT_Z);
            translate([length, 0, 0])
                bevel_mask(wall, back_bevel, orient = ORIENT_Z);
        }
    }
}

module middle_wall() {
    middle_len = length - 2 * middle_bevel - 2 * middle_shoulder_length;
    wall_y = middle_y + middle_bevel - wall;

    module middle_bottom() {
        cube([middle_len, wall, 2 * lattice_border]);
    }

    module middle_lattice() {
        translate([0, 0, 2 * lattice_border])
            lattice([middle_len, wall, height - 3 * lattice_border], lattice_width, lattice_hole);
    }

    module middle_top() {
        translate([0, 0, height - lattice_border])
            difference() {
                cube([middle_len, wall, lattice_border]);
                translate([0, 0, lattice_border])
                    both_side_of_wall(SIDE_Y) {
                        bevel_mask(middle_len);
                    }
            }
    }

    translate([middle_bevel + middle_shoulder_length, wall_y, 0]) {
        middle_bottom();
        middle_lattice();
        middle_top();
    }
}

module back_wall() {
    full_len = length - 2 * back_bevel - 2 * back_shoulder_length;
    assert(back_hole_upper_len <= full_len, str("Back hole upper gap can't be longer than full length (w/o shoulders): ", full_len));
    assert(back_hole_lower_len <= back_hole_upper_len, str("Back hole lower gap can't be longer than upper gap: ", back_hole_upper_len));

    upper_part = (full_len - back_hole_upper_len) / 2;
    lower_part = (full_len - back_hole_lower_len) / 2;
    wall_y = width - wall;

    translate([back_bevel + back_shoulder_length, wall_y, 0]) {
        straight_wall();
        angled_wall();
        translate([full_len, 0, 0])
            mirror([1, 0, 0])
                angled_wall();

    }

    module straight_wall() {
        difference() {
            cube([full_len, wall, back_hole_height]);
            translate([0, 0, back_hole_height])
                both_side_of_wall(SIDE_Y) {
                    bevel_mask(full_len);
                }
        }
    }

    module angled_wall() {
        p_height = back_height - back_hole_height;
        lower_part_at_bottom = ((lower_part - upper_part) / p_height * back_height) + upper_part;

        lower_size = [lower_part_at_bottom, wall];
        upper_size = [upper_part, wall];
        shift = [- (lower_part_at_bottom - upper_part) / 2, 0];

        difference() {
            prismoid(lower_size, upper_size, back_height, shift, align = V_RIGHT + V_BACK + V_UP);
            translate([0, 0, back_height]) {
                both_side_of_wall(SIDE_Y) {
                    bevel_mask(upper_part);
                }
                translate([upper_part, 0, 0]) {
                    a = atan(p_height / (lower_part - upper_part));
                    rotate([0, a, 0])
                        both_side_of_wall(SIDE_Y) {
                            bevel_mask(back_height * 2);
                        }
                }
            }
        }
    }
}

bottom();
side_wall();
translate([length, 0, 0])
    mirror([1, 0, 0])
        side_wall();
middle_wall();
back_wall();
