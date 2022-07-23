include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>;
include <./frame-mockup.scad>;

debug = 1;
resolution = 64;

extrude_width = 0.5;
extrude_height = 0.24;
spacer = 0.2;

//x_cable_hole_diam = 17.5;

board_type = BTT_SKR_V1_4_TURBO;
//board_type = BTT_SKR_MINI_E3_V2_0;

zip_tie_width = 3;
base_thickness = zip_tie_width+extrude_height*5*2;
shell_thickness = extrude_width*4;
mount_thickness = extrude_width*4;
mount_screw_diam = 5 + spacer;
mount_screw_head_diam = 8 + spacer;
//mount_width = side_rail_length_rear - (NEMA_width(NEMA17_34) - (40/2 - 20/2)) -4;
mount_width = side_rail_length_rear - 10;
mount_height = 20;
//mount_screw_spacing = mount_width - mount_screw_head_diam - mount_thickness*6;
mount_screw_spacing = 70;

bevel_height = 5;
bevel_screw_hole = m3_thread_into_plastic_hole_diam;
bevel_small_od = bevel_screw_hole + extrude_width*4;
bevel_large_od = bevel_small_od+bevel_height*2;

board_length = pcb_length(board_type);
board_width = pcb_width(board_type);
//board_width = 90.6; // for skr e3 turbo version

//board_angle = -70;
board_angle = -90;

space_above_board = 8; // room for stepper wiring
space_below_board = (bevel_large_od/2-bevel_small_od/2)+10;
space_behind_board = 3/4*inch; // room for input/output power wiring
space_in_front_of_board = spacer*2; // room for input/output power wiring

internal_width = board_length + space_behind_board + space_in_front_of_board;
internal_height = board_width + space_below_board + space_above_board;
internal_depth = bevel_height + 34; // room for control board + steppers + heatsinks

overall_width = internal_width + mount_thickness*2;
overall_height = internal_height + base_thickness;
overall_depth = mount_thickness+internal_depth;

inner_rounded_diam = bevel_height*1.5;
outer_rounded_diam = inner_rounded_diam+mount_thickness*2;

wire_access_hole_width = 30;
wire_access_hole_depth = 15;

usb_hole_width = 14;
usb_hole_height = 13;

sd_hole_width = 16;
sd_hole_height = 4;

main_pos_y = -mount_width+overall_width/2;
board_pos_y = main_pos_y-internal_width/2+board_length/2+space_in_front_of_board;

retention_wing_width = mount_thickness*3;
retention_wing_thickness = extrude_width*2;
retention_cavity_thickness = retention_wing_thickness+spacer*4;
retention_cavity_width = retention_wing_width+spacer*4;
retention_wing_height = mount_thickness + retention_wing_thickness+spacer*2;

retention_locking_luck_gap = overall_height*0.35;

//detent_height = retention_wing_width/2-mount_thickness/2+spacer/2;
detent_height = 5;
detent_length = detent_height*3;
detent_dist_from_opening = 25;

y_hole_bracing_width = overall_width - mount_width - 15;

wiring_exit_hole_diam = 14;
wiring_exit_hole_from_end = wiring_exit_hole_diam/2+20;
wiring_exit_hole_roundness = 0.8;

zip_tie_clearance = extrude_width*4*2;
zip_tie_inner_diam = wiring_exit_hole_diam+zip_tie_clearance;
zip_tie_outer_diam = zip_tie_inner_diam+4;

z_motor_clearance = 3;

extrusion_brace_width = 45+mount_thickness*2;
extrusion_bridge_width = 18;
extrusion_brace_depth = 40-mount_thickness/2+z_motor_clearance;
//extrusion_brace_thickness = 4;
extrusion_brace_thickness = extrude_height*10;

module zip_tie_anchor(zip_tie_width=5,zip_tie_thickness=2) {
  module gusset(width,height,thickness,rounded_diam) {
    hull() {
      translate([-width/2,0,0.001]) {
        rounded_cube(width,thickness,0.002,rounded_diam,resolution);
      }
      translate([0,0,height/2]) {
        rounded_cube(rounded_diam,thickness,height,rounded_diam,resolution);
      }
    }
  }

  thickness = extrude_width*2;
  anchor_thickness = 2;
  reach = zip_tie_thickness+thickness*1.5;
  module body() {

    translate([zip_tie_thickness+thickness/2,0,0]) {
      rounded_cube(thickness,zip_tie_width+thickness*2,anchor_thickness,thickness,resolution);
    }
    for(y=[front,rear]) {
      translate([-thickness/2,y*(zip_tie_width/2+thickness/2),anchor_thickness/2]) {
        rotate([0,0,180]) {
          gusset(reach,reach,thickness,thickness);
        }
        translate([reach/2,0,-anchor_thickness/2]) {
          rounded_cube(reach,thickness,anchor_thickness,thickness,resolution);
        }
      }
    }
  }

  module holes() {
    translate([-thickness,0,0]) {
      cube([thickness,zip_tie_width+thickness*3,(anchor_thickness+reach)*2+1],center=true);
    }
  }

  difference() {
    body();
    holes();
  }
}

module position_buck_converter() {
  area_width = overall_width - mount_width - 12;
  translate([-mount_thickness-bevel_height,area_width/2,bevel_height*2+buck_conv_length/2]) {
    rotate([0,-90,0]) {
      rotate([0,0,90]) {
        // children();
      }
    }
  }
}

module position_rpi() {
  translate([-mount_thickness-bevel_height,-mount_width/2,overall_height-pcb_length(RPI3)/2-bevel_height]) {
    rotate([0,-90,0]) {
      rotate([0,0,180]) {
        // children();
      }
    }
  }
}

module position_board() {
  translate([-z_motor_clearance,board_pos_y,0]) {
    rotate([0,board_angle,0]) {
      translate([board_width/2+space_below_board,0,bevel_height+mount_thickness]) {
        rotate([0,0,-90]) {
          children();
        }
      }
    }
  }
}

module old_position_board() {
  translate([bevel_height,-mount_width+overall_width/2-internal_width/2+board_length/2,space_below_board+board_width/2]) {
    rotate([0,-90,0]) {
      rotate([0,0,-90]) {
        children();
      }
    }
  }
}

module position_rpi_holes() {
  pcb_hole_positions(RPI3) {
    children();
  }
}

module position_board_holes() {
  pcb_hole_positions(board_type) {
    children();
  }
}

module position_top() {
  translate([-z_motor_clearance,0,0]) {
    rotate([0,board_angle+90,0]) {
      translate([0,main_pos_y,overall_height]) {
        children();
      }
    }
  }
  /*
  position_board() {
    translate([0,-board_width/2-space_above_board+overall_height,-bevel_height-mount_thickness]) {
      rotate([-90,0,0]) {
        rotate([0,0,90]) {
          children();
        }
      }
    }
  }
  */
}

module new_vertical_electronics_mount() {

  module position_elbow_joint() {
    translate([-z_motor_clearance,main_pos_y,0]) {
      rotate([0,board_angle+90,0]) {
        rotate([0,0,0]) {
          children();
        }
      }
    }
  }

  module position_bottom() {
    translate([-z_motor_clearance,main_pos_y,-20]) {
      rotate([0,board_angle+90,0]) {
        rotate([0,0,0]) {
          children();
        }
      }
    }
  }

  module body() {
    // wire access holes for extruder / x axis
    position_wire_access_hole() {
      translate([0,0,-base_thickness]) {
        rounded_cube(wire_access_hole_width+mount_thickness*2,wire_access_hole_depth+mount_thickness*2,base_thickness*2,mount_thickness*3,resolution);
      }
    }
    // main back
    position_top() {
      translate([-overall_depth/2,0,-base_thickness/2]) {
        rounded_cube(overall_depth,overall_width,base_thickness,mount_thickness,resolution);
      }
      translate([-mount_thickness/2,0,-overall_height/2]) {
        rounded_cube(mount_thickness,overall_width,overall_height,mount_thickness,resolution);
      }

      // detent
      //for(y=[front,rear]) {
      for(y=[rear]) {
        translate([-overall_depth-retention_wing_height+detent_dist_from_opening,0,-detent_length/2]) {
          mirror([0,0,0]) {
            translate([0,overall_width/2,0]) {
              for(z=[top,bottom]) {
                mirror([0,0,z-1]) {
                  hull() {
                    translate([0,-mount_thickness/2,extrude_height]) {
                      rounded_cube(mount_thickness,mount_thickness,extrude_height,mount_thickness,resolution);
                    }
                    translate([0,-mount_thickness/2,detent_length/2-extrude_height/2]) {
                      rounded_cube(mount_thickness+detent_height*2,mount_thickness,extrude_height,mount_thickness,resolution);

                      translate([0,detent_height/2,0]) {
                        rounded_cube(mount_thickness,mount_thickness+detent_height,extrude_height,mount_thickness,resolution);
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
    // bottom mount face
    hull() {
      position_elbow_joint() {
        translate([-mount_thickness/2,0,0]) {
          rounded_cube(mount_thickness,overall_width,extrude_height,mount_thickness,resolution);
        }
      }
      position_bottom() {
        translate([-mount_thickness/2,0,0]) {
          rounded_cube(mount_thickness,overall_width,extrude_height,mount_thickness,resolution);
        }
      }
    }
    // close the z_motor_clearance between the mount and the extrusion
    translate([0,-mount_width+overall_width/2,-mount_height/2]) {
      hull() {
        translate([-z_motor_clearance-mount_thickness/2,0,0]) {
          rounded_cube(mount_thickness,overall_width,mount_height,mount_thickness,resolution);
        }
        translate([-mount_thickness/2,0,0]) {
          rounded_cube(mount_thickness,overall_width,mount_height-z_motor_clearance*2,mount_thickness,resolution);
        }
      }
    }
    
    // sides
    for(y=[front,rear]) {
      translate([0,y*(overall_width/2-mount_thickness/2),0]) {
        position_top() {
          translate([-overall_depth/2,0,-overall_height/2]) {
            rounded_cube(overall_depth,mount_thickness,overall_height,mount_thickness,resolution);
          }
          translate([-overall_depth,0,-overall_height/2]) {
            rounded_cube(retention_wing_height*2,mount_thickness,overall_height,retention_wing_thickness,resolution);

            translate([-retention_wing_height+retention_wing_thickness/2,0,0]) {
              difference() {
                rounded_cube(retention_wing_thickness,retention_wing_width,overall_height,retention_wing_thickness,resolution);
                for(y=[front,rear]) {
                  translate([0,y*(retention_wing_width/2+mount_thickness/2),0]) {
                    hull() {
                      cube([retention_wing_thickness*2,retention_wing_width,retention_locking_luck_gap],center=true);
                      cube([retention_wing_thickness*2,mount_thickness,retention_locking_luck_gap+retention_wing_width],center=true);
                    }
                  }
                }
              }
            }
          }
        }
        hull() {
          position_elbow_joint() {
            translate([-overall_depth/2,0,0]) {
              rounded_cube(overall_depth,mount_thickness,extrude_height,mount_thickness,resolution);
            }
          }
          position_bottom() {
            translate([-mount_thickness/2,0,0]) {
              rounded_cube(mount_thickness,mount_thickness,extrude_height,mount_thickness,resolution);
            }
          }
        }
      }
    }

    // bracing around hole to Y axis
    /*
    for(y=[0,-1*y_hole_bracing_width]) {
      translate([0,overall_width/2-mount_thickness/2+y,0]) {
        hull() {
          position_elbow_joint() {
            vertical_height = 50;
            translate([-mount_thickness/2,0,vertical_height/2]) {
              hole(mount_thickness,vertical_height,resolution);
            }
          }
          position_bottom() {
            translate([-mount_thickness/2,0,0]) {
              rounded_cube(mount_thickness,mount_thickness,extrude_height,mount_thickness,resolution);
            }
          }
        }
      }
    }
    */

    // bracing to extrusion // FIXME make a bit nicer and make bridges less wide
    translate([-z_motor_clearance,-mount_width+overall_width/2,0]) {
      vertical_height = overall_height*0.75;
      bridge_width = mount_thickness;
      bridge_thickness = extrusion_brace_thickness;
      hull() {
        translate([extrusion_brace_depth-mount_thickness/2,0,0]) {
          rotate([0,board_angle+90,0]) {
            translate([-bridge_width/2,0,bridge_thickness/2]) {
              rounded_cube(bridge_width,extrusion_brace_width,bridge_thickness,mount_thickness,resolution);
            }
          }
        }
        translate([bridge_width,0,0]) {
          rotate([0,board_angle+90,0]) {
            translate([-bridge_width/2,0,bridge_thickness/2]) {
              rounded_cube(bridge_width,extrusion_brace_width,bridge_thickness,mount_thickness,resolution);
            }
          }
        }
        translate([0,0,extrude_height/2]) {
          cube([mount_thickness/2,extrusion_brace_width-mount_thickness,extrude_height],center=true);
        }
      }
      full_spacing = extrusion_brace_width/2-mount_thickness/2;
      inner_spacing = extrusion_bridge_width/2+mount_thickness/2;
      rib_y_positions = [
        front*full_spacing,
        rear*full_spacing,
        front*inner_spacing,
        rear*inner_spacing,
      ];
      for(y=rib_y_positions) {
        translate([0,y,0]) {
          hull() {
            rotate([0,board_angle+90,0]) {
              rotate([0,0,0]) {
                translate([-mount_thickness/2,0,vertical_height/2]) {
                  hole(mount_thickness,vertical_height,resolution);
                }
              }
            }
            translate([extrusion_brace_depth-mount_thickness/2,0,0]) {
              rotate([0,board_angle+90,0]) {
                translate([-mount_thickness/2,0,bridge_thickness/2]) {
                  hole(mount_thickness,bridge_thickness,resolution);
                }
              }
            }
          }
        }
      }
    }

    position_board() {
      intersection() {
        union() {
          position_board_holes() {
            bevel(bevel_large_od,bevel_small_od,bevel_height);
          }
        }
        translate([board_length/2-internal_width/2,0,0]) {
          cube([internal_width+mount_thickness,overall_height*2,overall_depth*2],center=true);
        }
      }
    }

    // backside zip tie anchors
    backside_zip_tie_anchor_locations = [
      [-z_motor_clearance,-mount_width+overall_width*0.8,overall_height-20],
      [-z_motor_clearance,-mount_width+overall_width*0.8,overall_height-60],
      [-z_motor_clearance,-mount_width+overall_width*0.8,overall_height-100],
      [-z_motor_clearance,-mount_width+overall_width/2,overall_height-20],
      [-z_motor_clearance,-mount_width+overall_width*0.2,overall_height-20],
      [-z_motor_clearance,-mount_width+overall_width*0.2,overall_height-60],
    ];

    for(loc=backside_zip_tie_anchor_locations) {
      translate(loc) {
        zip_tie_anchor();
      }
    }

    // inside zip tie anchors
    inside_zip_tie_anchor_locations = [
      [-z_motor_clearance-mount_thickness,-mount_width+overall_width-mount_thickness-space_behind_board*0.4,73],
      [-z_motor_clearance-mount_thickness,-mount_width+overall_width-mount_thickness-space_behind_board*0.4,40],
      [-z_motor_clearance-mount_thickness,-mount_width+overall_width-mount_thickness-space_behind_board*0.4,1],
      [-z_motor_clearance-mount_thickness,-mount_width+overall_width*0.2,1],
      [-z_motor_clearance-mount_thickness,-mount_width+overall_width*0.5,1],
    ];

    for(loc=inside_zip_tie_anchor_locations) {
      translate(loc) {
        rotate([0,0,180]) {
          zip_tie_anchor();
        }
      }
    }

    // inside wall zip tie anchors
    inside_back_wall_zip_tie_anchor_locations = [
      [-z_motor_clearance-overall_depth*0.6,-mount_width+overall_width-mount_thickness,60],
      [-z_motor_clearance-overall_depth*0.6,-mount_width+overall_width-mount_thickness,20],
    ];

    for(loc=inside_back_wall_zip_tie_anchor_locations) {
      translate(loc) {
        rotate([0,0,-90]) {
          zip_tie_anchor();
        }
      }
    }

    // inside wall zip tie anchors
    inside_front_wall_zip_tie_anchor_locations = [
      [-z_motor_clearance-((overall_depth-bevel_height)*0.8),-mount_width+mount_thickness,60],
      [-z_motor_clearance-((overall_depth-bevel_height)*0.8),-mount_width+mount_thickness,20],
    ];

    for(loc=inside_front_wall_zip_tie_anchor_locations) {
      translate(loc) {
        rotate([0,0,90]) {
          zip_tie_anchor();
        }
      }
    }
  }

  module holes() {
    for(y=[front,0,rear],z=[top,bottom]) {
      translate([0,-mount_width/2+y*mount_screw_spacing/2,-20+z*10]) {
        rotate([0,90,0]) {
          hole(mount_screw_diam,20,resolution);
        }
      }
    }

    position_board() {
      position_board_holes() {
        hole(m3_thread_into_plastic_hole_diam,2*(bevel_height-0.1),resolution);
      }

      translate([-board_length/2-space_behind_board*0.6,-31,-bevel_height]) {
        rounded_cube(space_behind_board/2,space_behind_board*0.8,mount_thickness*4,mount_thickness,8);
      }
    }

    position_rpi() {
      position_rpi_holes() {
        hole(1.9,2*(bevel_height-0.1),resolution);
      }
    }

    position_buck_converter() {
      position_buck_converter_holes() {
        hole(1.9,2*(bevel_height-0.1),resolution);
      }
    }

    position_top() {
      translate([-overall_depth,-internal_width/2+wiring_exit_hole_from_end,-base_thickness/2]) {
        scale([1,wiring_exit_hole_roundness,]) {
          cube([zip_tie_clearance*2,zip_tie_outer_diam,base_thickness*3],center=true);
          translate([zip_tie_clearance,0,0]) {
            hole(wiring_exit_hole_diam,base_thickness*3,resolution);

            difference() {
              hole(zip_tie_outer_diam,zip_tie_width,resolution);
              hole(zip_tie_inner_diam,zip_tie_width+1,resolution);
            }
          }
        }
      }
    }

    // vent holes and wiring hole zip tie loop
    vent_hole_count_x = 5;
    vent_hole_count_y = 6;
    vent_hole_length = (internal_width-(vent_hole_count_y-1)*(mount_thickness))/(vent_hole_count_y);
    vent_hole_width = (overall_depth-(vent_hole_count_x+1)*(mount_thickness))/(vent_hole_count_x);
    vent_hole_y_spacing = vent_hole_length + mount_thickness;
    vent_hole_x_spacing = vent_hole_width + mount_thickness;
    position_top() {
      difference() {
        union() {
          translate([-mount_thickness-vent_hole_width/2,-internal_width/2+vent_hole_length/2,0]) {
            for(x=[0:vent_hole_count_x-1],y=[0:vent_hole_count_y-1]) {
              translate([-vent_hole_x_spacing*x,vent_hole_y_spacing*y,0]) {
                rounded_cube(vent_hole_width,vent_hole_length,base_thickness*2+0.1,0.1,resolution);
              }
            }
          }
        }
        hull() {
          translate([-overall_depth,-internal_width/2+wiring_exit_hole_from_end,-base_thickness/2]) {
            cube([zip_tie_clearance*2,zip_tie_outer_diam+mount_thickness*2,base_thickness*3],center=true);
            translate([zip_tie_clearance,0,0]) {
              hole(zip_tie_outer_diam+mount_thickness*2,base_thickness*3,resolution);
            }
          }
        }
      }
    }

    /*
    position_top() {
      // access holes for display cables
      translate([-bevel_height-20,-overall_width/2,-overall_height+space_below_board+40]) {
        cable_hole_height = 10;
        cable_hole_width = 36;
        cube([cable_hole_height,5,cable_hole_width],center=true);
      }
    }
    */

    /*
    // hole for y axis items
    translate([0,-mount_width+overall_width-y_hole_bracing_width/2,-40/2]) {
      rotate([0,90,0]) {
        rounded_cube(25,y_hole_bracing_width*0.75,overall_height*20,15,8);
      }
    }
    */

    translate([0,-mount_width+overall_width/2,0]) {
      for(x=[left,right]) {
        translate([20+x*10,0,extrusion_brace_thickness]) {
          rotate([0,0,90]) {
            supportless_hole(5.2,extrusion_bridge_width,extrusion_brace_depth,extrude_height,resolution);
          }
        }
      }
    }

    // clear out the z_motor_clearance between the mount and the extrusion
    translate([-mount_thickness,-mount_width+overall_width/2,-mount_height/2]) {
      hull() {
        translate([-z_motor_clearance-mount_thickness/2,0,0]) {
          cube([mount_thickness,internal_width,mount_height],center=true);
        }
        translate([-mount_thickness/2,0,0]) {
          cube([mount_thickness,internal_width,mount_height-z_motor_clearance*2],center=true);
        }
      }
    }

    z_stepper_hole_width = 8;
    z_stepper_hole_height = 16;
    translate([-z_motor_clearance,-mount_width+overall_width-mount_thickness-space_behind_board/2,overall_height-base_thickness-4-z_stepper_hole_height/2]) {
      rotate([0,90,0]) {
        rounded_cube(z_stepper_hole_height,z_stepper_hole_width,mount_thickness*4,z_stepper_hole_width*0.3,8);
      }
    }
  }

  if (debug) {
    % position_board() {
      pcb(board_type);
    }
    % position_rpi() {
      pcb(RPI3);
    }
    % position_buck_converter() {
      buck_converter();
    }
  }

  module position_wire_access_hole() {
    position_board() {
      translate([0,rear*(board_width/2+space_above_board+base_thickness),overall_depth-wire_access_hole_depth/2]) {
        translate([board_length/2-wire_access_hole_width/2,0,0]) {
          rotate([-90,0,0]) {
            // children();
          }
        }
      }
    }
  }

  module bridges() {
    // inside zip tie anchors
    inside_zip_tie_anchor_locations = [
      [-mount_thickness,-mount_width/2-mount_screw_spacing*0.7,-15],
      [-mount_thickness,-mount_width/2-mount_screw_spacing*0.25,-15],
      [-mount_thickness,-mount_width/2+mount_screw_spacing*0.25,-15],
      [-mount_thickness,-mount_width/2+mount_screw_spacing*0.75,-15],
    ];

    for(loc=inside_zip_tie_anchor_locations) {
      translate(loc) {
        rotate([0,0,180]) {
          zip_tie_anchor();
        }
      }
    }
    
  }

  difference() {
    body();
    holes();
  }
  bridges();
}

module old_new_vertical_electronics_lid() {
  wall_spacing = overall_width - mount_thickness;
  cavity_height = overall_height;
  thickness = extrude_width*2;
  end_cap_thickness = 0;

  od = retention_cavity_thickness + thickness*2;
  width = retention_cavity_width + thickness*2;
  mount_clearance = mount_thickness + spacer*2;

  arm_pos_y = wall_spacing/2+mount_thickness/2+detent_height+thickness/2;

  module body_profile() {
    for(y=[front,rear]) {
      translate([0,y*wall_spacing/2,0]) {
        translate([retention_wing_thickness/2,0,0]) {
          rounded_square(od,width,od,resolution);
        }
      }
    }

    translate([retention_wing_thickness/2,0,0]) {
      width = wall_spacing - retention_cavity_width - thickness;
      
      square([thickness,width],center=true);
    }
  }

  module hole_profile() {
    for(y=[front,rear]) {
      translate([0,y*wall_spacing/2,0]) {
        translate([retention_wing_thickness/2,0,0]) {
          rounded_square(retention_cavity_thickness,retention_cavity_width,retention_cavity_thickness,resolution);

          translate([20,0,0]) {
            square([40,mount_clearance],center=true);
          }
          translate([retention_cavity_thickness/2+thickness/2,0,0]) {
            for(x=[left,right],y=[front,rear]) {
              mirror([x-1,0,0]) {
                mirror([0,y-1,0]) {
                  translate([-thickness/2,mount_clearance/2,0]) {
                    round_corner_filler_profile(thickness,resolution);
                    
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  module body() {
    translate([0,0,-overall_height/2+end_cap_thickness]) {
      linear_extrude(height=cavity_height+end_cap_thickness,center=true,convexity=3) {
        body_profile();
      }
    }
    brace_height = 5;
    brace_thickness = thickness*3;
    for(z=[top,bottom]) {
      translate([0,0,-overall_height/2]) {
        mirror([0,0,z-1]) {
          translate([0,0,overall_height/2]) {
            hull() {
              translate([retention_wing_thickness/2,0,-brace_height/2]) {
                cube([brace_thickness,overall_width,brace_height],center=true);
              }
              translate([retention_wing_thickness/2,0,-brace_height-brace_thickness/2]) {
                cube([thickness,overall_width,brace_thickness],center=true);
              }
            }
          }
        }
      }
    }

    bridges();
  }

  module holes() {
    translate([0,0,-overall_height/2]) {
      linear_extrude(height=cavity_height*2,center=true,convexity=3) {
        hole_profile();
      }
      for(y=[front,rear]) {
        translate([retention_wing_height/2,y*wall_spacing/2,0]) {
          hull() {
            cube([thickness*2,retention_cavity_width,retention_locking_luck_gap],center=true);
            cube([thickness*2,retention_cavity_thickness,retention_locking_luck_gap+retention_cavity_width],center=true);
          }
        }
      }
    }
  }

  module bridges() {
    extra_length_for_handle = 10;
    max_height = detent_dist_from_opening+detent_length;
    arm_od = detent_height*2+thickness;
    arm_id = arm_od - thickness*2;

    translate([0,arm_pos_y-detent_height,-max_height/2]) {
      translate([arm_od/2,0,0]) {
        difference() {
          intersection() {
            hole(arm_od,max_height,resolution);
            translate([-arm_od/2,arm_od/2,0]) {
              cube([arm_od,arm_od,max_height*2],center=true);
            }
          }
          hole(arm_id,max_height+1,resolution);
        }
      }
    }
    translate([0,arm_pos_y,-detent_length/2]) {
      hull() {
        translate([arm_od/2,0,-detent_dist_from_opening/2]) {
          hole(thickness,max_height,resolution);
        }

        translate([detent_dist_from_opening+extra_length_for_handle,0,0]) {
          rounded_cube(detent_length/2,thickness,detent_length,thickness,resolution);
        }
      }

      hull() {
        translate([detent_dist_from_opening,0,0]) {
          rounded_cube(detent_length/2,thickness,detent_length,thickness,resolution);

          translate([0,-thickness/2-detent_height/2,0]) {
            rounded_cube(detent_length/2,detent_height,extrude_height,thickness,resolution);
          }
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
  //bridges();
}

module new_vertical_electronics_lid() {
  lid_onion_skin = extrude_height*3;
  lid_thickness = extrude_height*10;
  retention_width = retention_cavity_width + mount_thickness*2;
  retention_height = lid_thickness+retention_cavity_thickness/2+retention_wing_thickness/2 + 1.4;
  retention_length = overall_height*0.3;
  wall_spacing = overall_width - mount_thickness;
  cavity_height = overall_height;
  thickness = extrude_width*2;
  end_cap_thickness = 0;

  od = retention_cavity_thickness + thickness*2;
  retainer_width = retention_cavity_width + mount_thickness*2;
  mount_clearance = mount_thickness + spacer*2;

  arm_pos_y = wall_spacing/2+mount_thickness/2+detent_height+thickness/2;

  lid_width = wall_spacing + retainer_width;

  module position_wiring_exit_hole() {
    translate([-lid_thickness,-internal_width/2+wiring_exit_hole_from_end,0]) {
      children();
    }
  }

  module hole_profile() {
    for(y=[front,rear]) {
      translate([0,y*wall_spacing/2,0]) {
        translate([retention_wing_thickness/2,0,0]) {
          hull() {
            rounded_square(retention_cavity_thickness,retention_cavity_width,retention_cavity_thickness,resolution);
            /*
            translate([retention_wing_thickness/4,0,0]) {
              square([retention_wing_thickness/2,retention_cavity_width],center=true);
            }
            translate([-retention_cavity_thickness/4,0,0]) {
              # square([retention_cavity_thickness/2,retention_cavity_width],center=true);
            }
            */
            translate([retention_height/4,0,0]) {
              square([retention_height/2,mount_clearance],center=true);
            }
          }
          translate([retention_cavity_thickness/2+thickness/2,0,0]) {
            for(x=[left,right],y=[front,rear]) {
              mirror([x-1,0,0]) {
                mirror([0,y-1,0]) {
                  translate([-thickness/2,mount_clearance/2,0]) {
                    //round_corner_filler_profile(thickness,resolution);
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  module body() {
    translate([-lid_thickness,0,-overall_height/2]) {
      translate([lid_onion_skin/2,0,0]) {
        rotate([0,90,0]) {
          rounded_cube(overall_height,lid_width,lid_onion_skin,thickness,resolution);
        }
      }
      for(y=[left,right]) {
        translate([retention_height/2,y*wall_spacing/2,0]) {
          rotate([0,90,0]) {
            rounded_cube(overall_height,retention_width,retention_height,thickness,resolution);
          }
        }
      }
      rib_coords = [
        // top rim
        [
          [0,front*(lid_width/2-thickness/2),top*(overall_height/2-thickness/2)],
          [0,rear*(lid_width/2-thickness/2),top*(overall_height/2-thickness/2)],
          lid_thickness,
          thickness,
        ],
        // bottom rim
        [
          [0,front*(lid_width/2-thickness/2),bottom*(overall_height/2-thickness/2)],
          [0,rear*(lid_width/2-thickness/2),bottom*(overall_height/2-thickness/2)],
          retention_height,
          thickness,
        ],
        // diagonal
        [
          [0,front*(lid_width/2-thickness/2),bottom*(overall_height/2-thickness/2)],
          [0,rear*(lid_width/2-thickness/2),top*(overall_height/2-thickness/2)],
          lid_thickness,
          thickness,
        ],
        // diagonal
        [
          [0,front*(lid_width/2-thickness/2),top*(overall_height/2-thickness/2)],
          [0,rear*(lid_width/2-thickness/2),bottom*(overall_height/2-thickness/2)],
          lid_thickness,
          thickness,
        ],
        // middle horizontal
        [
          [0,front*(lid_width/2-thickness/2),0],
          [0,rear*(lid_width/2-thickness/2),0],
          retention_height,
          thickness,
        ],
        // middle vertical
        [
          [0,0,top*(overall_height/2-thickness/2)],
          [0,0,bottom*(overall_height/2-thickness/2)],
          lid_thickness,
          thickness,
        ],
      ];
      for(coord=rib_coords) {
        from = coord[0];
        to = coord[1];
        height = coord[2];
        thickness = coord[3];

        translate([height/2,0,0]) {
          hull() {
            translate(from) {
              rotate([0,90,0]) {
                hole(thickness,height,resolution);
              }
            }
            translate(to) {
              rotate([0,90,0]) {
                hole(thickness,height,resolution);
              }
            }
          }
        }
      }
      /*
      for(y=[left,right]) {
        translate([-lid_thickness/2+retention_height/2,y*wall_spacing/2,0]) {
          for(i=[left,right]) {
            translate([0,i*(retention_width/2-mount_thickness/2),0]) {
              cube([retention_height,mount_thickness,overall_height*0.9],center=true);
            }
          }
        }
        for(z=[top,bottom]) {
          mirror([0,0,z-1]) {
            translate([-lid_thickness/2+retention_height/2,y*wall_spacing/2,overall_height/2-retention_length/2]) {
              rotate([0,90,0]) {
                rounded_cube(retention_length,retention_width,retention_height,mount_thickness,resolution);
              }
            }
          }
        }
      }
      */
    }

    translate([0,wall_spacing/2+mount_thickness/2,-detent_length/2]) {
      base_width = detent_height+mount_thickness;
      translate([-lid_thickness+retention_height/2,base_width/2,0]) {
        rotate([0,90,0]) {
          rounded_cube(detent_length,base_width,retention_height,mount_thickness,resolution);
        }
      }

      extra_length_for_handle = 10;
      length = extra_length_for_handle + detent_dist_from_opening;
      less_height = detent_height*2;
      more_height = less_height + detent_height*2;
      for(s=[left,right]) {
        mirror([0,0,s-1]) {
          hull() {
            translate([detent_dist_from_opening,mount_thickness/2,0]) {
              rotate([0,90,0]) {
                hole(mount_thickness,less_height,resolution);
              }
            }
            translate([detent_dist_from_opening,base_width-mount_thickness/2,detent_length/2-mount_thickness/2]) {
              rotate([0,90,0]) {
                hole(mount_thickness,more_height,resolution);
              }
            }
          }
        }
      }
      for(s=[left,right]) {
        translate([detent_dist_from_opening,0,0]) {
          mirror([s-1,0,0]) {
            hull() {
              translate([-less_height/2+0.01,mount_thickness/2,0]) {
                rotate([0,90,0]) {
                  hole(mount_thickness,0.02,resolution);
                }
              }
              translate([-more_height/2+0.01,base_width-mount_thickness/2,0]) {
                rotate([0,90,0]) {
                  rounded_cube(detent_length,mount_thickness,0.02,mount_thickness,resolution);
                }
              }
            }
          }
        }
      }
      filler_height = detent_dist_from_opening-more_height/2;
      translate([detent_dist_from_opening-more_height/2-filler_height/2,base_width-mount_thickness/2,0]) {
        rotate([0,90,0]) {
          rounded_cube(detent_length,mount_thickness,filler_height,mount_thickness,resolution);
        }
      }
      translate([detent_dist_from_opening+more_height/2+extra_length_for_handle/2,base_width-mount_thickness/2,0]) {
        rotate([0,90,0]) {
          // rounded_cube(detent_length,mount_thickness,extra_length_for_handle,mount_thickness,resolution);
        }
      }
      /*
      translate([length/2,base_width-mount_thickness/2,0]) {
        rotate([0,90,0]) {
          rounded_cube(detent_length,mount_thickness,length,mount_thickness,resolution);
        }
      }
      hull() {
        less_height = detent_height*2;
        more_height = less_height + detent_height*1.5;
        translate([detent_dist_from_opening,mount_thickness/2,0]) {
          rotate([0,90,0]) {
            hole(mount_thickness,less_height,resolution);
          }
        }
        translate([detent_dist_from_opening+less_height/2-more_height/2,base_width-mount_thickness/2,0]) {
          rotate([0,90,0]) {
            hole(mount_thickness,more_height,resolution);
          }
        }
      }
      */
    }

    position_wiring_exit_hole() {
      translate([lid_thickness/2,0,-base_thickness/2-thickness/2]) {
        cube([lid_thickness,zip_tie_outer_diam+thickness*2,base_thickness+thickness],center=true);
      }
    }
  }

  module holes() {
    translate([0,0,-overall_height/2]) {
      linear_extrude(height=cavity_height*2,center=true,convexity=3) {
        hole_profile();
      }

      for(y=[front,rear]) {
        translate([retention_wing_thickness/2,y*(wall_spacing/2),0]) {
          translate([10,0,0]) {
            cube([20,retention_cavity_width,overall_height*0.4],center=true);
          }
        }
      }
    }

    position_wiring_exit_hole() {
      cube([overall_depth,zip_tie_outer_diam,base_thickness*2],center=true);
    }
  }

  difference() {
    body();
    holes();
  }
}

module old_vertical_electronics_mount() {
  module body() {
    translate([-mount_thickness/2,0,0]) {
      translate([0,-mount_width/2,-40+overall_height/2]) {
        // attach to extrusion
        rounded_cube(mount_thickness,mount_width,overall_height,mount_thickness,resolution);
      }

      translate([-mount_thickness/2+overall_depth/2,-mount_width+overall_width/2,overall_height-base_thickness/2]) {
        rounded_cube(overall_depth,overall_width,base_thickness,mount_thickness,resolution);
      }

      connector_lip_depth = mount_thickness/2+bevel_height+pcb_thickness(board_type)+5;
      front_faces = [ // lowest to highest
        [0,space_below_board+20,inner_rounded_diam], // below display connectors
        [space_below_board,space_below_board+board_width/2-15,overall_depth], // below display connectors
        [space_below_board+4,overall_height,connector_lip_depth], // lip to cover board near display connectors
        [space_below_board+board_width/2+21,overall_height,overall_depth], // above display connectors
      ];
      for(panel=front_faces) {
        height = panel[1] - panel[0];
        pos_z = panel[0] + height/2;
        depth = panel[2];

        // front
        translate([-mount_thickness/2,-mount_width+mount_thickness/2,pos_z]) {
          translate([depth/2,0,0]) {
            rounded_cube(depth,mount_thickness,height,mount_thickness,resolution);
          }
          translate([mount_thickness,mount_thickness/2,0]) {
            round_corner_filler(inner_rounded_diam,height);
          }
        }
      }

      translate([0,-mount_width+overall_width/2,overall_height/2]) {
        rounded_cube(mount_thickness,overall_width,overall_height,mount_thickness,resolution);

        // front
        translate([-mount_thickness/2,front*(overall_width/2-mount_thickness/2),0]) {
          column_width = 15;
          translate([overall_depth-column_width/2,0,0]) {
            rounded_cube(column_width,mount_thickness,overall_height,mount_thickness,resolution);
          }
          connector_lip_depth = mount_thickness+bevel_height+pcb_thickness(board_type)+8;
          translate([connector_lip_depth/2,0,0]) {
            // rounded_cube(connector_lip_depth,mount_thickness,overall_height,mount_thickness,resolution);
          }
        }
        translate([mount_thickness/2,internal_width/2,0]) {
          rotate([0,0,-90]) {
            round_corner_filler(inner_rounded_diam,overall_height);
          }
        }
      }

      // rear
      translate([0,-mount_width+overall_width-mount_thickness/2,overall_height]) {
        hull() {
          greater_height_depth = mount_thickness+bevel_height;
          translate([-mount_thickness/2+greater_height_depth/2,0,-overall_height/2]) {
            rounded_cube(greater_height_depth,mount_thickness,overall_height,mount_thickness,resolution);
          }
          lesser_height = overall_height-(overall_depth-greater_height_depth);
          translate([overall_depth-mount_thickness,0,-lesser_height/2]) {
            hole(mount_thickness,lesser_height,resolution);
          }
        }
      }
    }

    // inside stiffening ribs
    rib_depth = bevel_height-2; // let pins/uSD on the bottom of the PCBs clear the ribs
    union() {
      rib_space = internal_width-bevel_large_od*3;
      rib_count = 5;
      rib_spacing = rib_space/(rib_count-1);
      rib_height = overall_height-base_thickness;
      for(i=[0:(rib_count-1)]) {
        translate([-mount_thickness/2,-mount_width+overall_width/2-rib_space/2+rib_spacing*i,rib_height/2]) {
          hull() {
            translate([rib_depth/2+mount_thickness/2,0,0]) {
              rounded_cube(rib_depth,mount_thickness,rib_height-rib_depth*4,mount_thickness,resolution);
            }
            hole(mount_thickness,rib_height,resolution);
          }
        }
      }
    }

    // outside stiffening ribs
    union() {
      rib_space = mount_screw_spacing - mount_screw_head_diam - 3 - mount_thickness;
      rib_count = 5;
      rib_spacing = rib_space/(rib_count-1);
      rib_height = 40 + overall_height;
      for(i=[0:(rib_count-1)]) {
        translate([-mount_thickness/2,-mount_width/2-rib_space/2+rib_spacing*i,-40+rib_height/2]) {
          hull() {
            translate([-rib_depth/2-mount_thickness/2,0,0]) {
              rounded_cube(rib_depth,mount_thickness,rib_height-rib_depth*4,mount_thickness,resolution);
            }
            hole(mount_thickness,rib_height,resolution);
          }
        }
      }
    }

    // anchor to top of extrusion
    top_anchor_width = 20;
    top_anchor_depth = mount_screw_head_diam+spacer*4;
    top_anchor_height = top_anchor_depth*2+base_thickness;
    translate([overall_depth-top_anchor_width/2-mount_thickness,-mount_width,0]) {
      translate([0,mount_thickness/2,top_anchor_height/2]) {
        rounded_cube(top_anchor_width,mount_thickness,top_anchor_height,mount_thickness,resolution);
      }
      for(x=[left,right]) {
        hull() {
          translate([x*(top_anchor_width/2-mount_thickness/2),0,0]) {
            translate([0,mount_thickness/2,top_anchor_height/2]) {
              hole(mount_thickness,top_anchor_height,resolution);
            }
            translate([0,mount_thickness+top_anchor_depth/2,base_thickness/2]) {
              rounded_cube(mount_thickness,top_anchor_depth,base_thickness,mount_thickness,resolution);
            }
            
          }
        }
      }
      difference() {
        union() {
          translate([0,mount_thickness/2+top_anchor_depth/2,base_thickness/2]) {
            rounded_cube(top_anchor_width,mount_thickness+top_anchor_depth,base_thickness,mount_thickness,resolution);
          }
        }
        translate([0,mount_thickness+top_anchor_depth/2,base_thickness/2]) {
          hole(mount_screw_diam,20,4);
          translate([0,0,base_thickness/2]) {
             % hole(mount_screw_head_diam,3,resolution);
             // allow bridging rather than trying to make a hole in mid-air
             cube([top_anchor_width-mount_thickness*2,mount_screw_diam,extrude_height*2],center=true);
          }
        }
      }
    }

    intersection() {
      union() {
        position_board() {
          position_board_holes() {
            bevel(bevel_large_od,bevel_small_od,bevel_height);
          }
        }
      }
      translate([0,-mount_width+overall_width/2,0]) {
        cube([overall_depth*2,internal_width+mount_thickness,overall_height*2],center=true);
      }
    }

    position_rpi() {
      position_rpi_holes() {
        bevel(bevel_large_od,bevel_small_od,bevel_height);
      }
    }

    position_buck_converter() {
      position_buck_converter_holes() {
        bevel(bevel_large_od,bevel_small_od,bevel_height);
      }
    }

    // wire access holes for extruder / x axis
    position_wire_access_hole() {
      translate([0,0,-base_thickness]) {
        rounded_cube(wire_access_hole_width+mount_thickness*2,wire_access_hole_depth+mount_thickness*2,base_thickness*2,mount_thickness*3,resolution);
      }
    }
  }

  module holes() {
    for(y=[front,rear],z=[top,bottom]) {
      translate([0,-mount_width/2+y*mount_screw_spacing/2,-20+z*10]) {
        rotate([0,90,0]) {
          hole(mount_screw_diam,20,resolution);
        }
      }
    }

    // round the rear left corner for faster printing
    translate([-mount_thickness,-mount_width+overall_width,0]) {
      rotate([0,0,-90]) {
        round_corner_filler(outer_rounded_diam,overall_height*4);
      }
    }

    // round much of the front left corner for faster printing
    translate([-mount_thickness,-mount_width,0]) {
      transition_height = outer_rounded_diam/2;
      outer_rounded_height = overall_height-transition_height;
      translate([0,0,overall_height]) {
        round_corner_filler(outer_rounded_diam,outer_rounded_height*2);
      }
      difference() {
        translate([0,0,transition_height/2+0.1]) {
          cube([outer_rounded_diam,outer_rounded_diam,transition_height+0.2],center=true);
        }
        translate([outer_rounded_diam/2,outer_rounded_diam/2,transition_height]) {
          hole(outer_rounded_diam,2,resolution);
        }
        hull() {
          translate([outer_rounded_diam/2,outer_rounded_diam/2,transition_height-1]) {
            hole(outer_rounded_diam,2,resolution);
          }
          translate([mount_thickness/2,mount_thickness/2,-1]) {
            hole(mount_thickness,2,resolution);
          }
          translate([20,0.5,transition_height/2]) {
            cube([1,1,transition_height],center=true);
          }
          translate([0.5,20,transition_height/2]) {
            cube([1,1,transition_height],center=true);
          }
        }
      }
    }

    position_board() {
      // [  (29.15+31.5)/2,  8, -90, "usb_B" ],
      // [  (46.9+51.55)/2,  7, -90, "uSD", [14, 14, 2] ],
      translate([0,-board_width/2-spacer-base_thickness,pcb_thickness(board_type)/2]) {
        // cutout for USB cable
        translate([-board_length/2+(29.15+31.5)/2,0,usb_hole_height/2]) {
          rotate([90,0,0]) {
            hull() {
              rounded_cube(usb_hole_width,usb_hole_height,base_thickness*2,2,resolution);
              translate([0,0,1+spacer]) {
                rounded_cube(usb_hole_width,usb_hole_height+base_thickness*2,2,2,resolution);
              }
            }
          }
        }

        // cutout for uSD card
        translate([-board_length/2+(46.9+51.55)/2,0,sd_hole_height/2]) {
          rotate([90,0,0]) {
            hull() {
              rounded_cube(sd_hole_width,sd_hole_height,base_thickness*2,2,resolution);
              translate([0,0,1+spacer]) {
                rounded_cube(sd_hole_width,sd_hole_height+base_thickness*2,2,2,resolution);
              }
            }
          }
        }
      }
    }

    position_board() {
      position_board_holes() {
        hole(m3_thread_into_plastic_hole_diam,2*(bevel_height-0.1),resolution);
      }
    }

    position_rpi() {
      position_rpi_holes() {
        hole(1.9,2*(bevel_height-0.1),resolution);
      }
    }

    position_buck_converter() {
      position_buck_converter_holes() {
        hole(1.9,2*(bevel_height-0.1),resolution);
      }
    }

    // vent holes
    vent_hole_width = mount_thickness;
    vent_hole_count = 8;
    vent_hole_length = (board_length-bevel_large_od*2-10)/vent_hole_count;
    vent_hole_y_spacing = vent_hole_length + mount_thickness;
    vent_hole_x_spacing = vent_hole_width + mount_thickness;
    vent_hole_resume = 24;
    vent_x_pos = [
      vent_hole_width/2,
      /*
      vent_hole_resume,
      vent_hole_resume+vent_hole_x_spacing,
      vent_hole_resume+vent_hole_x_spacing*2,
      */
    ];
    for(x=vent_x_pos) {
      translate([x,-mount_width+mount_thickness+bevel_large_od,overall_height]) {
        for(i=[0:vent_hole_count-1]) {
          translate([0,vent_hole_length/2+vent_hole_y_spacing*i,0]) {
            rounded_cube(vent_hole_width,vent_hole_length,base_thickness*2+0.1,vent_hole_width,resolution);
          }
        }
      }
    }

    // wire access holes for extruder / x axis
    position_wire_access_hole() {
      rounded_cube(wire_access_hole_width,wire_access_hole_depth,base_thickness*5,mount_thickness,resolution);
    }
  }

  if (debug) {
    % position_board() {
      pcb(board_type);
    }
    % position_rpi() {
      pcb(RPI3);
    }
    % position_buck_converter() {
      buck_converter();
    }
  }

  module position_wire_access_hole() {
    position_board() {
      translate([0,-board_width/2-spacer*2,pcb_thickness(board_type)/2]) {
        // cutout for USB cable
        translate([-board_length/2+(29.15+31.5)/2+usb_hole_width/2+wire_access_hole_width/2+mount_thickness*2,0,sd_hole_height+wire_access_hole_depth/2+base_thickness+mount_thickness*2]) {
          rotate([90,0,0]) {
            children();
          }
        }
      }
    }
    //translate([overall_depth/2+3,-mount_width+bevel_large_od+wire_access_hole_width/2,overall_height-base_thickness]) {
    //  children();
    //}
  }

  difference() {
    body();
    holes();
  }
}

module position_lid() {
  position_top() {
    translate([-overall_depth-retention_wing_height,0,0]) {
      children();
    }
  }
}

module new_vertical_electronics_mount_assembly() {
  translate([-side_connector_length/2-40,40+side_rail_length_rear,40]) {
    new_vertical_electronics_mount();

    position_lid() {
      translate([0,0,-overall_height*0]) {
        // new_vertical_electronics_lid();
      }
    }

  }
}

module position_for_printing() {
  rotate([0,-board_angle+90,0]) {
    new_vertical_electronics_mount();
  }
}

if (debug) {
  new_vertical_electronics_mount();
}
