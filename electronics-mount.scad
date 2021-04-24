include <NopSCADlib/lib.scad>;
include <../plotter/lib/vitamins.scad>;
include <../plotter/lib/util.scad>;

extrude_width = 0.4;
extrude_height = 0.24;
wall_thickness = extrude_width*3;
spacer = 0.2;

brace_thickness = extrude_width*4;
base_thickness = 3;
gusset_plate_thickness = 2;

ender3_board_max_x = pcb_length(BTT_SKR_MINI_E3_V2_0);
ender3_board_max_y = pcb_width(BTT_SKR_MINI_E3_V2_0);

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

extrusion_end_pos_y = -40/2;
extrusion_top_pos_z = -main_height/2+20;

x_cable_hole_diam = 16;

lid_ledge_depth = 3.5;
lid_ledge_from_top = brace_thickness * 2;

module position_ender3_holes() {
  pcb_hole_positions(BTT_SKR_MINI_E3_V2_0) {
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

module electronics_mount() {
  echo("electronics mount height: ", main_height);
  echo("electronics mount width: ", main_width);
  echo("electronics mount depth: ", overall_depth);

  translate([-brace_thickness/2-20/2,extrusion_end_pos_y+50/2,extrusion_top_pos_z-40/2]) {
    rotate([90,0,0]) {
      rotate([0,0,90]) {
        % color("lightgrey") extrusion_2040(50);
      }
    }
  }

  module position_ender3_board() {
    //translate([right*(brace_thickness/2+bevel_height),-room_for_screw_terminal_cables/2,room_below_ender3_board/2-room_above_ender3_board/2+pcb_length(BTT_SKR_MINI_E3_V2_0)/2]) {
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

      for(y=[front,rear]) {
        mirror([0,y-1,0]) {
          translate([-brace_thickness/2+overall_depth/2,main_width/2-brace_thickness/2,0]) {
            rounded_square(overall_depth,brace_thickness,brace_thickness);

            translate([overall_depth/2-lid_ledge_from_top-brace_thickness/2,-lid_ledge_depth/2,0]) {
              rounded_square(brace_thickness,lid_ledge_depth+brace_thickness,brace_thickness);
            }
          }

          translate([brace_thickness/2,main_width/2-brace_thickness,0]) {
            rotate([0,0,-90]) {
              round_corner_filler_profile(brace_thickness);
            }
          }
        }
      }
    }

    module holes() {
      for(y=[front,rear]) {
        mirror([0,y-1,0]) {
          translate([-brace_thickness/2,-main_width/2,0]) {
            round_corner_filler_profile(brace_thickness*3);
          }
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

  module body() {
    linear_extrude(height=main_height,center=true,convexity=3) {
      profile();
    }
    translate([0,0,main_height/2-base_thickness/2]) {
      hull() {
        outer_diam = brace_thickness*3;
        translate([-brace_thickness/2+outer_diam/2,0,0]) {
          rounded_cube(outer_diam,main_width,base_thickness,outer_diam);
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

    // gussets to extrusion
    translate([0,extrusion_end_pos_y+40/2+brace_thickness/2,extrusion_top_pos_z+spacer]) {
      gusset_branch_width = (20 - 3)/2;
      gusset_branch_height = gusset_branch_width*1.1;
      gusset_reach = 40+brace_thickness/2;
      gusset_height = gusset_reach*1.5;

      translate([-40/2,0,gusset_plate_thickness/2]) {
        rounded_cube(40+brace_thickness,40+brace_thickness,gusset_plate_thickness,brace_thickness,resolution);
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
      main_width/2-ridge_from_outer_edge,
      main_width/2-ridge_from_outer_edge/2,
    ];
    module ridge_fin(width=ridge_depth,height=ridge_depth) {
      gusset(width,height,brace_thickness,brace_thickness);
      translate([width/2,0,-lid_ledge_depth/2]) {
        rounded_cube(width,brace_thickness,lid_ledge_depth,brace_thickness);
      }
    }

    num_braces = 3;
    brace_spacing_x = ridge_depth/(num_braces);
    brace_spacing_z = (ridge_depth+brace_thickness/2)/(num_braces);
    translate([overall_depth-lid_ledge_from_top-brace_thickness,0,-main_height/2+lid_ledge_depth/2]) {
      for(i=[0:num_braces-1]) {
        translate([-brace_spacing_x*i,0,(brace_spacing_z)*i]) {
          cube([brace_thickness,main_width,lid_ledge_depth],center=true);
        }
        translate([-brace_spacing_x*i,0,0]) {
          cube([brace_thickness,main_width,lid_ledge_depth],center=true);
        }
      }
    }
    translate([0,0,-main_height/2+lid_ledge_depth]) {
      ridge_fin();

      for(y=[front,rear]) {
        mirror([0,y-1,0]) {
          translate([overall_depth-lid_ledge_from_top-brace_thickness,main_width/2-lid_ledge_depth,0]) {
            rotate([0,0,-90]) {
              ridge_fin(ridge_depth/2-brace_thickness/2-0.55,ridge_depth/2);
            }
          }

          for(y=ridge_positions_y) {
            translate([0,y,0]) {
              ridge_fin();
            }
          }
        }
      }
    }
  }

  module holes() {
    vent_hole_width = 2;
    vent_hole_length = 14;
    vent_hole_spacing_x = vent_hole_width + 2.8;
    vent_hole_spacing_y = vent_hole_length + 2.8;
    num_vent_holes_x = 6;
    num_vent_holes_y = 5;

    module vent_hole_line() {
      for(y=[0:num_vent_holes_y-1]) {
        translate([0,y*vent_hole_spacing_y,0]) {
          rounded_cube(vent_hole_width,vent_hole_length,base_thickness*2+1,vent_hole_width);
        }
      }
    }

    // vent holes
    translate([brace_thickness/2+vent_hole_width/2+0.5,-main_width/2+brace_thickness*3+vent_hole_length/2,main_height/2]) {
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

      // bed wiring hole
      translate([0,0,0]) {
        //% debug_axes();
      }
    }

  }

  position_ender3_board() {
    % pcb(BTT_SKR_MINI_E3_V2_0);
  }

  difference() {
    body();
    holes();
  }
}

module ender3_board() {
  board_thickness = 2;

  ender3_usb_offset_from_top_y = 22.27;
  ender3_usb_connector_height = 5.2;
  ender3_usb_connector_width = 29.92 - ender3_usb_offset_from_top_y;
  ender3_usb_connector_depth = 8;
  ender3_usb_connector_offset_y = ender3_board_max_y-ender3_usb_offset_from_top_y-ender3_usb_connector_width/2;

  power_input_width = 11;
  power_input_depth = 11;
  power_input_height = 20;
  power_input_pos_x = 1+power_input_depth/2;
  power_input_pos_y = 5+power_input_width/2;

  microsd_socket_x = 14;
  microsd_socket_y = 15;
  microsd_socket_z = 2;
  microsd_socket_from_edge_y = 2;

  module body() {
    translate([ender3_board_max_x/2,ender3_board_max_y/2,board_thickness/2]) {
      color("green") cube([ender3_board_max_x,ender3_board_max_y,board_thickness],center=true);
    }

    translate([ender3_board_max_x-ender3_usb_connector_depth/2+2,ender3_usb_connector_offset_y,board_thickness+ender3_usb_connector_height/2]) {
      color("silver") cube([ender3_usb_connector_depth,ender3_usb_connector_width,ender3_usb_connector_height],center=true);
    }

    translate([ender3_board_max_x-microsd_socket_x/2,ender3_board_max_y-microsd_socket_from_edge_y-microsd_socket_y/2,board_thickness+microsd_socket_z/2]) {
      color("silver") cube([microsd_socket_x,microsd_socket_y,microsd_socket_z],center=true);
    }

    translate([power_input_pos_x,power_input_pos_y,board_thickness/2+power_input_height/2]) {
      color("lightgreen") cube([power_input_depth,power_input_width,power_input_height],center=true);
    }

    output_block_depth = 10;
    output_block_width = 30;
    output_block_height = 14;
    translate([13+output_block_width/2,output_block_depth/2,board_thickness+output_block_height/2]) {
      // power outputs
      color("lightgreen") cube([output_block_width,output_block_depth,output_block_height],center=true);
    }

    endstop_block_width = 48.25;
    endstop_block_depth = 6;
    endstop_block_height = 7;
    translate([46.5+endstop_block_width/2,endstop_block_depth/2,board_thickness+endstop_block_height/2]) {
      // power outputs
      color("white") cube([endstop_block_width,endstop_block_depth,endstop_block_height],center=true);
    }

    motor_connector_width = 12.5;
    motor_connector_depth = 5.75;
    motor_connector_height = 7;
    motor_connector_offsets_x = [4,24,45,62.5];
    for(x=motor_connector_offsets_x) {
      translate([x+motor_connector_width/2,ender3_board_max_y-0.75-motor_connector_depth/2,board_thickness+motor_connector_height/2]) {
        color("white") cube([motor_connector_width,motor_connector_depth,motor_connector_height],center=true);
      }
    }
  }

  module holes() {
    position_ender3_holes() {
      hole(3,board_thickness*3,resolution);
    }
  }

  difference() {
    body();
    holes();
  }
}

module raspi_3a() {
  board_thickness = 1.5;

  usb_connector_height = 7.1;
  usb_connector_width = 13.1;
  usb_connector_length = 14;
  usb_connector_overhang = 2;
  usb_connector_offset_y = 31.45;

  microusb_connector_width = 8;
  microusb_connector_height = 3;
  microusb_connector_length = 6;
  microusb_connector_overhang = 1.5;

  gpio_width = 5;
  gpio_length = 50;
  gpio_pos_x = 7+gpio_length/2;
  gpio_pos_y = rasp_a_plus_max_y-1-gpio_width/2;

  microsd_width = 11;
  microsd_length = 15;
  microsd_thickness = 1.5;
  microsd_overhang = 2;

  rasp_plus_max_x = rasp_a_plus_max_x + 20;
  rasp_connector_area_x = 22;
  rasp_connector_area_y = 53;
  rasp_connector_area_z = 16;
  rasp_connector_overhang = 2;

  module body() {
    translate([0,rasp_a_plus_max_y/2,board_thickness/2]) {
      translate([rasp_a_plus_max_x/2,0,0]) {
        color("green") rounded_cube(rasp_a_plus_max_x,rasp_a_plus_max_y,board_thickness,3);
      }

      translate([rasp_plus_max_x/2,0,0]) {
        color("green", 0.4) rounded_cube(rasp_plus_max_x,rasp_a_plus_max_y,board_thickness,3);
      }
    }

    translate([rasp_a_plus_max_x-usb_connector_length/2+usb_connector_overhang,usb_connector_offset_y,board_thickness+usb_connector_height/2]) {
      color("silver") cube([usb_connector_length,usb_connector_width,usb_connector_height],center=true);
    }

    translate([rasp_plus_max_x-rasp_connector_area_x/2+rasp_connector_overhang,rasp_a_plus_max_y/2,board_thickness+rasp_connector_area_z/2]) {
      color("silver", 0.4) cube([rasp_connector_area_x,rasp_connector_area_y,rasp_connector_area_z],center=true);
    }

    translate([microsd_length/2-microsd_overhang,rasp_a_plus_max_y/2,-microsd_thickness/2]) {
      color("#333") cube([microsd_length,microsd_width,microsd_thickness],center=true);
    }

    translate([10.6,microusb_connector_length/2-microusb_connector_overhang,board_thickness+microusb_connector_height/2]) {
      color("silver") cube([microusb_connector_width,microusb_connector_length,microusb_connector_height],center=true);
    }

    translate([gpio_pos_x,gpio_pos_y,board_thickness+3]) {
      color("#333") cube([gpio_length,gpio_width,6],center=true);
    }
  }

  module holes() {
    position_pi_holes() {
      color("tan") hole(2.5,board_thickness*3,resolution);
    }
  }

  difference() {
    body();
    holes();
  }
}

module pi_b_plus() {
}

electronics_mount();
