module lattice_example() {
    lattice([280, 10, 212], 10, 15);
}

module lattice(size, lattice_width, hole_width, angle = 45) {
    min_angle = 0;
    max_angle = 89;
    assert(min_angle <= angle, str("minimum angle: ", min_angle));
    assert(angle <= max_angle, str("maximum angle: ", max_angle));

    difference() {
        lattices();
        cutoff_overlaps();
    }

    function lattice_length(length) = length / cos(angle) + lattice_width * tan(angle);

    module lattices() {
        partial_lattice(size.x, size.z);
        translate([0, 0, size.z])
            rotate([0, 90, 0])
                partial_lattice(size.z, size.x);
    }

    module partial_lattice(length, height) {
        start_point = - lattice_width * sin(angle);
        lattice_l = lattice_length(length);
        v_dist = (lattice_width + hole_width) / cos(angle);
        lattice_cnt = ceil((height + length * tan(angle)) / v_dist);

        for (i = [0:lattice_cnt]) {
            translate([start_point, 0, i * v_dist])
                rotate([0, angle, 0])
                    cube([lattice_l, size.y, lattice_width]);
        }
    }

    module cutoff_overlaps() {
        longer_side = max(size.x, size.z);
        border_half = lattice_length(longer_side) + longer_side;
        y_overlap = 0.1;

        difference() {
            translate([- border_half + size.x / 2, - y_overlap, - border_half + size.z / 2])
                cube([2 * border_half, size.y + 2 * y_overlap, 2 * border_half]);
            cube(size);
        }
    }
}