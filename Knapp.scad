/* Conventions in this file:
 * x-direction is usually the width
 * y-direction is usually the length
 * z-direction is usually the height
 * everything in r-direction is also length
 *
 * We stick with short cryptic names
 *
 * Every module has example usage attached to it, commented out
 * 
 * The whole knapp is built with a 20 mm diameter
 * */

cord_r = 0.6;
cord_swing = 0.7;
cord_h = 2*(cord_r + cord_swing); /* after scaling with 0.5 */
cord_fr = 10;            /* after scaling with 0.5 */

// TODO:
/* We probably want a tauring about twice as thick, same radius
 * Alternatively, keep thickness halve radius, remove scale(0.5)
 * */
module tauringen(){
//  scale(0.5)
//    import("r52sw60.stl", convexity=6);
  import("fr10r6sw7.stl", convexity=8);
}

module ltri(width, length, height){
  linear_extrude(height=height, slices=1)
    polygon(points=[[-width/2,0],[width/2,0],[0,length]], convexity=1); 
}
//ltri(10, 20, 2);

module htrih(width,length, height){
  w_2 = width/2;
  polyhedron(
            points     = [[-w_2,     0,      0],
                          [ w_2,     0,      0],
                          [   0,     0, height],
                          [   0,length,      0]],
            triangles  = [[0,1,2],
                          [3,0,2],
                          [3,1,0],
                          [1,3,2]],
            convexity  =2
            );
}


/* A lying equilateral triangle */
module htri(width,length){
  w_2 = width/2;
  wsq3_2 = w_2*sqrt(3);
  polyhedron(
            points     = [[-w_2,     0,      0],
                          [ w_2,     0,      0],
                          [   0,     0, wsq3_2],
                          [   0,length,      0]],
            triangles  = [[0,1,2],
                          [3,0,2],
                          [3,1,0],
                          [1,3,2]],
            convexity  =2
            );
}
//htri(10,20);

module spin(){
  union(){
    for(vz=[0:90:360]){
      rotate([0,0,vz]) child(0);
    }
  }
}
//spin() rotate([90,0,0]) cylinder(r=3, h=10);

module waveslice(length, height, r, offset, downset){
  tan_pi_8 = 0.41421356237309; /* tan(pi/8) degrees */
  base = 0.35;
  difference(){
    translate([0,0,-base]) ltri(tan_pi_8*2*length, length, height+base);
    translate([0,-downset,r-offset]) sphere(r=r);
  }
}
//waveslice(10,2.0,30, 0.5, 3.6, $fn=90);
//spin()
//for(v=[45/2,3*45/2]){
//  rotate([0,0,v]) rotate([10,0,0])
//    translate([0,-6.2,0])
//    waveslice(6.2,2.2,31, 0.5, 3.6, $fn=90);
//}

module toblerone(width, length){
  w_2 = width/2;
  w_sq3_2 = w_2*sqrt(3);
  polyhedron(
            points     = [
                          [-w_2,      0,        0],
                          [ w_2,      0,        0],
                          [   0,      0,  w_sq3_2],
                          [-w_2, length,        0],
                          [ w_2, length,        0],
                          [   0, length,  w_sq3_2]
                          ],
            triangles  = [[0,1,2],
                          [4,3,5],
                          [3,0,2],
                          [3,2,5],
                          [1,4,2],
                          [2,4,5],
                          [4,1,3],
                          [3,1,0]],
            convexity  =2
            );
}
//toblerone(3,10);

module arrow(length, arrow_width, shaft_width){
  head_length = 0.3*length;
  shaft_length = length-head_length;
  union(){
    //toblerone(shaft_width, shaft_length+0.1);
    htri(arrow_width, length);
    translate([0,shaft_length,0]) htri(arrow_width, head_length);
  }
}
//arrow(8,2,1);

module arrow2(length, base, base2, height){
  head_length = 0.35*length;
  shaft_length = length-head_length;
  union(){
    htrih(base2, length*0.8, height);
    translate([0,shaft_length,0]) htri(base, head_length);
  }
}
//arrow2(8,3,6,8);

/* Rotating the sphere can make cool effects here...
 */
module silo(sphere_r, cyl_r, h, eggness){
  intersection(){
    translate([0,0,-(sphere_r*eggness)+h])
      rotate([0,0,0])
        scale([1,1,eggness])
          sphere(r=sphere_r);
    cylinder(r=cyl_r, h=h+10);
  }
}
//silo(63,9.2,2.0, 2, $fn=200);

module knapp(){
  knapp_r          = cord_fr-0.8;
  arrow_off_center = 2.0;
  arrow_lift = 1;
  ltri_h = 2.3;
  waveslice_lift=1.8;
  waveslice_r=knapp_r/2+cord_r+2;
  union(){
    /* Knapp without decoration */
    cylinder(r=knapp_r, h=1);
    silo(sphere_r = 39,            /* shpere_r here determines edge band width */
            cyl_r = knapp_r-0.1,
                h = 1.7,
          eggness = 1,             /* eggnes creates an ellipsoid */
              $fn = 70); 
    /* Rope ring, defined i own module */
    rotate([0,90,0]) translate([-(cord_h-cord_r)/2,-cord_fr,0]) tauringen();
    /* Quadratic decoration in middle, "boxes" */
    rotate([0,0,45]) translate([-1.0, -1.0, 0]) cube([2,2,3.3]);
    rotate([0,0,45]) translate([-1.5, -1.5, 0]) cube([3,3,3.0]);
    rotate([0,0,45]) translate([-2.0, -2.0, 0]) cube([4,4,2.7]);
    difference(){
     spin()
      union(){
        /* Arrow */
        translate([0,0,arrow_lift]) rotate([0,0,0]) translate([0,arrow_off_center,0])
          arrow2(
            length = knapp_r+2*cord_r-arrow_off_center-0.3,
              base = 3,
             base2 = 5.0,
            height = 2.8-arrow_lift);
        /* Wave corners */
        for(v=[45/2,3*45/2]){
        translate([0,0,waveslice_lift])
        rotate([0,0,v]) rotate([6,0,0])
          translate([0,-waveslice_r,0])
            waveslice(waveslice_r,0.19,30, 0.5, 3.6, $fn=60);
          //old  waveslice(waveslice_r,ltri_h-waveslice_lift,8, 1, -2.5);
        }
      }
      /* None of center decor above boxes */
      translate([-cord_fr/2,-cord_fr/2,2.7]) cube(cord_fr);
      /* Arrow flat-tops */
      spin()
        translate([cord_fr-3,-cord_fr/2,2.0]) cube(cord_fr);
    }
    spin(){
      rotate([0,0,45]){
        /* Boats */
        ltri(3.4,knapp_r*0.68,ltri_h);
        /* Dots */
        translate([knapp_r*0.80,0,1.30]) sphere(r=0.62, $fn=10);
      }
    }
  }
}
knapp();

module flat_knapp(){
  difference(){
    knapp();
    translate([0,0,-20]) cube(40,center=true);
  }
}
//flat_knapp();
