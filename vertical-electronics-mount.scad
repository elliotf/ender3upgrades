include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>;
include <./frame-mockup.scad>;

debug = 1;
extrude_width = 0.5;
extrude_height = 0.24;
wall_thickness = extrude_width*3;
spacer = 0.2;

extrusion_top_pos_z = 0;

base_thickness = 3;
brace_thickness = extrude_width*4;
gusset_plate_thickness = 2;

board_type = BTT_SKR_V1_4_TURBO;
//board_type = BTT_SKR_MINI_E3_V2_0;

bevel_height = 5;
bevel_screw_hole = m3_thread_into_plastic_hole_diam;
bevel_small_od = bevel_screw_hole + extrude_width*4;
bevel_large_od = bevel_small_od+bevel_height*2;

x_cable_hole_diam = 17.5;
x_cable_hole_outer_diam = x_cable_hole_diam + brace_thickness*2;

lid_ledge_depth = 3.5;
lid_ledge_from_top = 6;

board_length = pcb_length(board_type);
//board_width = pcb_width(board_type);
board_width = 90.6;

room_for_screw_terminal = 5;
controller_side_depth = 30 + bevel_height;
overall_depth = controller_side_depth + brace_thickness + lid_ledge_from_top;
overall_width = board_length + room_for_screw_terminal + bevel_height*2 + spacer*2 + wall_thickness*2; // TODO: add walls, cabling room, etc
height_above_extrusion = board_width + base_thickness + spacer + bevel_height;
height_below_extrusion = 30;
overall_height = height_below_extrusion+height_above_extrusion;

echo("overall_depth: ", overall_depth);

lid_tab_count = 4;
lid_tab_width = 10;
lid_thickness = lid_ledge_from_top;
lid_length = overall_height - base_thickness;
lid_width = overall_width - brace_thickness*2 - spacer*2;
lid_tab_thickness = lid_thickness*0.6;
lid_tab_edge_thickness = 0.28;
lid_tab_depth = base_thickness-0.6;
lid_tab_spacing_y = (overall_width-2*(brace_thickness+lid_ledge_depth)-lid_tab_width-2)/(lid_tab_count-1);
lid_tab_hole_length = lid_tab_width+0.4;
lid_tab_hole_width = lid_tab_thickness+0.4;
lid_screw_body_diam = m3_threaded_insert_diam+wall_thickness*4;
lid_screw_body_thickness = 12;
lid_screw_from_end = lid_screw_body_diam/2;

num_vent_fins = 4;
vent_fin_spacing = overall_width/(num_vent_fins+1);

module position_ender3_holes() {
  pcb_hole_positions(board_type) {
    children();
  }
}

module position_lid_tabs_y() {
  for(y=[0:lid_tab_count-1]) {
    translate([0,-overall_width/2+brace_thickness+lid_ledge_depth+1+lid_tab_width/2+y*lid_tab_spacing_y,0]) {
      children();
    }
  }
}

module position_lid() {
  translate([-overall_depth+lid_thickness-0.1,0,-height_below_extrusion+overall_height-base_thickness-lid_length/2-0.0]) {
    rotate([0,0,0]) {
      rotate([0,-90,0]) {
        children();
      }
    }
  }
}

module position_lid_screws() {
  for(y=[left,right]) {
    mirror([0,y-1,0]) {
      translate([-lid_length/2+lid_screw_from_end,lid_width/2-lid_screw_from_end,0]) {
        children();
      }
    }
  }
}

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

module skr_mini_e3_turbo_vertical_electronics_mount() {
  module zip_tie_anchor(zip_tie_width,zip_tie_thickness) {
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

  module position_ender3_board() {
    translate([
      -brace_thickness-bevel_height,
      -overall_width/2+pcb_length(board_type)/2+brace_thickness+spacer,
      height_above_extrusion-base_thickness-spacer-bevel_height/2-board_width/2,
    ]) {
      rotate([0,-90,0]) {
        rotate([0,0,-90]) {
          children();
        }
      }
    }
  }

  module body() {
    intersection() {
      position_ender3_board() {
        position_ender3_holes() {
          bevel(bevel_large_od,bevel_small_od,bevel_height);
        }
      }
      translate([-overall_depth/2,0,-height_below_extrusion+overall_height/2]) {
        rounded_cube(overall_depth-1,overall_width-1,overall_height-1,brace_thickness*5,resolution);
      }
    }
    translate([-overall_depth/2,0,-height_below_extrusion+overall_height-base_thickness/2]) {
      rounded_cube(overall_depth,overall_width,base_thickness,brace_thickness,resolution);
    }

    body_offset = 0.5;
    translate([0,0,-height_below_extrusion+overall_height/2-body_offset]) {
      height = overall_height-body_offset*2;
      translate([-brace_thickness/2,0,0]) {
        cube([brace_thickness,overall_width,height],center=true);
      }

      for(y=[front,rear]) {
        mirror([0,y-1,0]) {
          translate([-overall_depth/2,overall_width/2-brace_thickness/2,0]) {
            rounded_cube(overall_depth,brace_thickness,height,brace_thickness);

            translate([-overall_depth/2+lid_ledge_from_top+brace_thickness/2,-lid_ledge_depth/2-0.1,0]) {
              rounded_cube(brace_thickness,lid_ledge_depth+brace_thickness-0.2,height,brace_thickness);
            }
          }

          translate([-brace_thickness,overall_width/2-brace_thickness,0]) {
            rotate([0,0,180]) {
              round_corner_filler(brace_thickness,height);
            }
          }
        }
      }
    }

    num_bottom_ridges = 4;
    bottom_ridge_spacing = overall_width / (num_bottom_ridges + 1);
    bottom_ridge_offset = -5;
    ridge_depth = overall_depth-lid_ledge_from_top-brace_thickness/2;
    ridge_from_outer_edge = lid_ledge_depth+ridge_depth-brace_thickness/2;
    ridge_positions_y = [
    ];
    module ridge_fin(width=ridge_depth,height=ridge_depth*0.9) {
      gusset(width,height,brace_thickness-0.005,brace_thickness-0.005);
      translate([-width/2,0,-lid_ledge_depth/2]) {
        rounded_cube(width,brace_thickness-0.005,lid_ledge_depth,brace_thickness-0.005);
      }
    }

    num_braces = 2;
    brace_spacing_x = ridge_depth/(num_braces);
    brace_spacing_z = (ridge_depth-brace_thickness*1.5)/(num_braces);
    for(y=[front,rear]) {
      mirror([0,y-1,0]) {
        translate([-ridge_depth,-overall_width/2+lid_ledge_depth,-height_below_extrusion+lid_ledge_depth]) {
          rotate([0,0,-90]) {
            ridge_fin(ridge_depth/2-brace_thickness/2-0.55,ridge_depth/2);
          }
        }
      }
    }

    translate([-overall_depth+lid_ledge_from_top+brace_thickness/2,0,-height_below_extrusion+lid_ledge_depth/2]) {
      for(i=[0:num_braces-1]) {
        translate([brace_spacing_x*i,0,(brace_spacing_z)*i]) {
          cube([brace_thickness,overall_width,lid_ledge_depth],center=true);
        }
        translate([brace_spacing_x*i,0,0]) {
          cube([brace_thickness,overall_width,lid_ledge_depth],center=true);
        }
      }

      /*
      translate([0,0,0]) {
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
      */
    }

    bridge_spacing = 20;
    for(y=[1:num_vent_fins]) {
      translate([-brace_thickness/2,-overall_width/2,-height_below_extrusion+lid_ledge_depth]) {
        translate([0,y*vent_fin_spacing,0]) {
          ridge_fin();
        }
      }
    }

    // gusset anchors to top of to extrusion
    translate([-brace_thickness/2,0,extrusion_top_pos_z]) {
      gusset_branch_width = (20 - 3)/2;
      gusset_branch_height = gusset_branch_width*1.1;
      //gusset_reach = 40+brace_thickness/2;
      gusset_reach = 20+brace_thickness/2;
      gusset_overhang = 50;
      gusset_height = gusset_reach-brace_thickness/2;

      translate([gusset_reach/2,0,gusset_plate_thickness/2]) {
        rounded_cube(gusset_reach,40+brace_thickness,gusset_plate_thickness,brace_thickness,resolution);

        translate([gusset_reach/2,0,gusset_plate_thickness*0.85]) {
          zip_tie_anchor(3,1.5);
        }
      }
      for(y=[front,0,rear]) {
        translate([0,y*(40/2),gusset_branch_height+gusset_plate_thickness]) {
          rotate([0,0,180]) {
            gusset(gusset_reach,gusset_height,brace_thickness,brace_thickness);
          }
        }
      }
      for(y=[front,rear],side=[front,rear]) {
        hull() {
          mirror([0,y-1,0]) {
            translate([0,-20/2,0]) {
              mirror([0,side-1,0]) {
                translate([gusset_reach/2,-10,gusset_plate_thickness]) {
                  rotate([0,0,-90]) {
                    gusset(gusset_branch_width,gusset_branch_height,gusset_reach,brace_thickness);
                  }
                }
              }
            }
          }
        }
      }

      num_zip_tie_anchors = 3;
      zip_tie_anchor_from_end = 30;
      zip_tie_anchor_spacing = (overall_width-zip_tie_anchor_from_end*2)/(num_zip_tie_anchors-1);
      for(i=[0:num_zip_tie_anchors-1]) {
        translate([brace_thickness/2,-overall_width/2+zip_tie_anchor_from_end+i*zip_tie_anchor_spacing,gusset_plate_thickness+gusset_branch_height+gusset_height+5]) {
          zip_tie_anchor(5,2);
        }
      }
    }

    position_lid() {
      position_lid_screws() {
        diam = lid_screw_body_diam-0.01;
        translate([0,0,-lid_screw_body_thickness/2-brace_thickness/2]) {
          hull() {
            hole(diam,lid_screw_body_thickness,resolution);

            translate([lid_screw_body_diam/2,lid_screw_body_diam/2+brace_thickness,0]) {
              cube([diam*2,0.1,lid_screw_body_thickness],center=true);
            }
          }
        }
      }
    }
  }

  module holes() {
    position_ender3_board() {
      position_ender3_holes() {
        hole(bevel_screw_hole,bevel_height*2,resolution);
      }
    }

    translate([0,0,-height_below_extrusion+overall_height/2]) {
      for(y=[front,rear]) {
        mirror([0,y-1,0]) {
          translate([0,overall_width/2,0]) {
            rotate([0,0,180]) {
              round_corner_filler(brace_thickness*3,overall_height+1);
            }
          }
        }
      }
    }

    num_vent_holes_x = 5;
    num_vent_holes_y = 4;
    from_edge_y = brace_thickness+lid_ledge_depth+1;
    from_edge_x = brace_thickness;
    vent_hole_width = (overall_depth-lid_ledge_from_top-1-brace_thickness-from_edge_x-brace_thickness*(num_vent_holes_x-1))/num_vent_holes_x;
    vent_hole_length = (overall_width-from_edge_y*2-brace_thickness*(num_vent_holes_y-1))/num_vent_holes_y;
    vent_hole_spacing_x = vent_hole_width + brace_thickness;
    vent_hole_spacing_y = vent_hole_length + brace_thickness;

    echo("vent_hole_width: ", vent_hole_width);

    union() {
      // vent holes
      translate([-from_edge_x-vent_hole_width/2,-overall_width/2+from_edge_y+vent_hole_length/2,-height_below_extrusion+overall_height-base_thickness/2]) {
        translate([0,0,0]) {
          for(x=[0:num_vent_holes_x-1],y=[0:num_vent_holes_y-1]) {
            translate([-x*vent_hole_spacing_x,y*vent_hole_spacing_y,0]) {
              //rounded_cube(vent_hole_width,vent_hole_length,base_thickness*2+1,brace_thickness);
              cube([vent_hole_width,vent_hole_length,base_thickness+1],center=true);
            }
          }
        }
      }
    }

    translate([-overall_depth+lid_thickness-lid_tab_thickness/2,0,-height_below_extrusion+overall_height-base_thickness]) {
      position_lid_tabs_y() {
        hull() {
          translate([0,0,0]) {
            rounded_cube(lid_tab_thickness,lid_tab_hole_length,0.1,brace_thickness,resolution);
            edge_hole_width = lid_tab_edge_thickness+0.5;
            translate([lid_tab_thickness/2-edge_hole_width/2,0,0]) {
              rounded_cube(edge_hole_width,lid_tab_hole_length,2*(lid_tab_depth+0.2),edge_hole_width,resolution);
            }
          }
        }
        // rounded_cube(lid_tab_hole_width,lid_tab_hole_length,base_thickness*4,brace_thickness,resolution);
      }
    }

    // port access
    position_ender3_board() {
      translate([pcb_length(BTT_SKR_MINI_E3_V2_0)/2+base_thickness/2,pcb_width(BTT_SKR_MINI_E3_V2_0)/2,0]) {
        rounded_diam = 4;
        // micro usb
        translate([0,-(22.27 + 29.92)/2,3]) {
          hole_width = 12;
          hole_height = 6;
          rotate([0,90,0]) {
            rotate([0,0,90]) {
              rounded_cube(hole_width,hole_height,base_thickness*2,rounded_diam,8);
            }
          }
        }

        // micro sd card access
        translate([0,-( 2.13 + 17.17)/2,3]) {
          hole_width = 16;
          hole_height = 6;
          rotate([0,90,0]) {
            rotate([0,0,90]) {
              rounded_cube(hole_width,hole_height,base_thickness*2,rounded_diam,8);
            }
          }
        }

        // 12864 display cable hole
        hole_height = 12;
        translate([0,-53.5,10+hole_height/2]) {
          hole_width = 23;
          rotate([0,90,0]) {
            rotate([0,0,90]) {
              rounded_cube(hole_width,hole_height,base_thickness*2,rounded_diam,8);
            }
          }
        }
      }
    }

    // power inlet
    power_inlet_hole_height = 6;
    power_inlet_hole_width = 16;
    translate([-brace_thickness/2,overall_width/2-12+power_inlet_hole_height/2,0]) {
      translate([0,0,4+power_inlet_hole_width/2]) {
        rotate([0,90,0]) {
          rounded_cube(power_inlet_hole_width,power_inlet_hole_height,brace_thickness+1,4,8);
        }

        // z motor holes
        z_wiring_hole_height = 6;
        z_wiring_hole_width = 16;
        translate([0,0,power_inlet_hole_width/2+5+z_wiring_hole_width/2]) {
          rotate([0,90,0]) {
            rounded_cube(z_wiring_hole_width,z_wiring_hole_height,brace_thickness+1,4,8);
          }
        }
      }
    }


    // anchor to top of extrusion
    hole_length=50;
    translate([20/2,0,extrusion_top_pos_z]) {
      for(y=[front,rear]) {
        translate([0,y*10,gusset_plate_thickness]) {
          cube([5.2,m5_bolt_head_diam+0,extrude_height*2],center=true);
          cube([5.2,5.2,extrude_height*4],center=true);
          hole(5.2,extrude_height*6,8);
          hole(5.2,gusset_plate_thickness*3,resolution);

          translate([0,0,hole_length/2]) {
            hole(m5_bolt_head_diam+1,hole_length,8);
          }
        }
      }
    }

    translate([-brace_thickness/2,-overall_width/2+vent_fin_spacing/2,-20/2]) {
      for(y=[0:num_vent_fins]) {
        translate([0,y*vent_fin_spacing,0]) {
          rotate([0,90,0]) {
            hole(5.2,brace_thickness+1,8);
          }
        }
      }
    }

    /*
    for(y=[front,rear]) {
      mirror([0,y-1,0]) {
        translate([0,overall_width/2,0]) {
          rotate([0,0,180]) {
            round_corner_filler(brace_thickness*5);
          }
        }
      }
    }
    */

    position_lid() {
      position_lid_screws() {
        hole(m3_threaded_insert_diam,(lid_screw_body_thickness+2)*2,resolution);
      }
    }
  }

  if (debug) {
    % position_ender3_board() {
      pcb(board_type);
      board_thickness = pcb_thickness(board_type);
      translate([0,0,board_thickness/2-0.05]) {
        cube([board_length,board_width,board_thickness],center=true);
      }

    }
  }

  difference() {
    body();
    holes();
  }
}

module skr_mini_e3_turbo_electronics_lid() {
  ridge_height = lid_ledge_from_top-lid_thickness/2;

  module profile() {
    screw_hole_diam = 3.6;
    screw_body_diam = screw_hole_diam+wall_thickness*4;
    module body() {
      rounded_square(lid_length,lid_width,lid_screw_body_diam);
    }

    module holes() {
      position_lid_screws() {
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

    vent_hole_width = 2;

    for(y=[front,rear]) {
      translate([lid_length/2,0,-lid_thickness/2]) {
        position_lid_tabs_y() {
          hull() {
            translate([0,0,lid_tab_edge_thickness/2]) {
              rounded_cube(lid_tab_depth*2,lid_tab_width,lid_tab_edge_thickness,vent_hole_width);
            }
            translate([-vent_hole_width/2,0,lid_tab_thickness/2]) {
              rounded_cube(vent_hole_width,lid_tab_width,lid_tab_thickness,vent_hole_width);
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

module vertical_electronics_mount_assembly() {
  translate([-side_connector_length/2-40,side_rail_length_rear+40-overall_width/2-1,40]) {
    position_lid() {
      translate([0,0,lid_thickness/2]) {
        skr_mini_e3_turbo_electronics_lid();
      }
    }

    //color("lightgrey", 0.2) skr_mini_e3_turbo_vertical_electronics_mount();
    % skr_mini_e3_turbo_vertical_electronics_mount();
  }
}

if (debug) {
  vertical_electronics_mount_assembly();
}
//skr_mini_e3_turbo_electronics_lid();
