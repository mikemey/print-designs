include <../libs/BOSL/constants.scad>
use <../libs/BOSL/masks.scad>
use <../libs/BOSL/shapes.scad>
use <../basics/lattice_wall.scad>

wall = 4;
length = 95;
width = 88;
height = 83;

back_height = 58;
back_width = 18;
front_width = 23;
front_panel_height = 10;
front_panel_notch = 2;

assert(front_panel_notch <= wall, "Notch of front panel needs to be smaller than wall thickness");

cham = 1.1;
back_bevel = 6;
middle_bevel = 8;

incline_height = 42;
incline_angle = 45;
bevel_angle = 45;

lattice_border = 7;
lattice_width = 4;
lattice_hole = 8.2;

middle_shoulder_length = 12;
back_shoulder_length = 10;

back_hole_height = 25;
back_hole_upper_len = 50;
back_hole_lower_len = 35;

separator_wall = 2;
separator_wall_offsets = [length / 3, length * 2 / 3];
separator_wall_height = height - 5;
separator_wall_lattice_width = 3;
separator_wall_lattice_hole = 5;

USB_A_SIZE = [5, 12.5, front_panel_height + 2];
USB_C_SIZE = [8.8, 3, front_panel_height + 2];
SD_CARD_SIZE = [24.5, 2.5, front_panel_height + 2];

SIDE_X = [wall, 0, 0];
SIDE_Y = [0, wall, 0];

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

module mirror_offset(offset = length) {
    translate([offset, 0, 0])
        mirror([1, 0, 0])
            children();
}

module side_wall() {
    middle_y = width - wall - back_width - middle_bevel;
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
        difference() {
            union() {
                side_wall_lattice();
                side_wall_front_wall_border();
            }
            front_incline_mask();
        }
    }

    module side_wall_hole() {
        incl_start_h = incline_height - 2 * lattice_border - lattice_border / tan((180 - incline_angle) / 2);
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
        translate([wall, lattice_border, 2 * lattice_border])
            rotate([0, 0, 90])
                lattice([lattice_side_hole_w, wall, lattice_side_hole_h], lattice_width, lattice_hole);
    }

    module side_wall_front_wall_border() {
        filler_len = lattice_border + wall;
        translate([0, front_width - lattice_border / 2, 0])
            cube([wall, filler_len, height]);
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
        wall_y = width - back_width - 2 * wall;
        translate([middle_bevel, wall_y, 0]) {
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
        translate([wall / 2, - 1, - 1])
            cube([length - wall, front_width + 1, wall + 2]);
    }
}

module front_wall() {
    front_wall_z = incline_height + (front_width + wall) * tan(incline_angle);

    difference() {
        translate([0, front_width, 0]) {
            cube([length, wall, 2 * lattice_border]);
            front_side_wall();
            mirror_offset() { front_side_wall(); }
            front_top_wall();
            front_lattice();
        }
        front_incline_mask();
        chamfer_front_wall();
    }

    module front_side_wall() {
        translate([wall - cham, 0, 0])
            cube([lattice_border + cham, wall, height]);
    }

    module front_top_wall() {
        top_wall_h = 2 * lattice_border;
        z_offset = front_wall_z - top_wall_h;
        translate([lattice_border, 0, z_offset]) {
            cube([length - 2 * lattice_border, wall, top_wall_h]);
        }
    }

    module front_lattice() {
        translate([lattice_border, 0, 2 * lattice_border])
            lattice([length - 2 * lattice_border, wall, front_wall_z - 4 * lattice_border], lattice_width, lattice_hole);
    }

    module chamfer_front_wall() {
        translate([0, front_width + wall - cham, front_wall_z - cham])
            cube([length, cham + 1, cham]);
    }
}

module middle_wall() {
    middle_len = length - 2 * middle_bevel - 2 * middle_shoulder_length;
    wall_y = width - back_width - 2 * wall;

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
        mirror_offset(full_len) { angled_wall(); }
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

module separator_walls() {
    wall_y_len = width - back_width - front_width - wall;

    lattice_w = wall_y_len - 2 * wall - 2 * lattice_border;
    lattice_top_w = width - back_width - 2 * wall - lattice_border
        - (height - incline_height) / tan(incline_angle)
        - lattice_border / tan((180 - incline_angle) / 2);
    lattice_h = separator_wall_height - 3 * lattice_border;
    lattice_front_h = lattice_h - (lattice_w - lattice_top_w) * tan(incline_angle);

    difference() {
        translate([0, front_width, 0])
            for (offset = separator_wall_offsets) {
                translate([offset, 0, 0])
                    separator_wall(offset);
            }
        translate([0, 0, separator_wall_height - height])
            front_incline_mask();
        translate([0, 0, separator_wall_height])
            cube([length, width, height]);
    }

    module separator_wall(offset) {
        difference() {
            union() {
                cube([separator_wall, wall_y_len, height]);
                wall_end();
                translate([0, wall_y_len - wall, 0])
                    wall_end();
            }
            separator_wall_hole();
        }
        translate([separator_wall, lattice_border + wall, 2 * lattice_border])
            rotate([0, 0, 90])
                lattice([lattice_w, separator_wall, lattice_h], separator_wall_lattice_width, separator_wall_lattice_hole);

        module wall_end() {
            translate([- separator_wall / 2, 0, 0])
                cube([separator_wall * 2, wall, height]);
        }

        module separator_wall_hole() {
            translate([- 1, lattice_border + wall, 2 * lattice_border])
                rotate([90, 0, 90])
                    linear_extrude(wall + 2)
                        polygon([
                                [0, 0], [lattice_w, 0], [lattice_w, lattice_h],
                                [lattice_w - lattice_top_w, lattice_h], [0, lattice_front_h]
                            ]);
        }
    }
}

module front_frame() {
    frame_length = length - wall;
    translate([wall / 2, 0, 0]) {
        frame_wall();
        translate([frame_length, front_width, 0])
            rotate([0, 0, 180])
                frame_wall();
    }

    module frame_wall() {
        difference() {
            cube([frame_length, wall, front_panel_height]);
            translate([0, wall - front_panel_notch, front_panel_height - front_panel_notch])
                cube([frame_length, front_panel_notch + 1, front_panel_notch + 1]);
        }
    }
}

module front_panel() {
    difference() {
        translate([wall / 2, 0, 0])
            cube([length - wall, front_width, front_panel_height]);
        translate([0, front_width / 2, front_panel_height / 2]) {
            translate([USB_A_SIZE.x * 2, 0, 0])
                usb_a();
            translate([USB_A_SIZE.x * 4, 0, 0])
                usb_a();
            translate([USB_A_SIZE.x * 6, 0, 0])
                usb_a();
            translate([USB_A_SIZE.x * 8.3, 0, 0])
                double_usb_c();
            translate([USB_A_SIZE.x * 11, 0, 0])
                double_usb_c();
            translate([USB_A_SIZE.x * 15.1, 0, 0]) {
                y_offset = SD_CARD_SIZE.y * 1.5;
                translate([0, y_offset, 0])
                    sd_card();
                translate([0, - y_offset, 0])
                    sd_card();
            }
        }
    }

    module usb_a() {
        cube(USB_A_SIZE, center = true);
    }

    module usb_c() {
        cube(USB_C_SIZE, center = true);
    }

    module sd_card() {
        cube(SD_CARD_SIZE, center = true);
    }

    module double_usb_c() {
        y_offset = USB_A_SIZE.y / 2 - USB_C_SIZE.y / 2;
        translate([0, y_offset, 0])
            usb_c();
        translate([0, - y_offset, 0]) {
            usb_c();
        }
    }
}

module organizer() {
    bottom();
    side_wall();
    mirror_offset() { side_wall(); }
    front_wall();
    middle_wall();
    separator_walls();
    back_wall();
    front_frame();
}

organizer();
translate([0, - 1.5 * front_width, 0])
    front_panel();