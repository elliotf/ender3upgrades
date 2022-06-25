include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>;
include <./frame-mockup.scad>;

debug = 1;

extrude_width = 0.5;
extrude_height = 0.24;
spacer = 0.2;

//x_cable_hole_diam = 17.5;

board_type = BTT_SKR_V1_4_TURBO;
//board_type = BTT_SKR_MINI_E3_V2_0;

base_thickness = 3;
shell_thickness = extrude_width*4;
mount_thickness = extrude_width*4;
mount_screw_diam = 5 + spacer;
mount_screw_head_diam = 8 + spacer;
mount_width = side_rail_length_rear - NEMA_width(NEMA17_34);
mount_screw_spacing = mount_width - mount_screw_head_diam - mount_thickness*4;

bevel_height = 5;
bevel_screw_hole = m3_thread_into_plastic_hole_diam;
bevel_small_od = bevel_screw_hole + extrude_width*4;
bevel_large_od = bevel_small_od+bevel_height*2;

board_length = pcb_length(board_type);
board_width = pcb_width(board_type);
//board_width = 90.6; // for skr e3 turbo version

board_angle = 90;

space_below_board = 10; // room for stepper wiring
space_behind_board = 3/4*inch; // room for input/output power wiring

internal_width = board_length + space_behind_board + spacer*2;
internal_height = board_width + space_below_board + spacer*2;
internal_depth = 30 + bevel_height;

lid_thickness = 5;

overall_width = internal_width + mount_thickness*2;
overall_height = internal_height + base_thickness;
overall_depth = 40+mount_thickness;

inner_rounded_diam = bevel_height*1.5;
outer_rounded_diam = inner_rounded_diam+mount_thickness*2;

wire_access_hole_width = 30;
wire_access_hole_depth = 15;

usb_hole_width = 14;
usb_hole_height = 13;

sd_hole_width = 16;
sd_hole_height = 4;

module position_buck_converter() {
  area_width = overall_width - mount_width - 12;
  translate([-mount_thickness-bevel_height,area_width/2,bevel_height*2+buck_conv_length/2]) {
    rotate([0,-90,0]) {
      rotate([0,0,90]) {
        children();
      }
    }
  }
}

module position_rpi() {
  translate([-mount_thickness-bevel_height,-mount_width/2,overall_height-pcb_length(RPI3)/2-bevel_height]) {
    rotate([0,-90,0]) {
      rotate([0,0,180]) {
        children();
      }
    }
  }
}

module position_board() {
  translate([bevel_height,-mount_width+overall_width/2-internal_width/2+board_length/2,space_below_board+board_width/2]) {
    rotate([0,90,0]) {
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

module new_vertical_electronics_mount() {
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

module new_vertical_electronics_mount_assembly() {
  //translate([-side_connector_length/2-40,side_rail_length_rear+40,40]) {
  translate([-side_connector_length/2-40,40+side_rail_length_rear,40]) {
    // position_lid() {
    //   translate([0,0,lid_thickness/2]) {
    //     // skr_mini_e3_turbo_electronics_lid();
    //   }
    // }

    //color("lightgrey", 0.2) skr_mini_e3_turbo_vertical_electronics_mount();
    new_vertical_electronics_mount();
  }
}

if (debug) {
  new_vertical_electronics_mount();
}
