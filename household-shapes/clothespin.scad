$fn = 64;

// total length of pin
length = 80;
// width of pin
width = 9.5;

// hole diameter for spring
spring_d = 6.5;

// spring support width
spring_support_w = 4.5;

// height at middle
center_height = 8.5;

// height at head-end
head_height = 7.5;

// distance from head to bolt notch
head_length = 22;

// skip following steps of head-hole-creation
skip_head_holes_ixs = [0, 3, 6, 13, 19, 20];

// distance from head-end to spring notch center
middle_length = 16;

// groove width of bolt notch
bolt_notch_width = 3;

// groove height of bolt notch
bolt_notch_height = 1;

// spacer length
spacer_l = 6;

// spacer height
spacer_h = 11;

// distance between spacer and mid-point
spacer_dist = 0.1;

// hanging hole diameter
hanging_hole_d = 0;

// hanging hole distance from pin end
hanging_hole_dist = 5.5;

extruder_width = 0.35;
wall_thickness = extruder_width * 2;

head_profile_pct = [
    // slope upwards
        [0, 0], [5, 37], [13, 70], [19, 82], [25, 89], [31, 91],
    // first notch with tines
        [35, 55], [38, 55], [41, 61], [44, 55], [47, 61],
        [50, 55], [53, 61], [56, 55], [59, 55], [69, 98],
    // second notch rounded
        [75, 98],
        [75.5, 90], [76.5, 85], [78.5, 80],
        [80, 79],
        [81.5, 80], [83.5, 85], [84.5, 90],
        [85, 98],
    // head-end
        [100, 100], [100, 0]
    ];

head_profile = head_profile_pct * [[head_length / 100, 0], [0, head_height / 100]];
spring_center = head_length + middle_length;


module profile_wall() {
    linear_extrude(wall_thickness)
        union() {
            polygon([
                    [0, 0], [length, 0], [length, wall_thickness],
                    [spring_center, center_height], [head_length, head_height],
                    [head_length, wall_thickness]
                ]);
            polygon(head_profile);
        }
}

module head_roof() {
    inner_w = width - 2 * wall_thickness;
    difference() {
        linear_extrude(width)
            polygon(head_profile);
        translate([0, 0, wall_thickness])
            for (i = [1: len(head_profile) - 2]) {
                if (!search(i, skip_head_holes_ixs)) {
                    p0 = head_profile[i];
                    p1 = head_profile[i + 1];
                    translate([p0.x, 0, 0])
                        cube([p1.x - p0.x, min(p0.y, p1.y) - wall_thickness, inner_w]);
                }}
    }
    translate([head_length - wall_thickness, 0, 0])
        cube([wall_thickness, head_height, width]);
}

module pin_floor() {
    difference() {
        translate([head_length + bolt_notch_width, 0, 0])
            cube([length - head_length - bolt_notch_width, wall_thickness, width]);
        translate([length - hanging_hole_dist, 0, width / 2])
            rotate([- 90, 0, 0])
                cylinder(d = hanging_hole_d, h = wall_thickness);
    }
}

module spacer() {
    spacer_w = width / 2 - wall_thickness - spacer_dist;
    straight_spacer_h = spacer_h - spacer_w + wall_thickness;
    translate([head_length + middle_length / 2 - spacer_l / 2, wall_thickness, wall_thickness]) {
        difference() {
            union() {
                cube([spacer_l, straight_spacer_h, spacer_w]);
                difference() {
                    translate([0, straight_spacer_h, spacer_w]) {
                        rotate([0, 90, 0])
                            cylinder(r = spacer_w, h = spacer_l);
                    }
                    cube([spacer_l, straight_spacer_h, spacer_l]);
                    translate([0, wall_thickness, spacer_w])
                        cube([spacer_l, spacer_h, spacer_l]);
                }
            }
            color("green")
                translate([wall_thickness, 0, 0])
                    cube([spacer_l - 2 * wall_thickness, spacer_h + wall_thickness, spacer_w - wall_thickness]);
        }}
}

module spring_support() {
    translate([spring_center - spring_support_w / 2, 0, 0])
        cube([spring_support_w, center_height, width]);
}

module bolt_notch() {
    translate([head_length, 0, 0])
        cube([bolt_notch_width + wall_thickness, bolt_notch_height + wall_thickness, width]);
}

module spring_hole() {
    translate([spring_center, center_height, 0])
        cylinder(d = spring_d, h = width);
}

module bolt_notch_hole() {
    translate([head_length, 0, 0])
        cube([bolt_notch_width, bolt_notch_height, width - wall_thickness]);
}

difference() {
    union() {
        profile_wall();
        translate([0, 0, width - wall_thickness])  profile_wall();
        head_roof();
        pin_floor();
        spacer();
        spring_support();
        bolt_notch();
    }
    spring_hole();
    bolt_notch_hole();
}
