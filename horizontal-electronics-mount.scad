include <NopSCADlib/lib.scad>;
include <lumpyscad/lib.scad>;
include <./frame-mockup.scad>;


extrude_width = 0.5;
extrude_height = 0.24;
wall_thickness = extrude_width*2;
spacer = 0.2;

base_thickness = 3;
gusset_plate_thickness = 2;

board_type = BTT_SKR_V1_4_TURBO;
//board_type = BTT_SKR_MINI_E3_V2_0;

vent_hole_width = 2.5;
num_vent_holes_x = 5;
num_vent_holes_y = 8;
vent_hole_wall_thickness = wall_thickness*2;
vent_hole_spacing_x = vent_hole_width + vent_hole_wall_thickness;

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

module one_side_horizontal_electronics_mount() {
  board_type = BTT_SKR_V1_4_TURBO;
  bottom_thickness = 3;
  bevel_height = 4;
  room_behind_board = 8;
  room_for_screw_terminals = 20;
  room_for_ports = 20;

  ender3_board_pos = [
    wall_thickness*2+room_for_ports+pcb_width(board_type)/2,
    -wall_thickness*2-room_for_screw_terminals-pcb_length(board_type)/2,
    bevel_height+bottom_thickness
  ];

  board_screw_diam = pcb_hole_d(board_type);
  //internal_width = pcb_length(board_type) + room_for_screw_terminals + spacer*2;
  //internal_width = side_connector_length/2+20/2-wall_thickness*4;
  //overall_width = internal_width + wall_thickness*4;
  internal_width = room_for_ports+pcb_width(board_type)+spacer*2;
  overall_width = internal_width+wall_thickness*4;
  internal_depth = pcb_length(board_type) + room_for_screw_terminals + spacer*2;
  //overall_width = internal_width + wall_thickness*4;

  dist_below_main_rail = 5;
  overall_depth = internal_depth + wall_thickness*4;
  overall_height = 40 - 7; // just below Y rail
  internal_height = overall_height-bottom_thickness;

  y_rail_anchor_width = 16;
  y_rail_anchor_depth = 12;
  y_rail_anchor_plate_thickness = 3;

  board_screw_hole_diam = 2.8;
  rpi_screw_hole_diam = 2.1;

  module position_main_body() {
    translate([overall_width/2,-overall_depth/2,overall_height/2]) {
      children();
    }
  }

  module position_ender3_board() {
    translate(ender3_board_pos) {
      rotate([0,0,-90]) {
        children();
      }
    }
  }

  module position_buck_converter() {
    translate([overall_width-wall_thickness*2-pcb_width(RPI3)/2,-wall_thickness*2-1,overall_height-buck_conv_width/2]) {
      rotate([90,0,0]) {
        rotate([0,0,-90]) {
          // children();
        }
      }
    }
  }

  module position_rpi() {
    translate([overall_width-wall_thickness*2-pcb_width(RPI3)/2-spacer,-overall_depth+pcb_length(RPI3)/2+wall_thickness*2-0.5,bevel_height+bottom_thickness]) {
      rotate([0,0,-90]) {
        // children();
      }
    }
  }

  module position_y_rail_anchor() {
    translate([side_connector_length/2,-overall_depth-y_rail_anchor_depth/2,40-7]) {
      children();
    }
  }

  module body() {
    inner_rounded_diam = spacer*2;
    outer_rounded_diam = inner_rounded_diam+wall_thickness*4;
    position_main_body() {
      difference() {
        rounded_cube(overall_width,overall_depth,overall_height,outer_rounded_diam,resolution);

        translate([0,0,overall_height/2]) {
          rounded_cube(internal_width,internal_depth,internal_height*2,inner_rounded_diam,resolution);
        }
      }
    }

    // anchor to Y rail
    position_y_rail_anchor() {
      height = y_rail_anchor_depth*1.5;

      translate([0,y_rail_anchor_depth/2+wall_thickness,-height/2]) {
        rounded_cube(y_rail_anchor_width,wall_thickness*2,height,wall_thickness*2,resolution);
      }
      translate([0,wall_thickness,-y_rail_anchor_plate_thickness/2]) {
        rounded_cube(y_rail_anchor_width,y_rail_anchor_depth+wall_thickness*2,y_rail_anchor_plate_thickness,wall_thickness*2,resolution);
      }

      for(x=[left,right]) {
        hull() {
          translate([x*(y_rail_anchor_width/2-wall_thickness),0,0]) {
            translate([0,y_rail_anchor_depth/2+wall_thickness,-height/2]) {
              rounded_cube(wall_thickness*2,wall_thickness*2,height,wall_thickness*2,resolution);
            }
            translate([0,wall_thickness,-y_rail_anchor_plate_thickness/2]) {
              rounded_cube(wall_thickness*2,y_rail_anchor_depth+wall_thickness*2,y_rail_anchor_plate_thickness,wall_thickness*2,resolution);
            }
          }
        }
      }
    }

    intersection() {
      position_main_body() {
        cube([overall_width,overall_depth,overall_height],center=true);
      }
      union() {
        position_ender3_board() {
          position_ender3_holes() {
            id = board_screw_hole_diam+wall_thickness*4;
            od = id + bevel_height*2;
            bevel(od,id,bevel_height);
          }
        }
        position_rpi() {
          position_rpi_holes() {
            id = rpi_screw_hole_diam+wall_thickness*4;
            od = id + bevel_height*2;
            bevel(od,id,bevel_height);
          }
        }
      }
    }

    translate([side_connector_length/2,-overall_depth,0]) {
      // % debug_axes(5);
    }

    position_buck_converter() {
      % buck_converter();
    }
  }

  module holes() {
    position_ender3_board() {
      position_ender3_holes() {
        hole(board_screw_hole_diam,100,8);
      }
      // [  (29.15+31.5)/2,  8, -90, "usb_B" ],
      // [  (46.9+51.55)/2,  7, -90, "uSD", [14, 14, 2] ],
      translate([-pcb_length(board_type)/2,-pcb_width(board_type)/2,pcb_thickness(board_type)-spacer]) {
        usb_width = 36.09-24.11+spacer*2;
        usb_height = 11.2+spacer*2;
        translate([(29.15+31.5)/2,0,usb_height/2]) {
          cube([usb_width+spacer*2,8+spacer*2,usb_height],center=true);
        }

        usd_width = 57.49-42.46;
        usd_height = 2.5;
        translate([(46.9+51.55)/2,0,usd_height/2]) {
          cube([usd_width,8+spacer*2,usd_height],center=true);
        }
      }
    }

    position_rpi() {
      position_rpi_holes() {
        hole(rpi_screw_hole_diam,100,8);
      }
      translate([0,0,overall_height/2]) {
        rounded_cube(pcb_length(RPI3)+spacer*2,pcb_width(RPI3)+spacer*2,overall_height,pcb_radius(RPI3)*2+spacer*2,resolution);
      }

      translate([pcb_length(RPI3)/2,-pcb_width(RPI3)/2,pcb_thickness(RPI3)-spacer]) {
        /*
        [-8.5,  10.25, 0, "rj45"],
        [-6.5,  29,    0, "usb_Ax2"],
        [-6.5,  47,    0, "usb_Ax2"],
        */

        translate([0,10.25,14/2]) {
          cube([10,16.5,14],center=true);
        }
        for(y=[29,47]) {
          translate([0,y,16/2]) {
            cube([30,15.6,15.6],center=true);
          }
        }
      }
    }

    position_y_rail_anchor() {
      hole_diam = 3.2;
      translate([0,0,-y_rail_anchor_plate_thickness]) {
        // so that we can put a hole in mid-air without having to post-process
        hole(hole_diam,20,resolution);
        cube([y_rail_anchor_width-wall_thickness*4,hole_diam,extrude_height*2],center=true);
        cube([hole_diam,hole_diam,extrude_height*4],center=true);
        hole(hole_diam,extrude_height*6,8);
      }
    }
  }

  position_ender3_board() {
    // % cube([110,85,30],center=true);
    % pcb(board_type);
  }

  position_rpi() {
    % pcb(RPI3);
  }

  difference() {
    body();
    holes();
  }
}

module twofer_horizontal_electronics_mount(include_rpi=0) {
  board_type = BTT_SKR_V1_4_TURBO;
  bottom_thickness = 3;
  bevel_height = 4;
  room_behind_board = 8;
  room_for_screw_terminals = 20;

  board_screw_diam = pcb_hole_d(board_type);
  internal_depth = pcb_width(board_type) + room_behind_board + spacer*2;
  overall_width = (include_rpi) ? 200 : side_connector_length/2+10;
  internal_width = overall_width-wall_thickness*4;
  dist_below_main_rail = 5;
  overall_depth = internal_depth + wall_thickness*4;
  overall_height = 40 - 7; // just below Y rail
  internal_height = overall_height-bottom_thickness;

  y_rail_anchor_width = 16;
  y_rail_anchor_depth = 12;
  y_rail_anchor_plate_thickness = 3;

  board_screw_hole_diam = 2.8;
  rpi_screw_hole_diam = 2.1;

  ender3_board_pos = [
    wall_thickness*2+room_for_screw_terminals+pcb_length(board_type)/2,
    //wall_thickness*2+room_for_screw_terminals+pcb_length(board_type)/2-spacer,
    -wall_thickness*2-internal_depth+pcb_width(board_type)/2+spacer,
    bevel_height+bottom_thickness
  ];

  module position_main_body() {
    translate([overall_width/2,-overall_depth/2,overall_height/2]) {
      children();
    }
  }

  module position_ender3_board() {
    translate(ender3_board_pos) {
      children();
    }
  }

  module position_buck_converter() {
    if (include_rpi) {
      translate([overall_width-wall_thickness*2-pcb_width(RPI3)/2,-wall_thickness*2-1,overall_height-buck_conv_width/2]) {
        rotate([90,0,0]) {
          rotate([0,0,-90]) {
            children();
          }
        }
      }
    }
  }

  module position_rpi() {
    if (include_rpi) {
      translate([overall_width-wall_thickness*2-pcb_width(RPI3)/2-spacer,-overall_depth+pcb_length(RPI3)/2+wall_thickness*2-0.5,bevel_height+bottom_thickness]) {
        rotate([0,0,-90]) {
          children();
        }
      }
    }
  }

  module position_y_rail_anchor() {
    translate([side_connector_length/2,-overall_depth-y_rail_anchor_depth/2,40-7]) {
      children();
    }
  }

  module slot_anchor(length,retainer=0) {
    depth = v_slot_cavity_depth-2;
    height = v_slot_opening-spacer*4;
    retain_thickness = 2;
    retain_height = 1.6;

    support_width = extrude_width*6;
    support_height = 30-height/2 + extrude_height/2;
    support_space = 1;

    do_supports = 1;

    translate([0,0,0]) {
      for(z=[10,30]) {
        translate([depth/2-wall_thickness,0,z]) {
          rounded_cube(depth+wall_thickness*2,length,height,wall_thickness*2,resolution);
        }
        if (retainer) {
          translate([depth-retain_thickness/2,0,z+retain_height/2]) {
            rounded_cube(retain_thickness,length,height+retain_height,wall_thickness*2,resolution);
          }
        }
        if (do_supports) {
          bridge_width = depth+support_space+support_width;
          translate([bridge_width/2,0,z-height/2+extrude_height/2]) {
            rounded_cube(bridge_width,length,extrude_height,support_width,resolution);
          }
        }
      }

      if (do_supports) {
        translate([depth+support_space+support_width/2,0,support_height/2]) {
          rounded_cube(support_width,length,support_height,support_width,resolution);
        }
        width = extrude_width*8;
        translate([depth+support_space+support_width/2,0,extrude_height/2]) {
          rounded_cube(width,length+width,extrude_height,width,resolution);
        }
      }
    }
  }

  module slot_anchor_profile(retainer=0) {
    depth = v_slot_cavity_depth-2;
    height = v_slot_opening-spacer*4;
    retain_thickness = 2;
    retain_height = 1.6;

    support_width = extrude_width*2;
    support_height = 10-height/2 + extrude_height;
    support_space = 0;

    do_supports = 1;

    translate([0,0,0]) {
      for(z=[10]) {
        translate([depth/2,z]) {
          square([depth,height],center=true);
        }
        if (retainer) {
          translate([depth-retain_thickness/2,z+retain_height/2]) {
            square([retain_thickness,height+retain_height],center=true);
          }
        }
        if (do_supports) {
          bridge_width = depth+support_space+support_width;
          translate([bridge_width/2-0.2,z-height/2+extrude_height/2]) {
            # square([bridge_width,extrude_height],center=true);
          }
        }
      }

      if (do_supports) {
        translate([depth+support_space+support_width/2,support_height/2]) {
          square([support_width,support_height],center=true);
        }
        translate([depth/2,extrude_height]) {
          square([depth,extrude_height*2],center=true);
        }
      }
    }
  }

  module body() {
    inner_rounded_diam = spacer*2;
    outer_rounded_diam = inner_rounded_diam+wall_thickness*4;
    position_main_body() {
      difference() {
        rounded_cube(overall_width,overall_depth,overall_height,outer_rounded_diam,resolution);

        translate([0,0,overall_height/2]) {
          rounded_cube(internal_width,internal_depth,internal_height*2,inner_rounded_diam,resolution);
        }
      }
    }

    // slot anchors
    for(y=[front,rear]) {
      length = 20;
      translate([0,-overall_depth/2+y*(overall_depth/2-wall_thickness*4-length/2),0]) {
        mirror([1,0,0]) {
          slot_anchor(20, "include retainer");
          /*
          rotate([90,0,0]) {
            linear_extrude(height=length,convexity=3,center=true) {
              slot_anchor_profile("include retainer");
            }
          }
          */
        }
      }
    }
    rear_support_width = 20;
    translate([overall_width-wall_thickness*4-rear_support_width/2,0]) {
      rotate([0,0,90]) {
        slot_anchor(20);
        /*
        rotate([90,0,0]) {
          linear_extrude(height=rear_support_width,convexity=3,center=true) {
            slot_anchor_profile();
          }
        }
        */
      }
    }

    // anchor to Y rail
    position_y_rail_anchor() {
      height = y_rail_anchor_depth*1.5;

      translate([0,y_rail_anchor_depth/2+wall_thickness,-height/2]) {
        rounded_cube(y_rail_anchor_width,wall_thickness*2,height,wall_thickness*2,resolution);
      }
      translate([0,wall_thickness,-y_rail_anchor_plate_thickness/2]) {
        rounded_cube(y_rail_anchor_width,y_rail_anchor_depth+wall_thickness*2,y_rail_anchor_plate_thickness,wall_thickness*2,resolution);
      }

      for(x=[left,right]) {
        hull() {
          translate([x*(y_rail_anchor_width/2-wall_thickness),0,0]) {
            translate([0,y_rail_anchor_depth/2+wall_thickness,-height/2]) {
              rounded_cube(wall_thickness*2,wall_thickness*2,height,wall_thickness*2,resolution);
            }
            translate([0,wall_thickness,-y_rail_anchor_plate_thickness/2]) {
              rounded_cube(wall_thickness*2,y_rail_anchor_depth+wall_thickness*2,y_rail_anchor_plate_thickness,wall_thickness*2,resolution);
            }
          }
        }
      }
    }

    intersection() {
      position_main_body() {
        cube([overall_width,overall_depth,overall_height],center=true);
      }
      union() {
        position_ender3_board() {
          position_ender3_holes() {
            id = board_screw_hole_diam+wall_thickness*4;
            od = id + bevel_height*2;
            bevel(od,id,bevel_height);
          }
        }
        position_rpi() {
          position_rpi_holes() {
            id = rpi_screw_hole_diam+wall_thickness*4;
            od = id + bevel_height*2;
            bevel(od,id,bevel_height);
          }
        }
      }
    }

    translate([side_connector_length/2,-overall_depth,0]) {
      // % debug_axes(5);
    }

    // FIXME: y axis strain relief here

    position_buck_converter() {
      % buck_converter();
    }
  }

  module holes() {
    position_ender3_board() {
      position_ender3_holes() {
        hole(board_screw_hole_diam,100,resolution);
      }
      // [  (29.15+31.5)/2,  8, -90, "usb_B" ],
      // [  (46.9+51.55)/2,  7, -90, "uSD", [14, 14, 2] ],
      translate([-pcb_length(board_type)/2,-pcb_width(board_type)/2,pcb_thickness(board_type)-spacer]) {
        usb_width = 36.09-24.11+spacer*2;
        usb_height = 11.2+spacer*2;
        translate([(29.15+31.5)/2,0,usb_height/2]) {
          cube([usb_width+spacer*2,8+spacer*2,usb_height],center=true);
        }

        usd_width = 57.49-42.46;
        usd_height = 2.5;
        translate([(46.9+51.55)/2,0,usd_height/2]) {
          cube([usd_width,8+spacer*2,usd_height],center=true);
        }
      }
    }

    position_rpi() {
      position_rpi_holes() {
        hole(rpi_screw_hole_diam,100,8);
      }
      translate([0,0,overall_height/2]) {
        rounded_cube(pcb_length(RPI3)+spacer*2,pcb_width(RPI3)+spacer*2,overall_height,pcb_radius(RPI3)*2+spacer*2,resolution);
      }

      translate([pcb_length(RPI3)/2,-pcb_width(RPI3)/2,pcb_thickness(RPI3)-spacer]) {
        /*
        [-8.5,  10.25, 0, "rj45"],
        [-6.5,  29,    0, "usb_Ax2"],
        [-6.5,  47,    0, "usb_Ax2"],
        */

        translate([0,10.25,14/2]) {
          cube([10,16.5,14],center=true);
        }
        for(y=[29,47]) {
          translate([0,y,16/2]) {
            cube([30,15.6,15.6],center=true);
          }
        }
      }
    }

    /*
    */
    wire_hole_width = 40-10;
    wire_hole_pos_x = 15+40/2;
    wire_hole_height = 20-bottom_thickness-1;
    translate([wire_hole_pos_x,-wall_thickness*4+10,bottom_thickness+wire_hole_height/2+extrude_height]) {
      cube([wire_hole_width,20,wire_hole_height],center=true);
    }

    position_y_rail_anchor() {
      hole_diam = 3.2;
      translate([0,0,-y_rail_anchor_plate_thickness]) {
        // so that we can put a hole in mid-air without having to post-process
        hole(hole_diam,20,resolution);
        cube([y_rail_anchor_width-wall_thickness*4,hole_diam,extrude_height*2],center=true);
        cube([hole_diam,hole_diam,extrude_height*4],center=true);
        hole(hole_diam,extrude_height*6,8);
      }
    }
  }

  position_ender3_board() {
    // % cube([110,85,30],center=true);
    % pcb(board_type);
  }

  position_rpi() {
    % pcb(RPI3);
  }

  difference() {
    body();
    holes();
  }
}

module vertical_electronics_mount() {
  module position_ender3_board() {
    translate([
      0,
      0,
      0,
    ]) {
      rotate([0,-90,0]) {
        rotate([0,0,-90]) {
          children();
        }
      }
    }
  }

  module body() {
  }

  module holes() {
  }

  position_ender3_board() {
    % pcb(board_type);
  }

  difference() {
    body();
    holes();
  }
}

module vertical_electronics_mount() {
  module position_ender3_board() {
    translate([
      0,
      0,
      0,
    ]) {
      rotate([0,-90,0]) {
        rotate([0,0,-90]) {
          children();
        }
      }
    }
  }

  module body() {
  }

  module holes() {
  }

  position_ender3_board() {
    % pcb(board_type);
  }

  difference() {
    body();
    holes();
  }
}

module horizontal_electronics_mount_assembly() {
  translate([-side_connector_length/2,0,0]) {
    horizontal_electronics_mount();
  }
}

buck_conv_hole_spacing_x = 16.4; // untested
buck_conv_hole_spacing_y = 30; // untested
buck_conv_hole_diam = 3;
buck_conv_width = 21.2; // sample more boards
buck_conv_length = 43.1; // sample more boards
buck_conv_overall_height = 14; // screw on pot sticks up highest

module buck_converter() {
  board_thickness = 1.3;

  cap_diam = 8;
  cap_height = 11;
  cap_coords = [
    [left*2,rear*(buck_conv_length/2-cap_diam/2-1),board_thickness+cap_height/2],
    [left*0.5,front*(buck_conv_length/2-cap_diam/2-1),board_thickness+cap_height/2],
  ];

  pot_y = 9.5;
  pot_x = 4.5;
  pot_z = 10;
  pot_coord = [-buck_conv_width/2+pot_x/2,buck_conv_length/2-19+pot_y/2,board_thickness+pot_z/2];

  pot_screw_diam = 2.3;
  pot_screw_height = 1.55;

  module body() {
    translate([0,0,board_thickness/2]) {
      color("green") cube([buck_conv_width,buck_conv_length,board_thickness],center=true);
    }

    for(coord=cap_coords) {
      translate(coord) {
        color("lightgrey") hole(cap_diam,cap_height,resolution);
      }
    }

    translate(pot_coord) {
      color("#229") cube([pot_x,pot_y,pot_z],center=true);

      translate([-pot_x/2+pot_screw_diam/2,-pot_y/2+pot_screw_diam/2,pot_z/2+pot_screw_height/2]) {
        color("gold") hole(pot_screw_diam,pot_screw_height,12);
      }
    }

    coil_side = 12.25;
    coil_height = 7;
    translate([buck_conv_width/2-coil_side/2-1.5,buck_conv_length/2-coil_side/2-10.3,board_thickness+coil_height/2]) {
      color("#555") rounded_cube(coil_side,coil_side,coil_height,3,16);
    }

    fet_width = 8.5;
    fet_length = 9.5;
    fet_height = 3.3;
    fet_plate_width = fet_width + 1.3;
    fet_plate_height = 1.3;
    translate([-buck_conv_width/2,-buck_conv_length/2+fet_length/2+10.4,board_thickness]) {
      translate([2.6+fet_width/2,0,fet_plate_height+fet_height/2]) {
        color("#555") cube([fet_width,fet_length,fet_height],center=true);
      }
      translate([1+fet_plate_width/2,0,fet_plate_height/2]) {
        color("lightgrey") cube([fet_plate_width,fet_length,fet_plate_height],center=true);
      }
    }
  }

  module holes() {
    for(side=[front,rear]) {
      translate([side*buck_conv_hole_spacing_x/2,side*buck_conv_hole_spacing_y/2,0]) {
        hole(buck_conv_hole_diam,board_thickness*3,resolution);
      }

      for(x=[left,right]) {
        translate([x*(buck_conv_width/2-2),side*(buck_conv_length/2-2),board_thickness]) {
          hole(1,board_thickness*3,12);

          color("lightgrey") cube([4,4,0.1],center=true);
        }
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

module horizontal_electronics_mount() {
  twofer_horizontal_electronics_mount(0);
  //twofer_horizontal_electronics_mount(1);
  //one_side_horizontal_electronics_mount();
}

module position_buck_converter_holes() {
  for(x=[left,right],y=[front,rear]) {
    translate([x*(buck_conv_hole_spacing_x/2),y*(buck_conv_hole_spacing_y/2),0]) {
      children();
    }
  }
}
