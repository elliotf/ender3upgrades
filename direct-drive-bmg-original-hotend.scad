include <../plotter/lib/util.scad>;
include <../plotter/lib/vitamins.scad>;

nema17_side = 42;
extrude_width = 0.5;
extrude_height = 0.2;
spacer = 0.2;

left = -1;
right = 1;
top = 1;
bottom = -1;
front = -1;
rear = 1;

resolution = 64;

heatsink_thickness = 12;
heatsink_standoff_height = 3;

wall_thickness = extrude_width*3;

mount_thickness = extrude_width*3*2;
echo("mount_thickness: ", mount_thickness);

carriage_material_thickness = 2.5;
carriage_rounded_diam = (32-23.5)*2;
carriage_width = 64;
carriage_height = 47.5;
carriage_wheel_spacing = 40;
carriage_wheel_pos_z = -11.9;
carriage_wheel_screw_diam = 5+0.4;
carriage_wheel_screw_head_diam = m5_fsc_head_diam+0.5;
carriage_spacer_diam = 8;

crush_ring_height = 0.1;
crush_ring_count = 8;

heatsink_cover_width = 24*2;
heatsink_cover_height = 22.85*2;
heatsink_cover_depth = 42;
heatsink_cover_positions = [
  [-1.5,-14.35], // top
  [-19,-33.25], // left
];
heatsink_cover_screw_area_diam = 16;
heatsink_cover_pos_x = heatsink_cover_positions[0][0] + 10.5;
heatsink_cover_pos_z = heatsink_cover_positions[0][1] - 27.25;
heatsink_cover_screw_diam = m4_diam+0.4;
heatsink_cover_screw_head_diam = m4_fsc_head_diam+0.4;
heatsink_cover_material_thickness = 1;

bmg_depth = 42;
bmg_width = 33;
bmg_main_height = 54;
bmg_top_depth = 30;
bmg_filament_y_from_motor_shaft = 4.2;
bmg_filament_from_lever_side = 16;
bmg_filament_from_motor = 23;

space_below_motor = extrude_width*4;

//filament_pos_x = (23.5-9.5)/2 + 9.5;
filament_pos_x = carriage_wheel_spacing/2-3.5;
filament_pos_y = front*(8.5+4/2);
//filament_pos_y = front*(heatsink_standoff_height+heatsink_thickness/2);
echo("filament_pos_y: ", filament_pos_y);

bmg_pos_x = filament_pos_x-bmg_filament_from_motor;
bmg_pos_y = filament_pos_y-bmg_filament_y_from_motor_shaft;
bmg_pos_z = spacer+space_below_motor+spacer+nema17_side/2;

motor_pos_x = bmg_pos_x-mount_thickness;
motor_pos_y = bmg_pos_y;
motor_pos_z = bmg_pos_z;

carriage_spacer_hole_diam = carriage_spacer_diam;
wheel_frame_rounded_diam = carriage_spacer_hole_diam+crush_ring_height*2+wall_thickness*2*2;
wheel_frame_depth = 7.5;
overall_width = carriage_wheel_spacing+wheel_frame_rounded_diam;

echo("wheel_frame_rounded_diam: ", wheel_frame_rounded_diam);

module crush_ring_hole_profile(diam,crush_ring_height=0.2,count=6) {
  outer_diam = diam + crush_ring_height*2;
  difference() {
    accurate_circle(outer_diam,resolution);
    deg = 360/count;
    for(r=[0:count-1]) {
      rotate([0,0,r*deg]) {
        translate([0,outer_diam/2,0]) {
          scale([5,1,1]) {
            rotate([0,0,90]) {
              accurate_circle(crush_ring_height*2,6);
            }
          }
        }
      }
    }
  }
}

module bmg_mount() {
  zip_tie_mount_width = 10;
  zip_tie_mount_inner = 10;
  zip_tie_mount_pos_x = overall_width/2+zip_tie_mount_width/2+2;
  //zip_tie_bottom_pos_z=spacer+space_below_motor-zip_tie_mount_width/2;
  zip_tie_bottom_pos_z = 0;
  zip_tie_mount_length = 40;

  module position_motor() {
    translate([motor_pos_x,motor_pos_y,motor_pos_z]) {
      rotate([0,0,90]) {
        rotate([90,0,0]) {
          children();
        }
      }
    }
  }

  position_motor() {
    % color("#555", 0.8) motor_nema17(23);

    translate([0,0,mount_thickness]) {
      % simplified_bmg();
    }
  }

  module motor_cavity(length) {
    intersection() {
      cube([nema17_side+spacer*2,nema17_side+spacer*2,length],center=true);
      hole(57,length+1,resolution*2);
    }
  }

  module carriage_wheel_mount_profile() {

    module position_wheels() {
      for(x=[left,right]) {
        translate([x*(carriage_wheel_spacing/2),carriage_wheel_pos_z,0]) {
          rotate([0,0,0]) {
            children();
          }
        }
      }
    }

    module body() {
      hull() {
        position_wheels() {
          accurate_circle(wheel_frame_rounded_diam,resolution);
        }

        translate([0,spacer+space_below_motor/2,0]) {
          rounded_square(overall_width,space_below_motor,space_below_motor);
        }
        translate([zip_tie_mount_pos_x,zip_tie_bottom_pos_z]) {
          accurate_circle(zip_tie_mount_width,resolution);
        }
      }

      translate([zip_tie_mount_pos_x,zip_tie_bottom_pos_z-zip_tie_mount_width/2+zip_tie_mount_length/2,0]) {
        rounded_square(zip_tie_mount_width,zip_tie_mount_length,zip_tie_mount_width);
      }

      translate([zip_tie_mount_pos_x-zip_tie_mount_width/2,space_below_motor+spacer,0]) {
        rotate([0,0,90]) {
          // # round_corner_filler_profile(4,resolution);
        }
      }

      hull() {
        translate([0,spacer+space_below_motor/2,0]) {
          rounded_square(overall_width-space_below_motor,space_below_motor,space_below_motor);
        }
        translate([bmg_pos_x-mount_thickness/2,motor_pos_z+nema17_side/2-1]) {
          square([mount_thickness,2],center=true);
        }
      }
    }

    module holes() {
      position_wheels() {
        difference() {
          crush_ring_hole_profile(carriage_spacer_hole_diam,crush_ring_height,crush_ring_count);
          // accurate_circle(carriage_spacer_diam,resolution);
        }
      }

      // heatsink screw backing room, because the threaded portion sticks out
      translate(heatsink_cover_positions[0]) {
        accurate_circle(5.5,resolution/4);
      }

      // make room for BMG lever
      hull() {
        rounded_diam = 4;
        translate([zip_tie_mount_pos_x-zip_tie_mount_width/2-rounded_diam/2,spacer+space_below_motor+rounded_diam/2]) {
          accurate_circle(rounded_diam,resolution);

          translate([0,20,0]) {
            square([rounded_diam,20],center=true);
          }
        }
        translate([bmg_pos_x+rounded_diam/2,motor_pos_z+nema17_hole_spacing/2+3/2,0]) {
          accurate_circle(rounded_diam,resolution);
        }
        large_rounded_diam = 20;
        translate([bmg_pos_x+large_rounded_diam/2+8,spacer+space_below_motor+large_rounded_diam/2+7,0]) {
          accurate_circle(large_rounded_diam,resolution*2);
        }
      }

      // make motor side prettier
      hull() {
        rounded_diam = 7;
        smaller_rounded_diam = space_below_motor;
        translate([-overall_width/2+space_below_motor/2+0.2,spacer+space_below_motor+smaller_rounded_diam/2]) {
          accurate_circle(smaller_rounded_diam,resolution);
        }
        translate([motor_pos_x-rounded_diam/2,motor_pos_z+nema17_hole_spacing/2+3/2,0]) {
          accurate_circle(rounded_diam,resolution);
        }
      }
    }

    difference() {
      body();
      holes();
    }
  }

  module body() {
    translate([0,carriage_material_thickness+wheel_frame_depth/2,0]) {
      rotate([90,0,0]) {
        linear_extrude(center=true,convexity=3,height=wheel_frame_depth) {
          carriage_wheel_mount_profile();
        }
      }
    }

    translate([motor_pos_x+mount_thickness/2,motor_pos_y,motor_pos_z-space_below_motor/2]) {
      cube([mount_thickness,nema17_side,nema17_side+space_below_motor],center=true);
    }

    // lateral webbing
    hull() {
      translate([0,0,spacer+space_below_motor/2]) {
        // leave room for the filament/bowden coupler
        webbing_width = overall_width/2+filament_pos_x-12/2;
        translate([-overall_width/2+webbing_width/2,carriage_material_thickness+1,0]) {
          rotate([90,0,0]) {
            rounded_cube(webbing_width,space_below_motor,2,space_below_motor,resolution);
          }
        }
        translate([motor_pos_x+mount_thickness/2,motor_pos_y-nema17_hole_spacing/2,0]) {
          rotate([90,0,0]) {
            rounded_cube(mount_thickness,space_below_motor,2,space_below_motor,resolution);
          }
        }
      }
    }

    zip_tie_mount_above_carriage = zip_tie_mount_length-abs(zip_tie_bottom_pos_z)-zip_tie_mount_width/2;
    zip_tie_mount_top = zip_tie_bottom_pos_z-zip_tie_mount_width/2+zip_tie_mount_length;
    zip_tie_anchor_length = zip_tie_mount_top-(motor_pos_z-nema17_hole_spacing/2)+2;
    translate([zip_tie_mount_pos_x,-10,zip_tie_mount_top-zip_tie_anchor_length/2]) {
      rotate([90,0,0]) {
        rounded_cube(zip_tie_mount_width,zip_tie_anchor_length,26,zip_tie_mount_width);
      }
    }
    /*
    translate([zip_tie_mount_pos_x,0,zip_tie_mount_above_carriage/2]) {
      rotate([90,0,0]) {
        rounded_cube(zip_tie_mount_width,zip_tie_mount_above_carriage,10,zip_tie_mount_width);

      }
    }
    */
  }

  module holes() {
    position_motor() {
      for(x=[left,right],y=[front,rear]) {
        translate([x*(nema17_hole_spacing/2),y*(nema17_hole_spacing/2),0]) {
          hole(3.2,mount_thickness*2+1,16);
        }
      }

      hull() {
        hole(nema17_shoulder_diam+1,mount_thickness*2+1,resolution);

        rotate([0,0,90]) {
          translate([0,nema17_shoulder_diam/2,0]) {
            cube([nema17_shoulder_diam/2,2,mount_thickness*2+1],center=true);
          }
        }
      }

      for(z=[top,bottom]) {
        cavity_length = 33;
        translate([0,0,mount_thickness/2+z*(mount_thickness/2+cavity_length/2)]) {
          motor_cavity(cavity_length);

          translate([nema17_hole_spacing/2,-nema17_hole_spacing/2,z*cavity_length/2]) {
            hole(7,cavity_length,resolution);
            rotate([0,0,90]) {
              translate([0,20,0]) {
                cube([7,40,cavity_length],center=true);
              }
            }
          }
        }
      }
    }

    // trim corners
    translate([0,motor_pos_y,motor_pos_z]) {
      motor_diam = 54;

      for(r=[-45,45,135]) {
        rotate([r,0,0]) {
          translate([0,0,motor_diam/2+20]) {
            cube([100,80,40],center=true);
          }
        }
      }
    }

    // zip tie whatnots
    translate([zip_tie_mount_pos_x,-3,motor_pos_z-nema17_hole_spacing/2]) {
      angle = 10;
      rotate([angle,0,0]) {
        translate([0,-12,zip_tie_mount_length/2]) {
          cube([zip_tie_mount_width+1,20,zip_tie_mount_length+1],center=true);
        }
        translate([0,-2,zip_tie_mount_length/2]) {
          translate([0,0,-6]) {
            rotate([-angle,0,0]) {
              for(z=[top,bottom]) {
                translate([0,0,z*4]) {
                  //% debug_axes();
                  inner_diam = zip_tie_mount_width+2;
                  outer_diam = inner_diam+4;
                  zip_tie_width = 3;
                  difference() {
                    hole(outer_diam,zip_tie_width,resolution);
                    hole(inner_diam,zip_tie_width+1,resolution);
                  }
                }
              }
            }
          }
          resize([zip_tie_mount_width-extrude_width*4,7,zip_tie_mount_length]) {
            hole(7,1,resolution);
          }
          rotate([-angle,0,0]) {
            translate([0,-10,0]) {
              // # cube([zip_tie_mount_width+1,20,zip_tie_mount_length+1],center=true);
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

module simplified_bmg() {
  color("#555", 0.7) {
    translate([7.2585,9.0551,0]) {
      import("/home/efoster/work/reprap/ender3upgrades/bmg-extruder.stl", convexity=5);
    }
  }
  /*
  rounded_diam = 10;

  color("#555", 0.7) translate([0,0,bmg_width/2]) {
    linear_extrude(center=true,convexity=3,height=bmg_width) {
      hull() {
        rounded_square(bmg_depth,bmg_depth,rounded_diam,8);

        translate([bmg_depth/2-bmg_top_depth/2,-bmg_depth/2+bmg_main_height-rounded_diam,0]) {
          rounded_square(bmg_top_depth,rounded_diam,rounded_diam,8);
        }
      }
    }
  }

  translate([bmg_depth/2-bmg_filament_from_lever_side,0,bmg_filament_from_motor]) {
    rotate([90,0,0]) {
      // % color("blue", 0.2) hole(4,200,resolution);
    }
  }
  */
}

module x_carriage() {
  module profile() {
    module body() {
      hull() {
        translate([0,carriage_wheel_pos_z,0]) {
          rounded_square(carriage_width,abs(carriage_wheel_pos_z)*2,carriage_rounded_diam);
        }
        translate([0,-carriage_height+1,0]) {
          square([carriage_width,2],center=true);
        }
      }
    }

    module holes() {
      for(x=[left,right]) {
        translate([x*carriage_wheel_spacing/2,carriage_wheel_pos_z,0]) {
          accurate_circle(carriage_wheel_screw_diam,resolution);
        }
      }

      for(coord=heatsink_cover_positions) {
        translate(coord) {
          accurate_circle(heatsink_cover_screw_diam,resolution);
        }
      }
    }

    difference() {
      body();
      holes();
    }
  }

  color("#555", 0.5) {
    translate([0,carriage_material_thickness/2,0]) {
      rotate([90,0,0]) {
        linear_extrude(convexity=3,height=carriage_material_thickness,center=true) {
          profile();
        }
      }
    }

    translate([heatsink_cover_pos_x,front*heatsink_cover_depth/2,heatsink_cover_pos_z]) {
      cube([heatsink_cover_width,heatsink_cover_depth,heatsink_cover_height],center=true);
    }
  }

  translate([filament_pos_x,filament_pos_y,0]) {
    % color("orange", 0.3) hole(4,200,resolution);
  }
}

bmg_mount();
% x_carriage();

module direct_drive_assembly() {
  translate([0,front*(20-4),-carriage_wheel_pos_z+20]) {
    bmg_mount();
    % x_carriage();
  }
}

/*
% debug_axes(0.005);
translate([7.2585,9.0551,0]) {
  % debug_axes(0.005);
  simplified_bmg();
}
*/
