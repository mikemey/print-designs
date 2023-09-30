// number of pegs
clip_count = 11; // [1:60]

// Width of one peg
clip_width = 15;

// Length of the pegs
clip_length = 40;

// Thickness of the peg walls 
clip_wall = 2.8;

// Height
clip_height = 5;
clip_distance = 4;

// Space between the pegs.
gap = .7;

rod_diameter = 14.5;
rod_radius = rod_diameter * 0.5;
// rod_wall = 2.45; // thickness of the rod clip wall
rod_wall = 4; // thickness of the rod clip wall

//rod_hole_count = 4;
rod_hole_count = 4;
rod_hole_distance = 8;
//rod_hole_distance = clip_distance + gap;
rod_hole_width = 6.5;
//rod_hole_width = clip_width;

rod_bevel_angle = 30;

// Opening angle of the rod clip
alpha = 115; // [0.0:180.0]

$fn = 32;


// calculated
l = clip_count*clip_width + (clip_count-1)*(clip_distance + gap); // total length
teeth_inner_diameter = clip_distance - 2 * clip_wall;


// echo information
echo("total length is: ", l);


union() {

    // clips
    translate([0.5*clip_width, rod_radius + rod_wall, 0])
    for (i = [0:clip_count-1]) {
        dx = i*(clip_width+clip_distance+gap);
        
        translate([dx,0,0])
        difference() {
            
            // clip base
            union() {
                // clip shape
                translate([-0.5*clip_width,-.2*clip_width,0])
                cube([clip_width, clip_length - 0.3*clip_width, clip_height]);                
                translate([0,clip_length - 0.5*clip_width,0]) 
                cylinder(h=clip_height, d=clip_width);
                
                // teeth
                translate([-0.5*clip_width, clip_length - 0.5*clip_width - 0.5*clip_distance, 0]) 
                difference() {
                    cylinder(h=clip_height, d=clip_distance);
                    cylinder(h=clip_height, d=teeth_inner_diameter);
                }
                translate([0.5*clip_width, clip_length - 0.5*clip_width - 0.5*clip_distance, 0]) 
                difference() {
                    cylinder(h=clip_height, d=clip_distance);
                    cylinder(h=clip_height, d=teeth_inner_diameter);
                }
                translate([-0.5*clip_width,0.5*(clip_length - 0.5*clip_width), 0]) 
                difference() {
                    cylinder(h=clip_height, d=clip_distance);
                    cylinder(h=clip_height, d=teeth_inner_diameter);
                }
                translate([0.5*clip_width,0.5*(clip_length - 0.5*clip_width), 0]) 
                difference() {
                    cylinder(h=clip_height, d=clip_distance);
                    cylinder(h=clip_height, d=teeth_inner_diameter);
                }
                
            }
            
            // clip inner pocket
            union() {
                translate([-0.5*clip_width+clip_wall,0,0])
                cube([clip_width-2*clip_wall, clip_length - 0.5*clip_width, clip_height]);
                
                translate([0,clip_length - 0.5*clip_width,0]) {
                    cylinder(h=clip_height, d=clip_width-2*clip_wall);
                }
                // teeth holes
                translate([-0.5*clip_width, clip_length - 0.5*clip_width - 0.5*clip_distance - teeth_inner_diameter / 2, 0])
                cube([clip_wall, teeth_inner_diameter, clip_height * 2]);

                translate([0.5*clip_width - clip_wall, clip_length - 0.5*clip_width - 0.5*clip_distance - teeth_inner_diameter / 2, 0]) 
                cube([clip_wall, teeth_inner_diameter, clip_height * 2]);

                translate([-0.5*clip_width,0.5*(clip_length - 0.5*clip_width) - teeth_inner_diameter / 2, 0]) 
                cube([clip_wall, teeth_inner_diameter, clip_height * 2]);

                translate([0.5*clip_width - clip_wall,0.5*(clip_length - 0.5*clip_width) - teeth_inner_diameter / 2, 0]) 
                cube([clip_wall, teeth_inner_diameter, clip_height * 2]);
            }
        }
//        color("cyan") {
//            translate([-0.5*clip_width, clip_length - 0.5*clip_width - 0.5*clip_distance - teeth_inner_diameter / 2, 0])
//            cube([clip_wall, teeth_inner_diameter, clip_height * 2]);
//            
//            translate([0.5*clip_width - clip_wall, clip_length - 0.5*clip_width - 0.5*clip_distance - teeth_inner_diameter / 2, 0]) 
//            cube([clip_wall, teeth_inner_diameter, clip_height * 2]);
//
//            translate([-0.5*clip_width,0.5*(clip_length - 0.5*clip_width) - teeth_inner_diameter / 2, 0]) 
//            cube([clip_wall, teeth_inner_diameter, clip_height * 2]);
//
//            translate([0.5*clip_width - clip_wall,0.5*(clip_length - 0.5*clip_width) - teeth_inner_diameter / 2, 0]) 
//            cube([clip_wall, teeth_inner_diameter, clip_height * 2]);
//        }
    }

    // rod clip
    translate([0, 0, rod_radius+rod_wall]) {
        rotate([0, 90, 0]) {
            difference() {
                union() {
                    // outer rod 
                    outer_rod_width = rod_diameter + 2 * rod_wall;
                    color("red") cylinder(h=l, d=outer_rod_width);                
                    translate([0, -rod_radius - rod_wall, 0])
                    cube([rod_radius + rod_wall, outer_rod_width, l]);
                    
//                    color("blue")
//                    translate([rod_radius, -rod_radius - rod_wall * 4, 0])
//                    rotate([0, 0, 45])
//                    cube([rod_wall * 6, rod_wall * 3, l]);
                }
                // rod hole
                cylinder(h=l, d=(rod_diameter));
                
                // opening
                rotate([0, 0, -(180 - alpha) / 2])
                linear_extrude(height=l) {
                    polygon([
                        [0,0],
                        [-cos(0.5*alpha)*(rod_radius + rod_wall),sin(0.5*alpha)*(rod_radius + rod_wall)],
                        [-(rod_radius + rod_wall),sin(0.5*alpha)*(rod_radius + rod_wall)],
                        [-(rod_radius + rod_wall),-sin(0.5*alpha)*(rod_radius + rod_wall)],
                        [-cos(0.5*alpha)*(rod_radius + rod_wall),-sin(0.5*alpha)*(rod_radius + rod_wall)]
                        ]);
                }
                
                // rod bevel
                translate([0, -(rod_radius + rod_wall * 4) / cos(rod_bevel_angle), 0])
                rotate([0, 0, rod_bevel_angle])
                cube([rod_wall * 6, rod_wall * 3, l]);
                
                // rod holes
//                for (i = [0:rod_hole_count-1]) {
//                    dx = i * (rod_hole_width + rod_hole_distance);
//                    translate([-rod_radius - rod_wall, 0, dx]) {
//                        cube([rod_diameter + 2 * rod_wall - clip_height, rod_radius + 5, rod_hole_width]);
//                        translate([0, -rod_radius - rod_wall, 0]) {
//                            cube([rod_diameter + 2 * rod_wall, rod_radius + rod_wall, rod_hole_width]);
//                        }
//                    }
//                }            
            }
        }
    }
}

