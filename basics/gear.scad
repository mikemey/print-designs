$fn = 128;

module gear(diameter, height, teeth_count, teeth_height, teeth_top_length, teeth_bottom_distance) {
    difference() {
        cylinder(d = diameter, h = height);
        teeth_holes(diameter / 2, height, teeth_count, teeth_height, teeth_top_length, teeth_bottom_distance);
    }
}

module teeth_holes(radius, height, teeth_count, teeth_height, teeth_top_length, teeth_bottom_distance) {
    rot = 360 / teeth_count;
    outer_dist = arc_length(radius, rot) - teeth_top_length;

    linear_extrude(height)
        for (i = [0:teeth_count]) {
            rotate([0, 0, i * rot])
                translate([0, - radius, 0])
                    teeth_hole(teeth_height, outer_dist, teeth_bottom_distance);
        }
}

function arc_length(radius, angle) = radius * angle * (PI / 180);

module teeth_hole(teeth_height, outer_dist, inner_dist) {
    out = outer_dist / 2;
    inner = inner_dist / 2;
    polygon([
            [- out, 0], [out, 0], [inner, teeth_height], [- inner, teeth_height]
        ]);
}

module gear_example() {
    height = 5;
    diameter = 80;
    teeth_count = 40;
    teeth_height = 3;
    teeth_top_length = 2;
    teeth_bottom_distance = 3;

    //translate([0, 0, - height])
    //    cylinder(d = diameter, h = height);
    gear(diameter, height, teeth_count, teeth_height, teeth_top_length, teeth_bottom_distance);
}
