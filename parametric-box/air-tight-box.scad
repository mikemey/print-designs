include <../libs/BOSL/constants.scad>
use <../libs/BOSL/masks.scad>
use <../basics/basic-shapes.scad>

$fn = 128;
//$fn = 24;

print_line_w = 0.35;
wall = print_line_w * 4;

base_w = 15;
base_l = 35;
height = 15;
inner_r = 4;

brace_w = 3;
brace_spacing = [0.35, 0.65];

brim_w = 2.5 * wall;
brim_h = 5;
notch_h = 1;
notch_wall = 1;
// tolerance between notch and notch-hole
notch_spacing = 0.5;

snap_bottom_l = 20;
snap_r = 2;
snap_notch_r = 1;
snap_top_l = 6;
// distance of snap to brim:
snap_distance = 0.2;

// define cutouts of snap-support:
snap_support_cutout_w = 2.5;
snap_support_cutout_spacing = [0.2, 0.4, 0.6, 0.8];

inner_w = base_w + 2 * inner_r;
inner_l = base_l + 2 * inner_r;

outer_r = inner_r + wall;
outer_w = base_w + 2 * outer_r;
outer_l = base_l + 2 * outer_r;

outer_brim_r = inner_r + brim_w;
outer_brim_w = base_w + 2 * outer_brim_r;
outer_brim_l = base_l + 2 * outer_brim_r;

module bottom() {
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

    module notch_hole(tolerance) {
        notch_hole_w = notch_wall + tolerance;
        notch_offset = wall - brim_w / 2 - notch_hole_w / 2;
        translate([notch_offset, notch_offset, height - notch_h])
            notch(notch_hole_w, notch_h);
    }

    difference() {
        union() {
            box_walls();
            box_braces();
            brim();
            bottom_snap();
        }
        inner_cutout();
        notch_hole(0);
    }
}


module bottom_snap() {
    snap_center_w = wall - brim_w - snap_r - snap_distance;
    snap_support_w = snap_r * 2 + snap_distance + brim_w;
    snap_start_l = outer_l / 2 - snap_bottom_l / 2;

    module snap_rod() {
        rotate([- 90, 0, 0])
            cylinder(h = snap_bottom_l, r = snap_r);
        sphere(r = snap_notch_r);
        translate([0, snap_bottom_l, 0])
            sphere(r = snap_notch_r);
    }

    module snap_support() {
        support_offset_h = snap_r * cos(45);
        support_w = snap_r + snap_distance + brim_w;
        support_prism_w = support_w + snap_r * sin(45);
        translate([0, 0, - support_offset_h]) {
            cube([support_w, snap_bottom_l, support_offset_h]);
            translate([support_w, snap_bottom_l, - support_prism_w])
                rotate([90, 0, - 90])
                    prism_right_triangle(snap_bottom_l, support_prism_w, support_prism_w);
        }
    }

    module snap_support_cutouts() {
        translate([- snap_r, 0, - height])
            for (offset = snap_support_cutout_spacing) {
                offset_y = offset * snap_bottom_l - snap_support_cutout_w / 2;
                translate([0, offset_y, 0])
                    cube([snap_support_w * 2, snap_support_cutout_w, height * 2]);
            }
    }

    translate([snap_center_w, snap_start_l, height]) {
        snap_rod();
        difference() {
            snap_support();
            snap_support_cutouts();
        }
    }
}


module notch(w, h) {
    notch_offset = brim_w / 2 - w / 2;
    notch_inner_w = inner_w + 2 * notch_offset;
    notch_inner_l = inner_l + 2 * notch_offset;
    notch_inner_r = inner_r + notch_offset;

    notch_outer_w = notch_inner_w + 2 * w;
    notch_outer_l = notch_inner_l + 2 * w;
    notch_outer_r = notch_inner_r + w;

    difference() {
        cube_rounded_edges(notch_outer_w, notch_outer_l, h, notch_outer_r);
        translate([w, w, - 1])
            cube_rounded_edges(notch_inner_w, notch_inner_l, h + 2, notch_inner_r);
    }
}


module top() {
    module top_floor() {
    }

    module sides() {

    }

    top_floor();
    sides();
}

bottom();
//top();
