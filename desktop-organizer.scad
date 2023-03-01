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
lattice_side_hole_w = width - back_width - 3 * wall - 2 * lattice_border;
lattice_side_hole_h = height - 3 * lattice_border;

module side_wall() {
    difference() {
        union() {
            difference() {
                cube([wall, width, height]);
                translate([- 1, width - back_width - wall - middle_bevel, back_height])
                    cube([wall + 2, width, height]);
                front_incline_mask();
                side_wall_hole();
            }
            side_wall_lattice();
        }
        bevel_side_wall();
    }

    color("coral") bevel_side_wall();
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
    }}

module bevel_side_wall() {
    chamfer_mask(incline_height, cham, orient = ORIENT_Z, center = false);
    translate([wall, 0, wall])
        chamfer_mask(incline_height, cham, orient = ORIENT_Z, center = false);

    translate([0, 0, incline_height])
        rotate([- incline_angle, 0, 0])
            chamfer_mask(width, cham, orient = ORIENT_Z, center = false);
}

cube([length, width, wall]);
side_wall();
//translate([length, 0, 0])
//    mirror([1, 0, 0])
//        side_wall();

