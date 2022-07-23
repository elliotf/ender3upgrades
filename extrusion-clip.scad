include <lumpyscad/lib.scad>;

resolution = 128;
extrusion_width = 0.5;
wall_thickness = 1;
tolerance = 0.2;

module extrusion_clip_profile_arrow(opening_height = 4,opening_width = 8) {
  overall_height = opening_height+wall_thickness*2;
  overall_width = v_slot_opening+opening_width + wall_thickness;
  prong_length = v_slot_cavity_depth-tolerance*2;
  //length_behind_extrusion = (v_slot_opening_behind_slot_width-v_slot_opening)/2-tolerance;
  length_behind_extrusion = 1.75;
  echo("length_behind_extrusion: ", length_behind_extrusion);
  module body() {
    for(y=[front,rear]) {
      mirror([0,y-1,0]) {
        // angled retainer
        hull() {
          translate([0,v_slot_opening/2-wall_thickness/2,0]) {
            translate([-v_slot_cavity_depth+wall_thickness/2+tolerance,0,0]) {
              accurate_circle(wall_thickness,resolution);
            }
            translate([-v_slot_depth-wall_thickness/2-tolerance,0,0]) {
              accurate_circle(wall_thickness,resolution);
            }
          }
          translate([-v_slot_depth-wall_thickness/2-tolerance,v_slot_opening/2+length_behind_extrusion-wall_thickness/2,0]) {
            accurate_circle(wall_thickness,resolution);
          }
        }

        // retainer arms
        translate([-v_slot_depth,v_slot_opening/2-wall_thickness/2,0]) {
          square([v_slot_depth*2+0.1,wall_thickness],center=true);
        }
      }
    }

    // end cap

    // longer/outer arm & co
    translate([-wall_thickness+overall_height/2,-v_slot_opening/2+wall_thickness/2,0]) {
      rounded_square(overall_height+wall_thickness*2,wall_thickness,wall_thickness,resolution);
    }
    translate([overall_height-wall_thickness/2,-v_slot_opening/2+overall_width/2,0]) {
      rounded_square(wall_thickness,overall_width,wall_thickness,resolution);
    }

    // shorter/inner arm & co
    short_arm_length = opening_height+wall_thickness-tolerance;
    translate([-wall_thickness+short_arm_length/2,v_slot_opening/2-wall_thickness/2,0]) {
      rounded_square(short_arm_length+wall_thickness*2,wall_thickness,wall_thickness,resolution);
    }
    translate([wall_thickness/2,v_slot_opening/2+opening_width/2,0]) {
      rounded_square(wall_thickness,opening_width+wall_thickness*2,wall_thickness,resolution);
    }

    // end cap
    translate([overall_height/2,-v_slot_opening/2+overall_width-wall_thickness/2,0]) {
      rounded_square(overall_height,wall_thickness,wall_thickness,resolution);
    }
    /*
    translate([short_arm_length-wall_thickness/2,v_slot_opening/2+tolerance/2,0]) {
      rounded_square(wall_thickness,wall_thickness*2+tolerance,wall_thickness,resolution);
    }
    translate([short_arm_length/2,v_slot_opening/2+wall_thickness/2+tolerance,0]) {
      rounded_square(short_arm_length,wall_thickness,wall_thickness,resolution);
    }
    */

    hull() {
     
      
    }
  }

  module holes() {
    
  }
  
  difference() {
    body();
    holes();
  }
}

module extrusion_clip_profile_minimal(opening_height = 4,opening_width = 8) {
  overall_height = opening_height+wall_thickness*2;
  overall_width = v_slot_opening+opening_width + wall_thickness;
  prong_length = v_slot_cavity_depth-tolerance*2;
  //length_behind_extrusion = (v_slot_opening_behind_slot_width-v_slot_opening)/2-tolerance;
  length_behind_extrusion = 1.25;
  room_for_extrusion_sharp = 0;

  module body() {
    for(x=[left,right]) {
      mirror([x-1,0,0]) {
        translate([-v_slot_opening/2-length_behind_extrusion/2+wall_thickness/2,-v_slot_depth-wall_thickness/2,0]) {
          rounded_square(length_behind_extrusion+wall_thickness,wall_thickness,wall_thickness,resolution);
        }
        translate([-v_slot_opening/2+wall_thickness/2,-v_slot_depth+room_for_extrusion_sharp/2,0]) {
          rounded_square(wall_thickness,wall_thickness*2+room_for_extrusion_sharp,wall_thickness,resolution);
        }
        hull() {
          translate([-v_slot_opening/2+wall_thickness/2,-v_slot_depth+room_for_extrusion_sharp+wall_thickness/2,0]) {
            accurate_circle(wall_thickness,resolution);
          }
          translate([-v_slot_width/2+wall_thickness/2,wall_thickness/2,0]) {
            accurate_circle(wall_thickness,resolution);
          }
        }
      }
    }
  }

  module holes() {
    
  }
  
  difference() {
    body();
    holes();
  }
}

module extrusion_clip_wiring_holder(opening_height = 4,opening_width = 8) {
  overall_height = opening_height+wall_thickness*2;
  overall_width = v_slot_width+opening_width + wall_thickness;

  module body() {
    extrusion_clip_profile_minimal();

    /*
    translate([0,wall_thickness/2,0]) {
      difference() {
        accurate_circle(v_slot_width,resolution);
        accurate_circle(v_slot_width-wall_thickness*2,resolution);
        translate([0,-v_slot_width/2,0]) {
          square([v_slot_width*2,v_slot_width],center=true);
        }
      }
    }
    */

    guard_height = overall_height-wall_thickness-tolerance;
    translate([-v_slot_width/2+wall_thickness/2,guard_height/2,0]) {
      rounded_square(wall_thickness,guard_height,wall_thickness,resolution);
    }
    translate([-v_slot_width/2-opening_width/2,wall_thickness/2,0]) {
      rounded_square(opening_width+wall_thickness*2,wall_thickness,wall_thickness,resolution);
    }

    translate([v_slot_width/2-wall_thickness/2,overall_height/2,0]) {
      rounded_square(wall_thickness,overall_height,wall_thickness,resolution);
    }
    translate([v_slot_width/2-overall_width/2,overall_height-wall_thickness/2,0]) {
      rounded_square(overall_width,wall_thickness,wall_thickness,resolution);
    }

    translate([v_slot_width/2-overall_width+wall_thickness/2,overall_height/2,0]) {
      rounded_square(wall_thickness,overall_height,wall_thickness,resolution);
    }
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

module extrusion_wiring_retainer() {
  module body() {
    extrusion_clip_profile_minimal();

    translate([0,wall_thickness/2,0]) {
      difference() {
        accurate_circle(v_slot_width,resolution);
        accurate_circle(v_slot_width-wall_thickness*2,resolution);
        translate([0,-v_slot_width/2,0]) {
          square([v_slot_width*2,v_slot_width],center=true);
        }
      }
    }
  }

  module holes() {
  }

  difference() {
    body();
    holes();
  }
}

% translate([0,-20/2,0]) {
  extrusion_2020_profile();
}

linear_extrude(height=0.1) {
  //extrusion_clip_profile_minimal();
  extrusion_clip_wiring_holder();
}

translate([-20/2,-20/2,0]) {
  rotate([0,0,90]) {
    linear_extrude(height=0.1) {
      extrusion_wiring_retainer();
    }
  }
}

translate([20/2,-20/2,0]) {
  color("grey", 0.1) {
    linear_extrude(height=0.1) {
      extrusion_clip_profile_arrow();
    }
  }
}
