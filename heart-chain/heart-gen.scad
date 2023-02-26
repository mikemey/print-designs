include <bevel_extrude.scad>

//$fn = 128;


heart_length = 21;
heart_width = 36;
heart_height = 10;

radius = 90;
angle = 14;

pieces = floor(360 / angle);

import_angles = [90, 270];
import_translates = [
        [24, - 75.42, 0],
        [24 - heart_width, - 60.5, 0]
    ];

module heart(index) {
    import_angle = import_angles[index % 2];
    import_translate = import_translates[index % 2];

    color("red")
        rotate([0, 0, import_angle])
            translate(import_translate)
                import("/Users/michael/Documents/3D Print/designs/single_heart.stl");
}


//for (i = [0:pieces - 1]) {
//    pa = angle * i;
//    dx = radius * cos(pa);
//    dy = radius * sin(pa);
//   
//    echo("position: ", dx, dy);
//    
//    rotate([0, 0, pa])
//    translate([radius, -heart_width / 2, 0])
//    heart(i);
//}



//cube([heart_length, heart_width, 8]);
//rotate([0, 0, import_angles[1]])
translate([- 30, - 60, 0])
    import("/Users/michael/Documents/3D Print/designs/heart-chain/single_heart.stl");


//heart_size_factor = 10;
//heart_thickness = 5;
//
//module chamfer_extrude(height = 2, angle = 10, center = false) {
//    translate([ 0, 
//                0, 
//                (center == false) ? (height - 0.001) :
//                                    (height - 0.002) / 2 ]) {
//        minkowski() {
//            // convert 2D path to very thin 3D extrusion
//            linear_extrude(height = 0.001) {
//                children();
//            }
//            // generate $fn-sided pyramid with apex at origin,
//            // rotated "point-up" along the y-axis
//            rotate(270) {
//                rotate_extrude() {
//                    polygon([
//                        [ 0,                    0.001 - height  ],
//                        [ height * tan(angle),  0.001 - height  ],
//                        [ 0,                    0               ]
//                    ]);
//                }
//            }
//        }
//    }
//}

//module flat_heart(size_factor = heart_size_factor) {
//    sf = size_factor;
//    dsf = sf * 2;
//    
////    translate([-dsf, -dsf, 0])
//    chamfer_extrude(heart_thickness, 45) {
//        square(dsf);
//
//        translate([sf, dsf, 0])
//        circle(sf);
//
//        translate([dsf, sf, 0])
//        circle(sf);
//    }
//}
//
//module heart_with_hole() {
//    difference() {
//        flat_heart(heart_size_factor);
//        flat_heart(heart_size_factor - heart_thickness);
//    }
//}
//
////rotate([-60, 0, 0])
////heart_with_hole();
//flat_heart();





module prism(l, w, h) {
    polyhedron(//pt 0        1        2        3        4        5
    points = [[0, 0, 0], [l, 0, 0], [l, w, 0], [0, w, 0], [0, w, h], [l, w, h]],
    faces = [[0, 1, 2, 3], [5, 4, 3, 2], [0, 4, 5, 1], [0, 3, 4], [5, 2, 1]]
    );
}

//prism(20, 5, 3);

heart_points = [
        [0, 1.16],
        [0.02, 1.2],
        [0.10, 1.28],
        [0.20, 1.36],
        [0.30, 1.41],
        [0.40, 1.45],
        [0.50, 1.48],
        [0.60, 1.49],
        [0.70, 1.49],
        [0.80, 1.48],
        [0.90, 1.46],
        [1.00, 1.41],
        [1.10, 1.35],
        [1.22, 1.22],
        [1.29, 1.1],
        [1.32, 1.00],
        [1.35, 0.90],
        [1.36, 0.80],
        [1.36, 0.70],
        [1.36, 0.60],
        [1.34, 0.50],
        [1.32, 0.40],
        [1.29, 0.30],
        [1.25, 0.20],
        [1.21, 0.10],
        [1.15, 0.00],
        [1.09, - 0.10],
        [1.02, - 0.20],
        [0.95, - 0.30],
        [0.86, - 0.40],
        [0.77, - 0.50],
        [0.66, - 0.60],
        [0.10, - 1.10],
        [0.00, - 1.15],
//        [0.00, - 1.10],
//        [0.00, - 1.15],
        [-0.10, - 1.10],
        [- 0.66, - 0.60],
        [- 0.77, - 0.50],
        [- 0.86, - 0.40],
        [- 0.95, - 0.30],
        [- 1.02, - 0.20],
        [- 1.09, - 0.10],
        [- 1.15, 0.00],
        [- 1.21, 0.10],
        [- 1.25, 0.20],
        [- 1.29, 0.30],
        [- 1.32, 0.40],
        [- 1.34, 0.50],
        [- 1.36, 0.60],
        [- 1.36, 0.70],
        [- 1.36, 0.80],
        [- 1.35, 0.90],
        [- 1.32, 1.00],
        [- 1.29, 1.1],
        [- 1.22, 1.22],
        [- 1.10, 1.35],
        [- 1.00, 1.41],
        [- 0.90, 1.46],
        [- 0.80, 1.48],
        [- 0.70, 1.49],
        [- 0.60, 1.49],
        [- 0.50, 1.48],
        [- 0.40, 1.45],
        [- 0.30, 1.41],
        [- 0.20, 1.36],
        [- 0.10, 1.28],
        [- 0.02, 1.2],
    ];

translate([0, 15, 0])
    linear_extrude(5)
        difference() {
            scale(10)
                polygon(heart_points);
//            translate([0, 0.0, 0])
                scale(7)
                    polygon(heart_points);
        }



bevel_extrude(height=10,bevel_depth=2,$fn=16)
scale(30)
    polygon(heart_points);
























