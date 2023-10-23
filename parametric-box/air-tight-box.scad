include <../libs/BOSL/constants.scad>
use <../libs/BOSL/masks.scad>
use <../basics/basic-shapes.scad>

$fn = 128;
//$fn = 24;

print_line_w = 0.35;
wall = print_line_w * 4;

base_w = 15;
base_l = 35;
bottom_h = 20;
top_h = 10;
inner_r = 4;

brace_w = 3;
brace_spacing = [0.35, 0.65];

brim_w = 2.5 * wall;
brim_h = 5;
// seal height in brim, twice for full seal
seal_h = 1;
seal_wall = 1;
// tolerance between seal and seal-hole
seal_tolerance = 0.1;

hinge_bottom_l = 20;
hinge_r = 2;
hinge_notch_r = 1;
hinge_top_l = 6;
// distance of hinge to brim:
hinge_distance = 0.2;

// define cutouts of hinge-support:
hinge_support_cutout_w = 2.5;
hinge_support_cutout_spacing = [0.2, 0.4, 0.6, 0.8];
hinge_tolerance = 0.15;

inner_w = base_w + 2 * inner_r;
inner_l = base_l + 2 * inner_r;

outer_r = inner_r + wall;
outer_w = base_w + 2 * outer_r;
outer_l = base_l + 2 * outer_r;

outer_brim_r = inner_r + brim_w;
outer_brim_w = base_w + 2 * outer_brim_r;
outer_brim_l = base_l + 2 * outer_brim_r;

// hinge center x offset from 0
hinge_offset_x = wall - brim_w - hinge_r - hinge_distance;
hinge_support_w = hinge_r * 2 + hinge_distance + brim_w;
hinge_offset_y = outer_l / 2 - hinge_bottom_l / 2;

module half_box(seal_hole_tolerance, height) {
    // brim offset from x/y axes:
    brim_offset = brim_w - wall;

    module box_walls() {
        cube_rounded_edges(outer_w, outer_l, height, outer_r);
    }

    module box_braces() {
        for (offset = brace_spacing) {
            dist_y = offset * outer_brim_l - brace_w / 2 - brim_offset;
            translate([- brim_offset, dist_y, 0]) {
                difference() {
                    cube([outer_brim_w, brace_w, height]);
                    chamfer_mask_y(brace_w * 2, brim_offset);
                    translate([outer_brim_w, 0, 0])
                        chamfer_mask_y(brace_w * 2, brim_offset);
                }
            }

            dist_x = offset * outer_brim_w - brace_w / 2 - brim_offset;
            translate([dist_x, - brim_offset, 0]) {
                difference() {
                    cube([brace_w, outer_brim_l, height]);
                    chamfer_mask_x(brace_w * 2, brim_offset);
                    translate([0, outer_brim_l, 0])
                        chamfer_mask_x(brace_w * 2, brim_offset);
                }
            }
        }
    }

    module inner_cutout() {
        translate([wall, wall, wall]) {
            cube_rounded_edges(inner_w, inner_l, height, inner_r);
        }
    }

    module brim() {
        flat_brim_h = brim_h - brim_offset;

        module brim_base() {
            size = [outer_brim_w, outer_brim_l, flat_brim_h];
            translate([- brim_offset, - brim_offset, height - flat_brim_h])
                cube_rounded_edges(outer_brim_w, outer_brim_l, flat_brim_h, outer_brim_r);
        }

        module angled_brim_corners() {
            module corner() {
                translate([- brim_offset + outer_brim_r, - brim_offset + outer_brim_r, height - brim_h])
                    cylinder(h = brim_offset, r1 = outer_r, r2 = outer_brim_r);
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
            translate([outer_r, 0, height - brim_h])
                rotate([90, 0, 0])
                    prism_right_triangle(base_w, brim_offset, brim_offset);
            translate([outer_r, outer_brim_l - brim_offset, height - brim_h + brim_offset])
                rotate([180, 0, 0])
                    prism_right_triangle(base_w, brim_offset, brim_offset);
            translate([- brim_offset, outer_r, height - brim_h + brim_offset])
                rotate([180, 0, 90])
                    prism_right_triangle(base_l, brim_offset, brim_offset);
            translate([outer_brim_w - 2 * brim_offset, outer_r, height - brim_h])
                rotate([90, 0, 90])
                    prism_right_triangle(base_l, brim_offset, brim_offset);
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
            hinge_factor = 0.8;
            hinge_slide_x = 2 * hinge_notch_r * hinge_factor;
            hinge_slide_y = hinge_notch_r * hinge_factor;
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
    support_offset_h = hinge_r * cos(45);
    support_w = hinge_r + hinge_distance + brim_w;
    support_prism_w = support_w + hinge_r * sin(45);
    translate([0, 0, - support_offset_h]) {
        cube([support_w, length, support_offset_h]);
        translate([support_w, length, - support_prism_w])
            rotate([90, 0, - 90])
                prism_right_triangle(length, support_prism_w, support_prism_w);
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

half_box(0, bottom_h) {
    bottom_hinge(bottom_h);
}

translate([hinge_offset_x * 2, outer_l, bottom_h - top_h])
    rotate([0, 0, 180])
        half_box(seal_tolerance, top_h) {
            top_hinge(top_h);
        }

translate([outer_w * 1.5, 0, 0])
    seal(seal_wall, seal_h * 2);
