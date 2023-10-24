include <../libs/BOSL/constants.scad>
use <../libs/BOSL/masks.scad>
use <../basics/basic-shapes.scad>

$fn = 128;
//$fn = 12;

print_line_w = 0.35;
wall = print_line_w * 4;

base_w = 50;
base_l = 85;
bottom_h = 25;
top_h = 15;
inner_r = 4;

brace_w = 8;
brace_spacing = [0.35, 0.65];

brim_w = 3 * wall;
// height of straight part of brim
brim_h = 5;
// angle of all angled surfaces (bottom brim, -braces and hinge supports)
angle = 35;

// seal height in brim, twice for full seal
seal_h = 1;
seal_wall = 1;
// tolerance between seal and seal-hole
seal_tolerance = 0.2;

hinge_bottom_l = 20;
hinge_r = 2.5;
hinge_notch_r = 1.8;
hinge_top_l = 6;
// distance of hinge to brim:
hinge_distance = 1;
// distance of top hinge to bottom hinge:
hinge_tolerance = 0.3;
// percentage of hinge_notch_r for hole to slide in hinge-notch
hinge_hole_factor = 0.85;

// define cutouts of hinge-support:
hinge_support_cutout_w = 3;
hinge_support_cutout_spacing = [0.3, 0.7];

latch_w = 2;
latch_l = 8;
latch_r = 1;

// ========= derived values =========
inner_w = base_w + 2 * inner_r;
inner_l = base_l + 2 * inner_r;

outer_r = inner_r + wall;
outer_w = base_w + 2 * outer_r;
outer_l = base_l + 2 * outer_r;

// brim offset from x/y axes:
brim_offset = brim_w - wall;
outer_brim_r = inner_r + brim_w;
outer_brim_w = base_w + 2 * outer_brim_r;
outer_brim_l = base_l + 2 * outer_brim_r;

// hinge center x offset from 0
hinge_offset_x = wall - brim_w - hinge_r - hinge_distance;
hinge_support_w = hinge_r * 2 + hinge_distance + brim_w;
hinge_offset_y = outer_l / 2 - hinge_bottom_l / 2;

function angled_height(w) = w / tan(angle);

module half_box(seal_hole_tolerance, height, add_latch_hole = false) {
    module box_walls() {
        cube_rounded_edges(outer_w, outer_l, height, outer_r);
    }

    module box_braces() {
        brace_cutoff_w = brim_offset;
        brace_cutoff_l = brace_w * 3;
        brace_cutoff_h = angled_height(brace_cutoff_w);
        brace_offset = brim_offset / 2;

        module braces_x(offset) {
            dist_x = offset * outer_brim_w - brace_w / 2 - brim_offset;
            translate([dist_x, 0, 0])
                difference() {
                    translate([0, - brim_offset, 0])
                        cube([brace_w, outer_brim_l, height]);
                    translate([brace_w * 2, - brace_offset, 0]) {
                        rotate([0, 0, 180])
                            prism_right_triangle(brace_cutoff_l, brace_cutoff_w, brace_cutoff_h);
                        translate([- brace_cutoff_l, outer_brim_l - brace_cutoff_w, 0])
                            prism_right_triangle(brace_cutoff_l, brace_cutoff_w, brace_cutoff_h);
                    }
                }
        }

        module braces_y(offset) {
            dist_y = offset * outer_brim_l - brace_w / 2 - brim_offset;
            translate([0, dist_y, 0])
                difference() {
                    translate([- brim_offset, 0, 0])
                        cube([outer_brim_w, brace_w, height]);
                    translate([- brace_offset, - brace_w, 0]) {
                        rotate([0, 0, 90])
                            prism_right_triangle(brace_cutoff_l, brace_cutoff_w, brace_cutoff_h);
                        translate([outer_brim_w - brace_cutoff_w, brace_cutoff_l, 0])
                            rotate([0, 0, 270])
                                prism_right_triangle(brace_cutoff_l, brace_cutoff_w, brace_cutoff_h);
                    }
                }
        }

        for (offset = brace_spacing) {
            braces_x(offset);
            braces_y(offset);
        }
    }

    module inner_cutout() {
        translate([wall, wall, wall]) {
            cube_rounded_edges(inner_w, inner_l, height, inner_r);
        }
    }

    module brim() {
        angled_brim_h = angled_height(brim_offset);

        module brim_base() {
            translate([- brim_offset, - brim_offset, height - brim_h])
                cube_rounded_edges(outer_brim_w, outer_brim_l, brim_h, outer_brim_r);
        }

        module angled_brim_corners() {
            module corner() {
                corner_offset = - brim_offset + outer_brim_r;
                translate([corner_offset, corner_offset, height - brim_h - angled_brim_h])
                    cylinder(h = angled_brim_h, r1 = outer_r, r2 = outer_brim_r);
            }

            dist_x = outer_brim_w - 2 * outer_brim_r;
            dist_y = outer_brim_l - 2 * outer_brim_r;

            corner();
            translate([dist_x, 0, 0])
                corner();
            translate([0, dist_y, 0])
                corner();
            translate([dist_x, dist_y, 0])
                corner();
        }
        module angled_brim_sides() {
            translate([0, 0, height - brim_h]) {
                translate([outer_r, 0, - angled_brim_h])
                    rotate([90, 0, 0])
                        prism_right_triangle(base_w, angled_brim_h, brim_offset);
                translate([outer_r, outer_brim_l - brim_offset, 0])
                    rotate([180, 0, 0])
                        prism_right_triangle(base_w, brim_offset, angled_brim_h);
                translate([- brim_offset, outer_r, 0])
                    rotate([180, 0, 90])
                        prism_right_triangle(base_l, brim_offset, angled_brim_h);
                if (add_latch_hole) {
                    difference() {
                        angle_brim_latch_side();
                        latch_hole();
                    }
                } else {
                    angle_brim_latch_side();
                }
            }

            module angle_brim_latch_side() {
                translate([outer_brim_w - 2 * brim_offset, outer_r, - angled_brim_h])
                    rotate([90, 0, 90])
                        prism_right_triangle(base_l, angled_brim_h, brim_offset);
            }
            module latch_hole() {
                hole_l = latch_l * 1.4;
                hole_offset = outer_r + base_l / 2 - hole_l / 2;
                translate([outer_w, hole_offset, - angled_brim_h])
                    cube([brim_w, hole_l, angled_brim_h]);
            }
        }
        brim_base();
        angled_brim_sides();
        angled_brim_corners();
    }

    module seal_hole(tolerance) {
        seal_hole_w = seal_wall + tolerance;
        seal_offset = wall - brim_w / 2 - seal_hole_w / 2;
        translate([seal_offset, seal_offset, height - seal_h])
            seal(seal_hole_w, seal_h);
    }

    difference() {
        union() {
            box_walls();
            box_braces();
            brim();
            children();
        }
        inner_cutout();
        seal_hole(seal_hole_tolerance);
    }
}

module bottom_hinge(height) {
    module hinge_rod() {
        rotate([- 90, 0, 0])
            cylinder(h = hinge_bottom_l, r = hinge_r);
        sphere(r = hinge_notch_r);
        translate([0, hinge_bottom_l, 0])
            sphere(r = hinge_notch_r);
    }

    module hinge_support_cutouts() {
        translate([- hinge_r, 0, - height])
            for (offset = hinge_support_cutout_spacing) {
                offset_y = offset * hinge_bottom_l - hinge_support_cutout_w / 2;
                translate([0, offset_y, 0])
                    cube([hinge_support_w * 2, hinge_support_cutout_w, height * 2]);
            }
    }

    translate([hinge_offset_x, hinge_offset_y, height]) {
        hinge_rod();
        difference() {
            hinge_support(hinge_bottom_l);
            hinge_support_cutouts();
        }
    }
}

module top_hinge(height) {
    module hinge_rod(hole_front) {
        hole_y = hole_front ? 0 : hinge_top_l;
        hinge_rotation = hole_front ? 0: 180;
        difference() {
            union() {
                rotate([- 90, 0, 0])
                    cylinder(h = hinge_top_l, r = hinge_r);
                hinge_support(hinge_top_l);
            }
            translate([0, hole_y, 0])
                sphere(r = hinge_notch_r);
            rotate([0, 0, hinge_rotation])
                hinge_slide_in_hole();
        }

        module hinge_slide_in_hole() {
            hinge_slide_x = 2 * hinge_notch_r * hinge_hole_factor;
            hinge_slide_y = hinge_notch_r * hinge_hole_factor;
            hinge_slide_r = hinge_slide_y;

            translate([- hinge_slide_x / 2, - hole_y, 0])
                difference() {
                    cube([hinge_slide_x, hinge_slide_y, hinge_r]);
                    translate([0, hinge_slide_y, 0]) {
                        fillet_mask_z(hinge_r, hinge_slide_r, align = V_UP);
                        translate([hinge_slide_x, 0, 0])
                            fillet_mask_z(hinge_r, hinge_slide_r, align = V_UP);
                    }
                }
        }
    }

    front_hinge_offset_y = hinge_offset_y - hinge_top_l - hinge_tolerance;
    back_hinge_offset_y = hinge_offset_y + hinge_bottom_l + hinge_tolerance;

    translate([hinge_offset_x, front_hinge_offset_y, height])
        hinge_rod(false);
    translate([hinge_offset_x, back_hinge_offset_y, height])
        hinge_rod(true);
}

module hinge_support(length) {
    support_offset_h = hinge_r * sin(angle);
    support_w = hinge_r + hinge_distance + brim_w;
    support_prism_w = support_w + hinge_r * cos(angle);
    support_prism_h = angled_height(support_prism_w);
    translate([0, 0, - support_offset_h]) {
        cube([support_w, length, support_offset_h]);
        translate([support_w, length, - support_prism_h])
            rotate([90, 0, - 90])
                prism_right_triangle(length, support_prism_h, support_prism_w);
    }
}

module seal(w, h) {
    seal_offset = brim_w / 2 - w / 2;
    seal_inner_w = inner_w + 2 * seal_offset;
    seal_inner_l = inner_l + 2 * seal_offset;
    seal_inner_r = inner_r + seal_offset;

    seal_outer_w = seal_inner_w + 2 * w;
    seal_outer_l = seal_inner_l + 2 * w;
    seal_outer_r = seal_inner_r + w;

    difference() {
        cube_rounded_edges(seal_outer_w, seal_outer_l, h, seal_outer_r);
        translate([w, w, - 1])
            cube_rounded_edges(seal_inner_w, seal_inner_l, h + 2, seal_inner_r);
    }
}

module latch(height) {
    offset_y = outer_l / 2 - latch_l / 2;
    offset_z = latch_w + brim_w;
    flat_height = brim_h * 2 + latch_r;

    module latch_support() {
        support_h = angled_height(offset_z);
        translate([- brim_w, 0, - support_h])
            rotate([90, 0, 90])
                prism_right_triangle(latch_l, support_h, offset_z);
    }

    module latch_snap() {
        top_height = latch_w / 2 * tan(30);
        translate([0, 0, flat_height]) {
            rotate([- 90, 0, 0])
                cylinder(h = latch_l, r = latch_r);
            translate([0, 0, latch_r]) {
                translate([latch_w, 0, 0])
                    rotate([0, 0, 90])
                        prism_right_triangle(latch_l, latch_w / 2, top_height);
                translate([0, latch_l, 0])
                    rotate([0, 0, - 90])
                        prism_right_triangle(latch_l, latch_w / 2, top_height);

            }
        }
    }

    translate([outer_w + brim_offset, offset_y, height - brim_h]) {
        cube([latch_w, latch_l, flat_height + latch_r]);
        latch_support();
        latch_snap();
    }
}

module floor_cutoff() {
    module bottom_box_floor() {
        translate([- outer_w * 0.1, - outer_l * 0.1, - bottom_h])
            cube([outer_w * 1.2, outer_l * 1.2, bottom_h]);
    }
    module top_box_floor() {
        floor_height = bottom_h - top_h;
        translate([- outer_w * 1.1 + 2 * hinge_offset_x, - outer_l * 0.1, 0])
            cube([outer_w * 1.2, outer_l * 1.2, floor_height]);
    }

    bottom_box_floor();
    top_box_floor();
}

difference() {
    union() {
        half_box(0, bottom_h, true) {
            bottom_hinge(bottom_h);
        }

        translate([hinge_offset_x * 2, outer_l, bottom_h - top_h])
            rotate([0, 0, 180])
                half_box(seal_tolerance, top_h) {
                    top_hinge(top_h);
                    latch(top_h);
                }

        translate([outer_w * 1.5, 0, 0])
            seal(seal_wall, seal_h * 2);

        opposing_brim_base();
    }
    floor_cutoff();
}

module opposing_brim_base() {
    color("#99444477")
        translate([- outer_brim_w + 2 * hinge_offset_x + brim_offset, - brim_offset, bottom_h])
            difference() {
                cube_rounded_edges(outer_brim_w, outer_brim_l, brim_h, outer_brim_r);
                translate([(outer_brim_w - inner_w) / 2, (outer_brim_l - inner_l) / 2, - 0.001])
                    cube_rounded_edges(inner_w, inner_l, brim_h + 0.002, inner_r);
            }
}
