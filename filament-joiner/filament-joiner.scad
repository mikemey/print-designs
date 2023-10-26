use <../basics/basic-shapes.scad>

$fn = 128;

holder_w = 10;
holder_h = 3;
holder_full_x = 40;
holder_full_y = 40;

holder_grooves_offset_x = 27;
holder_grooves_distance = 7;
filament_r1 = 2.85 / 2;
filament_r2 = 1.75 / 2;

print_line_w = 0.35;

clamp_w = 12;
clamp_h = 7;
clamp_grooves_offset_x = 5;
clamp_hole_y1 = 2.5;
clamp_hole_y2 = 9;
clamp_hole_angled_x = 23;
clamp_hole_straight_x = 7;
clamp_wall = 3 * print_line_w;
clamp_angle = 3.5;

holder();
clamp();

module holder() {
    hole_y = holder_full_y - 2 * holder_w;

    difference() {
        cube([holder_full_x, holder_full_y, holder_h]);
        translate([holder_w, holder_w, - 1])
            cube([holder_full_x, hole_y, holder_h + 2]);
        rod_holes();
    }
}

module clamp() {
    x_offset = holder_grooves_offset_x - clamp_grooves_offset_x;
    y_offset = (holder_full_y - clamp_w) / 2;
    difference() {
        translate([x_offset, y_offset, holder_h])
            difference() {
                cube([clamp_hole_angled_x + clamp_hole_straight_x, clamp_w, clamp_h]);
                clamp_hole();
            }
        rod_holes();
    }

    module clamp_hole() {
        y_offset = (clamp_w - clamp_hole_y2) / 2 ;
        translate([clamp_wall + clamp_hole_straight_x + clamp_hole_angled_x, y_offset, clamp_wall])
            rotate([0, clamp_angle, 0]) {
                translate([- clamp_hole_straight_x, 0, 0]) {
                    clamp_prism_base_w = (clamp_hole_y2 - clamp_hole_y1) / 2;
                    rotate([0, 270, 0])
                        prism_right_triangle(clamp_h, clamp_prism_base_w, clamp_hole_angled_x);
                    translate([- clamp_hole_angled_x, clamp_prism_base_w, 0])
                        cube([clamp_hole_angled_x, clamp_hole_y1, clamp_h]);

                    translate([0, clamp_prism_base_w * 2 + clamp_hole_y1, clamp_h])
                        rotate([0, 90, 180])
                            prism_right_triangle(clamp_h, clamp_prism_base_w, clamp_hole_angled_x);
                    cube([clamp_hole_straight_x + 1, clamp_hole_y2, clamp_h]);
                }}
    }
}

module rod_holes() {
    hole_len = holder_full_y + 2;
    translate([holder_grooves_offset_x, holder_full_y + 1, holder_h])
        rotate([90, 0, 0]) {
            cylinder(h = hole_len, r = filament_r1);
            translate([holder_grooves_distance, 0, 0])
                cylinder(h = hole_len, r = filament_r2);
        }
}
