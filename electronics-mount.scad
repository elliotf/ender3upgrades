include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>;

extrude_width = 0.4;
extrude_height = 0.24;
wall_thickness = extrude_width*3;
spacer = 0.2;

brace_thickness = extrude_width*4;
base_thickness = 3;
gusset_plate_thickness = 2;

//board_type = BTT_SKR_V1_4_TURBO;
board_type = BTT_SKR_MINI_E3_V2_0;

ender3_board_max_x = pcb_length(board_type);
ender3_board_max_y = pcb_width(board_type);

// BTT_SKR_MINI_E3_V2_0

echo("BTT_SKR_MINI_E3_V2_0: ", BTT_SKR_MINI_E3_V2_0[10]);

// use a high bevel height to allow for airflow beneath the board
bevel_height = 4;

// raspi isn't actually this tall, but the buck converter is
//raspi_side_depth = 14 + bevel_height;
controller_side_depth = 25 + bevel_height;
overall_depth = controller_side_depth + brace_thickness;

room_for_screw_terminal_cables = 16;
room_above_ender3_board = base_thickness + 0.5;
room_below_ender3_board = 27;
main_height = pcb_length(BTT_SKR_MINI_E3_V2_0) + room_below_ender3_board + room_above_ender3_board;
main_width = ender3_board_max_y + room_for_screw_terminal_cables + brace_thickness + bevel_height;

extrusion_offset_x = 0;
extrusion_end_pos_y = -40/2+5;
extrusion_top_pos_z = -main_height/2+18;

x_cable_hole_diam = 17.5;
x_cable_hole_outer_diam = x_cable_hole_diam + brace_thickness*2;

lid_ledge_depth = 3.5;
lid_ledge_from_top = brace_thickness * 2;

lid_thickness = lid_ledge_from_top;
lid_length = main_height - base_thickness;
lid_width = main_width - brace_thickness*2 - 1;

vent_hole_from_edge = brace_thickness+lid_ledge_depth;
vent_hole_width = 2;
num_vent_holes_x = 5;
num_vent_holes_y = 5;
vent_hole_wall_thickness = 2.8;
vent_hole_length = (main_width-vent_hole_from_edge*2-(vent_hole_wall_thickness*(num_vent_holes_y-1)))/num_vent_holes_y;
vent_hole_spacing_x = vent_hole_width + 2.8;
vent_hole_spacing_y = vent_hole_length + 2.8;

lid_tab_count = 2;
lid_tab_width = 10;
lid_tab_thickness = lid_thickness*0.6;
lid_tab_edge_thickness = 0.28;
lid_tab_depth = base_thickness-0.6;
lid_tab_from_center = lid_width*0.28;
lid_tab_hole_length = lid_tab_width+0.4;
lid_tab_hole_width = lid_tab_thickness+0.4;
lid_screw_body_diam = m3_threaded_insert_diam+wall_thickness*4;
lid_screw_from_end = lid_screw_body_diam/2;

module position_ender3_holes() {
  pcb_hole_positions(board_type) {
    children();
  }
}

module position_rpi_holes() {
  pcb_hole_positions(RPI3) {
    children();
  }
}

module gusset(width,height,thickness,rounded_diam) {
  hull() {
    translate([width/2,0,0.025]) {
      rounded_cube(width,thickness,0.05,rounded_diam,resolution);
    }
    translate([0,0,height/2]) {
      rounded_cube(rounded_diam,thickness,height,rounded_diam,resolution);
    }
  }
}

translate([0,-50,0]) {
  // gusset(40,40,brace_thickness, brace_thickness);
}

module vertical_skr_e3_mini_electronics_mount() {
  echo("electronics mount height: ", main_height);
  echo("electronics mount width: ", main_width);
  echo("electronics mount depth: ", overall_depth);

  module position_rpi() {
    /*
    translate([-brace_thickness/2-bevel_height,-12,main_height/2-base_thickness-1]) {
      // vertical orientation
      translate([0,pcb_length(RPI3)/2+pcb_width(RPI3)/2-61.5-3.5,pcb_length(RPI3)/2-(61.5+3.5)]) {
        rotate([0,-90,0]) {
          rotate([0,0,0]) {
            children();
          }
        }
      }
      // horizontal orientation
      translate([0,0,-pcb_width(RPI3)/2]) {
        rotate([0,-90,0]) {
          rotate([0,0,-90]) {
            children();
          }
        }
      }
    }
    */
  }

  position_rpi() {
    % pcb(RPI3);
    //% pcb(RPI4);
  }

  module position_ender3_board() {
    translate([right*(brace_thickness/2+bevel_height),-room_for_screw_terminal_cables/2,main_height/2-room_above_ender3_board]) {
      rotate([0,-90,0]) {
        rotate([180,0,0]) {
          // push ender board aside slightly to make room for cables to screw-in terminals
          translate([-ender3_board_max_x/2,0,0]) {
            children();
          }
        }
      }
    }
  }

  module profile() {
    module body() {
      rounded_square(brace_thickness,main_width,brace_thickness);

      // meat for the x axis cabling to anchor to
      translate([brace_thickness/2+x_cable_hole_diam/4,rear*(main_width/2-brace_thickness-x_cable_hole_diam/4)]) {
        square([x_cable_hole_diam/2,x_cable_hole_diam/2],center=true);
      }

      translate([brace_thickness/2,-main_width/2+brace_thickness,0]) {
        # round_corner_filler_profile(brace_thickness*3);
      }

      for(y=[front,rear]) {
        mirror([0,y-1,0]) {
          translate([-brace_thickness/2+overall_depth/2,main_width/2-brace_thickness/2,0]) {
            rounded_square(overall_depth,brace_thickness,brace_thickness);

            translate([overall_depth/2-lid_ledge_from_top-brace_thickness/2,-lid_ledge_depth/2,0]) {
              rounded_square(brace_thickness,lid_ledge_depth+brace_thickness,brace_thickness);
            }
          }
        }
      }
    }

    module holes() {
      translate([-brace_thickness/2,-main_width/2,0]) {
        round_corner_filler_profile(brace_thickness*5);
      }
      translate([-brace_thickness/2,main_width/2]) {
        rotate([0,0,-90]) {
          round_corner_filler_profile(x_cable_hole_outer_diam);
        }
      }

      translate([brace_thickness/2+x_cable_hole_diam/2,rear*(main_width/2-brace_thickness-x_cable_hole_diam/2)]) {
        accurate_circle(x_cable_hole_diam,resolution);
      }
    }

    difference() {
      body();
      holes();
    }
  }

  module position_lid_tabs() {
    for(y=[front,rear]) {
      translate([-brace_thickness/2+overall_depth,y*lid_tab_from_center,main_height/2-base_thickness]) {
        translate([-lid_thickness+lid_tab_thickness/2,0,0]) {
          children();
        }
      }
    }
  }

  module body() {
    linear_extrude(height=main_height,center=true,convexity=3) {
      profile();
    }
    translate([0,0,main_height/2-base_thickness/2]) {
      hull() {
        outer_diam = brace_thickness*5;
        translate([-brace_thickness/2+outer_diam/2,-main_width/2+outer_diam/2,0]) {
          hole(outer_diam,base_thickness,resolution);
        }
        translate([-brace_thickness/2+x_cable_hole_outer_diam/2,main_width/2-x_cable_hole_outer_diam/2,0]) {
          hole(x_cable_hole_outer_diam,base_thickness,resolution);
        }
        translate([overall_depth-brace_thickness,0,0]) {
          rounded_cube(brace_thickness,main_width,base_thickness,brace_thickness);
        }
      }
    }


    // extra girth for side of extrusion mount
    translate([brace_thickness/2,0,extrusion_top_pos_z-20/2]) {
      resize([brace_thickness,main_width-brace_thickness*2,20]) {
        rotate([90,0,0]) {
          // hole(1,1,6);
        }
      }
    }

    intersection() {
      // ensure bevels don't poke out
      translate([overall_depth/2,0,0]) {
        cube([overall_depth,main_width-brace_thickness,main_height],center=true);
      }
      position_ender3_board() {
        position_ender3_holes() {
          bevel_rim_diam = m3_thread_into_plastic_hole_diam+extrude_width*4;
          bevel(bevel_rim_diam+bevel_height*2,bevel_rim_diam,bevel_height);
        }
      }
    }
    position_rpi() {
      pcb_hole_positions(RPI3) {
        bevel_rim_diam = m3_thread_into_plastic_hole_diam+extrude_width*4;
        bevel(bevel_rim_diam+bevel_height*2,bevel_rim_diam,bevel_height);
      }
    }

    // gussets to extrusion
    translate([0,extrusion_end_pos_y+40/2+brace_thickness/2,extrusion_top_pos_z+spacer]) {
      gusset_branch_width = (20 - 3)/2;
      gusset_branch_height = gusset_branch_width*1.1;
      //gusset_reach = 40+brace_thickness/2;
      gusset_reach = 40+brace_thickness/2;
      gusset_overhang = 50;
      gusset_height = gusset_reach*tan(90-gusset_overhang)+gusset_branch_height;

      translate([-gusset_reach/2,0,gusset_plate_thickness/2]) {
        rounded_cube(gusset_reach,40+brace_thickness,gusset_plate_thickness,brace_thickness,resolution);
      }
      for(y=[front,0,rear]) {
        translate([0,y*(40/2),gusset_branch_height+gusset_plate_thickness]) {
          rotate([0,0,180]) {
            gusset(gusset_reach,gusset_height-gusset_branch_height,brace_thickness,brace_thickness);
          }
        }
      }
      for(y=[front,rear],side=[front,rear]) {
        hull() {
          mirror([0,y-1,0]) {
            translate([0,-20/2,0]) {
              mirror([0,side-1,0]) {
                translate([-gusset_reach/2,-10,gusset_plate_thickness]) {
                  rotate([0,0,90]) {
                    gusset(gusset_branch_width,gusset_branch_height,gusset_reach,brace_thickness);
                  }
                }
              }
            }
          }
        }
      }
    }

    num_bottom_ridges = 4;
    bottom_ridge_spacing = main_width / (num_bottom_ridges + 1);
    bottom_ridge_offset = -5;
    ridge_depth = overall_depth-lid_ledge_from_top-brace_thickness/2;
    ridge_from_outer_edge = lid_ledge_depth+ridge_depth-brace_thickness/2;
    ridge_positions_y = [
    ];
    module ridge_fin(width=ridge_depth,height=ridge_depth) {
      gusset(width,height,brace_thickness,brace_thickness);
      translate([width/2,0,-lid_ledge_depth/2]) {
        rounded_cube(width,brace_thickness,lid_ledge_depth,brace_thickness);
      }
    }

    num_braces = 2;
    brace_spacing_x = ridge_depth/(num_braces);
    brace_spacing_z = (ridge_depth+brace_thickness/2)/(num_braces);
    for(y=[front,rear]) {
      mirror([0,y-1,0]) {
        translate([overall_depth-lid_ledge_from_top-brace_thickness,main_width/2-lid_ledge_depth,-main_height/2+lid_ledge_depth]) {
          rotate([0,0,-90]) {
            ridge_fin(ridge_depth/2-brace_thickness/2-0.55,ridge_depth/2);
          }
        }
      }
    }

    translate([overall_depth-lid_ledge_from_top-brace_thickness,0,-main_height/2+lid_ledge_depth/2]) {
      for(i=[0:num_braces-1]) {
        translate([-brace_spacing_x*i,0,(brace_spacing_z)*i]) {
          cube([brace_thickness,main_width,lid_ledge_depth],center=true);
        }
        translate([-brace_spacing_x*i,0,0]) {
          cube([brace_thickness,main_width,lid_ledge_depth],center=true);
        }
      }

      translate([0,0,0]) {
        % debug_axes();
        hull() {
          cube([brace_thickness,lid_screw_body_diam*2,lid_ledge_depth-0.24*2],center=true);
          screw_body_depth = brace_thickness*4;
          translate([brace_thickness/2-screw_body_depth/2,0,-lid_ledge_depth/2-lid_screw_from_end]) {
            rotate([0,90,0]) {
              hole(lid_screw_body_diam,screw_body_depth,resolution);
            }
          }
        }
      }
    }
    intersection() {
      // ensure bevels don't poke out
      translate([overall_depth/2,0,-main_height/2-base_thickness/2]) {
        cube([overall_depth,main_width-x_cable_hole_diam,main_height*2],center=true);
      }
      union() {
        bridge_spacing = 20;
        for(y=[front,rear]) {
          translate([0,40/2+extrusion_end_pos_y,-main_height/2+lid_ledge_depth]) {
            mirror([0,y-1,0]) {
              ridge_fin();
              for(y=[0:bridge_spacing:main_width]) {
                translate([0,y,0]) {
                  ridge_fin();
                }
              }
            }
          }
        }
      }
    }
  }

  module holes() {
    module vent_hole_line() {
      for(y=[0:num_vent_holes_y-1]) {
        translate([0,y*vent_hole_spacing_y,0]) {
          rounded_cube(vent_hole_width,vent_hole_length,base_thickness*2+1,vent_hole_width);
        }
      }
    }

    // vent holes
    translate([brace_thickness/2+vent_hole_width/2+0.5,-main_width/2+vent_hole_from_edge+vent_hole_length/2,main_height/2]) {
      translate([0,0,0]) {
        for(x=[0:num_vent_holes_x-1],y=[0:num_vent_holes_y-1]) {
          should_vent = !(
            (y < 2 && (x == 1 || x == 2)) // usb and sd card access
            || (y > 3 && x < 4) // top cabling hole
            //|| (y == 2 && x > 3)
          );

          translate([x*vent_hole_spacing_x,y*vent_hole_spacing_y,0]) {
            if (should_vent) {
              rounded_cube(vent_hole_width,vent_hole_length,base_thickness*2+1,vent_hole_width);
            }
          }
        }
      }
    }

    position_lid_tabs() {
      hull() {
        translate([-0.1-lid_tab_hole_width/2,0,0]) {
          translate([lid_tab_hole_width/2,0,0]) {
            rounded_cube(lid_tab_hole_width,lid_tab_hole_length,0.1,brace_thickness,resolution);
          }
          edge_hole_width = lid_tab_edge_thickness+0.5;
          translate([edge_hole_width/2,0,0]) {
            rounded_cube(edge_hole_width,lid_tab_hole_length,2*(lid_tab_depth+0.2),edge_hole_width,resolution);
          }
        }
      }
      // rounded_cube(lid_tab_hole_width,lid_tab_hole_length,base_thickness*4,brace_thickness,resolution);
    }

    // X axis cabling
    translate([brace_thickness/2+x_cable_hole_diam/2,rear*(main_width/2-brace_thickness-x_cable_hole_diam/2),main_height/2]) {
      hole(x_cable_hole_diam,base_thickness*2+0.2,resolution);

      translate([x_cable_hole_diam*0.25,-x_cable_hole_diam*0.25,0]) {
        for(z=[-10,-25]) {
          for(r=[20,70]) {
            rotate([0,0,r]) {
              translate([0,40/2,z]) {
                cube([2,40,3],center=true);
              }
            }
          }
        }
      }
    }

    // anchor to side of extrusion
    translate([0,extrusion_end_pos_y+40/2,extrusion_top_pos_z-20/2]) {
      for(y=[front,rear]) {
        translate([0,y*10,0]) {
          rotate([0,90,0]) {
            hole(5.2,10);
          }
        }
      }
    }

    // anchor to end of extrusion
    translate([-brace_thickness/2-40/2,extrusion_end_pos_y-brace_thickness/2,extrusion_top_pos_z-40/2]) {
      for(x=[left,right],y=[front,rear]) {
        rotate([90,0,0]) {
          translate([x*10,y*10,0]) {
            hole(5.2,10,8);
          }
        }
      }
    }

    // anchor to top of extrusion
    hole_length=50;
    translate([-brace_thickness/2-40/2,extrusion_end_pos_y+40/2+brace_thickness/2,extrusion_top_pos_z+spacer]) {
      for(y=[0,1]) {
        translate([0,10+20*y,2]) {
          translate([0,0,hole_length/2]) {
            // hole(m5_bolt_head_diam+1,hole_length,8);
          }
        }
      }
      for(x=[left,right],y=[front,rear]) {
        translate([x*10,y*10,gusset_plate_thickness/2]) {
          translate([0,0,-extrude_height]) {
            hole(5.2,gusset_plate_thickness,resolution);
          }

          translate([0,0,gusset_plate_thickness/2+hole_length/2+0.05]) {
            hole(m5_bolt_head_diam+1,hole_length,resolution);
          }
        }
      }
    }

    // lid screw
    translate([0,0,-main_height/2-lid_screw_from_end]) {
      rotate([0,90,0]) {
        hole(m3_threaded_insert_diam,overall_depth*2+1,resolution);
      }
    }

    position_rpi() {
      pcb_hole_positions(RPI3) {
        //hole(m3_thread_into_plastic_hole_diam,2*(bevel_height),8);
        hole(2.1,2*(bevel_height),8);
      }
    }

    position_ender3_board() {
      // ender 3 mounting
      position_ender3_holes() {
        hole(m3_thread_into_plastic_hole_diam,2*(bevel_height),8);
      }

      // micro usb / micro sd card access
      translate([pcb_length(BTT_SKR_MINI_E3_V2_0)/2+base_thickness+0.5,pcb_width(BTT_SKR_MINI_E3_V2_0)/2,0]) {
        rounded_diam = 4;
        translate([0,-(22.27 + 29.92)/2,3]) {
          rotate([0,90,0]) {
            rotate([0,0,90]) {
              hole_width = 12;
              hole_height = 7;
              hull() {
                rounded_cube(hole_width,hole_height,base_thickness*2+0.1,rounded_diam);
                translate([0,base_thickness*0.5,0]) {
                  rounded_cube(hole_width,hole_height+base_thickness,0.05,rounded_diam);
                }
              }
            }
          }
        }

        translate([0,-( 2.13 + 17.17)/2,2.5]) {
          rotate([0,90,0]) {
            rotate([0,0,90]) {
              hole_width = 16;
              hole_height = 5;
              hull() {
                rounded_cube(hole_width,hole_height,base_thickness*2+0.1,rounded_diam);
                translate([0,base_thickness*0.5,0]) {
                  rounded_cube(hole_width,hole_height+base_thickness,0.05,rounded_diam);
                }
              }
            }
          }
        }
      }
    }
  }

  position_ender3_board() {
    % pcb(board_type);
  }

  difference() {
    body();
    holes();
  }
}

module electronics_lid() {
  ridge_height = lid_ledge_from_top-lid_thickness/2;

  module profile() {
    screw_hole_diam = 3.6;
    screw_body_diam = screw_hole_diam+wall_thickness*4;
    module body() {
      rounded_square(lid_length,lid_width,lid_thickness);

      translate([lid_length/2,0,0]) {
        hull() {
          translate([-1/2,0,0]) {
            square([1,screw_body_diam*2],center=true);
          }
          translate([lid_screw_from_end,0,0]) {
            accurate_circle(screw_body_diam,resolution);
          }
        }
      }
    }

    module holes() {
      translate([lid_length/2+lid_screw_from_end,0,0]) {
        accurate_circle(screw_hole_diam,resolution);
      }
    }

    difference() {
      body();
      holes();
    }
  }

  module body() {
    linear_extrude(height=lid_thickness,center=true,convexity=3) {
      profile();
    }

    for(y=[front,rear]) {
      translate([-lid_length/2,0,-lid_thickness/2]) {
        position_lid_tabs_y() {
          hull() {
            translate([0,0,lid_tab_edge_thickness/2]) {
              rounded_cube(lid_tab_depth*2,lid_tab_width,lid_tab_edge_thickness,vent_hole_width);
            }
            translate([vent_hole_width/2,0,lid_tab_thickness/2]) {
              # rounded_cube(vent_hole_width,lid_tab_width,lid_tab_thickness,vent_hole_width);
            }
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

module vertical_skr_e3_mini_electronics_mount_assembly() {
  translate([-brace_thickness/2+overall_depth-lid_thickness/2+0.1,0,-main_height/2+lid_length/2-0.2]) {
    rotate([0,90,0]) {
      // electronics_lid();
    }
  }

  translate([-side_connector_length/2-40,side_rail_length_rear,40-extrusion_top_pos_z]) {
    rotate([0,0,180]) {
      vertical_skr_e3_mini_electronics_mount();
    }
  }

  translate([-brace_thickness/2+extrusion_offset_x,extrusion_end_pos_y+100/2,extrusion_top_pos_z-20/2]) {
    rotate([90,0,0]) {
      rotate([0,0,0]) {
        % color("lightgrey") extrusion_2040(100);
      }
    }
  }
}

//assembly();
