include <../libs/BOSL/constants.scad>
use <../libs/BOSL/masks.scad>

module cube_rounded_edges(width, length, height, edge_radius) {
    difference() {
        cube([width, length, height]);
        fillet_mask_z(height, edge_radius, align = V_UP);
        translate([width, 0, 0])
            fillet_mask_z(height, edge_radius, align = V_UP);
        translate([0, length, 0])
            fillet_mask_z(height, edge_radius, align = V_UP);
        translate([width, length, 0])
            fillet_mask_z(height, edge_radius, align = V_UP);
    }
}

module prism_right_triangle(l, w, h) {
    polyhedron(//pt 0        1          2          3          4          5
    points = [[0, 0, 0], [l, 0, 0], [l, w, 0], [0, w, 0], [0, w, h], [l, w, h]],
    faces = [[0, 1, 2, 3], [5, 4, 3, 2], [0, 4, 5, 1], [0, 3, 4], [5, 2, 1]]
    );
}
