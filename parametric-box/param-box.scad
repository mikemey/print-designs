$fn = 64;

base_l = 50;
base_w = 30;
base_h = 15;
inner_r = 4;

print_line_w = 0.35;
wall = print_line_w * 4;
//brim_w = wall;
//brim_w = ceil(wall);
brim_w = 3;
brim_h = 5;
brace_l = 5;

notch_h = 1;
notch_clearance = 0.5;

hinge_d = 6;
hinge_notch_d = 3;
hinge_notch_lock_w = 1;
hinge_clearance = 0.7;

snap_l = 8;
snap_w = 3;
snap_clearance = 0.5;
snap_notch = 4;

outer_r = inner_r + wall;
brim_r = inner_r + brim_w;
wall_offset = brim_w - wall;

full_render = false;

bottom_piece();
//translate([0, base_w * 2, 0])
//    top_piece();

module round_outer_corner(height, outer_radius_bottom, outer_radius_top, inner_radius = inner_r) {
    border = max(outer_radius_bottom, outer_radius_top);
    difference() {
        cylinder(h = height, r1 = outer_radius_bottom, r2 = outer_radius_top);
        cylinder(h = height, r = inner_radius);
        translate([- border, 0, 0])
            cube([2 * border, 2 * border, height]);
        translate([0, - border, 0])
            cube([2 * border, 2 * border, height]);
    }
}

module round_inner_corner(height, outer_radius, inner_radius_bottom, inner_radius_top = 0) {
    r_diff = outer_radius - inner_radius_bottom;
    translate([0, 0, height])
        difference() {
            cylinder(h = r_diff, r = outer_radius);
            cylinder(h = height, r1 = outer_radius, r2 = inner_radius_top);
            cylinder(h = height, r = inner_radius_bottom);
            translate([- outer_radius, 0, 0])
                cube([2 * outer_radius, 2 * outer_radius, height]);
            translate([0, - outer_radius, 0])
                cube([2 * outer_radius, 2 * outer_radius, height]);
        }
}

module prism(l, w, h) {
    polyhedron(//pt 0        1          2          3          4          5
    points = [[0, 0, 0], [l, 0, 0], [l, w, 0], [0, w, 0], [0, w, h], [l, w, h]],
    faces = [[0, 1, 2, 3], [5, 4, 3, 2], [0, 4, 5, 1], [0, 3, 4], [5, 2, 1]]
    );
}

module bottom() {
    module bottom_corner() {
        round_outer_corner(wall, inner_r, inner_r, 0);
    }

    translate([wall, outer_r, 0])
        cube([base_l + 2 * outer_r - 2 * wall, base_w, wall]);

    translate([outer_r, wall, 0])
        cube([base_l, base_w + 2 * outer_r - 2 * wall, wall]);

    translate([outer_r, outer_r, 0])
        bottom_corner();

    translate([outer_r, base_w + outer_r, 0])
        rotate([0, 0, - 90])
            bottom_corner();

    translate([base_l + outer_r, outer_r, 0])
        rotate([0, 0, 90])
            bottom_corner();

    translate([base_l + outer_r, base_w + outer_r, 0])
        rotate([0, 0, 180])
            bottom_corner();
}

function first_brace_start(l) = (l / 4) - brace_l / 2 ;
function second_brace_start(l) = (l / 2 * 1.5) - brace_l / 2;

module sides() {
    module wall_with_braces(length) {
        module brace() {
            difference() {
                cube([brace_l, brim_w, base_h + wall]);
                translate([0, wall, 0])
                    prism(brace_l, - wall, wall);
            }
        }

        translate([0, 0, wall]) {
            cube([length, wall, base_h]);
            prism(length, wall, - wall);
        }

        translate([first_brace_start(length), - wall_offset, 0])
            brace();
        translate([second_brace_start(length), - wall_offset, 0])
            brace();
    }

    module wall_corner() {
        translate([0, 0, wall]) {
            round_outer_corner(base_h, outer_r, outer_r);
            translate([0, 0, - outer_r])
                round_outer_corner(outer_r, 0, outer_r);
        }
    }

    translate([outer_r, 0, 0]) {
        translate([0, outer_r, 0])
            wall_corner();

        wall_with_braces(base_l);

        translate([base_l, outer_r, 0])
            rotate([0, 0, 90])
                wall_corner();

        translate([- outer_r, base_w + outer_r, 0])
            rotate([0, 0, - 90])
                wall_with_braces(base_w);

        translate([0, base_w + outer_r, 0])
            rotate([0, 0, - 90])
                wall_corner();

        translate([base_l, base_w + 2 * outer_r, 0])
            rotate([0, 0, 180])
                wall_with_braces(base_l);

        translate([base_l, base_w + outer_r, 0])
            rotate([0, 0, 180])
                wall_corner();

        translate([base_l + outer_r, outer_r, 0])
            rotate([0, 0, 90])
                wall_with_braces(base_w);
    }
}

module brim() {
    module brim_corner() {
        color("lightblue") {
            round_outer_corner(brim_h, brim_r, brim_r);
            translate([0, 0, - brim_r])
                round_outer_corner(brim_r, 0, brim_r);
        }
    }

    color("MediumAquamarine")
        translate([- wall_offset, - wall_offset, base_h + wall - brim_h]) {
            translate([brim_r, brim_r, 0])
                brim_corner();

            translate([brim_r, 0, 0]) {
                cube([base_l, brim_w, brim_h]);
                prism(base_l, brim_w, - brim_w);
            }

            translate([base_l + brim_r, brim_r, 0]) {
                rotate([0, 0, 90])
                    brim_corner();
            }

            translate([0, brim_r, 0]) {
                cube([brim_w, base_w, brim_h]);
                rotate([0, 0, 90])
                    prism(base_w, - brim_w, - brim_w);
            }

            translate([base_l + brim_r, base_w + brim_r, 0])
                rotate([0, 0, 180])
                    brim_corner();

            translate([base_l + 2 * brim_r - brim_w, brim_r, 0]) {
                cube([brim_w, base_w, brim_h]);
                translate([brim_w, 0, 0])
                    rotate([0, 0, 90])
                        prism(base_w, brim_w, - brim_w);
            }

            translate([brim_r, base_w + brim_r, 0])
                rotate([0, 0, - 90])
                    brim_corner();

            translate([brim_r, base_w + 2 * brim_r - brim_w, 0]) {
                cube([base_l, brim_w, brim_h]);
                translate([0, brim_w, 0])
                    prism(base_l, - brim_w, - brim_w);
            }
        }
}

module base_shape() {
    translate([wall_offset, wall_offset, 0]) {
        bottom();
        sides();
        brim();
    }
}

module notch(base_height, clearance) {
    module notch_straight(length) {
        translate([0, - notch_h, 0])
            cube([length, notch_h * 2, clearance]);
        translate([0, - notch_h, 0])
            prism(length, notch_h, - notch_h);
        translate([0, notch_h, 0])
            prism(length, - notch_h, - notch_h);
    }

    module notch_corner() {
        notch_middle_r = inner_r + brim_w / 2;
        notch_outer_r = notch_middle_r + notch_h;
        notch_inner_r = notch_middle_r - notch_h;
        round_outer_corner(clearance, notch_outer_r, notch_outer_r, notch_inner_r);
        translate([0, 0, - notch_outer_r]) {
            round_outer_corner(notch_outer_r, 0, notch_outer_r, notch_middle_r);
            round_inner_corner(notch_middle_r, notch_middle_r, notch_inner_r);
        }
    }

    translate([0, 0, base_height]) {
        translate([brim_r, brim_w / 2, 0])
            notch_straight(base_l);
        translate([brim_r, brim_r + base_w + inner_r + brim_w / 2, 0])
            notch_straight(base_l);
        translate([brim_w / 2, brim_r, 0])
            rotate([0, 0, 90])
                notch_straight(base_w);
        translate([brim_r + base_l + inner_r + brim_w / 2, brim_r, 0])
            rotate([0, 0, 90])
                notch_straight(base_w);

        translate([brim_r, brim_r, 0])
            notch_corner();

        translate([base_l + brim_r, brim_r, 0])
            rotate([0, 0, 90])
                notch_corner();

        translate([brim_r, base_w + brim_r, 0])
            rotate([0, 0, - 90])
                notch_corner();

        translate([base_l + brim_r, base_w + brim_r, 0])
            rotate([0, 0, 180])
                notch_corner();
    }
}

module bottom_hinge_hole(offset, hole_l) {
    translate([offset - hinge_clearance, 0, base_h + wall])
        rotate([0, 90, 0])
            cylinder(h = hole_l, d = hinge_d + 2 * hinge_clearance);
}

module bottom_hinge(start, end) {
    translate([start, 0, base_h + wall]) {
        rotate([0, 90, 0])
            cylinder(h = end - start, d = hinge_d);
        sphere(d = hinge_notch_d);
    }
    translate([end, 0, base_h + wall])
        sphere(d = hinge_notch_d);
}

module bottom_snap_hole() {
    snap_hole_l = snap_l + 2 * snap_clearance;

    translate([brim_r + base_l / 2 - snap_hole_l / 2, brim_r + base_w + outer_r])
        cube([snap_l + 2 * snap_clearance, brim_w, base_h + wall - brim_h]);
}

module bottom_piece() {
    hinge_hole_l = brace_l + 2 * hinge_clearance;
    difference() {
        base_shape();
        if (full_render || !$preview) {
            notch(base_h + wall - notch_clearance + 0.001, notch_clearance);
        }
        translate([brim_r, 0, 0]) {
            bottom_hinge_hole(first_brace_start(base_l), hinge_hole_l);
            bottom_hinge_hole(second_brace_start(base_l), hinge_hole_l);
        }
        bottom_snap_hole();
    }

    translate([brim_r, 0, 0])
        bottom_hinge(first_brace_start(base_l) + hinge_hole_l - hinge_clearance, second_brace_start(base_l) - hinge_clearance);

}

module top_hole() {
    hole_l = second_brace_start(base_l) - first_brace_start(base_l) - brace_l;
    translate([first_brace_start(base_l) + brim_r + brace_l, 0, base_h + wall])
        rotate([0, 90, 0])
            cylinder(h = hole_l, d = hinge_d + 2 * hinge_clearance);
}

module top_hinge(offset) {
    translate([offset + brim_r, 0, base_h + wall])
        rotate([0, 90, 0])
            cylinder(h = brace_l, d = hinge_d);
}

module top_hinge_socket(offset, rot = 0) {
    translate([offset + brim_r, 0, base_h + wall])
        rotate([0, 0, rot]) {
            sphere(d = hinge_notch_d);
            translate([- hinge_notch_lock_w, - hinge_notch_d / 2, 0])
                cube([hinge_notch_lock_w, hinge_notch_d, hinge_d]);
        }
}

module top_snap() {
    bevel_h = brim_w + snap_w;
    translate([brim_r + base_l / 2 - snap_l / 2, base_w + 2 * brim_r, base_h + wall - brim_h]) {
        cube([snap_l, snap_w, 2 * brim_h + snap_notch + snap_clearance]);
        translate([0, snap_w, 0])
            prism(snap_l, - bevel_h, - bevel_h);
        translate([0, 0, 2 * brim_h + snap_notch / 2 + snap_clearance])
            rotate([0, 90, 0])
                cylinder(snap_l, d = snap_notch);
        translate([0, 0, 2 * brim_h + snap_notch + snap_clearance]) {
            prism(snap_l, snap_w / 2, snap_w / 2);
            translate([0, snap_w, 0])
                prism(snap_l, - snap_w / 2, snap_w / 2);
        }
    }
}

module top_piece() {
    difference() {
        union() {
            base_shape();
            translate([0, base_w + brim_r * 2, 0])
                rotate([180, 0, 0])
                    notch(- base_h - wall, 0);
            top_hinge(first_brace_start(base_l));
            top_hinge(second_brace_start(base_l));
        }
        top_hole();
        top_hinge_socket(first_brace_start(base_l) + brace_l);
        top_hinge_socket(second_brace_start(base_l), 180);
    }
    top_snap();
}
