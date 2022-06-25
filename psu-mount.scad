include <./frame-mockup.scad>;
include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>;

printed_color = "gold";

extrude_width = 0.5;
extrude_height = 0.24;
wall_thickness = extrude_width*2;
spacer = 0.2;

extrusion_screw_hole_diam = 5.2;

psu_mirror_x = 1; // 0 == cables on left, 1 == cables on right

psu_pos_x = -side_connector_length/2+psu_length/2+wall_thickness*2+0.5;
psu_pos_y = -psu_width/2;
psu_pos_z = psu_height/2+wall_thickness*2;
psu_cap_length = 10;
psu_screw_hole_diam = 4.1;
psu_support_depth = psu_width*0.15;

plate_thickness = 6;

fan_from_end = 48; // not very accurate, only for visualization
fan_from_side = 38; // not very accurate, only for visualization

module position_psu() {
  translate([psu_pos_x,psu_pos_y,psu_pos_z]) {
    rotate([0,0,90]) {
      children();
    }
  }
}

module psu_assembly() {
  mirror([psu_mirror_x,0,0]) {
    translate([0,-side_rail_length_front+side_rail_length]) {
      position_psu() {
        // for whatever reason, I designed this whole thing with the plug on the right side
        // which now seems stupid, but go ahead and mirror here so that the fan is rendered
        // on the correct side if/when I mirror it so that the plug is on the rear left
        mirror([psu_mirror_x,0,0]) {
          % psu();
        }
      }

      psu_mount_plug_side();
      psu_mount_non_plug_side();
      psu_mount_corner_support();
    }
  }
}

module psu_mount_non_plug_side_frame_profile() {
  rounded_diam = wall_thickness*2;
  inner_rounded_diam = 1;
  outer_rounded_diam = inner_rounded_diam+2*rounded_diam;
  tab_depth = wall_thickness*2+v_slot_cavity_depth-1;
  overall_height = psu_height + wall_thickness*4 + spacer*2;

  module frame() {
    translate([0,overall_height/2]) {
      translate([wall_thickness,0,0]) {
        rounded_square(wall_thickness*2,overall_height,rounded_diam);
      }
      for(z=[top,bottom]) {
        translate([psu_cap_length/2+wall_thickness,z*(overall_height/2-wall_thickness)]) {
          rounded_square(psu_cap_length+wall_thickness*2,wall_thickness*2,rounded_diam);
        }
          /*
          mirror([0,z-1,0]) {
            translate([0,overall_height/2,0]) {
              rotate([0,0,-90]) {
                # round_corner_filler_profile(outer_rounded_diam,resolution);
              }
            }
          }
          */
        mirror([0,z-1,0]) {
          translate([wall_thickness*2,overall_height/2-wall_thickness*2,0]) {
            rotate([0,0,-90]) {
              round_corner_filler_profile(1,resolution);
            }
          }
        }
      }
    }
  }

  module cuts() {
    translate([0,overall_height/2]) {
      for(z=[top,bottom]) {
        mirror([0,z-1,0]) {
          translate([0,overall_height/2,0]) {
            rotate([0,0,-90]) {
              round_corner_filler_profile(outer_rounded_diam,resolution);
            }
          }
        }
      }
    }
  }

  difference() {
    frame();
    cuts();
  }

  // slot tabs
  for(z=[top,bottom],s=[top,bottom]) {
    translate([wall_thickness*2-tab_depth/2,40/2+z*(20/2)+s*((v_slot_opening-0.5)/2-wall_thickness)]) {
      rounded_square(tab_depth,wall_thickness*2,rounded_diam);
    }
  }
}

module psu_mount_non_plug_side() {
  rounded_diam = wall_thickness*2;
  inner_rounded_diam = 1;
  outer_rounded_diam = inner_rounded_diam+2*rounded_diam;
  tab_depth = wall_thickness*2+v_slot_cavity_depth-1;
  overall_height = psu_height + wall_thickness*4 + spacer*2;

  translate([0,0,0]) {
    // % v_slot_profile();
  }

  module v_slot_profile() {
    module frame() {
      translate([0,overall_height/2]) {
        translate([wall_thickness,0,0]) {
          rounded_square(wall_thickness*2,overall_height,rounded_diam);
        }
        for(z=[top,bottom]) {
          translate([psu_cap_length/2+wall_thickness,z*(overall_height/2-wall_thickness)]) {
            rounded_square(psu_cap_length+wall_thickness*2,wall_thickness*2,rounded_diam);
          }
            /*
            mirror([0,z-1,0]) {
              translate([0,overall_height/2,0]) {
                rotate([0,0,-90]) {
                  # round_corner_filler_profile(outer_rounded_diam,resolution);
                }
              }
            }
            */
          mirror([0,z-1,0]) {
            translate([wall_thickness*2,overall_height/2-wall_thickness*2,0]) {
              rotate([0,0,-90]) {
                round_corner_filler_profile(1,resolution);
              }
            }
          }
        }
      }
    }

    module cuts() {
      translate([0,overall_height/2]) {
        for(z=[top,bottom]) {
          mirror([0,z-1,0]) {
            translate([0,overall_height/2,0]) {
              rotate([0,0,-90]) {
                round_corner_filler_profile(outer_rounded_diam,resolution);
              }
            }
          }
        }
      }
    }

    difference() {
      frame();
      cuts();
    }

    // slot tabs
    for(z=[top,bottom],s=[top,bottom]) {
      translate([wall_thickness*2-tab_depth/2,40/2+z*(20/2)+s*((v_slot_opening-0.5)/2-wall_thickness)]) {
        rounded_square(tab_depth,wall_thickness*2,rounded_diam);
      }
    }
  }

  module plate_profile() {
    module body() {
      hull() {
        translate([0,overall_height/2,0]) {
          rounded_square(2*(psu_cap_length+wall_thickness*2),overall_height,rounded_diam);
        }
        translate([-40/2,40/2,0]) {
          rounded_square(40,40,rounded_diam/2);
        }
      }
    }

    module holes() {
      translate([-40/2,40/2,0]) {
        translate([right*(20/2),bottom*(20/2),0]) {
          accurate_circle(extrusion_screw_hole_diam,resolution);
        }
        translate([left*(20/2),top*(20/2),0]) {
          accurate_circle(extrusion_screw_hole_diam,resolution);
        }
      }
    }

    difference() {
      body();
      holes();
    }
  }

  module body() {
    translate([-side_connector_length/2,0,0]) {
      translate([0,-psu_support_depth/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=psu_support_depth,convexity=3,center=true) {
            //v_slot_profile();
            psu_mount_non_plug_side_frame_profile();
          }
        }
      }
      translate([0,plate_thickness/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=plate_thickness,convexity=3,center=true) {
            plate_profile();
          }
        }
      }
    }
  }

  module holes() {

  }

  color(printed_color) difference() {
    body();
    holes();
  }
}

module psu_mount_corner_support() {
  rounded_diam = wall_thickness*2;
  tab_depth = wall_thickness*2+v_slot_cavity_depth-1;
  overall_height = psu_height + wall_thickness*4 + spacer*2;
  corner_space = side_rail_length_rear-psu_width-spacer*2;
  cover_width = psu_cap_length+wall_thickness*2;

  screw_pos_x = cover_width;
  screw_pos_z = 20/2;

  screw_head_hole_diam = m3_bolt_head_diam+2;

  module v_slot_profile() {
    translate([0,overall_height/2]) {
      translate([wall_thickness,0,0]) {
        rounded_square(wall_thickness*2,overall_height,rounded_diam);
      }
      for(z=[top,bottom]) {
        translate([psu_cap_length/2+wall_thickness,z*(overall_height/2-wall_thickness)]) {
          rounded_square(psu_cap_length+wall_thickness*2,wall_thickness*2,rounded_diam);
        }
        mirror([0,z-1,0]) {
          translate([wall_thickness*2,overall_height/2-wall_thickness*2,0]) {
            rotate([0,0,-90]) {
              round_corner_filler_profile(1,resolution);
            }
          }
        }
      }
    }

    for(z=[top,bottom],s=[top,bottom]) {
      translate([wall_thickness*2-tab_depth/2,40/2+z*(20/2)+s*((v_slot_opening-0.5)/2-wall_thickness)]) {
        rounded_square(tab_depth,wall_thickness*2,rounded_diam);
      }
    }
  }

  module cap_profile() {
    hull() {
      translate([cover_width/2,overall_height/2]) {
        rounded_square(cover_width,overall_height,rounded_diam);
      }
      translate([screw_pos_x,screw_pos_z,0]) {
        accurate_circle(screw_head_hole_diam+extrude_width*8,resolution);
      }
    }

    for(z=[top,bottom]) {
      translate([wall_thickness*2-tab_depth/2,40/2+z*(20/2)]) {
        rounded_square(tab_depth,v_slot_opening-0.5,rounded_diam);
      }
    }
  }

  module body() {
    translate([-side_connector_length/2,-side_rail_length_rear,0]) {
      translate([0,corner_space/2+psu_support_depth/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=psu_support_depth+corner_space,convexity=3,center=true) {
            // v_slot_profile();
            psu_mount_non_plug_side_frame_profile();
          }
        }
      }
      translate([0,corner_space/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=corner_space,convexity=3,center=true) {
            cap_profile();
          }
        }
      }
    }
  }

  module holes() {
    translate([-side_connector_length/2+screw_pos_x,-side_rail_length_rear,screw_pos_z]) {
      rotate([-90,0,0]) {
        hole(3.2,200,16);

        translate([0,0,50+3]) {
          hole(screw_head_hole_diam,100,16);
        }
      }
    }
  }

  color(printed_color) difference() {
    body();
    holes();
  }
}

module psu_mount_plug_side() {
  overall_height = psu_height + wall_thickness*4 + spacer*2;
  rounded_diam = wall_thickness*2;
  outer_rounded_diam = rounded_diam*2;
  tab_depth = wall_thickness*2+v_slot_cavity_depth-1;
  psu_cap_length = 15 + wall_thickness*2;

  dist_to_psu = side_connector_length/2-psu_pos_x-psu_length/2-spacer*2;

  slot_depth = side_rail_length_rear-0.5;

  between_psu_and_connector = slot_depth-psu_width-spacer;
  plug_body_height = iec_flange_h(IEC_320_C14_switched_fused_inlet);
  plug_body_width = dist_to_psu;

  plug_pos_x = side_connector_length/2-dist_to_psu/2;
  plug_pos_z = iec_flange_h(IEC_320_C14_switched_fused_inlet)/2;

  module position_plug() {
    translate([plug_pos_x,psu_pos_y+psu_width/2+plate_thickness,plug_pos_z]) {
      rotate([-90,0,0]) {
        children();
      }
    }
  }

  module position_screw_hole() {
    for(z=[top,bottom]) {

      translate([psu_pos_x+psu_length/2-32.5,psu_pos_y+psu_width/2+plate_thickness/2,psu_pos_z-z*(psu_height/2-12.5)]) {
        rotate([90,0,0]) {
          children();
        }
      }
    }
  }

  module profile() {
    // v slot tabs
    translate([0,40/2]) {
      for(z=[top,bottom],s=[top,bottom]) {
        translate([-wall_thickness*2+tab_depth/2+0.1,z*(20/2)]) {
          mirror([0,s-1,0]) {
            translate([0,((v_slot_opening-0.2)/2-wall_thickness)]) {
              rounded_square(tab_depth-0.2,wall_thickness*2,rounded_diam);

              % translate([0,0,0]) {
                //debug_axes(0.5);
              }
            }
          }
        }
        /*
        translate([-wall_thickness*2+tab_depth/2,z*(20/2)+s*((v_slot_opening-0.5)/2-wall_thickness)]) {
          rounded_square(tab_depth,wall_thickness*2,rounded_diam);
        }
        */
      }
    }
    translate([-dist_to_psu/2,wall_thickness]) {
      rounded_square(dist_to_psu,wall_thickness*2,rounded_diam);
    }

    translate([0,overall_height/2]) {
      translate([-wall_thickness,0,0]) {
        // slot-side face plate
        rounded_square(wall_thickness*2,overall_height,rounded_diam);
      }

      translate([-dist_to_psu,bottom*(psu_height/2+spacer)]) {
        translate([wall_thickness,0,0]) {
          rounded_square(wall_thickness*2,wall_thickness*4,rounded_diam);
        }

        translate([-psu_cap_length/2+1,bottom*wall_thickness]) {
          rounded_square(psu_cap_length+2,wall_thickness*2,rounded_diam);
        }
      }
    }
  }

  module body() {
    translate([side_connector_length/2,-slot_depth/2+1,0]) {
      rotate([90,0,0]) {
        linear_extrude(height=slot_depth+2.1,convexity=4,center=true) {
          profile();
        }
      }
    }

    // extrusion plate anchor
    translate([side_connector_length/2,0,0]) {
      translate([0,plate_thickness/2,20]) {
        rotate([90,0,0]) {
          rounded_cube(80,40,plate_thickness,rounded_diam,resolution);
        }
      }
    }

    // psu retainers
    for(y=[front,rear]) {
      translate([side_connector_length/2-dist_to_psu+wall_thickness,psu_pos_y+y*psu_width/2,psu_pos_z]) {
        // % debug_axes();
        cube([wall_thickness*2,5,psu_height+1],center=true);
      }
    }

    // plug plate
    hull() {
      translate([side_connector_length/2,0,0]) {
        translate([-dist_to_psu-psu_cap_length/2,plate_thickness/2,wall_thickness]) {
          rotate([90,0,0]) {
            rounded_cube(psu_cap_length,wall_thickness*2,plate_thickness,wall_thickness*2,resolution);
          }
        }
      }
      position_plug() {
        translate([0,0,-plate_thickness/2]) {
          height = iec_flange_h(IEC_320_C14_switched_fused_inlet);
          translate([0,0,-plate_thickness/2+0.1]) {
            rounded_cube(plug_body_width,height,0.2,rounded_diam,resolution);
          }
          translate([0,0,plate_thickness/2-0.1]) {
            rounded_cube(iec_flange_w(IEC_320_C14_switched_fused_inlet),height,0.2,iec_flange_r(IEC_320_C14_switched_fused_inlet)*2,resolution);
          }
          iec_screw_positions(IEC_320_C14_switched_fused_inlet) {
            hole(iec_flange_r(IEC_320_C14_switched_fused_inlet)*2,plate_thickness,resolution);
          }
        }
      }
      position_screw_hole() {
        hole(psu_screw_hole_diam+wall_thickness*4,plate_thickness,resolution);
      }
    }

    // end cap opposite plug
    translate([side_connector_length/2-dist_to_psu/2-psu_cap_length/2,-side_rail_length_rear+between_psu_and_connector/2+0.5,overall_height/2]) {
      rotate([90,0,0]) {
        rounded_cube(dist_to_psu+psu_cap_length-0.01,overall_height-0.01,between_psu_and_connector+0.1,rounded_diam);
      }
    }

    plug_flat_length = iec_depth(IEC_320_C14_switched_fused_inlet)+5-plate_thickness;
    flat_pos_y = front*(plug_flat_length+plug_body_height-overall_height+10);
    translate([side_connector_length/2,0,0]) {
      // flat area
      hull() {
        width = dist_to_psu+psu_cap_length;
        translate([-width/2,0,overall_height-wall_thickness]) {
          translate([0,flat_pos_y,0]) {
            rotate([90,0,0]) {
              rounded_cube(width,wall_thickness*2,0.02,wall_thickness*2);
            }
          }
          translate([0,-slot_depth+between_psu_and_connector,0]) {
            rotate([90,0,0]) {
              rounded_cube(width,wall_thickness*2,0.02,wall_thickness*2);
            }
          }
        }
      }
      // extrusion-side wall
      hull() {
        translate([-wall_thickness,flat_pos_y,overall_height/2]) {
          rotate([90,0,0]) {
            rounded_cube(wall_thickness*2,overall_height,0.02,wall_thickness*2);
          }
        }
        translate([-wall_thickness,-plug_flat_length/2,plug_body_height/2]) {
          rotate([90,0,0]) {
            rounded_cube(wall_thickness*2,plug_body_height,plug_flat_length,wall_thickness*2);
          }
        }
      }
      // top
      translate([-dist_to_psu/2,-plug_flat_length/2,plug_body_height-wall_thickness]) {
        rotate([90,0,0]) {
          rounded_cube(dist_to_psu,wall_thickness*2,plug_flat_length,wall_thickness*2);
        }
      }
      hull() {
        translate([-dist_to_psu/2-psu_cap_length/2,flat_pos_y,overall_height-wall_thickness]) {
          rotate([90,0,0]) {
            rounded_cube(dist_to_psu+psu_cap_length,wall_thickness*2,0.02,wall_thickness*2);
          }
        }
      translate([-dist_to_psu/2,-plug_flat_length,plug_body_height-wall_thickness]) {
        rotate([90,0,0]) {
          rounded_cube(dist_to_psu,wall_thickness*2,0.02,wall_thickness*2);
        }
      }
      }
      // angle over psu
      hull() {
        translate([-dist_to_psu-psu_cap_length+wall_thickness,flat_pos_y,overall_height-wall_thickness]) {
          rotate([90,0,0]) {
            hole(wall_thickness*2,0.02,resolution);
          }
        }
        translate([-dist_to_psu+wall_thickness,-plug_flat_length/2,plug_body_height-wall_thickness]) {
          rotate([90,0,0]) {
            hole(wall_thickness*2,plug_flat_length,resolution);
          }
        }
        translate([-dist_to_psu-psu_cap_length+wall_thickness,-plug_flat_length/2,overall_height-wall_thickness]) {
          rotate([90,0,0]) {
            hole(wall_thickness*2,plug_flat_length,resolution);
          }
        }
      }
    }

    // slot fillers
    for(z=[10,30]) {
      translate([side_connector_length/2+tab_depth-dist_to_psu/2-psu_cap_length/2-tab_depth/2-wall_thickness,-slot_depth-tab_depth/2+0.01,z]) {
        rotate([90,0,0]) {
          rounded_cube(dist_to_psu+tab_depth+psu_cap_length-wall_thickness*2,v_slot_opening-0.2,tab_depth,rounded_diam);
        }
      }
    }
  }

  module holes() {
    translate([side_connector_length/2+40/2,0,40/2]) {
      rotate([90,0,0]) {
        translate([right*20/2,top*20/2,0]) {
          hole(extrusion_screw_hole_diam,plate_thickness*3,16);
        }
        translate([left*20/2,bottom*20/2,0]) {
          hole(extrusion_screw_hole_diam,plate_thickness*3,16);
        }
      }
    }

    position_plug() {
      translate([0,0,-plate_thickness/2]) {
        width = iec_body_w(IEC_320_C14_switched_fused_inlet)+spacer*5;
        height = iec_body_h(IEC_320_C14_switched_fused_inlet)+spacer*5;
        hull() {
          rounded_cube(width,height,plate_thickness+1,rounded_diam,resolution);
          rounded_cube(width-5,height-5,plate_thickness+21,rounded_diam,resolution);
        }
      }

      iec_screw_positions(IEC_320_C14_switched_fused_inlet) {
        hull() {
          hole(m3_thread_into_plastic_hole_diam,(plate_thickness+10)*2,resolution);
        }
      }
    }

    position_screw_hole() {
      hole(psu_screw_hole_diam,plate_thickness*2+1,resolution);
    }

    cable_hole_width = 9;
    cable_hole_height = 5;
    hole_pos_x = [dist_to_psu*0.35,dist_to_psu-wall_thickness*2-cable_hole_width/2];
    // tall cable hole
    translate([side_connector_length/2-hole_pos_x[1],-slot_depth+between_psu_and_connector,overall_height/2]) {
      hole_height = overall_height-wall_thickness*6;
      translate([0,0,0]) {
        cube([cable_hole_width,60,hole_height],center=true);
      }
    }
    for(x=hole_pos_x) {
      translate([side_connector_length/2-x,-slot_depth+between_psu_and_connector,0]) {
        translate([0,0,overall_height/2]) {
          cube([cable_hole_width,extrude_height*4*2,psu_height+spacer*2],center=true);
        }
        translate([0,-between_psu_and_connector,20]) {
          //# cube([cable_hole_width,30,cable_hole_width],center=true);
          cube([cable_hole_width,30,cable_hole_width],center=true);
          for(r=[0,-90]) {
            rotate([0,r,0]) {
              translate([0,-5,20]) {
                cube([cable_hole_width,cable_hole_height*2+10,40],center=true);
              }
            }
          }
        }
        // % debug_axes(3);
      }
    }
  }

  position_plug() {
    //% iec(IEC_320_C14_switched_fused_inlet);
  }

  difference() {
    body();
    holes();
  }
}
