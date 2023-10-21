include <../libs/BOSL/constants.scad>
use <../libs/BOSL/shapes.scad>
use <../libs/BOSL/masks.scad>
use <../libs/BOSL/transforms.scad>

$fn = 64;

// trimming length
trimming_length = 11;
// spacer count
spacer_count = 6;
// thickness factor of spacers - depending on trimmer length
spacer_w_factor = 0.08;
// overlap of spacers to plate
spacer_overlap = 8.8;
// distance between centers of outer spacers
spacers_w = 30.5;
// flange length at head of spacer
spacer_flange_overshoot = 7;

// total width
outer_w = 42;

// width of bottom clips at front
bottom_front_w = 33.8;
// width of bottom clips at back
bottom_back_w = 35;
// length of bottom clips
bottom_len = 12;
// thickness of bottom and side walls
clip_wall = 2.5;
// angle at front around razor
front_angle = 45;

// inner height distance between clips and plate
inner_height = 4.9;

// length of straight plate
plate_length = 15;
// length of straight plate
plate_height = 2;
// diameter of top-plate half-circle at touching point
plate_half_circle_d = 34;
// radius of top-plate half-circle to outer point
plate_half_circle_r = 14;

// width of plate hole
plate_hole_w = 30.5;
// radius of plate hole
plate_hole_r = 30;
// x offset of plate hole circle
plate_hole_x_offset = - 16;

text_font = "arial:style=Bold";
text_size = 8;
text_offset = 6;

razor_blade_distance = 2;
trimmer = trimming_length - razor_blade_distance;

front_strut_l = clip_wall / tan(front_angle);
spacer_start_y = (outer_w - spacers_w) / 2;

module extension_base() {
    top_plate();
    front_strut();
    side_wall();

    module top_plate() {
        translate([0, 0, clip_wall + inner_height]) {
            difference() {
                plate_base();
                plate_hole();
                plate_number();
            }
        }

        module plate_base() {
            plate_len = plate_length + front_strut_l;
            cube([plate_len, outer_w, plate_height]);
            translate([plate_len, outer_w / 2, 0]) {
                plate_half_circle();
            }
        }

        module plate_half_circle() {
            scale([plate_half_circle_r / (plate_half_circle_d / 2), 1, 1])
                difference() {
                    cylinder(d = plate_half_circle_d, h = plate_height);
                    up(plate_height) fillet_cylinder_mask(r = plate_half_circle_d / 2, fillet = plate_height);
                }
        }

        module plate_hole() {
            hole_height = plate_height + 2;
            translate([plate_hole_x_offset, outer_w / 2, - 1])
                difference() {
                    cylinder(r = plate_hole_r, h = hole_height);
                    hole_cutout();
                    mirror([0, 1, 0])
                        hole_cutout();
                }

            module hole_cutout() {
                translate([- plate_hole_r, plate_hole_w / 2, 0])
                    cube([2 * plate_hole_r, plate_hole_r, hole_height]);
            }
        }

        module plate_number() {
            translate([plate_length + text_size / 2 + text_offset, outer_w / 2, plate_height * 2 / 3])
                rotate([0, 0, 90])
                    linear_extrude(text_size)
                        text(str(trimming_length), size = text_size, halign = "center", valign = "center", font = text_font);
        }
    }

    module front_strut() {
        translate([front_strut_l / 2, outer_w / 2, 0])
            rotate([0, 0, - 90])
                prismoid(size1 = [outer_w, front_strut_l], size2 = [outer_w, 0], shift = [0, - front_strut_l / 2], h = clip_wall);
    }

    module side_wall() {
        wall_with_clip();
        translate([0, outer_w, 0])
            mirror([0, 1, 0])
                wall_with_clip();

        module wall_with_clip() {
            base_side_wall();
            bottom_clip();
            difference() {
                front_wall();
                front_wall_razor_cutout();
            }

            sw_height = clip_wall + inner_height;

            module base_side_wall() {
                to_top = plate_length + front_strut_l - bottom_len;
                cube([bottom_len, clip_wall, sw_height]);
                translate([bottom_len, clip_wall / 2, 0])
                    prismoid(size1 = [0, clip_wall], size2 = [to_top, clip_wall], shift = [to_top / 2, 0], h = sw_height);
            }

            module bottom_clip() {
                clip_front_y = (outer_w - bottom_front_w) / 2;
                clip_back_y = (outer_w - bottom_back_w) / 2;
                clip_diff = (clip_front_y - clip_back_y) / 2;
                translate([0, clip_front_y / 2, clip_wall / 2])
                    rotate([0, 90, 0])
                        prismoid(size1 = [clip_wall, clip_front_y], size2 = [clip_wall, clip_back_y], shift = [0, - clip_diff], h = bottom_len);
            }

            module front_wall() {
                front_wall_h = sw_height + plate_height;
                front_wall_top_len = front_wall_h / tan(front_angle);
                translate([0, spacer_start_y / 2, 0])
                    prismoid(size1 = [0, spacer_start_y], size2 = [front_wall_top_len, spacer_start_y], shift = [- front_wall_top_len / 2, 0], h = front_wall_h);
            }

            module front_wall_razor_cutout() {
                cutout_l = inner_height / tan(front_angle);
                translate([0, spacer_start_y / 2 + clip_wall, clip_wall])
                    prismoid(size1 = [0, spacer_start_y], size2 = [cutout_l, spacer_start_y], shift = [- cutout_l / 2, 0], h = inner_height);
            }
        }
    }
}

module spacers() {
    spacer_stepper = spacers_w / (spacer_count - 1);
    difference() {
        translate([0, spacer_start_y, 0])
            for (i = [0:spacer_count - 1]) {
                translate([0, i * spacer_stepper, 0])
                    single_spacer();
            }
        spacers_cutout();
    }

    cutout_h = clip_wall + inner_height;
    cutout_l = cutout_h / tan(front_angle);
    razor_x_offset = cutout_l - front_strut_l;

    module single_spacer() {
        translate([- razor_x_offset, 0, cutout_h]) {
            scale([1, spacer_w_factor, 1])
                sphere(r = trimmer);
            spacer_top_half();
            spacer_bottom_triangle();
            spacer_flange();
        }
    }

    module spacer_top_half() {
        rotate([0, 90, 0])
            linear_extrude(plate_length + plate_half_circle_r)
                scale([1, spacer_w_factor, 1])
                    circle(r = trimmer);
    }

    module spacer_bottom_triangle() {
        angled_spacer_len = cutout_h / sin(front_angle);
        rotate([0, front_angle + 90, 0])
            linear_extrude(angled_spacer_len)
                scale([1, spacer_w_factor, 1])
                    circle(r = trimmer);
    }

    module spacer_flange() {
        flange_factor = spacer_w_factor * 0.7;
        flange_bottom_thickness = trimmer * flange_factor;
        translate([- spacer_flange_overshoot, 0, 0]) {
            difference() {
                union() {
                    spacer_flange_body();
                    spacer_flange_rounded_head();
                }
                spacer_flange_cutoff();
            }
        }

        module spacer_flange_body() {
            rotate([0, 90, 0])
                linear_extrude(spacer_flange_overshoot)
                    scale([1, flange_factor, 1])
                        circle(r = trimmer);
        }

        module spacer_flange_rounded_head() {
            scale([flange_factor * 2, flange_factor, 1])
                sphere(r = trimmer);
        }

        module spacer_flange_cutoff() {
            translate([- spacer_flange_overshoot, - flange_bottom_thickness, - trimmer])
                cube([2 * spacer_flange_overshoot, 2 * flange_bottom_thickness, trimmer]);
        }
    }

    module spacers_cutout() {
        translate([front_strut_l, outer_w / 2, 0])
            prismoid(size1 = [0, outer_w], size2 = [cutout_l, outer_w], shift = [- cutout_l / 2, 0], h = cutout_h);
        translate([front_strut_l, 0, 0])
            cube([plate_length + plate_half_circle_r, outer_w, inner_height + clip_wall]);
        translate([- razor_x_offset - trimmer, 0, - trimmer])
            cube([2 * trimmer + plate_length + plate_half_circle_r, outer_w, trimmer]);
        translate([plate_hole_x_offset, outer_w / 2, cutout_h + trimmer])
            fillet_cylinder_mask(r = plate_hole_r + spacer_overlap, fillet = 2 * (trimmer - plate_height));
    }
}

extension_base();
spacers();
