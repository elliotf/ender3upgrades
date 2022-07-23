include <./frame-mockup.scad>;
include <lumpyscad/lib.scad>;
include <NopSCADlib/lib.scad>;

debug = true;

psu_extrude_width = 0.6;
extrude_height = 0.24;
non_plug_wall_thickness = psu_extrude_width;
spacer = 0.2;

psu_cap_length = 12;
psu_terminal_cover_length = psu_terminal_area_depth + 2;

extrusion_screw_hole_diam = 5.2;

power_cable_thickness = 3.5+spacer*2;
power_cable_width = 7+spacer*2;

// it would be nice to have the 24v cables shorter, but this would mean that 24v and mains would
// cross over each other and be more likely to have mains going through 24v lines.
//
// However, if we flip the PSU over, it would let 24v and mains stay separated
psu_mirror_x = 1; // 0 == cables on left, 1 == cables on right
psu_in_front = 0;

plug_body_hole_width = iec_body_w(IEC_320_C14_switched_fused_inlet) + spacer*3;
plug_body_hole_height = iec_body_h(IEC_320_C14_switched_fused_inlet) + spacer*3;

echo("side_connector_length: ", side_connector_length);
echo("plug_body_hole_width: ", plug_body_hole_width);
echo("non_plug_wall_thickness: ", non_plug_wall_thickness);

psu_pos_x = side_connector_length/2-psu_length/2-plug_body_hole_width-non_plug_wall_thickness*2;
psu_pos_y = -psu_width/2;
psu_pos_z = psu_height/2+non_plug_wall_thickness*2;
psu_screw_hole_diam = 4.5;
psu_support_depth = psu_cap_length;

psu_non_plug_side_gap_to_psu = side_connector_length/2-(psu_length/2+abs(psu_pos_x))-spacer;
//psu_non_plug_side_gap_to_psu = 5;

echo("psu_height: ", psu_height);

echo("psu_pos_x: ", psu_pos_x);
echo("psu_length: ", psu_length);
echo("psu_length/2+abs(psu_pos_x): ", psu_length/2+abs(psu_pos_x));
echo("psu_non_plug_side_gap_to_psu: ", psu_non_plug_side_gap_to_psu);

plate_thickness = 8;

fan_from_end = 48; // not very accurate, only for visualization
fan_from_side = 38; // not very accurate, only for visualization

tab_width = v_slot_opening-0.5;

cable_hole_cut_height = psu_height/2-non_plug_wall_thickness*8;

module position_psu() {
  translate([psu_pos_x,psu_pos_y,psu_pos_z]) {
    rotate([0,0,90]) {
      children();
    }
  }
}

module position_assembly() {
  if (psu_in_front) {
    translate([0,40,0]) {
      rotate([0,0,180]) {
        children();
      }
    }
  } else {
    children();
  }
}

module mirror_assembly() {
  if (!psu_in_front && psu_mirror_x) {
    mirror([1,0,0]) {
      children();
    }
  } else {
    children();
  }
}

module psu_assembly() {
  position_assembly() {
    mirror_assembly() {
      translate([0,-side_rail_length_front+side_rail_length]) {
        psu_mount_plug_side();
        psu_mount_non_plug_side();
        psu_mount_corner_support();

        position_psu() {
          // for whatever reason, I designed this whole thing with the plug on the right side
          // which now seems stupid, but go ahead and mirror here so that the fan is rendered
          // on the correct side if/when I mirror it so that the plug is on the rear left
          rotate([0,180*psu_mirror_x,0]) {
            // if we're mirroring X, flip the PSU to keep 24v and mains away from each other
            // this means the exhaust fan is pointed down, however, and we should probably make
            // sure it has room to breathe
            psu();
          }
        }
      }
    }
  }
}

module old_psu_mount_non_plug_side_frame_profile() {
  rounded_diam = non_plug_wall_thickness*2;
  inner_rounded_diam = 1;
  outer_rounded_diam = inner_rounded_diam+2*rounded_diam;
  tab_depth = v_slot_cavity_depth-0.4;
  overall_height = psu_height + non_plug_wall_thickness*4 + spacer*2;

  bottom_height = 40/2-power_cable_width/2;
  top_height = 40-bottom_height-power_cable_width;

  hollow_tab_inside_width = tab_width-non_plug_wall_thickness*4;

  module frame() {
    translate([psu_non_plug_side_gap_to_psu+20,psu_pos_z,0]) {
      % square([40,psu_height],center=true);
    }
    overall_tab_length = tab_depth+psu_non_plug_side_gap_to_psu;
    for(z=[top,bottom]) {
      translate([0,40/2]) {
        mirror([0,z-1]) {
          translate([-tab_depth/2,20/2]) {
            square([tab_depth,tab_width],center=true);
          }
        }
      }
    }
    translate([psu_non_plug_side_gap_to_psu/2-tab_width/4,40/2]) {
      rounded_square(psu_non_plug_side_gap_to_psu+tab_width/2,20,non_plug_wall_thickness*2);
    }

    // slot tabs
    /*
    for(z=[top,bottom],s=[top,bottom]) {
      translate([non_plug_wall_thickness*2-tab_depth+non_plug_wall_thickness,40/2+z*(20/2)]) {
        rounded_square(non_plug_wall_thickness*2,tab_width,rounded_diam);
      }
      translate([non_plug_wall_thickness*2-tab_depth/2,40/2+z*(20/2)+s*(tab_width/2-non_plug_wall_thickness)]) {
        rounded_square(tab_depth,non_plug_wall_thickness*2,rounded_diam);
      }
    }
    */
    /*
    translate([0,bottom_height/2]) {
      difference() {
        hull() {
          translate([outer_rounded_diam/2,0,0]) {
            rounded_square(outer_rounded_diam,bottom_height,outer_rounded_diam);
          }
          translate([psu_non_plug_side_gap_to_psu+psu_cap_length-rounded_diam/2+non_plug_wall_thickness*2,0,0]) {
            rounded_square(rounded_diam,bottom_height,rounded_diam);
          }
        }
      }
    }
    */
    translate([0,overall_height/2]) {
      /*
      translate([non_plug_wall_thickness,0,0]) {
        rounded_square(non_plug_wall_thickness*2,overall_height,rounded_diam);
      }
      for(z=[top,bottom]) {
        translate([psu_cap_length/2+non_plug_wall_thickness,z*(overall_height/2-non_plug_wall_thickness)]) {
          rounded_square(psu_cap_length+non_plug_wall_thickness*2,non_plug_wall_thickness*2,rounded_diam);
        }
        mirror([0,z-1,0]) {
          translate([non_plug_wall_thickness*2,overall_height/2-non_plug_wall_thickness*2,0]) {
            rotate([0,0,-90]) {
              round_corner_filler_profile(1,resolution);
            }
          }
        }
      }
      */
    }
  }

  module cuts() {
    translate([psu_non_plug_side_gap_to_psu-non_plug_wall_thickness*2-30,40/2,0]) {
      // rounded_square(60,20-tab_width,hollow_tab_inside_width);
    }
    space_between_psu_retainers = 20-hollow_tab_inside_width-tab_width*2;
    space_between_psu_retainer_od = psu_non_plug_side_gap_to_psu*2-tab_width;
    space_between_psu_retainer_id = space_between_psu_retainer_od - non_plug_wall_thickness*4;
    for(z=[top,bottom]) {
      translate([0,40/2]) {
        mirror([0,z-1]) {
          translate([0,20/2]) {
            translate([psu_non_plug_side_gap_to_psu,-hollow_tab_inside_width/2,0]) {
              rotate([0,0,180]) {
                round_corner_filler_profile(tab_width,resolution);
              }
              translate([0,-tab_width,0]) {
                rotate([0,0,90]) {
                  round_corner_filler_profile(tab_width,resolution);
                }
              }
            }
            for(s=[top,bottom]) {
              mirror([0,s-1,0]) {
                translate([-tab_depth,-tab_width/2]) {
                  round_corner_filler_profile(tab_width,resolution);
                }
              }
            }

            translate([-tab_depth+non_plug_wall_thickness*2+30,0]) {
              rounded_square(60,hollow_tab_inside_width,hollow_tab_inside_width);
            }
            translate([0,-hollow_tab_inside_width-non_plug_wall_thickness*2]) {
              translate([psu_non_plug_side_gap_to_psu-30-non_plug_wall_thickness*2,0]) {
                rounded_square(60,hollow_tab_inside_width,hollow_tab_inside_width);
              }

              translate([0,-hollow_tab_inside_width/2]) {
                rotate([0,0,-90]) {
                  round_corner_filler_profile(space_between_psu_retainer_od,resolution);
                }
              }
            }
          }
        }
      }
    }
    translate([non_plug_wall_thickness*2+30,40/2]) {
      rounded_square(60,space_between_psu_retainers,space_between_psu_retainer_id);
    }
    translate([-30,40/2]) {
      square([60,20-tab_width],center=true);
    }
    /*
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
    */
  }

  difference() {
    frame();
    cuts();
  }
}

module unused_wire_access_holes() {
  for(z=[top,bottom]) {
    translate([0,0,non_plug_wall_thickness*2+psu_height/2+z*psu_height/4]) {
      debug_axes();
    }
  }
}

module psu_mount_non_plug_side_frame_profile() {
  rounded_diam = non_plug_wall_thickness*2;
  inner_rounded_diam = 1;
  outer_rounded_diam = inner_rounded_diam+2*rounded_diam;
  tab_depth = v_slot_cavity_depth-0.4;

  bottom_height = 40/2-power_cable_width/2;
  top_height = 40-bottom_height-power_cable_width;

  tab_width = v_slot_opening-0.5;
  hollow_tab_inside_width = tab_width-non_plug_wall_thickness*4;
  retain_length = non_plug_wall_thickness*6;
  bevel_cover_flat_length = 5;

  module frame() {
    translate([0,psu_height/2+non_plug_wall_thickness*2,0]) {
      hull() {
        translate([non_plug_wall_thickness,0,0]) {
          accurate_circle(non_plug_wall_thickness*2,resolution);
        }
        translate([psu_non_plug_side_gap_to_psu-non_plug_wall_thickness,0,0]) {
          accurate_circle(non_plug_wall_thickness*2,resolution);
        }
      }
    }
    translate([0,40/2]) {
      translate([non_plug_wall_thickness,0,0]) {
        rounded_square(non_plug_wall_thickness*2,20-tab_width+non_plug_wall_thickness*4,non_plug_wall_thickness*2);
      }
    }
    for(z=[top,bottom]) {
      translate([0,40/2]) {
        mirror([0,z-1]) {
          translate([0,20/2]) {
            intersection() {
              difference() {
                rounded_square(2*(tab_depth),tab_width,tab_width);
                rounded_square(2*(tab_depth-non_plug_wall_thickness*2),hollow_tab_inside_width,hollow_tab_inside_width);
              }
              translate([-tab_depth+non_plug_wall_thickness,0,0]) {
                square([tab_depth*2,tab_width*2],center=true);
              }
            }
          }
        }
      }

      translate([psu_non_plug_side_gap_to_psu,psu_pos_z,0]) {
        mirror([0,z-1,0]) {
          translate([0,psu_height/2+non_plug_wall_thickness,0]) {
            translate([-non_plug_wall_thickness+psu_cap_length/2,0,0]) {
              rounded_square(psu_cap_length+non_plug_wall_thickness*2,non_plug_wall_thickness*2,non_plug_wall_thickness*2);
            }
            translate([-non_plug_wall_thickness,-retain_length/2+non_plug_wall_thickness,0]) {
              rounded_square(non_plug_wall_thickness*2,retain_length,non_plug_wall_thickness*2);
            }
          }
        }
      }
    }

    // bottom!
    bottom_flat_length = 10-tab_width/2 + non_plug_wall_thickness*2;
    translate([non_plug_wall_thickness,bottom_flat_length/2,0]) {
      rounded_square(non_plug_wall_thickness*2,bottom_flat_length,non_plug_wall_thickness*2);
    }
    hull() {
      translate([non_plug_wall_thickness,non_plug_wall_thickness,0]) {
        accurate_circle(non_plug_wall_thickness*2,resolution);
      }
      translate([psu_non_plug_side_gap_to_psu-non_plug_wall_thickness,non_plug_wall_thickness,0]) {
        accurate_circle(non_plug_wall_thickness*2,resolution);
      }
    }

    // top!
    translate([non_plug_wall_thickness,30+tab_width/2+bevel_cover_flat_length/2-non_plug_wall_thickness*2,0]) {
      rounded_square(non_plug_wall_thickness*2,bevel_cover_flat_length,non_plug_wall_thickness*2);
    }
    translate([psu_non_plug_side_gap_to_psu/2,30+tab_width/2-non_plug_wall_thickness,0]) {
      rounded_square(bevel_cover_flat_length,non_plug_wall_thickness*2,non_plug_wall_thickness*2);
    }
    /*
    hull() {
      translate([non_plug_wall_thickness,30+tab_width/2+bevel_cover_flat_length-non_plug_wall_thickness*3,0]) {
        accurate_circle(non_plug_wall_thickness*2,resolution);
      }
      translate([psu_non_plug_side_gap_to_psu-non_plug_wall_thickness,psu_pos_z+psu_height/2+non_plug_wall_thickness,0]) {
        accurate_circle(non_plug_wall_thickness*2,resolution);
      }
    }
    */
  }

  module cuts() {
  }

  difference() {
    frame();
    cuts();
  }
}

module y_axis_strain_relief() {
  wire_cavity_diam = 7;
  zip_tie_width = 4;
  zip_tie_thickness = 3;
  zip_tie_clearance = psu_extrude_width*4*2;
  zip_tie_id = wire_cavity_diam+zip_tie_clearance;
  zip_tie_od = zip_tie_id+zip_tie_thickness*2;
  translate([-side_connector_length/2-40,0,10]) {
    rotate([0,0,-15]) {
      translate([-wire_cavity_diam*0.25,plate_thickness*0.85-zip_tie_width/2,0]) {
        rotate([90,0,0]) {
          hole(wire_cavity_diam,plate_thickness*3,resolution);

          difference() {
            hole(zip_tie_od,zip_tie_width,resolution);
            hole(zip_tie_id,zip_tie_width+1,resolution);
          }
        }
      }
    }
  }
}

module psu_mount_non_plug_side() {
  rounded_diam = non_plug_wall_thickness*2;
  inner_rounded_diam = 1;
  outer_rounded_diam = inner_rounded_diam+2*rounded_diam;
  tab_depth = non_plug_wall_thickness*2+v_slot_cavity_depth-1;
  overall_height = psu_height + non_plug_wall_thickness*4;

  translate([0,0,0]) {
    // % v_slot_profile();
  }

  module v_slot_profile() {
    module frame() {
      translate([0,overall_height/2]) {
        translate([non_plug_wall_thickness,0,0]) {
          rounded_square(non_plug_wall_thickness*2,overall_height,rounded_diam);
        }
        for(z=[top,bottom]) {
          translate([psu_cap_length/2+non_plug_wall_thickness,z*(overall_height/2-non_plug_wall_thickness)]) {
            rounded_square(psu_cap_length+non_plug_wall_thickness*2,non_plug_wall_thickness*2,rounded_diam);
          }
            /*
            mirror([0,z-1,0]) {
              translate([0,overall_height/2,0]) {
                rotate([0,0,-90]) {
                  round_corner_filler_profile(outer_rounded_diam,resolution);
                }
              }
            }
            */
          mirror([0,z-1,0]) {
            translate([non_plug_wall_thickness*2,overall_height/2-non_plug_wall_thickness*2,0]) {
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
      translate([non_plug_wall_thickness*2-tab_depth/2,40/2+z*(20/2)+s*((v_slot_opening-0.5)/2-non_plug_wall_thickness)]) {
        rounded_square(tab_depth,non_plug_wall_thickness*2,rounded_diam);
      }
    }
  }

  module plate_profile() {
    module body() {
      hull() {
        translate([0,overall_height/2,0]) {
          rounded_square(2*(psu_non_plug_side_gap_to_psu+psu_cap_length),overall_height,rounded_diam);
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
      translate([0,non_plug_wall_thickness*2+psu_height/2,0]) {
        cable_hole_cut_width = psu_non_plug_side_gap_to_psu-non_plug_wall_thickness*2;
        space_between = psu_extrude_width*6;
        spacing = space_between/2+cable_hole_cut_height/2;
        for(y=[front,rear]) {
          mirror([0,y-1,0]) {
            translate([non_plug_wall_thickness*2+cable_hole_cut_width/2,spacing,0]) {
              rounded_square(cable_hole_cut_width,cable_hole_cut_height,non_plug_wall_thickness*2);
            }
          }
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
          linear_extrude(height=psu_support_depth,convexity=5,center=true) {
            //v_slot_profile();
            psu_mount_non_plug_side_frame_profile();
          }
        }
      }
      translate([0,plate_thickness/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=plate_thickness,convexity=5,center=true) {
            plate_profile();
          }
        }
      }
    }
  }

  module holes() {
    if (!psu_mirror_x) {
      y_axis_strain_relief();
    }
  }

  difference() {
    body();
    holes();
  }
}

module psu_mount_corner_support() {
  rounded_diam = non_plug_wall_thickness*2;
  tab_depth = non_plug_wall_thickness*2+v_slot_cavity_depth-1;
  overall_height = psu_height + non_plug_wall_thickness*4;
  corner_space = side_rail_length_rear-psu_width-spacer*2;
  cover_width = psu_cap_length+psu_non_plug_side_gap_to_psu;

  screw_head_hole_diam = m3_bolt_head_diam+2;
  screw_area_od = screw_head_hole_diam+psu_extrude_width*4;

  screw_pos_x = max(cover_width/2,screw_area_od/2);
  screw_pos_z = 20/2;

  module cap_profile() {
    hull() {
      translate([cover_width/2,overall_height/2]) {
        rounded_square(cover_width,overall_height,rounded_diam);
      }
      translate([screw_pos_x,screw_pos_z,0]) {
        accurate_circle(screw_head_hole_diam+psu_extrude_width*8,resolution);
      }
    }

    for(z=[top,bottom]) {
      translate([non_plug_wall_thickness*2-tab_depth/2,40/2+z*(20/2)]) {
        rounded_square(tab_depth,tab_width,tab_width);
      }
    }
  }

  module body() {
    translate([-side_connector_length/2,-side_rail_length_rear,0]) {
      translate([0,corner_space/2+psu_support_depth/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=psu_support_depth+corner_space,convexity=5,center=true) {
            psu_mount_non_plug_side_frame_profile();
          }
        }
      }
      translate([0,corner_space/2,0]) {
        rotate([90,0,0]) {
          linear_extrude(height=corner_space,convexity=5,center=true) {
            cap_profile();
          }
        }
      }
    }
  }

  module holes() {
    screw_mount_thickness = 3;
    translate([-side_connector_length/2,-side_rail_length_rear,0]) {
      translate([screw_pos_x,0,screw_pos_z]) {
        rotate([-90,0,0]) {
          hole(3.2,200,16);

          translate([0,0,50+screw_mount_thickness]) {
            hole(screw_head_hole_diam,100,16);
          }
        }
      }

      translate([cover_width,corner_space,non_plug_wall_thickness*2+psu_height/2]) {
        cut_width = cover_width-non_plug_wall_thickness*2;
        cut_depth = corner_space-screw_mount_thickness-1;
        rounded_diam = (psu_height/2-cable_hole_cut_height)/2;
        //rounded_diam = non_plug_wall_thickness*2;
        for(z=[top,bottom]) {
          translate([0,0,z*(psu_height/4+cable_hole_cut_height/2)/2]) {
            rotate([90,0,0]) {
              rounded_cube(cut_width*2,cable_hole_cut_height,cut_depth*2,rounded_diam,resolution);
              for(y=[front,rear]) {
                mirror([0,y-1,0]) {
                  translate([0,cable_hole_cut_height/2,0]) {
                    rotate([0,0,90]) {
                      round_corner_filler(rounded_diam,cut_depth*2);
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

  difference() {
    body();
    holes();
  }
}

module psu_mount_plug_side() {
  overall_height = psu_height + non_plug_wall_thickness*4+spacer;
  rounded_diam = non_plug_wall_thickness*2;
  outer_rounded_diam = rounded_diam*2;
  tab_depth = non_plug_wall_thickness*2+v_slot_cavity_depth-1;

  dist_to_psu = side_connector_length/2-psu_pos_x-psu_length/2;

  slot_depth = side_rail_length_rear-0.5;

  between_psu_and_connector = slot_depth-psu_width-spacer;
  plug_body_height = iec_flange_h(IEC_320_C14_switched_fused_inlet);
  plug_body_width = plug_body_hole_width+non_plug_wall_thickness*4;

  plug_pos_x = side_connector_length/2-plug_body_hole_width/2-non_plug_wall_thickness*2;
  plug_pos_z = plug_body_height/2;

  plug_flat_length = iec_depth(IEC_320_C14_switched_fused_inlet)+40-plate_thickness;
  flat_pos_y = front*(plug_flat_length+plug_body_height-overall_height+15);

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
        translate([-non_plug_wall_thickness*2+tab_depth/2+0.1,z*(20/2)]) {
          mirror([0,s-1,0]) {
            translate([0,((v_slot_opening-0.2)/2-non_plug_wall_thickness)]) {
              rounded_square(tab_depth-0.2,non_plug_wall_thickness*2,rounded_diam);

              % translate([0,0,0]) {
                //debug_axes(0.5);
              }
            }
          }
        }
        /*
        translate([-non_plug_wall_thickness*2+tab_depth/2,z*(20/2)+s*((v_slot_opening-0.5)/2-non_plug_wall_thickness)]) {
          rounded_square(tab_depth,non_plug_wall_thickness*2,rounded_diam);
        }
        */
      }
    }
    // bottom
    translate([-dist_to_psu/2,non_plug_wall_thickness]) {
      rounded_square(dist_to_psu,non_plug_wall_thickness*2,rounded_diam);
    }

    translate([0,overall_height/2]) {
      translate([-non_plug_wall_thickness,0,0]) {
        // v slot-side face plate
        rounded_square(non_plug_wall_thickness*2,overall_height,rounded_diam);
      }

      translate([-dist_to_psu,bottom*(overall_height/2-non_plug_wall_thickness*2)]) {
        psu_retainer_height = (plug_body_height-plug_body_hole_height)/2;
        translate([non_plug_wall_thickness,-non_plug_wall_thickness*2+psu_retainer_height/2,0]) {
          rounded_square(non_plug_wall_thickness*2,psu_retainer_height,rounded_diam);
        }

        translate([-psu_terminal_cover_length/2+2,bottom*non_plug_wall_thickness]) {
          rounded_square(psu_terminal_cover_length+4,non_plug_wall_thickness*2,rounded_diam);
        }
      }
    }
  }

  module body() {
    translate([side_connector_length/2,-slot_depth/2+1,0]) {
      rotate([90,0,0]) {
        linear_extrude(height=slot_depth+2.1,convexity=5,center=true) {
          profile();
        }
      }
    }

    // psu retainers
    for(y=[front]) {
      translate([side_connector_length/2-dist_to_psu+non_plug_wall_thickness,psu_pos_y+y*psu_width/2,psu_pos_z]) {
        cube([non_plug_wall_thickness*2,5,overall_height-0.5],center=true);
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

    // plug plate
    hull() {
      translate([side_connector_length/2,0,0]) {
        translate([-dist_to_psu-psu_terminal_cover_length/2,plate_thickness/2,non_plug_wall_thickness]) {
          rotate([90,0,0]) {
            rounded_cube(psu_terminal_cover_length,non_plug_wall_thickness*2,plate_thickness,non_plug_wall_thickness*2,resolution);
          }
        }
      }
      position_plug() {
        translate([0,0,-plate_thickness/2]) {
          translate([0,0,-plate_thickness/2+0.1]) {
            rounded_cube(plug_body_width,plug_body_height,0.2,rounded_diam,resolution);
          }
          translate([0,0,plate_thickness/2-0.1]) {
            rounded_cube(iec_flange_w(IEC_320_C14_switched_fused_inlet),plug_body_height,0.2,iec_flange_r(IEC_320_C14_switched_fused_inlet)*2,resolution);
          }
          iec_screw_positions(IEC_320_C14_switched_fused_inlet) {
            hole(iec_flange_r(IEC_320_C14_switched_fused_inlet)*2,plate_thickness,resolution);
          }
        }
      }
      position_screw_hole() {
        hole(psu_screw_hole_diam+non_plug_wall_thickness*8,plate_thickness,resolution);
      }
    }

    // end cap opposite plug
    translate([side_connector_length/2-dist_to_psu/2-psu_terminal_cover_length/2,-side_rail_length_rear+between_psu_and_connector/2+0.5,overall_height/2]) {
      rotate([90,0,0]) {
        rounded_cube(dist_to_psu+psu_terminal_cover_length-0.01,overall_height-0.01,between_psu_and_connector+0.1,rounded_diam);
      }
    }

    translate([side_connector_length/2,0,0]) {
      // flat area
      hull() {
        width = dist_to_psu+psu_terminal_cover_length;
        translate([-width/2,0,overall_height-non_plug_wall_thickness]) {
          translate([0,flat_pos_y,0]) {
            rotate([90,0,0]) {
              rounded_cube(width,non_plug_wall_thickness*2,0.02,non_plug_wall_thickness*2);
            }
          }
          translate([0,-slot_depth+between_psu_and_connector,0]) {
            rotate([90,0,0]) {
              rounded_cube(width,non_plug_wall_thickness*2,0.02,non_plug_wall_thickness*2);
            }
          }
        }
      }
      // extrusion-side wall
      hull() {
        translate([-non_plug_wall_thickness,flat_pos_y,overall_height/2]) {
          rotate([90,0,0]) {
            rounded_cube(non_plug_wall_thickness*2,overall_height,0.02,non_plug_wall_thickness*2);
          }
        }
        translate([-non_plug_wall_thickness,-plug_flat_length/2,plug_body_height/2]) {
          rotate([90,0,0]) {
            rounded_cube(non_plug_wall_thickness*2,plug_body_height,plug_flat_length,non_plug_wall_thickness*2);
          }
        }
      }
      // top
      translate([-plug_body_width/2,-plug_flat_length/2,plug_body_height-non_plug_wall_thickness]) {
        rotate([90,0,0]) {
          rounded_cube(plug_body_width,non_plug_wall_thickness*2,plug_flat_length,non_plug_wall_thickness*2);
        }
      }
      hull() {
        translate([-dist_to_psu/2-psu_terminal_cover_length/2,flat_pos_y,overall_height-non_plug_wall_thickness]) {
          rotate([90,0,0]) {
            rounded_cube(dist_to_psu+psu_terminal_cover_length,non_plug_wall_thickness*2,0.02,non_plug_wall_thickness*2);
          }
        }
        translate([-plug_body_width/2,-plug_flat_length,plug_body_height-non_plug_wall_thickness]) {
          rotate([90,0,0]) {
            rounded_cube(plug_body_width,non_plug_wall_thickness*2,0.02,non_plug_wall_thickness*2);
          }
        }
      }
      // angle over psu
      hull() {
        translate([-dist_to_psu-psu_terminal_cover_length+non_plug_wall_thickness,flat_pos_y,overall_height-non_plug_wall_thickness]) {
          rotate([90,0,0]) {
            hole(non_plug_wall_thickness*2,0.02,resolution);
          }
        }
        translate([-plug_body_width+non_plug_wall_thickness,-plug_flat_length/2,plug_body_height-non_plug_wall_thickness]) {
          rotate([90,0,0]) {
            hole(non_plug_wall_thickness*2,plug_flat_length,resolution);
          }
        }
        translate([-dist_to_psu-psu_terminal_cover_length+non_plug_wall_thickness,-plug_flat_length/2,overall_height-non_plug_wall_thickness]) {
          rotate([90,0,0]) {
            hole(non_plug_wall_thickness*2,plug_flat_length,resolution);
          }
        }
      }
    }

    // slot fillers
    for(z=[10,30]) {
      translate([side_connector_length/2+tab_depth-dist_to_psu/2-psu_terminal_cover_length/2-tab_depth/2-non_plug_wall_thickness,-slot_depth-tab_depth/2+0.01,z]) {
        rotate([90,0,0]) {
          rounded_cube(dist_to_psu+tab_depth+psu_terminal_cover_length-non_plug_wall_thickness*2,v_slot_opening-0.2,tab_depth,rounded_diam);
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

      // 24v PSU supply hole
      if (psu_mirror_x) {
        access_hole_width = 12;
        access_hole_height = 5;
        translate([-40/2,-plug_flat_length+access_hole_width/2,-40/2+plug_body_height-access_hole_height]) {
          rotate([0,90,0]) {
            rounded_cube(access_hole_height,access_hole_width,20,non_plug_wall_thickness,8);
          }
        }
      }
    }

    position_plug() {
      translate([0,0,-plate_thickness/2]) {
        rounded_cube(plug_body_hole_width,plug_body_hole_height,plate_thickness+1,rounded_diam,resolution);
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
    hole_pos_x = [dist_to_psu*0.35,dist_to_psu-non_plug_wall_thickness*2-cable_hole_width/2];
    // tall cable hole
    translate([side_connector_length/2-hole_pos_x[1],-slot_depth+between_psu_and_connector,overall_height/2]) {
      hole_height = overall_height-non_plug_wall_thickness*6;
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
          //cube([cable_hole_width,30,cable_hole_width],center=true);
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

    if (psu_mirror_x) {
      mirror([1,0,0]) {
        y_axis_strain_relief();
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

if (debug) {
  //psu_mount_non_plug_side_frame_profile();
  //psu_mount_non_plug_side();
  //psu_mount_corner_support();
  //psu_mount_plug_side();
  psu_assembly();
}
/*
*/
